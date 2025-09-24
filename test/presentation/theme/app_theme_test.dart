import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/presentation/theme/app_colors.dart';
import 'package:open_adventure/presentation/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses the expected color tokens', () {
      final ThemeData theme = AppTheme.light();
      final ColorScheme scheme = theme.colorScheme;

      expect(scheme.primary, AppColorSchemes.light.primary);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(theme.useMaterial3, isTrue);
      expect(theme.textTheme.titleLarge?.fontSize, 22);
    });

    test('dark theme preserves typography and component baselines', () {
      final ThemeData theme = AppTheme.dark();
      final ButtonStyle? style = theme.elevatedButtonTheme.style;

      expect(theme.scaffoldBackgroundColor, const Color(0xFF121318));
      expect(theme.textTheme.titleLarge?.fontWeight, FontWeight.w700);
      expect(style?.minimumSize?.resolve(const <WidgetState>{})?.height, 52);
    });
  });
}
