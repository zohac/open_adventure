/// GameSnapshot captures the minimal persisted state required to resume a game
/// during sprint S2 (location, turn count, RNG seed).
class GameSnapshot {
  /// Current location identifier.
  final int loc;

  /// Number of turns elapsed when the snapshot was taken.
  final int turns;

  /// RNG seed associated with the current run (used for determinism).
  final int rngSeed;

  /// Creates an immutable snapshot of the game state.
  const GameSnapshot({
    required this.loc,
    required this.turns,
    required this.rngSeed,
  });

  /// Serialises the snapshot to a JSON-friendly map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'loc': loc,
        'turns': turns,
        'rng_seed': rngSeed,
        'schema_version': 1,
      };

  /// Creates a snapshot from decoded JSON.
  factory GameSnapshot.fromJson(Map<String, dynamic> json) {
    return GameSnapshot(
      loc: (json['loc'] as num).toInt(),
      turns: (json['turns'] as num).toInt(),
      rngSeed: (json['rng_seed'] as num).toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSnapshot &&
          runtimeType == other.runtimeType &&
          loc == other.loc &&
          turns == other.turns &&
          rngSeed == other.rngSeed;

  @override
  int get hashCode => Object.hash(loc, turns, rngSeed);
}
