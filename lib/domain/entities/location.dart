/// Location entity representing a place in the adventure world.
class Location {
  /// Sequential identifier (index in `locations.json`).
  final int id;

  /// Canonical name/key (e.g. "LOC_START").
  final String name;

  /// Optional short description.
  final String? shortDescription;

  /// Optional long description.
  final String? longDescription;

  /// Optional map tag (used for image mapping or map display).
  final String? mapTag;

  /// True if the location is considered loud/noisy (optional; default false).
  final bool loud;

  /// Arbitrary boolean conditions flags (from `locations.json`).
  final Map<String, bool> conditions;

  /// Creates an immutable Location entity.
  const Location({
    required this.id,
    required this.name,
    this.shortDescription,
    this.longDescription,
    this.mapTag,
    this.loud = false,
    this.conditions = const {},
  });
}

