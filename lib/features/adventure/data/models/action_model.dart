// lib/features/adventure/data/models/action_model.dart

import '../../domain/entities/action.dart';

class ActionModel extends Action {
  ActionModel({
    required super.type,
    required super.value,
  });

  factory ActionModel.fromJson(List<dynamic> json) {
    final type = json[0];
    final value = json[1];
    return ActionModel(type: type, value: value);
  }
}
