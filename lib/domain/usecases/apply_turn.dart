import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/close_object.dart';
import 'package:open_adventure/domain/usecases/drop_object.dart';
import 'package:open_adventure/domain/usecases/examine.dart';
import 'package:open_adventure/domain/usecases/extinguish_lamp.dart';
import 'package:open_adventure/domain/usecases/drink_liquid.dart';
import 'package:open_adventure/domain/usecases/light_lamp.dart';
import 'package:open_adventure/domain/usecases/open_object.dart';
import 'package:open_adventure/domain/usecases/take_object.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/command.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

/// Routes an [ActionOption] to the appropriate domain interaction use case.
///
/// Travel options are delegated to [ApplyTurnGoto]; interaction options invoke
/// the dedicated interaction use case (take, drop, examine, lamp toggles,
/// open/close). Meta options are expected to be consumed by the application
/// layer prior to reaching this orchestrator.
class ApplyTurn {
  /// Builds an [ApplyTurn] orchestrator with all interaction dependencies.
  const ApplyTurn({
    required ApplyTurnGoto travel,
    required Examine examine,
    required TakeObject takeObject,
    required DropObject dropObject,
    required OpenObject openObject,
    required CloseObject closeObject,
    required LightLamp lightLamp,
    required ExtinguishLamp extinguishLamp,
    required DrinkLiquid drinkLiquid,
  }) : _travel = travel,
       _examine = examine,
       _takeObject = takeObject,
       _dropObject = dropObject,
       _openObject = openObject,
       _closeObject = closeObject,
       _lightLamp = lightLamp,
       _extinguishLamp = extinguishLamp,
       _drinkLiquid = drinkLiquid;

  final ApplyTurnGoto _travel;
  final Examine _examine;
  final TakeObject _takeObject;
  final DropObject _dropObject;
  final OpenObject _openObject;
  final CloseObject _closeObject;
  final LightLamp _lightLamp;
  final ExtinguishLamp _extinguishLamp;
  final DrinkLiquid _drinkLiquid;

  /// Applies the given [option] to [game] and returns the resulting turn.
  ///
  /// Throws a [StateError] when the option category or verb cannot be routed.
  Future<TurnResult> call(ActionOption option, Game game) {
    switch (option.category) {
      case 'travel':
        return _applyTravel(option, game);
      case 'interaction':
        return _applyInteraction(option, game);
      default:
        throw StateError('Unsupported action category: ${option.category}');
    }
  }

  Future<TurnResult> _applyTravel(ActionOption option, Game game) {
    final Command command = Command(verb: option.verb, target: option.objectId);
    return _travel(command, game);
  }

  Future<TurnResult> _applyInteraction(ActionOption option, Game game) {
    final String verb = option.verb.toUpperCase();
    switch (verb) {
      case 'EXAMINE':
        return _examine(option.objectId, game);
      case 'TAKE':
        return _takeObject(_requireObjectId(option), game);
      case 'DROP':
        return _dropObject(_requireObjectId(option), game);
      case 'OPEN':
        return _openObject(_requireObjectId(option), game);
      case 'CLOSE':
        return _closeObject(_requireObjectId(option), game);
      case 'LIGHT':
        return _lightLamp(game);
      case 'EXTINGUISH':
        return _extinguishLamp(game);
      case 'DRINK':
        return _drinkLiquid(option.objectId, game);
      default:
        throw StateError('Unsupported interaction verb: ${option.verb}');
    }
  }

  String _requireObjectId(ActionOption option) {
    final String? objectId = option.objectId;
    if (objectId == null) {
      throw StateError('Action ${option.verb} requires an object id');
    }
    return objectId;
  }
}
