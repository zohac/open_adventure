import 'package:collection/collection.dart';

/// Game represents the current world state required en S2.
class Game {
  /// Current location id (index in `locations.json`).
  final int loc;

  /// Previous location id before the last move.
  final int oldLoc;

  /// Location id visited before [oldLoc] (used for BACK/RETURN).
  final int oldLc2;

  /// Location id the player is moving to (mirrors [loc] post-move).
  final int newLoc;

  /// Number of turns elapsed since start.
  final int turns;

  /// Seed used for deterministic RNG.
  final int rngSeed;

  /// Set of visited location IDs.
  final Set<int> visitedLocations;

  /// Whether the player has unlocked the set of magic words.
  final bool magicWordsUnlocked;

  /// Creates an immutable Game state.
  const Game({
    required this.loc,
    required this.oldLoc,
    int? oldLc2,
    required this.newLoc,
    required this.turns,
    required this.rngSeed,
    this.visitedLocations = const {},
    this.magicWordsUnlocked = false,
  }) : oldLc2 = oldLc2 ?? oldLoc;

  /// Returns a copy with updated fields.
  Game copyWith({
    int? loc,
    int? oldLoc,
    int? oldLc2,
    int? newLoc,
    int? turns,
    int? rngSeed,
    Set<int>? visitedLocations,
    bool? magicWordsUnlocked,
  }) =>
      Game(
        loc: loc ?? this.loc,
        oldLoc: oldLoc ?? this.oldLoc,
        oldLc2: oldLc2 ?? this.oldLc2,
        newLoc: newLoc ?? this.newLoc,
        turns: turns ?? this.turns,
        rngSeed: rngSeed ?? this.rngSeed,
        visitedLocations: visitedLocations ?? this.visitedLocations,
        magicWordsUnlocked: magicWordsUnlocked ?? this.magicWordsUnlocked,
      );

  static const SetEquality<int> _setEquality = SetEquality<int>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game &&
        loc == other.loc &&
        oldLoc == other.oldLoc &&
        oldLc2 == other.oldLc2 &&
        newLoc == other.newLoc &&
        turns == other.turns &&
        rngSeed == other.rngSeed &&
        _setEquality.equals(visitedLocations, other.visitedLocations) &&
        magicWordsUnlocked == other.magicWordsUnlocked;
  }

  @override
  int get hashCode => Object.hash(
        loc,
        oldLoc,
        oldLc2,
        newLoc,
        turns,
        rngSeed,
        _setEquality.hash(visitedLocations),
        magicWordsUnlocked,
      );
}
