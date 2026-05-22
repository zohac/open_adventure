// Open Adventure spacing tokens — port of `tokens.css` (`--s-*`, `--r-*`,
// `--b-*`, `--hit-*`). 4dp grid.

import 'package:flutter/material.dart';

@immutable
class OARadii {
  const OARadii({
    required this.r0,
    required this.r1,
    required this.r2,
    required this.r3,
  });

  /// `--r-0` 0px — default pixel chrome (sharp corners).
  final double r0;

  /// `--r-1` 2px — subtle softening.
  final double r1;

  /// `--r-2` 4px — secondary surfaces.
  final double r2;

  /// `--r-3` 8px — large cards (rare).
  final double r3;

  OARadii copyWith({double? r0, double? r1, double? r2, double? r3}) {
    return OARadii(
      r0: r0 ?? this.r0,
      r1: r1 ?? this.r1,
      r2: r2 ?? this.r2,
      r3: r3 ?? this.r3,
    );
  }

  static OARadii lerp(OARadii a, OARadii b, double t) {
    return OARadii(
      r0: lerpDouble(a.r0, b.r0, t),
      r1: lerpDouble(a.r1, b.r1, t),
      r2: lerpDouble(a.r2, b.r2, t),
      r3: lerpDouble(a.r3, b.r3, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OARadii &&
        other.r0 == r0 &&
        other.r1 == r1 &&
        other.r2 == r2 &&
        other.r3 == r3;
  }

  @override
  int get hashCode => Object.hash(r0, r1, r2, r3);
}

@immutable
class OABorderWidths {
  const OABorderWidths({
    required this.b1,
    required this.b2,
    required this.b3,
  });

  /// `--b-1` 1px — hairline border.
  final double b1;

  /// `--b-2` 2px — default pixel border.
  final double b2;

  /// `--b-3` 3px — emphasized border.
  final double b3;

  OABorderWidths copyWith({double? b1, double? b2, double? b3}) {
    return OABorderWidths(
      b1: b1 ?? this.b1,
      b2: b2 ?? this.b2,
      b3: b3 ?? this.b3,
    );
  }

  static OABorderWidths lerp(OABorderWidths a, OABorderWidths b, double t) {
    return OABorderWidths(
      b1: lerpDouble(a.b1, b.b1, t),
      b2: lerpDouble(a.b2, b.b2, t),
      b3: lerpDouble(a.b3, b.b3, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OABorderWidths &&
        other.b1 == b1 &&
        other.b2 == b2 &&
        other.b3 == b3;
  }

  @override
  int get hashCode => Object.hash(b1, b2, b3);
}

@immutable
class OAHitTargets {
  const OAHitTargets({
    required this.min,
    required this.comfy,
    required this.large,
  });

  /// `--hit-min` 44px — minimum tap target (a11y baseline).
  final double min;

  /// `--hit-comfy` 48px — confortable tap target (recommended).
  final double comfy;

  /// `--hit-large` 56px — emphasized tap target (primary CTAs).
  final double large;

  OAHitTargets copyWith({double? min, double? comfy, double? large}) {
    return OAHitTargets(
      min: min ?? this.min,
      comfy: comfy ?? this.comfy,
      large: large ?? this.large,
    );
  }

  static OAHitTargets lerp(OAHitTargets a, OAHitTargets b, double t) {
    return OAHitTargets(
      min: lerpDouble(a.min, b.min, t),
      comfy: lerpDouble(a.comfy, b.comfy, t),
      large: lerpDouble(a.large, b.large, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OAHitTargets &&
        other.min == min &&
        other.comfy == comfy &&
        other.large == large;
  }

  @override
  int get hashCode => Object.hash(min, comfy, large);
}

/// Spacing/radii/border/hit-target tokens.
@immutable
class OASpacing extends ThemeExtension<OASpacing> {
  const OASpacing({
    required this.s0,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s7,
    required this.s8,
    required this.s9,
    required this.s10,
    required this.radii,
    required this.borderWidths,
    required this.hitTargets,
  });

  final double s0;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s7;
  final double s8;
  final double s9;
  final double s10;
  final OARadii radii;
  final OABorderWidths borderWidths;
  final OAHitTargets hitTargets;

  /// Port direct de `tokens.css` (4dp grid).
  static const OASpacing standard = OASpacing(
    s0: 0,
    s1: 4,
    s2: 8,
    s3: 12,
    s4: 16,
    s5: 20,
    s6: 24,
    s7: 32,
    s8: 40,
    s9: 48,
    s10: 64,
    radii: OARadii(r0: 0, r1: 2, r2: 4, r3: 8),
    borderWidths: OABorderWidths(b1: 1, b2: 2, b3: 3),
    hitTargets: OAHitTargets(min: 44, comfy: 48, large: 56),
  );

  @override
  OASpacing copyWith({
    double? s0,
    double? s1,
    double? s2,
    double? s3,
    double? s4,
    double? s5,
    double? s6,
    double? s7,
    double? s8,
    double? s9,
    double? s10,
    OARadii? radii,
    OABorderWidths? borderWidths,
    OAHitTargets? hitTargets,
  }) {
    return OASpacing(
      s0: s0 ?? this.s0,
      s1: s1 ?? this.s1,
      s2: s2 ?? this.s2,
      s3: s3 ?? this.s3,
      s4: s4 ?? this.s4,
      s5: s5 ?? this.s5,
      s6: s6 ?? this.s6,
      s7: s7 ?? this.s7,
      s8: s8 ?? this.s8,
      s9: s9 ?? this.s9,
      s10: s10 ?? this.s10,
      radii: radii ?? this.radii,
      borderWidths: borderWidths ?? this.borderWidths,
      hitTargets: hitTargets ?? this.hitTargets,
    );
  }

  @override
  OASpacing lerp(ThemeExtension<OASpacing>? other, double t) {
    if (other is! OASpacing) return this;
    return OASpacing(
      s0: lerpDouble(s0, other.s0, t),
      s1: lerpDouble(s1, other.s1, t),
      s2: lerpDouble(s2, other.s2, t),
      s3: lerpDouble(s3, other.s3, t),
      s4: lerpDouble(s4, other.s4, t),
      s5: lerpDouble(s5, other.s5, t),
      s6: lerpDouble(s6, other.s6, t),
      s7: lerpDouble(s7, other.s7, t),
      s8: lerpDouble(s8, other.s8, t),
      s9: lerpDouble(s9, other.s9, t),
      s10: lerpDouble(s10, other.s10, t),
      radii: OARadii.lerp(radii, other.radii, t),
      borderWidths: OABorderWidths.lerp(borderWidths, other.borderWidths, t),
      hitTargets: OAHitTargets.lerp(hitTargets, other.hitTargets, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OASpacing &&
        other.s0 == s0 &&
        other.s1 == s1 &&
        other.s2 == s2 &&
        other.s3 == s3 &&
        other.s4 == s4 &&
        other.s5 == s5 &&
        other.s6 == s6 &&
        other.s7 == s7 &&
        other.s8 == s8 &&
        other.s9 == s9 &&
        other.s10 == s10 &&
        other.radii == radii &&
        other.borderWidths == borderWidths &&
        other.hitTargets == hitTargets;
  }

  @override
  int get hashCode => Object.hash(
        Object.hash(s0, s1, s2, s3, s4, s5),
        Object.hash(s6, s7, s8, s9, s10),
        radii,
        borderWidths,
        hitTargets,
      );
}

/// Local helper since `lerpDouble` from `dart:ui` returns a nullable.
@visibleForTesting
double lerpDouble(double a, double b, double t) => a + (b - a) * t;
