// lib/features/adventure/domain/entities/condition.dart

class Condition {
  final String type; // "not", "carry", "with", etc.
  final List<dynamic> parameters;

  Condition({
    required this.type,
    required this.parameters,
  });
}
