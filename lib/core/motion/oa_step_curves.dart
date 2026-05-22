// OAStepCurve — discrete-step animation curves for the pixel-art motion
// grammar (ADR-006). Port of CSS `steps(N, end)` from
// `design_handoff_open_adventure/motion.css`.
//
// Formula : `transformInternal(t) = ((t * N).ceil()) / N` for `t > 0`,
// `0` for `t == 0` (equivalent CSS `steps(N, end)`).
//
// Story 5-5 — Motion system.

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

@immutable
class OAStepCurve extends Curve {
  /// Creates a step curve with `steps` discrete plateaus over `[0, 1]`.
  ///
  /// `steps` must be a positive integer.
  const OAStepCurve._(this.steps) : assert(steps > 0, 'steps must be > 0');

  /// Number of discrete plateaus in the curve.
  final int steps;

  /// 2-step curve — chunky on/off transitions.
  static const OAStepCurve step2 = OAStepCurve._(2);

  /// 4-step curve — port of `--ease-pixel: steps(4, end)`.
  static const OAStepCurve step4 = OAStepCurve._(4);

  /// 8-step curve — finer pixel cadence for longer transitions.
  static const OAStepCurve step8 = OAStepCurve._(8);

  @override
  double transformInternal(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    return (t * steps).ceilToDouble() / steps;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OAStepCurve && other.steps == steps;
  }

  @override
  int get hashCode => steps.hashCode;

  @override
  String toString() => 'OAStepCurve(steps: $steps)';
}
