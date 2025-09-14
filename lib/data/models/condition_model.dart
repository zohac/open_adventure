/// ConditionModel represents a location→conditions mapping from assets/data/conditions.json.
class ConditionModel {
  /// Location key (e.g., 'LOC_START').
  final String location;

  /// List of condition flags at the location.
  final List<String> conditions;

  const ConditionModel({required this.location, this.conditions = const []});

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] ?? 'LOC_UNKNOWN') as String;
    final conds = (json['conditions'] as List?)?.cast<String>() ?? const <String>[];
    return ConditionModel(location: location, conditions: conds);
  }
}

