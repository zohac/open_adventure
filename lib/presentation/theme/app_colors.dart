import 'package:flutter/material.dart';

/// Defines the canonical color tokens for Open Adventure as per the visual
/// style guide. These tokens feed the light/dark [ColorScheme] instances used
/// throughout the application.
class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6C63FF),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0DEFF),
    onPrimaryContainer: Color(0xFF1D1760),
    secondary: Color(0xFF2E7D32),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD8F5D9),
    onSecondaryContainer: Color(0xFF0C3B0F),
    tertiary: Color(0xFF0288D1),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCDEBFF),
    onTertiaryContainer: Color(0xFF012033),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDE7E7),
    onErrorContainer: Color(0xFF5C0007),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF121212),
    surfaceDim: Color(0xFFF3F3F7),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF8F8FB),
    surfaceContainer: Color(0xFFF2F2F7),
    surfaceContainerHigh: Color(0xFFEDEDF2),
    surfaceContainerHighest: Color(0xFFE6E7EB),
    onSurfaceVariant: Color(0xFF43464D),
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1B1C20),
    onInverseSurface: Color(0xFFE6E7EB),
    inversePrimary: Color(0xFF8C88FF),
    surfaceTint: Color(0xFF6C63FF),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8C88FF),
    onPrimary: Color(0xFF1A1B1E),
    primaryContainer: Color(0xFF3E3A87),
    onPrimaryContainer: Color(0xFFE1DFFF),
    secondary: Color(0xFF81C784),
    onSecondary: Color(0xFF0C3B0F),
    secondaryContainer: Color(0xFF1F4E21),
    onSecondaryContainer: Color(0xFFD8F5D9),
    tertiary: Color(0xFF64B5F6),
    onTertiary: Color(0xFF012033),
    tertiaryContainer: Color(0xFF013856),
    onTertiaryContainer: Color(0xFFCDEBFF),
    error: Color(0xFFEF9A9A),
    onError: Color(0xFF5C0007),
    errorContainer: Color(0xFF7F1B22),
    onErrorContainer: Color(0xFFFDE7E7),
    surface: Color(0xFF121318),
    onSurface: Color(0xFFE6E7EB),
    surfaceDim: Color(0xFF0E0F12),
    surfaceBright: Color(0xFF1C1D22),
    surfaceContainerLowest: Color(0xFF090A0D),
    surfaceContainerLow: Color(0xFF16171C),
    surfaceContainer: Color(0xFF1B1D23),
    surfaceContainerHigh: Color(0xFF20232A),
    surfaceContainerHighest: Color(0xFF272A32),
    onSurfaceVariant: Color(0xFFC7CAD1),
    outline: Color(0xFF2A2E37),
    outlineVariant: Color(0xFF3B3F48),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E7EB),
    onInverseSurface: Color(0xFF121318),
    inversePrimary: Color(0xFF6C63FF),
    surfaceTint: Color(0xFF8C88FF),
  );
}

/// Provides categorical accent colors for travel, interaction and meta actions
/// as mandated by the visual style guide. Exposed as a [ThemeExtension] so
/// presentation widgets can retrieve consistent hues regardless of the active
/// brightness.
@immutable
class AppActionAccents extends ThemeExtension<AppActionAccents> {
  /// Creates a set of action accent colors.
  const AppActionAccents({
    required this.travel,
    required this.interaction,
    required this.meta,
  });

  /// Accent used for travel actions (movement between locations).
  final Color travel;

  /// Accent used for interaction actions (manipulating the environment).
  final Color interaction;

  /// Accent used for meta actions (UI, options, journal, saves...).
  final Color meta;

  /// Light theme accents defined by the visual style guide tokens.
  static const AppActionAccents light = AppActionAccents(
    travel: Color(0xFF2E7D32),
    interaction: Color(0xFF0288D1),
    meta: Color(0xFF616161),
  );

  /// Dark theme accents defined by the visual style guide tokens.
  static const AppActionAccents dark = AppActionAccents(
    travel: Color(0xFF81C784),
    interaction: Color(0xFF64B5F6),
    meta: Color(0xFF9E9E9E),
  );

  @override
  AppActionAccents copyWith({
    Color? travel,
    Color? interaction,
    Color? meta,
  }) {
    return AppActionAccents(
      travel: travel ?? this.travel,
      interaction: interaction ?? this.interaction,
      meta: meta ?? this.meta,
    );
  }

  @override
  AppActionAccents lerp(AppActionAccents? other, double t) {
    if (other == null) {
      return this;
    }
    return AppActionAccents(
      travel: Color.lerp(travel, other.travel, t) ?? travel,
      interaction: Color.lerp(interaction, other.interaction, t) ?? interaction,
      meta: Color.lerp(meta, other.meta, t) ?? meta,
    );
  }
}
