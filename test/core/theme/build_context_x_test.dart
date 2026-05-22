import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/build_context_x.dart';
import 'package:open_adventure/core/theme/oa_colors.dart';
import 'package:open_adventure/core/theme/oa_motion_tokens.dart';
import 'package:open_adventure/core/theme/oa_spacing.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/theme/oa_typography.dart';

void main() {
  group('BuildContextX', () {
    testWidgets('resolves the four OA extensions through context', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: OAThemeData.dark(),
          home: Builder(builder: (ctx) {
            captured = ctx;
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(captured.oaColors, isA<OAColors>());
      expect(captured.oaTypography, isA<OATypography>());
      expect(captured.oaSpacing, isA<OASpacing>());
      expect(captured.oaMotion, isA<OAMotionTokens>());
    });

    testWidgets('throws StateError when the theme lacks an OA extension',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(), // no OA extensions
          home: Builder(builder: (ctx) {
            captured = ctx;
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(() => captured.oaColors, throwsA(isA<StateError>()));
      expect(() => captured.oaTypography, throwsA(isA<StateError>()));
      expect(() => captured.oaSpacing, throwsA(isA<StateError>()));
      expect(() => captured.oaMotion, throwsA(isA<StateError>()));
    });
  });
}
