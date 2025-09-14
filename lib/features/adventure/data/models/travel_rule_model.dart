// lib/features/adventure/data/models/travel_rule_model.dart

import '../../domain/entities/travel_rule.dart';
import 'action_model.dart';
import 'condition_model.dart';

class TravelRuleModel extends TravelRule {
  TravelRuleModel({
    required super.verbs,
    required ActionModel super.action,
    ConditionModel? super.condition,
  });

  factory TravelRuleModel.fromJson(Map<String, dynamic> json) {
    final verbs = List<String>.from(json['verbs'] ?? []);
    final actionData = json['action'];
    final action = ActionModel.fromJson(actionData);

    ConditionModel? condition;
    if (json.containsKey('cond')) {
      condition = ConditionModel.fromJson(json['cond']);
    }

    return TravelRuleModel(
      verbs: verbs,
      action: action,
      condition: condition,
    );
  }
}
