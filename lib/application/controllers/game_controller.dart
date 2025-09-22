import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/command.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

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
    required ListAvailableActionsTravel listAvailableActions,
    required ApplyTurnGoto applyTurn,
    required SaveRepository saveRepository,
  })  : _adventureRepository = adventureRepository,
        _listAvailableActions = listAvailableActions,
        _applyTurn = applyTurn,
        _saveRepository = saveRepository,
        super(GameViewState.initial());

  final AdventureRepository _adventureRepository;
  final ListAvailableActionsTravel _listAvailableActions;
  final ApplyTurnGoto _applyTurn;
  final SaveRepository _saveRepository;

  static const int _maxJournalEntries = 200;

  /// Initializes the controller by loading the initial game and computing
  /// the first batch of actions. Also triggers an autosave so "Continue"
  /// can resume immediately.
  Future<void> init() async {
    value = value.copyWith(isLoading: true);

    final Game initialGame = await _adventureRepository.initialGame();
    final Location location =
        await _adventureRepository.locationById(initialGame.loc);
    final List<ActionOption> actions = await _listAvailableActions(initialGame);
    final String description = _selectDescription(location, firstVisit: true);
    final List<String> journal =
        description.isEmpty ? const <String>[] : <String>[description];

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

    if (option.category == 'meta' && option.verb == 'OBSERVER') {
      final Location location =
          await _adventureRepository.locationById(currentGame.loc);
      final description = location.longDescription?.isNotEmpty == true
          ? location.longDescription!
          : location.shortDescription ?? '';
      final updatedJournal =
          _appendJournal(value.journal, [description].where((m) => m.isNotEmpty).toList());
      value = value.copyWith(
        locationDescription: description,
        journal: List.unmodifiable(updatedJournal),
        locationTitle: location.name,
        locationMapTag: location.mapTag,
        locationId: location.id,
      );
      return;
    }

    final Command command = Command(verb: option.verb, target: option.objectId);
    final TurnResult result = await _applyTurn(command, currentGame);
    final Game newGame = result.newGame;
    final Location location =
        await _adventureRepository.locationById(newGame.loc);
    final List<ActionOption> actions = await _listAvailableActions(newGame);

    final List<String> messages =
        result.messages.where((m) => m.isNotEmpty).toList();
    final String description = messages.isNotEmpty
        ? messages.last
        : _selectDescription(location, firstVisit: false);
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

    await _saveRepository.autosave(_toSnapshot(newGame));
  }

  /// Recomputes the available actions for the current game without changing
  /// other presentation data.
  Future<void> refreshActions() async {
    final Game? game = value.game;
    if (game == null) {
      return;
    }
    final List<ActionOption> actions = await _listAvailableActions(game);
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
}
