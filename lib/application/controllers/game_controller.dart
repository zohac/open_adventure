import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/inventory.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';
import 'package:open_adventure/domain/value_objects/magic_words.dart';
import 'package:open_adventure/domain/value_objects/dwarf_tick_result.dart';

/// Immutable projection of the game state consumed by the Presentation layer.
class GameViewState {
  /// Underlying domain state (null until `init()` succeeds).
  final Game? game;

  /// Title of the current location (falls back to an empty string).
  final String locationTitle;

  /// Map tag of the current location when available (used for image lookup).
  final String? locationMapTag;

  /// Identifier of the current location (used for image fallback and tests).
  final int? locationId;

  /// Description currently shown to the user.
  final String locationDescription;

  /// Actions available to the player (travel only in S2).
  final List<ActionOption> actions;

  /// Journal of system messages (most recent last).
  final List<String> journal;

  /// Loading flag toggled while `init()` is running.
  final bool isLoading;

  const GameViewState({
    required this.game,
    required this.locationTitle,
    required this.locationMapTag,
    required this.locationId,
    required this.locationDescription,
    required this.actions,
    required this.journal,
    required this.isLoading,
  });

  factory GameViewState.initial() => const GameViewState(
    game: null,
    locationTitle: '',
    locationMapTag: null,
    locationId: null,
    locationDescription: '',
    actions: <ActionOption>[],
    journal: <String>[],
    isLoading: true,
  );

