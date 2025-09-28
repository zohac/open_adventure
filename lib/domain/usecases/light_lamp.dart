import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat d'interaction « Allumer la lampe ».
abstract class LightLamp {
  /// Tente d'allumer la lampe dans [game] et retourne le résultat du tour.
  Future<TurnResult> call(Game game);
}

/// Implémentation Domain de [LightLamp].
class LightLampImpl implements LightLamp {
  /// Crée un use case `LightLamp` dépendant du [AdventureRepository].
  const LightLampImpl({required AdventureRepository adventureRepository})
      : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

  static const int _lampWarningThreshold = 30;

  @override
  Future<TurnResult> call(Game game) async {
    final GameObject lamp = await _loadLamp();
    final GameObjectState? lampState = game.objectStates[lamp.id];
    if (lampState == null) {
      throw StateError('No state tracked for lamp id ${lamp.id}');
    }

    final bool isAccessible = lampState.isCarried || lampState.isAt(game.loc);
    if (!isAccessible) {
      return TurnResult(game, const <String>['journal.lamp.notHere']);
    }

    final List<String>? states = lamp.states;
    if (states == null || states.isEmpty) {
      throw StateError('Lamp must define states to toggle');
    }

    final int brightIndex = _indexWhere(states, (value) => value.contains('BRIGHT'));
    if (brightIndex == -1) {
      throw StateError('Lamp has no bright state defined');
    }

    final String brightStateValue = states[brightIndex];
    if (lampState.state == brightStateValue) {
      return TurnResult(game, const <String>['journal.lamp.already']);
    }

    if (game.limit <= 0) {
      return TurnResult(game, const <String>['journal.lamp.empty']);
    }

    final GameObjectState updatedLamp = lampState.copyWith(
      state: brightStateValue,
      prop: brightIndex,
    );

    final Map<int, GameObjectState> updatedStates =
        Map<int, GameObjectState>.from(game.objectStates)
          ..[lamp.id] = updatedLamp;

    final bool shouldWarn =
        game.limit <= _lampWarningThreshold && !game.lampWarningIssued;

    final Game updatedGame = game.copyWith(
      objectStates: Map.unmodifiable(updatedStates),
      lampWarningIssued: shouldWarn ? true : game.lampWarningIssued,
    );

    final List<String> messages = <String>['journal.lamp.success'];
    if (shouldWarn) {
      messages.add('journal.lamp.warning');
    }

    return TurnResult(updatedGame, messages);
  }

  Future<GameObject> _loadLamp() async {
    final List<GameObject> objects = await _adventureRepository.getGameObjects();
    for (final GameObject object in objects) {
      if (object.name == 'LAMP') {
        return object;
      }
    }
    throw StateError('Unable to resolve lamp object from repository');
  }

  int _indexWhere(List<String> values, bool Function(String) predicate) {
    for (var index = 0; index < values.length; index++) {
      if (predicate(values[index])) {
        return index;
      }
    }
    return -1;
  }
}
