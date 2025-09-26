import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/magic_words.dart';

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
    final currentLocation = await _repo.locationById(current.loc);
    for (final r in rules) {
      final canonical = _motion.toCanonical(r.motion);
      if (canonical.isEmpty || canonical == 'UNKNOWN') continue;
      if (!current.magicWordsUnlocked && MagicWords.isIncantation(canonical)) {
        continue;
      }
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

    final backTarget = await _resolveBackTarget(current, currentLocation);
    if (backTarget != null) {
      options.add(
        ActionOption(
          id: 'travel:${current.loc}->$backTarget:BACK',
          category: 'travel',
          label: 'actions.travel.back',
          icon: _motion.iconName('BACK'),
          verb: 'BACK',
          objectId: backTarget.toString(),
        ),
      );
    }

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
    if (options.isEmpty) {
      return const [
        ActionOption(
          id: 'meta:observer',
          category: 'meta',
          label: 'actions.observer.label',
          icon: 'visibility',
          verb: 'OBSERVER',
        ),
      ];
    }

    return options;
  }

  Future<int?> _resolveBackTarget(Game current, Location currentLocation) async {
    if (current.oldLoc == current.loc) {
      return null;
    }
    if (currentLocation.conditions['NOBACK'] == true) {
      return null;
    }

    final int candidate = current.oldLoc;
    final Location previousLocation;
    try {
      previousLocation = await _repo.locationById(candidate);
    } catch (_) {
      return null;
    }
    final bool previousForced = previousLocation.conditions['FORCED'] == true;
    final int resolved = previousForced ? current.oldLc2 : candidate;
    if (resolved == current.loc) {
      return null;
    }
    try {
      await _repo.locationById(resolved);
    } catch (_) {
      return null;
    }
    return resolved;
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
