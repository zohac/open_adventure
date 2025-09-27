import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat d'interaction « Ouvrir un objet ».
abstract class OpenObject {
  /// Tente d'ouvrir l'objet [objectId] dans [game] et retourne le résultat du tour.
  Future<TurnResult> call(String objectId, Game game);
}

/// Implémentation Domain de [OpenObject].
class OpenObjectImpl implements OpenObject {
  /// Crée un use case `OpenObject` dépendant du [AdventureRepository].
  const OpenObjectImpl({required AdventureRepository adventureRepository})
    : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

  static const Map<String, int> _requiredKeysByObject = <String, int>{
    'GRATE': 1,
  };

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
        _messageKey('notOpenable', object.name),
      ]);
    }

    final int openIndex = _indexWhere(
      definedStates,
      (value) => value.contains('OPEN'),
    );
    if (openIndex == -1) {
      return TurnResult(game, <String>[
        _messageKey('notOpenable', object.name),
      ]);
    }

    final String openStateValue = definedStates[openIndex];
    if (state.state == openStateValue) {
      return TurnResult(game, <String>[_messageKey('already', object.name)]);
    }

    final int? requiredKeyId = _requiredKeysByObject[object.name];
    if (requiredKeyId != null) {
      final GameObjectState? keyState = game.objectStates[requiredKeyId];
      final bool hasKey = keyState?.isCarried == true;
      if (!hasKey) {
        return TurnResult(game, <String>[
          _messageKey('requiresKey', object.name),
        ]);
      }
    }

    final GameObjectState updatedState = state.copyWith(
      state: openStateValue,
      prop: openIndex,
    );

    final Map<int, GameObjectState> updatedStates =
        Map<int, GameObjectState>.from(game.objectStates)
          ..[parsedId] = updatedState;

    final Game updatedGame = game.copyWith(
      objectStates: Map.unmodifiable(updatedStates),
    );

    final List<String> messages = <String>[_messageKey('success', object.name)];

    final List<String>? descriptions = object.stateDescriptions;
    if (descriptions != null && openIndex < descriptions.length) {
      messages.add(descriptions[openIndex]);
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
      'journal.open.$suffix.$objectKey';
}
