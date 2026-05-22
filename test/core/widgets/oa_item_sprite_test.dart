import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/build_context_x.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/widgets/oa_item_sprite.dart';

// 1×1 transparent PNG used to satisfy ImageProvider without hitting assets.
final Uint8List _onePx = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Widget _wrap(Widget child) => MaterialApp(
      theme: OAThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('OAItemSprite', () {
    testWidgets('non-tappable sprite exposes image semantics', (tester) async {
      await tester.pumpWidget(
        _wrap(OAItemSprite(image: MemoryImage(_onePx), label: 'Lamp')),
      );

      expect(find.bySemanticsLabel('Lamp'), findsOneWidget);
    });

    testWidgets('tappable sprite invokes onTap and ≥ 56dp tap target',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          OAItemSprite(
            image: MemoryImage(_onePx),
            label: 'Lamp',
            onTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(OAItemSprite));
      await tester.pump();

      expect(taps, 1);
      final size = tester.getSize(find.byType(OAItemSprite));
      expect(size.width, greaterThanOrEqualTo(56));
      expect(size.height, greaterThanOrEqualTo(56));
    });

    testWidgets('badgeCount renders a pill in the corner', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OAItemSprite(
            image: MemoryImage(_onePx),
            label: 'Coin pile',
            badgeCount: 12,
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('selected=true uses an amber border in the decoration',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (ctx) {
            captured = ctx;
            return OAItemSprite(
              image: MemoryImage(_onePx),
              label: 'Gem',
              selected: true,
              onTap: () {},
            );
          }),
        ),
      );

      final container = tester.widgetList<Container>(find.byType(Container)).first;
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, captured.oaColors.amber.base);
    });

    testWidgets('badgeCount > 99 is clamped to "99+"', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OAItemSprite(
            image: MemoryImage(_onePx),
            label: 'Pile',
            badgeCount: 250,
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('250'), findsNothing);
    });

    test('asserts badgeCount must be null or positive', () {
      expect(
        () => OAItemSprite(
          image: MemoryImage(_onePx),
          label: 'x',
          badgeCount: 0,
        ),
        throwsAssertionError,
      );
      expect(
        () => OAItemSprite(
          image: MemoryImage(_onePx),
          label: 'x',
          badgeCount: -3,
        ),
        throwsAssertionError,
      );
    });
  });
}
