import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/build_context_x.dart';
import 'package:open_adventure/core/theme/oa_colors.dart';
import 'package:open_adventure/core/theme/oa_motion_tokens.dart';
import 'package:open_adventure/core/theme/oa_spacing.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/theme/oa_typography.dart';

void main() {
  group('OAThemeData.dark()', () {
    testWidgets('exposes the four OA theme extensions and canonical values',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: OAThemeData.dark(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final theme = Theme.of(capturedContext);

      // (a) extension<OAColors> non-null.
      expect(theme.extension<OAColors>(), isNotNull);
      expect(theme.extension<OATypography>(), isNotNull);
      expect(theme.extension<OASpacing>(), isNotNull);
      expect(theme.extension<OAMotionTokens>(), isNotNull);

      // (b) amber.base = #F0A040.
      expect(
        capturedContext.oaColors.amber.base.toARGB32(),
        0xFFF0A040,
      );

      // (c) body.m fontSize = 15.
      expect(capturedContext.oaTypography.body.m.fontSize, 15);

      // (d) spacing s4 = 16.0.
      expect(capturedContext.oaSpacing.s4, 16.0);

      // (e) motion durBase = 200ms.
      expect(
        capturedContext.oaMotion.durBase,
        const Duration(milliseconds: 200),
      );
    });

    test('OAThemeData.dark() is Brightness.dark', () {
      expect(OAThemeData.dark().brightness, Brightness.dark);
    });
  });
}
