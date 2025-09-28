import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Contrat du use case « Inventaire ».
abstract class InventoryUseCase {
  /// Retourne la projection texte de l'inventaire pour [game].
  Future<TurnResult> call(Game game);
}

/// Implémentation Domain de [InventoryUseCase].
class InventoryUseCaseImpl implements InventoryUseCase {
  /// Crée un use case `InventoryUseCase` dépendant du [AdventureRepository].
  const InventoryUseCaseImpl({required AdventureRepository adventureRepository})
      : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

  @override
  Future<TurnResult> call(Game game) async {
    final List<GameObjectState> carried = game.objectStates.values
        .where((state) => state.isCarried)
        .toList(growable: false);

    if (carried.isEmpty) {
      return TurnResult(game, const <String>['You are not carrying anything.']);
    }

    final List<GameObject> objects =
        await _adventureRepository.getGameObjects();
    final Map<int, GameObject> index = <int, GameObject>{
      for (final GameObject object in objects) object.id: object,
    };

    final List<_InventoryEntry> entries = <_InventoryEntry>[];
    for (final GameObjectState state in carried) {
      final GameObject? object = index[state.id];
      if (object == null) {
        continue;
      }
      final String label = _normalizeLabel(object.inventoryDescription) ??
          _humanizeKey(object.name);
      entries.add(_InventoryEntry(id: object.id, label: label));
    }

    if (entries.isEmpty) {
      return TurnResult(game, const <String>['You are not carrying anything.']);
    }

    entries.sort((a, b) {
      final int labelCompare = a.label.toLowerCase().compareTo(
            b.label.toLowerCase(),
          );
      if (labelCompare != 0) {
        return labelCompare;
      }
      return a.id.compareTo(b.id);
    });

    final List<String> messages = <String>[
      'You are carrying:',
      ...entries.map((entry) => '• ${entry.label}'),
    ];

    return TurnResult(game, messages);
  }

  String? _normalizeLabel(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.startsWith('*')) {
      final String withoutMarker = trimmed.substring(1).trim();
      if (withoutMarker.isEmpty) {
        return null;
      }
      return withoutMarker;
    }
    return trimmed;
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
}

class _InventoryEntry {
  const _InventoryEntry({required this.id, required this.label});

  final int id;
  final String label;
}
