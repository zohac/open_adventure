/// TravelRule describes a possible movement from one location to another.
class TravelRule {
  /// Source location id (index in `locations.json`).
  final int fromId;

  /// Canonical motion verb (e.g. 'NORTH', 'SOUTH', or alias like 'WEST').
  final String motion;

  /// Destination location name/key (e.g. 'LOC_BUILDING').
  /// S1 keeps destination as name; id resolution happens in higher layers later.
  final String destName;

  /// Whether this rule is subject to dwarf blocking (kept for parity, unused in S1).
  final bool noDwarves;

  /// If true, indicates a 'stop' rule in the dataset (rare; unused in S1).
  final bool stop;

  /// Creates an immutable TravelRule.
  const TravelRule({
    required this.fromId,
    required this.motion,
    required this.destName,
    this.noDwarves = false,
    this.stop = false,
  });
}

