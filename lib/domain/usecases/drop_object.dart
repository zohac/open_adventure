import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat d'interaction « Poser un objet ».
abstract class DropObject {
  /// Applique la pose d'un objet identifié par [objectId] dans [game].
  Future<TurnResult> call(String objectId, Game game);
}

/// Implémentation Domain de [DropObject].
class DropObjectImpl implements DropObject {
  /// Crée un use case `DropObject` dépendant du [AdventureRepository].
  const DropObjectImpl({required AdventureRepository adventureRepository})
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

    if (!state.isCarried) {
      return TurnResult(
        game,
        <String>[_messageKey('notCarrying', object.name)],
      );
    }

    final GameObjectState updatedState = state.copyWith(
      isCarried: false,
      location: game.loc,
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
      'journal.drop.$suffix.$objectKey';
}
