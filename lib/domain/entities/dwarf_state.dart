import 'package:collection/collection.dart';

/// Immutable state snapshot for the dwarf subsystem.
class DwarfState {
  /// Whether the dwarf system has been activated (player reached the depths).
  final bool activated;

  /// Whether the introductory encounter message has already been surfaced.
  final bool introShown;

  /// Positions of individual dwarves; `-1` means wandering elsewhere.
  final List<int> dwarfLocations;

  /// Creates an immutable [DwarfState].
  const DwarfState({
    this.activated = false,
    this.introShown = false,
    this.dwarfLocations = const <int>[],
  });

  /// Returns a copy with updated fields.
  DwarfState copyWith({
    bool? activated,
    bool? introShown,
    List<int>? dwarfLocations,
  }) =>
      DwarfState(
        activated: activated ?? this.activated,
        introShown: introShown ?? this.introShown,
        dwarfLocations: dwarfLocations ?? this.dwarfLocations,
      );

  static const ListEquality<int> _listEquality = ListEquality<int>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DwarfState &&
        activated == other.activated &&
        introShown == other.introShown &&
        _listEquality.equals(dwarfLocations, other.dwarfLocations);
  }

  @override
  int get hashCode => Object.hash(
        activated,
        introShown,
        _listEquality.hash(dwarfLocations),
      );
}
