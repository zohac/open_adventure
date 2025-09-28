import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat d'interaction « Fermer un objet ».
abstract class CloseObject {
  /// Tente de fermer l'objet [objectId] dans [game] et retourne le résultat du tour.
  Future<TurnResult> call(String objectId, Game game);
}

/// Implémentation Domain de [CloseObject].
class CloseObjectImpl implements CloseObject {
  /// Crée un use case `CloseObject` dépendant du [AdventureRepository].
  const CloseObjectImpl({required AdventureRepository adventureRepository})
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

    if (!state.isCarried && !state.isAt(game.loc)) {
      return TurnResult(game, <String>[_messageKey('notHere', object.name)]);
    }

    final List<String>? definedStates = object.states;
    if (definedStates == null || definedStates.isEmpty) {
      return TurnResult(game, <String>[
        _messageKey('notCloseable', object.name),
      ]);
    }

    final int closedIndex = _indexWhere(
      definedStates,
      (value) => value.contains('CLOSE'),
    );
    if (closedIndex == -1) {
      return TurnResult(game, <String>[
        _messageKey('notCloseable', object.name),
      ]);
    }

    final String closedStateValue = definedStates[closedIndex];
    if (state.state == closedStateValue) {
      return TurnResult(game, <String>[_messageKey('already', object.name)]);
    }

    final GameObjectState updatedState = state.copyWith(
      state: closedStateValue,
      prop: closedIndex,
    );

    final Map<int, GameObjectState> updatedStates =
        Map<int, GameObjectState>.from(game.objectStates)
          ..[parsedId] = updatedState;

    final Game updatedGame = game.copyWith(
      objectStates: Map.unmodifiable(updatedStates),
    );

    final List<String> messages = <String>[_messageKey('success', object.name)];

    final List<String>? descriptions = object.stateDescriptions;
    if (descriptions != null && closedIndex < descriptions.length) {
      messages.add(descriptions[closedIndex]);
    }

    return TurnResult(updatedGame, messages);
  }

  Future<GameObject> _loadObject(int objectId) async {
    final List<GameObject> objects = await _adventureRepository
        .getGameObjects();
    for (final GameObject object in objects) {
      if (object.id == objectId) {
        return object;
      }
    }
    throw StateError('Unknown object id $objectId');
  }

  int _indexWhere(List<String> values, bool Function(String) predicate) {
    for (var index = 0; index < values.length; index++) {
      if (predicate(values[index])) {
        return index;
      }
    }
    return -1;
  }

  String _messageKey(String suffix, String objectKey) =>
      'journal.close.$suffix.$objectKey';
}
