import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
import 'package:open_adventure/domain/value_objects/command.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

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
    final destId = int.tryParse(command.target ?? '');
    if (destId == null) {
      throw StateError('Invalid destination id: ${command.target}');
    }
    final verb = _motion.toCanonical(command.verb);
    final rules = await _repo.travelRulesFor(current.loc);
    final destLoc = await _repo.locationById(destId);

    for (final r in rules) {
      final canonical = _motion.toCanonical(r.motion);
      if (canonical == verb && r.destName == destLoc.name) {
        final newGame = current.copyWith(
          oldLoc: current.loc,
          loc: destId,
          newLoc: destId,
          turns: current.turns + 1,
        );
        final desc = destLoc.longDescription?.isNotEmpty == true
            ? destLoc.longDescription!
            : destLoc.shortDescription ?? '';
        return TurnResult(newGame, [desc]);
      }
    }

    throw StateError(
        'No travel rule for ${command.verb} to ${destLoc.name} from ${current.loc}');
  }
}

