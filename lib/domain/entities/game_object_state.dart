import 'package:collection/collection.dart';

/// GameObjectState captures the dynamic state of an object within the game.
///
/// It models whether the object is currently carried by the player, where it
/// resides in the world, and its mutable state/property values as exposed by
/// the original adventure dataset.
class GameObjectState {
  /// Identifier of the object (matches the index in `objects.json`).
  final int id;

  /// Primary location identifier when the object is placed in the world.
  final int? location;

  /// Optional secondary location (for two-sided objects such as the grate).
  final int? fixedLocation;

  /// True when the player is currently carrying this object.
  final bool isCarried;

  /// Logical state value (e.g. `GRATE_OPEN`, `LAMP_BRIGHT`).
  final Object? state;

  /// Numerical property value (mirrors `prop` in the original codebase).
  final Object? prop;

  /// Creates an immutable [GameObjectState].
  const GameObjectState({
    required this.id,
    this.location,
    this.fixedLocation,
    this.isCarried = false,
    this.state,
    this.prop,
  });

  /// Returns `true` when the object is colocated with [loc].
  bool isAt(int loc) {
    return (location != null && location == loc) ||
        (fixedLocation != null && fixedLocation == loc);
  }

  /// Creates a copy of this state with overridden fields.
  GameObjectState copyWith({
    int? id,
    int? location,
    bool clearLocation = false,
    int? fixedLocation,
    bool clearFixedLocation = false,
    bool? isCarried,
    Object? state,
    bool clearState = false,
    Object? prop,
    bool clearProp = false,
  }) {
    return GameObjectState(
      id: id ?? this.id,
      location: clearLocation ? null : (location ?? this.location),
      fixedLocation: clearFixedLocation
          ? null
          : (fixedLocation ?? this.fixedLocation),
      isCarried: isCarried ?? this.isCarried,
      state: clearState ? null : (state ?? this.state),
      prop: clearProp ? null : (prop ?? this.prop),
    );
  }

  static const DeepCollectionEquality _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameObjectState) return false;
    return id == other.id &&
        location == other.location &&
        fixedLocation == other.fixedLocation &&
        isCarried == other.isCarried &&
        _equality.equals(state, other.state) &&
        _equality.equals(prop, other.prop);
  }

  @override
  int get hashCode => Object.hash(
    id,
    location,
    fixedLocation,
    isCarried,
    _equality.hash(state),
    _equality.hash(prop),
  );
}
