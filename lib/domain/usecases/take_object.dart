import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat d'interaction « Prendre un objet ».
abstract class TakeObject {
  /// Applique la prise d'un objet identifié par [objectId] dans [game].
  Future<TurnResult> call(String objectId, Game game);
}

/// Implémentation Domain de [TakeObject].
class TakeObjectImpl implements TakeObject {
  /// Crée un use case `TakeObject` dépendant du [AdventureRepository].
  const TakeObjectImpl({required AdventureRepository adventureRepository})
      : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

  @override
  Future<TurnResult> call(String objectId, Game game) async {
    final int? parsedId = int.tryParse(objectId);
    if (parsedId == null) {
      throw ArgumentError.value(objectId, 'objectId', 'must be a numeric id');
    }

    final GameObject object = await _loadObject(parsedId);
    final GameObjectState? state = game.objectStates[parsedId];
    if (state == null) {
      throw StateError('No state tracked for object id $parsedId');
    }

    if (object.immovable) {
      return TurnResult(
        game,
        <String>[_messageKey('immovable', object.name)],
      );
    }

    if (state.isCarried) {
      return TurnResult(
        game,
        <String>[_messageKey('alreadyCarrying', object.name)],
      );
    }

    if (!state.isAt(game.loc)) {
      return TurnResult(
        game,
        <String>[_messageKey('notHere', object.name)],
      );
    }

    final GameObjectState updatedState = state.copyWith(
      isCarried: true,
      clearLocation: true,
    );

    final Map<int, GameObjectState> updatedStates =
        Map<int, GameObjectState>.from(game.objectStates)
          ..[parsedId] = updatedState;

    final Game newGame = game.copyWith(
      objectStates: Map.unmodifiable(updatedStates),
    );

    return TurnResult(
      newGame,
      <String>[_messageKey('success', object.name)],
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

  String _messageKey(String suffix, String objectKey) =>
      'journal.take.$suffix.$objectKey';
}
