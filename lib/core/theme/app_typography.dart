import 'package:flutter/material.dart';

/// Builds the custom [TextTheme] mandated by the visual style guide, ensuring
/// font sizes, weights and leading ratios remain consistent across light/dark
/// themes.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(ColorScheme scheme) {
    final TextTheme base = ThemeData(brightness: scheme.brightness).textTheme;

    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
            height: 30 / 22,
            color: scheme.onSurface,
          ) ??
          TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
            height: 30 / 22,
            color: scheme.onSurface,
          ),
      titleMedium: base.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 26 / 18,
            color: scheme.onSurface,
          ) ??
          TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 26 / 18,
            color: scheme.onSurface,
          ),
      bodyLarge: base.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 24 / 16,
            color: scheme.onSurface,
          ) ??
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 24 / 16,
            color: scheme.onSurface,
          ),
      bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: scheme.onSurface.withValues(alpha: 0.92),
          ) ??
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: scheme.onSurface.withValues(alpha: 0.92),
          ),
      bodySmall: base.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: scheme.onSurface.withValues(alpha: 0.74),
          ) ??
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: scheme.onSurface.withValues(alpha: 0.74),
          ),
      labelLarge: base.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            height: 22 / 16,
            color: scheme.onPrimary,
          ) ??
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            height: 22 / 16,
            color: scheme.onPrimary,
          ),
      labelMedium: base.labelMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: scheme.onSurface,
          ) ??
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: scheme.onSurface,
          ),
    );
  }
}
