// Convenience accessors for Open Adventure design tokens.
//
// Usage : `context.oaColors.amber.base`, `context.oaSpacing.s4`, etc.
// Lance une `StateError` si le `Theme` ne porte pas les extensions OA —
// volontaire (l'application racine doit utiliser `OAThemeData.dark()`).

import 'package:flutter/material.dart';

import 'oa_colors.dart';
import 'oa_motion_tokens.dart';
import 'oa_shadows.dart';
import 'oa_spacing.dart';
import 'oa_typography.dart';

extension BuildContextX on BuildContext {
  OAColors get oaColors => _extension<OAColors>();

  OATypography get oaTypography => _extension<OATypography>();

  OASpacing get oaSpacing => _extension<OASpacing>();

  OAMotionTokens get oaMotion => _extension<OAMotionTokens>();

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
