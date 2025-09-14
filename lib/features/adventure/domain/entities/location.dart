// lib/features/adventure/domain/entities/location.dart

import 'travel_rule.dart';
import 'sound.dart';

class Location {
  final int id;
  final String name;
  final String? mapTag;
  final String? shortDescription;
  final String? longDescription;
  final Sound? sound;
  final bool loud;
  final Map<String, bool> conditions;
  final List<TravelRule> travel;

  Location({
    required this.id,
    required this.name,
    this.mapTag,
    this.shortDescription,
    this.longDescription,
    this.sound,
    this.loud = false,
    required this.conditions,
    required this.travel,
  });
}
