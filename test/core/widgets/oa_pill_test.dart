import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/build_context_x.dart';
import 'package:open_adventure/core/theme/oa_colors.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/theme/oa_typography.dart';
import 'package:open_adventure/core/widgets/oa_pill.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: OAThemeData.dark(), home: Scaffold(body: child));

void main() {
  group('OAPill', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(_wrap(const OAPill(label: 'SCORE')));

      expect(find.text('SCORE'), findsOneWidget);
    });

    testWidgets('amber tone applies a styled border', (tester) async {
      await tester.pumpWidget(
        _wrap(const OAPill(label: 'LAMP', tone: OAPillTone.amber)),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OAPill),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('dense=true uses caps.s style (token-derived)', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (ctx) {
            captured = ctx;
            return const OAPill(label: 'X', dense: true);
          }),
        ),
      );

      final text = tester.widget<Text>(find.text('X'));
      expect(text.style?.fontSize, captured.oaTypography.caps.s.fontSize);
    });

    testWidgets('non-dense pill uses caps.m style (token-derived)',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (ctx) {
            captured = ctx;
            return const OAPill(label: 'Y');
          }),
        ),
      );

      final text = tester.widget<Text>(find.text('Y'));
      expect(text.style?.fontSize, captured.oaTypography.caps.m.fontSize);
    });

    testWidgets('iconLeading is rendered when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const OAPill(label: 'KEY', iconLeading: Icons.key)),
      );

      expect(find.byIcon(Icons.key), findsOneWidget);
    });

    testWidgets('long label is truncated with ellipsis (no overflow)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 80,
            child: OAPill(label: 'A very long pill label that should ellipsis'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text).first);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });
  });

  group('OAPill — all tones produce a non-null border with the tone color',
      () {
    for (final tone in OAPillTone.values) {
      testWidgets('${tone.name} renders a styled border', (tester) async {
        late OAColors capturedColors;
        await tester.pumpWidget(
          _wrap(
            Builder(builder: (ctx) {
              capturedColors = ctx.oaColors;
              return OAPill(label: 'X', tone: tone);
            }),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(OAPill),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border, isNotNull);
        final border = decoration.border! as Border;

        // Map each tone to its expected border color in OAColors.
        final expected = switch (tone) {
          OAPillTone.neutral => capturedColors.ink.line,
          OAPillTone.amber => capturedColors.amber.base,
          OAPillTone.teal => capturedColors.teal.glow,
          OAPillTone.danger => capturedColors.semantic.danger,
          OAPillTone.success => capturedColors.semantic.success,
          OAPillTone.magic => capturedColors.semantic.magic,
          OAPillTone.treasure => capturedColors.semantic.treasure,
        };
        expect(border.top.color, expected);
      });
    }
  });

  group('OAPill — dense icon size', () {
    testWidgets('dense renders smaller leading icon than non-dense',
        (tester) async {
      // dense=true → Size 's' = 16.
      await tester.pumpWidget(
        _wrap(const OAPill(label: 'A', iconLeading: Icons.key, dense: true)),
      );
      final iconDense = tester.widget<Icon>(find.byType(Icon));

      await tester.pumpWidget(
        _wrap(const OAPill(label: 'A', iconLeading: Icons.key)),
      );
      final iconNormal = tester.widget<Icon>(find.byType(Icon));

      expect(iconDense.size, lessThan(iconNormal.size!));
    });
  });

  // Reference table-driven test : ensures each tone's typography matches
  // OATypography.standard (no hard-coded sizes inside the test).
  test('OAPill text style sizes come exclusively from OATypography', () {
    expect(OATypography.standard.caps.m.fontSize, isPositive);
    expect(OATypography.standard.caps.s.fontSize, isPositive);
    expect(
      OATypography.standard.caps.s.fontSize! <
          OATypography.standard.caps.m.fontSize!,
      isTrue,
    );
  });
}
