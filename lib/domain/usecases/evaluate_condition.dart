import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/value_objects/condition.dart';

/// Contrat d'évaluation d'une condition logique.
abstract class EvaluateCondition {
  /// Retourne `true` si [condition] est satisfaite dans [game].
  bool call(Condition condition, Game game);
}

/// Implémentation domaine de [EvaluateCondition].
class EvaluateConditionImpl implements EvaluateCondition {
  /// Crée un évaluateur stateless.
  const EvaluateConditionImpl();

  @override
  bool call(Condition condition, Game game) {
    switch (condition.type) {
      case ConditionType.carry:
        final state = _stateFor(game, condition.objectId);
        return state?.isCarried == true;
      case ConditionType.withObject:
        final state = _stateFor(game, condition.objectId);
        if (state == null) return false;
        if (state.isCarried) return true;
        final targetLoc = condition.locationId ?? game.loc;
        return state.isAt(targetLoc);
      case ConditionType.not:
        final inner = condition.inner;
        if (inner == null) {
          // Sans condition imbriquée, on considère la négation vraie par défaut
          // pour éviter d'ouvrir des routes dangereuses.
          return true;
        }
        return !call(inner, game);
      case ConditionType.at:
        final loc = condition.locationId;
        return loc != null && game.loc == loc;
      case ConditionType.state:
        final state = _stateFor(game, condition.objectId);
        if (state == null) return false;
        return state.state == condition.value;
      case ConditionType.prop:
        final state = _stateFor(game, condition.objectId);
        if (state == null) return false;
        return state.prop == condition.value;
      case ConditionType.have:
        final flag = condition.flagKey;
        return flag != null && game.flags.contains(flag);
    }
  }

  GameObjectState? _stateFor(Game game, int? objectId) {
    if (objectId == null) return null;
    return game.objectStates[objectId];
  }
}
