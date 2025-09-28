import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat du use case « Examiner un objet ».
abstract class Examine {
  /// Retourne la description contextuelle de l'objet [targetId] dans [game].
  Future<TurnResult> call(String? targetId, Game game);
}

/// Implémentation Domain de [Examine].
class ExamineImpl implements Examine {
  /// Crée un use case `Examine` dépendant du [AdventureRepository].
  const ExamineImpl({required AdventureRepository adventureRepository})
      : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

  @override
  Future<TurnResult> call(String? targetId, Game game) async {
    if (targetId == null) {
      throw ArgumentError.notNull('targetId');
    }
    final int? parsedId = int.tryParse(targetId);
    if (parsedId == null) {
      throw ArgumentError.value(targetId, 'targetId', 'must be a numeric id');
    }

    final GameObject object = await _loadObject(parsedId);
    final GameObjectState? state = game.objectStates[parsedId];
    if (state == null) {
      throw StateError('No state tracked for object id $parsedId');
    }

    final bool isVisible = state.isCarried || state.isAt(game.loc);
    if (!isVisible) {
      return TurnResult(game, <String>[_messageKey('notHere', object.name)]);
    }

    final bool isCarried = state.isCarried;
    final String description = _resolveDescription(
      object: object,
      state: state,
      carried: isCarried,
    );

    return TurnResult(game, <String>[
      _messageKey('success', object.name),
      description,
    ]);
  }

  Future<GameObject> _loadObject(int objectId) async {
    final List<GameObject> objects =
        await _adventureRepository.getGameObjects();
    for (final GameObject object in objects) {
      if (object.id == objectId) {
        return object;
      }
    }
    throw StateError('Unknown object id $objectId');
  }

  String _resolveDescription({
    required GameObject object,
    required GameObjectState state,
    required bool carried,
  }) {
    if (carried) {
      return _carriedDescription(object);
    }

    final String? contextual = _stateDescription(object, state);
    if (contextual != null && contextual.isNotEmpty) {
      return contextual;
    }
    return _fallbackVisibleDescription(object);
  }

  String _carriedDescription(GameObject object) {
    final String? label = _normalizeLabel(object.inventoryDescription);
    final String display = label ?? _humanizeKey(object.name);
    return 'You are carrying $display.';
  }

  String _fallbackVisibleDescription(GameObject object) {
    final String display = _normalizeLabel(object.inventoryDescription) ??
        _humanizeKey(object.name);
    return 'You see $display here.';
  }

  String? _stateDescription(GameObject object, GameObjectState state) {
    final List<String>? descriptions = object.stateDescriptions;
    if (descriptions == null || descriptions.isEmpty) {
      return null;
    }
    final Object? stateValue = state.state;
    final List<String>? states = object.states;
    if (stateValue != null && states != null && states.isNotEmpty) {
      final int index = states.indexOf(stateValue.toString());
      if (index >= 0 && index < descriptions.length) {
        final String candidate = descriptions[index].trim();
        if (candidate.isNotEmpty) {
          return candidate;
        }
        return null;
      }
      return null;
    }
    for (final String candidate in descriptions) {
      final String trimmed = candidate.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String? _normalizeLabel(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.startsWith('*') ? trimmed.substring(1).trim() : trimmed;
  }

  String _humanizeKey(String key) {
    final Iterable<String> words = key
        .toLowerCase()
        .split(RegExp(r'[_\s]+'))
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment[0].toUpperCase() + segment.substring(1));
    final String result = words.join(' ');
    return result.isEmpty ? key : result;
  }

  String _messageKey(String suffix, String objectKey) =>
      'journal.examine.$suffix.$objectKey';
}
