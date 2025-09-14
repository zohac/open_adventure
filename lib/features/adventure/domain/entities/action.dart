// lib/features/adventure/domain/entities/action.dart

class Action {
  final String type; // "goto", "speak", "special"
  final dynamic value; // e.g., location name, message ID

  Action({
    required this.type,
    required this.value,
  });
}
