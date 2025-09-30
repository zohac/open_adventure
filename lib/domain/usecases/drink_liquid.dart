import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contract for handling drink interactions (water from the bottle in S3).
abstract class DrinkLiquid {
  /// Attempts to drink the content associated with [objectId] within [game].
  Future<TurnResult> call(String? objectId, Game game);
}

/// Domain implementation that currently supports drinking water from the bottle.
class DrinkLiquidImpl implements DrinkLiquid {
  /// Builds a [DrinkLiquidImpl] wired to the adventure repository.
  const DrinkLiquidImpl({required AdventureRepository adventureRepository})
      : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

  @override
  Future<TurnResult> call(String? objectId, Game game) async {
    final int targetId = _parseObjectId(objectId);
    final GameObject object = await _loadObject(targetId);
    final GameObjectState? state = game.objectStates[targetId];
    if (state == null) {
      throw StateError('No state tracked for object id $targetId');
    }

    if (object.name != 'BOTTLE') {
      throw StateError('DrinkLiquid only supports the bottle in S3');
    }

    final bool isAccessible = state.isCarried || state.isAt(game.loc);
    if (!isAccessible) {
      return TurnResult(
        game,
        <String>[_message('notHere', object.name)],
      );
    }

    final List<String>? definedStates = object.states;
    if (definedStates == null || definedStates.isEmpty) {
      throw StateError('Bottle must define states to toggle');
    }

    final int waterIndex = _indexWhere(
      definedStates,
      (value) => value.contains('WATER'),
    );
    final int emptyIndex = _indexWhere(
      definedStates,
      (value) => value.contains('EMPTY'),
    );
    if (waterIndex == -1 || emptyIndex == -1) {
      throw StateError('Bottle must define water and empty states');
    }

    final bool hasWater = state.state == definedStates[waterIndex] ||
        state.prop == waterIndex;
    if (!hasWater) {
      return TurnResult(
        game,
        <String>[_message('empty', object.name)],
      );
    }

    final GameObjectState updatedState = state.copyWith(
      state: definedStates[emptyIndex],
      prop: emptyIndex,
    );

    final Map<int, GameObjectState> updatedStates =
        Map<int, GameObjectState>.from(game.objectStates)
          ..[targetId] = updatedState;

    final Game updatedGame = game.copyWith(
      objectStates: Map.unmodifiable(updatedStates),
    );

    return TurnResult(
      updatedGame,
      <String>[_message('success', object.name)],
    );
  }

  Future<GameObject> _loadObject(int objectId) async {
    final List<GameObject> objects = await _adventureRepository.getGameObjects();
    for (final GameObject object in objects) {
      if (object.id == objectId) {
        return object;
      }
    }
    throw StateError('Unknown object id $objectId');
  }

  int _parseObjectId(String? objectId) {
    if (objectId == null) {
      throw ArgumentError.notNull('objectId');
    }
    final int? parsed = int.tryParse(objectId);
    if (parsed == null) {
      throw ArgumentError.value(objectId, 'objectId', 'must be numeric');
    }
    return parsed;
  }

  int _indexWhere(List<String> values, bool Function(String) predicate) {
    for (var index = 0; index < values.length; index++) {
      if (predicate(values[index])) {
        return index;
      }
    }
    return -1;
  }

  String _message(String suffix, String objectKey) =>
      'journal.drink.$suffix.$objectKey';
}
