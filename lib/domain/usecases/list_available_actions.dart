import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';

/// ListAvailableActions (travel only) — calcule les options de déplacement.
class ListAvailableActionsTravel {
  final AdventureRepository _repo;
  final MotionCanonicalizer _motion;
  const ListAvailableActionsTravel(this._repo, this._motion);

  /// Retourne uniquement des options `category=travel` pour l'état courant.
  Future<List<ActionOption>> call(Game current) async {
    final rules = await _repo.travelRulesFor(current.loc);
    final candidates = <String, _TravelCandidate>{};
    Map<String, int>? nameToId;
    for (final r in rules) {
      final canonical = _motion.toCanonical(r.motion);
      if (canonical.isEmpty || canonical == 'UNKNOWN') continue;
      var destId = r.destId;
      if (destId == null) {
        nameToId ??= {for (final l in await _repo.getLocations()) l.name: l.id};
        final destName = r.destName;
        if (destName.isEmpty) continue;
        destId = nameToId[destName];
      }
      if (destId == null) continue;
      final candidate = _TravelCandidate(
        canonical: canonical,
        label: _motion.uiKey(canonical),
        icon: _motion.iconName(canonical),
        priority: _motion.priority(canonical),
        destId: destId,
      );
      final key = '${destId}_$canonical';
      final currentBest = candidates[key];
      if (currentBest == null || candidate.compareTo(currentBest) < 0) {
        candidates[key] = candidate;
      }
    }

    final options = candidates.values
        .map((c) => ActionOption(
              id: 'travel:${current.loc}->${c.destId}:${c.canonical}',
              category: 'travel',
              label: c.label,
              icon: c.icon,
              verb: c.canonical,
              objectId: c.destId.toString(),
            ))
        .toList();

    options.sort((a, b) {
      final pa = _motion.priority(a.verb);
      final pb = _motion.priority(b.verb);
      if (pa != pb) return pa - pb;
      final cl = a.label.compareTo(b.label);
      if (cl != 0) return cl;
      final da = int.tryParse(a.objectId ?? '') ?? 0;
      final db = int.tryParse(b.objectId ?? '') ?? 0;
      return da - db;
    });
    return options;
  }
}

class _TravelCandidate {
  final String canonical;
  final String label;
  final String? icon;
  final int priority;
  final int destId;

  const _TravelCandidate({
    required this.canonical,
    required this.label,
    required this.icon,
    required this.priority,
    required this.destId,
  });

  int compareTo(_TravelCandidate other) {
    if (priority != other.priority) {
      return priority - other.priority;
    }
    final labelComparison = label.compareTo(other.label);
    if (labelComparison != 0) {
      return labelComparison;
    }
    return destId - other.destId;
  }
}
