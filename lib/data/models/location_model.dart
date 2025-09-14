import 'package:open_adventure/domain/entities/location.dart';

/// Data model for locations.json entries, mapped to [Location].
class LocationModel extends Location {
  /// Constructs a [LocationModel] from the JSON entry and its sequential [id].
  ///
  /// The JSON shape in assets/data/locations.json is `[name, { ...data }]`.
  factory LocationModel.fromEntry(List<dynamic> entry, int id) {
    final name = entry.first as String;
    final data = Map<String, dynamic>.from(entry.last as Map);
    final desc = Map<String, dynamic>.from((data['description'] as Map?) ?? const {});
    final conditions = Map<String, bool>.from(data['conditions'] ?? const {});
    final loud = (data['loud'] as bool?) ?? false;
    return LocationModel(
      id: id,
      name: name,
      shortDescription: desc['short'] as String?,
      longDescription: desc['long'] as String?,
      mapTag: desc['maptag'] as String?,
      loud: loud,
      conditions: conditions,
    );
  }

  /// Creates an immutable [LocationModel].
  const LocationModel({
    required super.id,
    required super.name,
    super.shortDescription,
    super.longDescription,
    super.mapTag,
    super.loud = false,
    super.conditions = const {},
  });
}

