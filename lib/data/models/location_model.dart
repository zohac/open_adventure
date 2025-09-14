import 'package:open_adventure/domain/entities/location.dart';

/// Data model for locations.json entries, mapped to [Location].
class LocationModel extends Location {
  /// Constructs a [LocationModel] from a flattened JSON map and its [id].
  ///
  /// Expected shape (flattened):
  /// { 'name': String, 'description': { 'short'?, 'long'?, 'maptag'? },
  ///   'conditions': { String: bool }?, 'loud': bool? }
  factory LocationModel.fromJson(Map<String, dynamic> json, int id) {
    final desc = Map<String, dynamic>.from((json['description'] as Map?) ?? const {});
    final conditions = Map<String, bool>.from(json['conditions'] ?? const {});
    final loud = (json['loud'] as bool?) ?? false;
    return LocationModel(
      id: id,
      name: (json['name'] ?? 'Unknown') as String,
      shortDescription: desc['short'] as String?,
      longDescription: desc['long'] as String?,
      mapTag: desc['maptag'] as String?,
      loud: loud,
      conditions: conditions,
    );
  }

  /// Legacy constructor from raw entry `[name, { ...data }]` (kept for reference).
  factory LocationModel.fromEntry(List<dynamic> entry, int id) {
    final name = entry.first as String;
    final data = Map<String, dynamic>.from(entry.last as Map);
    return LocationModel.fromJson(<String, dynamic>{'name': name, ...data}, id);
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
