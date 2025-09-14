// lib/features/adventure/data/models/condition_model.dart

import '../../domain/entities/condition.dart';

class ConditionModel extends Condition {
  ConditionModel({
    required super.type,
    required super.parameters,
  });

  factory ConditionModel.fromJson(List<dynamic> json) {
    final type = json[0];
    final parameters = json.sublist(1);
    return ConditionModel(type: type, parameters: parameters);
  }
}
