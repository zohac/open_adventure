// Open Adventure motion durations — port of `tokens.css` (`--dur-*`).
//
// Cette story (5-3) expose UNIQUEMENT les durées. Les courbes
// (`Curves.stepN`, `Curves.easeOutPixel`) sont introduites par la
// Story 5-5 (Motion System) qui consommera ces durées.

import 'package:flutter/material.dart';

@immutable
class OAMotionTokens extends ThemeExtension<OAMotionTokens> {
  const OAMotionTokens({
    required this.durFast,
    required this.durBase,
    required this.durSlow,
  });

  /// `--dur-fast` 120ms — micro-feedback (tap, hover).
  final Duration durFast;

  /// `--dur-base` 200ms — transitions standard.
  final Duration durBase;

  /// `--dur-slow` 320ms — transitions emphasis.
  final Duration durSlow;

  /// Port direct de `tokens.css`.
  static const OAMotionTokens standard = OAMotionTokens(
    durFast: Duration(milliseconds: 120),
    durBase: Duration(milliseconds: 200),
    durSlow: Duration(milliseconds: 320),
  );

  @override
  OAMotionTokens copyWith({
    Duration? durFast,
    Duration? durBase,
    Duration? durSlow,
  }) {
    return OAMotionTokens(
      durFast: durFast ?? this.durFast,
      durBase: durBase ?? this.durBase,
      durSlow: durSlow ?? this.durSlow,
    );
  }

  @override
  OAMotionTokens lerp(ThemeExtension<OAMotionTokens>? other, double t) {
    if (other is! OAMotionTokens) return this;
    return OAMotionTokens(
      durFast: _lerpDuration(durFast, other.durFast, t),
      durBase: _lerpDuration(durBase, other.durBase, t),
      durSlow: _lerpDuration(durSlow, other.durSlow, t),
    );
  }
}

Duration _lerpDuration(Duration a, Duration b, double t) {
  return Duration(
    microseconds:
        (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t).round(),
  );
}
