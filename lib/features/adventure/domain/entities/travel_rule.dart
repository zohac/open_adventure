// lib/features/adventure/domain/entities/travel_rule.dart

import 'action.dart';
import 'condition.dart';

class TravelRule {
  final List<String> verbs;
  final Action action;
  final Condition? condition;

  TravelRule({
    required this.verbs,
    required this.action,
    this.condition,
  });
}
