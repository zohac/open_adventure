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
    final options = <ActionOption>[];
    final seen = <String>{};
    final locs = await _repo.getLocations();
    final nameToId = {for (final l in locs) l.name: l.id};
    for (final r in rules) {
      final canonical = _motion.toCanonical(r.motion);
      if (canonical == 'UNKNOWN') continue;
      final destName = r.destName;
      if (destName.isEmpty) continue;
      final destId = nameToId[destName];
      if (destId == null) continue;
      final id = 'travel:${current.loc}->$destId:$canonical';
      if (seen.contains(id)) continue;
      seen.add(id);
      final label = _motion.uiKey(canonical);
      final icon = _motion.iconName(canonical);
      options.add(ActionOption(
        id: id,
        category: 'travel',
        label: label,
        icon: icon,
        verb: canonical,
        objectId: destId.toString(),
      ));
    }
    // Tri: priorité (cardinal > vertical > autres), puis label, puis destId
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
