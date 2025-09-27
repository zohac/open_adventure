/// GameObject entity representing an interactive item in the world.
class GameObject {
  /// Sequential identifier (index from `objects.json`).
  final int id;

  /// Canonical name/key for the object.
  final String name;

  /// Word aliases used by the original parser (kept for reference/UI).
  final List<String> words;

  /// Initial locations where the object is present (as location names or ids normalized to names in S1).
  final List<String> locations;

  /// Whether the object can be moved; default true unless flagged otherwise.
  final bool immovable;

  /// True if the object is a treasure.
  final bool isTreasure;

  /// Optional logical states supported by the object (e.g. `GRATE_OPEN`).
  final List<String>? states;

  /// Optional descriptions indexed by [states].
  final List<String>? stateDescriptions;

  /// Creates an immutable GameObject.
  const GameObject({
    required this.id,
    required this.name,
    this.words = const [],
    this.locations = const [],
    this.immovable = false,
    this.isTreasure = false,
    this.states,
    this.stateDescriptions,
  });
}
