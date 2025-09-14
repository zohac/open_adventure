import 'package:open_adventure/domain/entities/travel_rule.dart';

/// Data model for travel.json entries, mapped to [TravelRule].
class TravelRuleModel extends TravelRule {
  /// Constructs a [TravelRuleModel] from a JSON map.
  factory TravelRuleModel.fromJson(Map<String, dynamic> json) {
    final fromIndex = json['from_index'] as int?;
    final motionRaw = json['motion'];
    final motion = motionRaw?.toString() ?? '';
    final destVal = json['destval']?.toString() ?? '';
    final noDwarves = json['nodwarves'] as bool? ?? false;
    final stop = json['stop'] as bool? ?? false;
    return TravelRuleModel(
      fromId: fromIndex ?? 0,
      motion: motion,
      destName: destVal,
      noDwarves: noDwarves,
      stop: stop,
    );
  }

  /// Creates an immutable [TravelRuleModel].
  const TravelRuleModel({
    required super.fromId,
    required super.motion,
    required super.destName,
    super.noDwarves = false,
    super.stop = false,
  });
}

