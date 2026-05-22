// OAAnimations — semantic animation triplets `(Duration, Curve)` for the
// Open Adventure motion system. Discretised pixel-art grammar (ADR-006).
// Story 5-5 — Motion system.

import 'package:flutter/material.dart';

import '../theme/oa_motion_tokens.dart';
import 'oa_step_curves.dart';

/// Animation semantics used across the app. Each maps to a `(duration, curve)`
/// triplet via [OAAnimations.resolve] / [OAMotion.of].
enum OAAnimationSemantic {
  /// No animation. Snap to end frame.
  instant,

  /// Micro-feedback : tap ripple, focus ring fade, switch toggle.
  fast,

  /// Default screen transition : scene fade-in, panel slide, route push.
  base,

  /// Emphasis : overlay onset (death screen, save loaded), important reveal.
  slow,

  /// Cinematic transitions : `Hall of Mists → Y2` warp, big-room reveal.
  cinematic,
}

@immutable
class _OASemanticEntry {
  const _OASemanticEntry(this.duration, this.curve);
  final Duration duration;
  final Curve curve;
}

@immutable
class OAAnimations extends ThemeExtension<OAAnimations> {
  const OAAnimations({
    required this.tokens,
    required this.cinematicDuration,
  });

  /// Source of duration constants (from Story 5-3).
  final OAMotionTokens tokens;

  /// Duration used for [OAAnimationSemantic.cinematic]. Not defined in
  /// `tokens.css` (which stops at `--dur-slow: 320ms`) — kept here so all
  /// timings remain documented in this file.
  final Duration cinematicDuration;

  /// Canonical animation set used across the app.
  static const OAAnimations standard = OAAnimations(
    tokens: OAMotionTokens.standard,
    cinematicDuration: Duration(milliseconds: 560),
  );

  /// Returns the `(duration, curve)` triplet for the given semantic,
  /// **without** honouring `MediaQuery.disableAnimations`. Use
  /// [OAMotion.of] to get reduce-motion-aware values.
  ({Duration duration, Curve curve}) raw(OAAnimationSemantic semantic) {
    final entry = _entry(semantic);
    return (duration: entry.duration, curve: entry.curve);
  }

  _OASemanticEntry _entry(OAAnimationSemantic semantic) {
    switch (semantic) {
      case OAAnimationSemantic.instant:
        return const _OASemanticEntry(Duration.zero, Curves.linear);
      case OAAnimationSemantic.fast:
        return _OASemanticEntry(tokens.durFast, OAStepCurve.step2);
      case OAAnimationSemantic.base:
        return _OASemanticEntry(tokens.durBase, OAStepCurve.step4);
      case OAAnimationSemantic.slow:
        return _OASemanticEntry(tokens.durSlow, OAStepCurve.step4);
      case OAAnimationSemantic.cinematic:
        return _OASemanticEntry(cinematicDuration, OAStepCurve.step8);
    }
  }

  @override
  OAAnimations copyWith({OAMotionTokens? tokens, Duration? cinematicDuration}) {
    return OAAnimations(
      tokens: tokens ?? this.tokens,
      cinematicDuration: cinematicDuration ?? this.cinematicDuration,
    );
  }

  @override
  OAAnimations lerp(ThemeExtension<OAAnimations>? other, double t) {
    if (other is! OAAnimations) return this;
    return OAAnimations(
      tokens: tokens.lerp(other.tokens, t),
      cinematicDuration: Duration(
        microseconds: (cinematicDuration.inMicroseconds +
                (other.cinematicDuration.inMicroseconds -
                        cinematicDuration.inMicroseconds) *
                    t)
            .round(),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OAAnimations &&
        other.tokens == tokens &&
        other.cinematicDuration == cinematicDuration;
  }

  @override
  int get hashCode => Object.hash(tokens, cinematicDuration);
}

/// Reduce-motion-aware accessor. Resolves an [OAAnimationSemantic] to a
/// concrete `(duration, curve)` using the ambient `MediaQuery`. When
/// `MediaQuery.disableAnimations == true`, every semantic collapses to
/// `(Duration.zero, Curves.linear)`.
class OAMotion {
  const OAMotion._(this._animations, this._disableAnimations);

  final OAAnimations _animations;
  final bool _disableAnimations;

  /// Build a motion resolver tied to the given context. Throws [StateError]
  /// if the [OAAnimations] extension is missing from the theme.
  factory OAMotion.of(BuildContext context) {
    final animations = Theme.of(context).extension<OAAnimations>();
    if (animations == null) {
      throw StateError(
        'Missing OAAnimations in ThemeData.extensions — wrap the app with '
        'OAThemeData.dark() (see lib/core/theme/oa_theme.dart).',
      );
    }
    final disabled = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return OAMotion._(animations, disabled);
  }

  /// `true` when reduce-motion is enabled at the OS level. All [resolve]
  /// calls return `(Duration.zero, Curves.linear)` in that case.
  bool get disableAnimations => _disableAnimations;

  /// Resolve a semantic to a `(duration, curve)` triplet, honouring
  /// reduce-motion.
  ({Duration duration, Curve curve}) resolve(OAAnimationSemantic semantic) {
    if (_disableAnimations) {
      return (duration: Duration.zero, curve: Curves.linear);
    }
    return _animations.raw(semantic);
  }
}
