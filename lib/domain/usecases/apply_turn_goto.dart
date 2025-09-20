import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
import 'package:open_adventure/domain/value_objects/command.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';
import 'package:open_adventure/domain/entities/travel_rule.dart';

/// ApplyTurnGoto — applique une commande de déplacement `goto`.
///
/// Recherche une règle de voyage correspondant au verbe canonique et à la
/// destination indiquée, puis met à jour l'état de jeu en conséquence.
class ApplyTurnGoto {
  final AdventureRepository _repo;
  final MotionCanonicalizer _motion;

  /// Crée un use case [`ApplyTurnGoto`].
  const ApplyTurnGoto(this._repo, this._motion);

  /// Applique un déplacement vers une destination.
  ///
  /// - [command] contient le verbe canonique et l'identifiant de destination.
  /// - [current] est l'état de jeu courant.
  ///
  /// Retourne un [TurnResult] avec le nouvel état et la description du lieu
  /// d'arrivée. Lève un [StateError] si aucune règle ne correspond.
  Future<TurnResult> call(Command command, Game current) async {
    final rawTarget = command.target;
    final destId = int.tryParse(rawTarget ?? '');
    if (destId == null) {
      throw StateError('Invalid destination id: $rawTarget');
    }

    final verb = _motion.toCanonical(command.verb);
    if (verb.isEmpty) {
      throw StateError('Invalid motion verb: ${command.verb}');
    }

    final rules = await _repo.travelRulesFor(current.loc);
    final destLoc = await _repo.locationById(destId);
    TravelRule? matched;
    for (final rule in rules) {
      final canonical = _motion.toCanonical(rule.motion);
      if (canonical != verb) continue;
      final matchesById = rule.destId != null && rule.destId == destLoc.id;
      final matchesByName = rule.destName.isNotEmpty && rule.destName == destLoc.name;
      if (matchesById || matchesByName) {
        matched = rule;
        break;
      }
    }

    if (matched == null) {
      throw StateError(
        'No travel rule for ${command.verb} to ${destLoc.name} from ${current.loc}',
      );
    }

    final alreadyVisited = current.visitedLocations.contains(destLoc.id);
    final visitedLocations = {
      ...current.visitedLocations,
      destLoc.id,
    };

    final newGame = current.copyWith(
      oldLoc: current.loc,
      loc: destLoc.id,
      newLoc: destLoc.id,
      turns: current.turns + 1,
      visitedLocations: visitedLocations,
    );

    final description = alreadyVisited
        ? (destLoc.shortDescription?.isNotEmpty == true
            ? destLoc.shortDescription!
            : destLoc.longDescription ?? '')
        : (destLoc.longDescription?.isNotEmpty == true
            ? destLoc.longDescription!
            : destLoc.shortDescription ?? '');

    return TurnResult(newGame, [description]);
  }
}
