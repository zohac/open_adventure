import 'package:collection/collection.dart';

import 'game_object_state.dart';

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

  /// Dynamic state of interactive objects indexed by identifier.
  final Map<int, GameObjectState> objectStates;

  /// Global boolean flags representing abstract conditions.
  final Set<String> flags;

  /// Remaining number of turns the lamp can stay lit. `-1` once depleted.
  final int limit;

  /// Clock #1 mirror from the original adventure logic (used for events).
  final int clock1;

  /// Clock #2 mirror from the original adventure logic (used for events).
  final int clock2;

  /// Whether the low-lamp warning has already been surfaced to the player.
  final bool lampWarningIssued;

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
    this.objectStates = const <int, GameObjectState>{},
    this.flags = const <String>{},
    this.limit = 0,
    this.clock1 = 0,
    this.clock2 = 0,
    this.lampWarningIssued = false,
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
    Map<int, GameObjectState>? objectStates,
    Set<String>? flags,
    int? limit,
    int? clock1,
    int? clock2,
    bool? lampWarningIssued,
  }) => Game(
    loc: loc ?? this.loc,
    oldLoc: oldLoc ?? this.oldLoc,
    oldLc2: oldLc2 ?? this.oldLc2,
    newLoc: newLoc ?? this.newLoc,
    turns: turns ?? this.turns,
    rngSeed: rngSeed ?? this.rngSeed,
    visitedLocations: visitedLocations ?? this.visitedLocations,
    magicWordsUnlocked: magicWordsUnlocked ?? this.magicWordsUnlocked,
    objectStates: objectStates ?? this.objectStates,
    flags: flags ?? this.flags,
    limit: limit ?? this.limit,
    clock1: clock1 ?? this.clock1,
    clock2: clock2 ?? this.clock2,
    lampWarningIssued: lampWarningIssued ?? this.lampWarningIssued,
  );

  static const SetEquality<int> _setEquality = SetEquality<int>();
  static const MapEquality<int, GameObjectState> _objectMapEquality =
      MapEquality<int, GameObjectState>();
  static const SetEquality<String> _flagEquality = SetEquality<String>();

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
        magicWordsUnlocked == other.magicWordsUnlocked &&
        _objectMapEquality.equals(objectStates, other.objectStates) &&
        _flagEquality.equals(flags, other.flags) &&
        limit == other.limit &&
        clock1 == other.clock1 &&
        clock2 == other.clock2 &&
        lampWarningIssued == other.lampWarningIssued;
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
    _objectMapEquality.hash(objectStates),
    _flagEquality.hash(flags),
    limit,
    clock1,
    clock2,
    lampWarningIssued,
  );
}
