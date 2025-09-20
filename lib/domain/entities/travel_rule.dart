/// TravelRule describes a possible movement from one location to another.
class TravelRule {
  /// Source location id (index in `locations.json`).
  final int fromId;

  /// Canonical motion verb (e.g. 'NORTH', 'SOUTH', or alias like 'WEST').
  final String motion;

  /// Destination location name/key (e.g. 'LOC_BUILDING').
  /// S1 keeps destination as name; id resolution happens in higher layers later.
  final String destName;

  /// Optional destination identifier when already resolved by the data layer.
  final int? destId;

  /// Optional condition type governing availability of the rule.
  final String? condType;

  /// Optional condition arguments (mirrors `travel.json`).
  final int? condArg1;
  final int? condArg2;

  /// Whether this rule is subject to dwarf blocking (kept for parity, unused in S1).
  final bool noDwarves;

  /// If true, indicates a 'stop' rule in the dataset (rare; unused in S1).
  final bool stop;

  /// Creates an immutable TravelRule.
  const TravelRule({
    required this.fromId,
    required this.motion,
    required this.destName,
    this.destId,
    this.condType,
    this.condArg1,
    this.condArg2,
    this.noDwarves = false,
    this.stop = false,
  });
}
