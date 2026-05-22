// Convenience accessors for Open Adventure design tokens.
//
// Usage : `context.oaColors.amber.base`, `context.oaSpacing.s4`, etc.
// Lance une `StateError` si le `Theme` ne porte pas les extensions OA —
// volontaire (l'application racine doit utiliser `OAThemeData.dark()`).

import 'package:flutter/material.dart';

import '../motion/oa_animations.dart';
import 'oa_colors.dart';
import 'oa_motion_tokens.dart';
import 'oa_shadows.dart';
import 'oa_spacing.dart';
import 'oa_typography.dart';

extension BuildContextX on BuildContext {
  OAColors get oaColors => _extension<OAColors>();

  OATypography get oaTypography => _extension<OATypography>();

  OASpacing get oaSpacing => _extension<OASpacing>();

  /// Raw duration tokens (cf. Story 5-3). Prefer [oaMotion] when you need
  /// a `(Duration, Curve)` resolved against the current reduce-motion
  /// setting (Story 5-5).
  OAMotionTokens get oaMotionTokens => _extension<OAMotionTokens>();

  /// Reduce-motion-aware semantic animation resolver (Story 5-5). Returns
  /// `(Duration.zero, Curves.linear)` for every semantic when
  /// `MediaQuery.disableAnimations` is `true`.
  OAMotion get oaMotion => OAMotion.of(this);

  OAShadows get oaShadows => _extension<OAShadows>();

  T _extension<T extends ThemeExtension<T>>() {
    final ext = Theme.of(this).extension<T>();
    if (ext == null) {
      throw StateError(
        'Missing $T in ThemeData.extensions — wrap the app with '
        'OAThemeData.dark() (see lib/core/theme/oa_theme.dart).',
      );
    }
    return ext;
  }
}
