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
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(OAStamp(label: 'DISABLED', onPressed: null)),
      );

      await tester.tap(find.byType(OAStamp), warnIfMissed: false);
      await tester.pump();

      expect(tapped, 0);
      expect(find.text('DISABLED'), findsOneWidget);

      // The underlying InkWell exposes onTap = null when the parent's
      // onPressed is null (this is what gates Material's pointer routing).
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
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
      // WCAG 2.5.5 : horizontal hit target too.
      expect(size.width, greaterThanOrEqualTo(44));
    });

    testWidgets('size regular reaches 48dp hit target', (tester) async {
      await tester.pumpWidget(
        _wrap(OAStamp(label: 'A', onPressed: () {})),
      );

      final size = tester.getSize(find.byType(OAStamp));
      expect(size.height, greaterThanOrEqualTo(48));
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

    test('asserts label or icon must be present', () {
      expect(
        () => OAStamp(label: '', onPressed: () {}),
        throwsAssertionError,
      );
    });

    testWidgets(
        'disabled opacity transition has zero duration when '
        'MediaQuery.disableAnimations == true (reduce motion contract)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OAThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: OAStamp(label: 'A', onPressed: null),
            ),
          ),
        ),
      );

      final animated =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(animated.duration, Duration.zero);
    });
  });
}
