/// Game represents the current world state required in S1.
class Game {
  /// Current location id (index in `locations.json`).
  final int loc;

  /// Previous location id before the last move.
  final int oldLoc;

  /// Location id the player is moving to (mirrors [loc] post-move).
  final int newLoc;

  /// Number of turns elapsed since start.
  final int turns;

  /// Seed used for deterministic RNG.
  final int rngSeed;

  /// Creates an immutable Game state.
  const Game({
    required this.loc,
    required this.oldLoc,
    required this.newLoc,
    required this.turns,
    required this.rngSeed,
  });

  /// Returns a copy with updated fields.
  Game copyWith({
    int? loc,
    int? oldLoc,
    int? newLoc,
    int? turns,
    int? rngSeed,
  }) =>
      Game(
        loc: loc ?? this.loc,
        oldLoc: oldLoc ?? this.oldLoc,
        newLoc: newLoc ?? this.newLoc,
        turns: turns ?? this.turns,
        rngSeed: rngSeed ?? this.rngSeed,
      );
}

