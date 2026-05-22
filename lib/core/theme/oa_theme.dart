// Open Adventure theme — assembles the four design system extensions
// (`OAColors`, `OATypography`, `OASpacing`, `OAMotionTokens`) into a
// single dark [ThemeData]. ADR-003 : dark only.

import 'package:flutter/material.dart';

import 'oa_colors.dart';
import 'oa_motion_tokens.dart';
import 'oa_spacing.dart';
import 'oa_typography.dart';

abstract final class OAThemeData {
  /// Canonical dark theme exposing every Open Adventure design token via
  /// `ThemeData.extensions`. No light variant by design (ADR-003).
  static ThemeData dark() {
    const colors = OAColors.dark;
    const typography = OATypography.standard;

    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: colors.amber.base,
      onPrimary: colors.ink.voidColor,
      secondary: colors.teal.glow,
      onSecondary: colors.ink.voidColor,
      surface: colors.ink.deep,
      onSurface: colors.paper.warm,
      surfaceContainer: colors.ink.mid,
      surfaceContainerHigh: colors.ink.raised,
      outline: colors.ink.line,
      outlineVariant: colors.ink.hairline,
      error: colors.semantic.danger,
      onError: colors.paper.bright,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.ink.voidColor,
      canvasColor: colors.ink.deep,
      fontFamily: OAFontFamily.body,
      textTheme: TextTheme(
        displayLarge: typography.display.xl,
        displayMedium: typography.display.l,
        displaySmall: typography.display.m,
        headlineMedium: typography.display.s,
        labelLarge: typography.action,
        labelMedium: typography.caps.m,
        labelSmall: typography.caps.s,
        bodyLarge: typography.body.l,
        bodyMedium: typography.body.m,
        bodySmall: typography.body.s,
      ).apply(
        bodyColor: colors.paper.warm,
        displayColor: colors.paper.bright,
      ),
      extensions: const <ThemeExtension<dynamic>>{
        colors,
        typography,
        OASpacing.standard,
        OAMotionTokens.standard,
      },
    );
  }
}
