/// Game represents the current world state required in S1.
class Game {
  /// Current location id (index in `locations.json`).
  final int loc;

  /// Number of turns elapsed since start.
  final int turns;

  /// Seed used for deterministic RNG.
  final int rngSeed;

  /// Creates an immutable Game state.
  const Game({
    required this.loc,
    required this.turns,
    required this.rngSeed,
  });

  /// Returns a copy with updated fields.
  Game copyWith({int? loc, int? turns, int? rngSeed}) => Game(
        loc: loc ?? this.loc,
        turns: turns ?? this.turns,
        rngSeed: rngSeed ?? this.rngSeed,
      );
}

