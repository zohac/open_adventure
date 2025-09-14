// lib/features/adventure/data/models/location_model.dart

import 'package:open_adventure/features/adventure/domain/enums/sound.dart';
import '../../domain/entities/location.dart';
import 'travel_rule_model.dart';
import 'sound_model.dart';

class LocationModel extends Location {
  LocationModel({
    required super.id,
    required super.name,
    super.mapTag,
    super.shortDescription,
    super.longDescription,
    required Sound sound,
    super.loud,
    required super.conditions,
    required List<TravelRuleModel> super.travel,
  }) : super(
    sound: sound = Sound.silent,
  );

  factory LocationModel.fromJson(List<dynamic> json, id) {
    final description = json['description'] ?? {};
    final shortDescription = description['short'];
    final longDescription = description['long'];
    final mapTag = description['maptag'];

    final conditions = Map<String, bool>.from(json['conditions'] ?? {});

    final soundStr = json['sound'];
    final sound = SoundModel.fromString(soundStr);

    final loud = json['loud'] ?? false;

    final travelData = json['travel'] as List<dynamic>? ?? [];
    final travel = travelData
        .map((e) => TravelRuleModel.fromJson(e))
        .toList();

    return LocationModel(
      id: id,
      name: json['name'] ?? 'Unknown',
      mapTag: mapTag,
      shortDescription: shortDescription,
      longDescription: longDescription,
      sound: sound,
      loud: loud,
      conditions: conditions,
      travel: travel,
    );
  }

  Map<String, dynamic> toJson() {
    // Implement if needed
    return {};
  }
}
