import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat d'interaction « Éteindre la lampe ».
abstract class ExtinguishLamp {
  /// Tente d'éteindre la lampe dans [game] et retourne le résultat du tour.
  Future<TurnResult> call(Game game);
}

/// Implémentation Domain de [ExtinguishLamp].
class ExtinguishLampImpl implements ExtinguishLamp {
  /// Crée un use case `ExtinguishLamp` dépendant du [AdventureRepository].
  const ExtinguishLampImpl({required AdventureRepository adventureRepository})
      : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

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

    final int darkIndex = _indexWhere(states, (value) => value.contains('DARK'));
    if (darkIndex == -1) {
      throw StateError('Lamp has no dark state defined');
    }

    final String darkStateValue = states[darkIndex];
    if (lampState.state == darkStateValue) {
      return TurnResult(game, const <String>['journal.lamp.extinguish.already']);
    }

    final GameObjectState updatedLamp = lampState.copyWith(
      state: darkStateValue,
      prop: darkIndex,
    );

    final Map<int, GameObjectState> updatedStates =
        Map<int, GameObjectState>.from(game.objectStates)
          ..[lamp.id] = updatedLamp;

    final Game updatedGame = game.copyWith(
      objectStates: Map.unmodifiable(updatedStates),
    );

    return TurnResult(
      updatedGame,
      const <String>['journal.lamp.extinguish.success'],
    );
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