  GameViewState copyWith({
    Game? game,
    String? locationTitle,
    String? locationMapTag,
    int? locationId,
    String? locationDescription,
    List<ActionOption>? actions,
    List<String>? journal,
    bool? isLoading,
  }) {
    return GameViewState(
      game: game ?? this.game,
      locationTitle: locationTitle ?? this.locationTitle,
      locationMapTag: locationMapTag ?? this.locationMapTag,
      locationId: locationId ?? this.locationId,
      locationDescription: locationDescription ?? this.locationDescription,
      actions: actions ?? this.actions,
      journal: journal ?? this.journal,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// S2 game orchestrator bridging domain use cases and persistence.
class GameController extends ValueNotifier<GameViewState> {
  GameController({
    required AdventureRepository adventureRepository,
    required ListAvailableActions listAvailableActions,
    required InventoryUseCase inventoryUseCase,
    required ApplyTurn applyTurn,
    required SaveRepository saveRepository,
    required DwarfSystem dwarfSystem,
  }) : _adventureRepository = adventureRepository,
       _listAvailableActions = listAvailableActions,
       _inventoryUseCase = inventoryUseCase,
       _applyTurn = applyTurn,
       _saveRepository = saveRepository,
       _dwarfSystem = dwarfSystem,
       super(GameViewState.initial());

  final AdventureRepository _adventureRepository;
  final ListAvailableActions _listAvailableActions;
  final InventoryUseCase _inventoryUseCase;
  final ApplyTurn _applyTurn;
  final SaveRepository _saveRepository;
  final DwarfSystem _dwarfSystem;
  Map<int, GameObject> _objectIndex = const <int, GameObject>{};

  static const int _maxJournalEntries = 200;
  static const int _lampWarningThreshold = 30;

  /// Initializes the controller by loading the initial game and computing
  /// the first batch of actions. Also triggers an autosave so "Continue"
  /// can resume immediately.
  Future<void> init() async {
    value = value.copyWith(isLoading: true);

    final List<GameObject> objects = await _adventureRepository
        .getGameObjects();
    _objectIndex = Map<int, GameObject>.unmodifiable(<int, GameObject>{
      for (final object in objects) object.id: object,
    });

    final Game initialGame = await _adventureRepository.initialGame();
    final Location location = await _adventureRepository.locationById(
      initialGame.loc,
    );
    final List<ActionOption> actions = _visibleActions(
      await _listAvailableActions(initialGame),
      initialGame,
    );
    final String description = _selectDescription(location, firstVisit: true);
    final List<String> journal = description.isEmpty
        ? const <String>[]
        : <String>[description];

    value = GameViewState(
      game: initialGame,
      locationTitle: location.name,
      locationMapTag: location.mapTag,
      locationId: location.id,
      locationDescription: description,
      actions: List.unmodifiable(actions),
      journal: List.unmodifiable(journal),
      isLoading: false,
    );

    await _saveRepository.autosave(_toSnapshot(initialGame));
  }

  /// Executes the chosen [option], updates the state and triggers autosave.
  Future<void> perform(ActionOption option) async {
    final Game? currentGame = value.game;
    if (currentGame == null) {
      throw StateError('Cannot perform action before init() succeeds.');
    }

    if (option.category == 'meta') {
      if (option.verb == 'OBSERVER') {
        final Location location = await _adventureRepository.locationById(
          currentGame.loc,
        );
        final description = location.longDescription?.isNotEmpty == true
            ? location.longDescription!
            : location.shortDescription ?? '';
        final updatedJournal = _appendJournal(
          value.journal,
          [description].where((m) => m.isNotEmpty).toList(),
        );
        value = value.copyWith(
          locationDescription: description,
          journal: List.unmodifiable(updatedJournal),
          locationTitle: location.name,
          locationMapTag: location.mapTag,
          locationId: location.id,
        );
        return;
      }

      if (option.verb == 'MAP') {
        // Navigation vers la carte gérée côté UI (onglet dédié S3).
        // Le contrôleur ne déclenche pas de tour ni de mutation domaine.
        return;
      }

      if (option.verb == 'INVENTORY') {
        final TurnResult inventoryResult = await _inventoryUseCase(currentGame);
        final List<String> messages = inventoryResult.messages
            .where((message) => message.isNotEmpty)
            .toList();
        if (messages.isEmpty) {
          value = value.copyWith(game: inventoryResult.newGame);
          return;
        }
        final List<String> updatedJournal = _appendJournal(
          value.journal,
          messages,
        );
        value = value.copyWith(
          game: inventoryResult.newGame,
          journal: List.unmodifiable(updatedJournal),
        );
        return;
      }
    }

    if (!currentGame.magicWordsUnlocked &&
        MagicWords.isIncantation(option.verb)) {
      return;
    }

    final TurnResult result = await _applyTurn(option, currentGame);
    Game newGame = result.newGame;
    final List<String> messages = result.messages
        .where((m) => m.isNotEmpty)
        .toList(growable: true);

    if (newGame != currentGame) {
      final DwarfTickResult dwarfTick = await _dwarfSystem.tick(newGame);
      newGame = dwarfTick.game;
      messages.addAll(
        dwarfTick.messages.where((message) => message.isNotEmpty),
      );

      final _LampTickOutcome lampOutcome = await _applyLampTimers(newGame);
      newGame = lampOutcome.game;
      messages.addAll(
        lampOutcome.messages.where((message) => message.isNotEmpty),
      );
    }

    final bool locationChanged = newGame.loc != currentGame.loc;
    final Location location = await _adventureRepository.locationById(
      newGame.loc,
    );
    final List<ActionOption> actions = _visibleActions(
      await _listAvailableActions(newGame),
      newGame,
    );
    final String description = locationChanged
        ? (messages.isNotEmpty
              ? messages.join('\n')
              : _selectDescription(location, firstVisit: false))
        : value.locationDescription;
    final List<String> updatedJournal = _appendJournal(value.journal, messages);

    value = value.copyWith(
      game: newGame,
      locationTitle: location.name,
      locationMapTag: location.mapTag,
      locationId: location.id,
      locationDescription: description,
      actions: List.unmodifiable(actions),
      journal: List.unmodifiable(updatedJournal),
      isLoading: false,
    );

    if (newGame != currentGame) {
      await _saveRepository.autosave(_toSnapshot(newGame));
    }
  }

  /// Recomputes the available actions for the current game without changing
  /// other presentation data.
  Future<void> refreshActions() async {
    final Game? game = value.game;
    if (game == null) {
      return;
    }
    final List<ActionOption> actions = _visibleActions(
      await _listAvailableActions(game),
      game,
    );
    value = value.copyWith(actions: List.unmodifiable(actions));
  }

  GameSnapshot _toSnapshot(Game game) =>
      GameSnapshot(loc: game.loc, turns: game.turns, rngSeed: game.rngSeed);

  List<String> _appendJournal(List<String> journal, List<String> messages) {
    if (messages.isEmpty) return journal;
    final List<String> combined = <String>[...journal, ...messages];
    if (combined.length <= _maxJournalEntries) {
      return combined;
    }
    return combined.sublist(combined.length - _maxJournalEntries);
  }

  Future<_LampTickOutcome> _applyLampTimers(Game game) async {
    final MapEntry<int, GameObjectState>? lampEntry = game.objectStates.entries
        .firstWhereOrNull((entry) {
          final Object? state = entry.value.state;
          return state == 'LAMP_BRIGHT' || state == 'LAMP_DARK';
        });
    if (lampEntry == null) {
      return _LampTickOutcome(game: game);
    }

    final GameObjectState lampState = lampEntry.value;
    if (lampState.state != 'LAMP_BRIGHT') {
      return _LampTickOutcome(game: game);
    }

    Game updatedGame = game;
    final List<String> messages = <String>[];
    var remaining = game.limit;

    if (remaining > 0) {
      remaining -= 1;
      updatedGame = updatedGame.copyWith(limit: remaining);
    }

    if (remaining > 0 &&
        remaining <= _lampWarningThreshold &&
        !updatedGame.lampWarningIssued) {
      updatedGame = updatedGame.copyWith(lampWarningIssued: true);
      messages.add(await _adventureRepository.arbitraryMessage('LAMP_DIM'));
    }

    if (remaining == 0) {
      final Map<int, GameObjectState> updatedStates =
          Map<int, GameObjectState>.from(updatedGame.objectStates)
            ..[lampEntry.key] = lampState.copyWith(state: 'LAMP_DARK', prop: 0);
      updatedGame = updatedGame.copyWith(
        objectStates: Map.unmodifiable(updatedStates),
        limit: -1,
        lampWarningIssued: true,
      );
      messages.add(await _adventureRepository.arbitraryMessage('LAMP_OUT'));
    }

    return _LampTickOutcome(game: updatedGame, messages: messages);
  }

  String _selectDescription(Location location, {required bool firstVisit}) {
    if (firstVisit) {
      if (location.longDescription != null &&
          location.longDescription!.isNotEmpty) {
        return location.longDescription!;
      }
      return location.shortDescription ?? '';
    }
    if (location.shortDescription != null &&
        location.shortDescription!.isNotEmpty) {
      return location.shortDescription!;
    }
    return location.longDescription ?? '';
  }

  List<ActionOption> _visibleActions(List<ActionOption> source, Game game) {
    if (game.magicWordsUnlocked) {
      return source;
    }
    return source
        .where((action) => !MagicWords.isIncantation(action.verb))
        .toList();
  }

  /// Returns the [GameObject] matching [id] when known.
  GameObject? objectById(int id) => _objectIndex[id];

  /// Overrides the internal object index for testing purposes.
  @visibleForTesting
  void debugSeedObjectIndex(Iterable<GameObject> objects) {
    _objectIndex = Map<int, GameObject>.unmodifiable(<int, GameObject>{
      for (final object in objects) object.id: object,
    });
  }
}

class _LampTickOutcome {
  _LampTickOutcome({
    required this.game,
    List<String> messages = const <String>[],
  }) : messages = List<String>.unmodifiable(messages);

  final Game game;
  final List<String> messages;
}
