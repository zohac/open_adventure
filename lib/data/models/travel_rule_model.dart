import 'package:open_adventure/domain/entities/travel_rule.dart';

/// Data model for travel.json entries, mapped to [TravelRule].
class TravelRuleModel extends TravelRule {
  /// Optional destination type (stringified) from travel.json.
  final String? destType;

  /// Constructs a [TravelRuleModel] from a JSON map.
  factory TravelRuleModel.fromJson(Map<String, dynamic> json) {
    final fromIndex = json['from_index'] as int?;
    final motionRaw = json['motion'];
    final motion = motionRaw?.toString() ?? '';
    final destRaw = json['destval'];
    final destVal = destRaw?.toString() ?? '';
    final noDwarves = json['nodwarves'] as bool? ?? false;
    final stop = json['stop'] as bool? ?? false;
    final condType =
        json.containsKey('condtype') ? json['condtype']?.toString() : null;
    final destType =
        json.containsKey('desttype') ? json['desttype']?.toString() : null;
    final condArg1 = json['condarg1'] is int
        ? json['condarg1'] as int
        : int.tryParse('${json['condarg1']}');
    final condArg2 = json['condarg2'] is int
        ? json['condarg2'] as int
        : int.tryParse('${json['condarg2']}');
    final destId = destRaw is int ? destRaw : int.tryParse(destVal);
    return TravelRuleModel(
      fromId: fromIndex ?? 0,
      motion: motion,
      destName: destVal,
      destId: destId,
      condType: condType,
      condArg1: condArg1,
      condArg2: condArg2,
      noDwarves: noDwarves,
      stop: stop,
      destType: destType,
    );
  }

  /// Creates an immutable [TravelRuleModel].
  const TravelRuleModel({
    required super.fromId,
    required super.motion,
    required super.destName,
    super.destId,
    super.condType,
    super.condArg1,
    super.condArg2,
    super.noDwarves = false,
    super.stop = false,
    this.destType,
  });
}
