import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Centralizes the construction of light/dark [ThemeData] instances aligned
/// with the 16-bit visual language described in `VISUAL_STYLE_GUIDE.md`.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _buildTheme(AppColorSchemes.light);

  static ThemeData dark() => _buildTheme(AppColorSchemes.dark);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final TextTheme textTheme = AppTypography.textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        scheme.brightness == Brightness.dark
            ? AppActionAccents.dark
            : AppActionAccents.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        toolbarHeight: 56,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.4),
        thickness: 1,
        space: AppSpacing.md,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: AppButtonThemes.elevated(scheme, textTheme),
      filledButtonTheme: AppButtonThemes.filled(scheme, textTheme),
      outlinedButtonTheme: AppButtonThemes.outlined(scheme, textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        labelStyle: textTheme.bodySmall!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}

class AppButtonThemes {
  const AppButtonThemes._();

  static ElevatedButtonThemeData elevated(
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize:
            const WidgetStatePropertyAll<Size>(Size.fromHeight(52)),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.primary.withValues(alpha: 0.38);
            }
            if (states.contains(WidgetState.pressed)) {
              return scheme.primary.withValues(alpha: 0.90);
            }
            return scheme.primary;
          },
        ),
        foregroundColor:
            WidgetStatePropertyAll<Color>(scheme.onPrimary),
        textStyle: WidgetStatePropertyAll<TextStyle>(textTheme.labelLarge!),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: const WidgetStatePropertyAll<double>(0),
      ),
    );
  }

  static FilledButtonThemeData filled(
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize:
            const WidgetStatePropertyAll<Size>(Size.fromHeight(48)),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        ),
        backgroundColor: WidgetStatePropertyAll<Color>(scheme.secondary),
        foregroundColor: WidgetStatePropertyAll<Color>(scheme.onSecondary),
        textStyle: WidgetStatePropertyAll<TextStyle>(textTheme.labelLarge!),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: const WidgetStatePropertyAll<double>(0),
      ),
    );
  }

  static OutlinedButtonThemeData outlined(
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize:
            const WidgetStatePropertyAll<Size>(Size.fromHeight(48)),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle>(textTheme.labelLarge!),
        foregroundColor: WidgetStatePropertyAll<Color>(scheme.primary),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: scheme.primary, width: 1.5),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
