import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/app_colors.dart';
import 'package:open_adventure/core/theme/oa_colors.dart';
import 'package:open_adventure/core/theme/oa_motion_tokens.dart';
import 'package:open_adventure/core/theme/oa_spacing.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/theme/oa_typography.dart';

void main() {
  group('OAThemeData.dark()', () {
    test('builds a dark-only theme with every canonical OA extension', () {
      final theme = OAThemeData.dark();

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.extension<OAColors>(), OAColors.dark);
      expect(theme.extension<OATypography>(), OATypography.standard);
      expect(theme.extension<OASpacing>(), OASpacing.standard);
      expect(theme.extension<OAMotionTokens>(), OAMotionTokens.standard);
    });

    test('keeps legacy action accents during Epic 5 page cohabitation', () {
      final theme = OAThemeData.dark();

      expect(theme.extension<AppActionAccents>(), AppActionAccents.dark);
    });

    test('derives Material colors and typography from OA tokens', () {
      final theme = OAThemeData.dark();

      expect(theme.colorScheme.primary, OAColors.dark.amber.base);
      expect(theme.colorScheme.secondary, OAColors.dark.teal.glow);
      expect(theme.scaffoldBackgroundColor, OAColors.dark.ink.voidColor);
      expect(
        theme.textTheme.bodyMedium?.fontFamily,
        OATypography.standard.body.m.fontFamily,
      );
      expect(
        theme.textTheme.bodyMedium?.fontSize,
        OATypography.standard.body.m.fontSize,
      );
      expect(
        theme.textTheme.bodyMedium?.color,
        OAColors.dark.paper.warm,
      );
      expect(
        theme.textTheme.labelLarge?.fontFamily,
        OATypography.standard.action.fontFamily,
      );
    });
  });
}
