import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
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

    testWidgets('dense=true uses the smaller caps style', (tester) async {
      await tester.pumpWidget(_wrap(const OAPill(label: 'X', dense: true)));

      final text = tester.widget<Text>(find.text('X'));
      expect(text.style?.fontSize, 10);
    });

    testWidgets('non-dense pill uses caps-m (12px)', (tester) async {
      await tester.pumpWidget(_wrap(const OAPill(label: 'Y')));

      final text = tester.widget<Text>(find.text('Y'));
      expect(text.style?.fontSize, 12);
    });

    testWidgets('iconLeading is rendered when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const OAPill(label: 'KEY', iconLeading: Icons.key)),
      );

      expect(find.byIcon(Icons.key), findsOneWidget);
    });
  });
}
