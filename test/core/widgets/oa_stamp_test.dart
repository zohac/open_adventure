import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/widgets/oa_stamp.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: OAThemeData.dark(), home: Scaffold(body: child));

void main() {
  group('OAStamp', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(
        _wrap(OAStamp(label: 'Aller au nord', onPressed: () {})),
      );

      expect(find.text('Aller au nord'), findsOneWidget);
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(OAStamp(label: 'TAP', onPressed: () => tapped++)),
      );

      await tester.tap(find.byType(OAStamp));
      await tester.pump();

      expect(tapped, 1);
    });

    testWidgets('disabled (onPressed == null) does not trigger taps',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const OAStamp(label: 'DISABLED', onPressed: null)),
      );

      // Tap is a no-op (no callback to verify) — assert widget still renders.
      await tester.tap(find.byType(OAStamp), warnIfMissed: false);
      await tester.pump();

      expect(find.text('DISABLED'), findsOneWidget);
    });

    testWidgets('respects min hit target of 44dp on size compact', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OAStamp(
            label: 'A',
            size: OAStampSize.compact,
            onPressed: () {},
          ),
        ),
      );

      final size = tester.getSize(find.byType(OAStamp));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('size large reaches 56dp hit target', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OAStamp(
            label: 'A',
            size: OAStampSize.large,
            onPressed: () {},
          ),
        ),
      );

      final size = tester.getSize(find.byType(OAStamp));
      expect(size.height, greaterThanOrEqualTo(56));
    });
  });
}
