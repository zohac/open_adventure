import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_typography.dart';

void main() {
  group('OATypography.standard scale', () {
    test('display family is Pixelify Sans across the four sizes', () {
      final display = OATypography.standard.display;
      expect(display.xl.fontFamily, 'Pixelify Sans');
      expect(display.xl.fontSize, 40);
      expect(display.l.fontSize, 28);
      expect(display.m.fontSize, 22);
      expect(display.s.fontSize, 18);
    });

    test('body family is DM Sans with sizes 17/15/13', () {
      final body = OATypography.standard.body;
      expect(body.l.fontFamily, 'DM Sans');
      expect(body.l.fontSize, 17);
      expect(body.m.fontSize, 15);
      expect(body.s.fontSize, 13);
    });

    test('caps family is Silkscreen 12/10', () {
      final caps = OATypography.standard.caps;
      expect(caps.m.fontFamily, 'Silkscreen');
      expect(caps.m.fontSize, 12);
      expect(caps.s.fontSize, 10);
    });

    test('action token is 16px and mono family is JetBrains Mono', () {
      final t = OATypography.standard;
      expect(t.action.fontSize, 16);
      expect(t.mono.fontFamily, 'JetBrains Mono');
    });
  });

  group('OAFontFamily constants', () {
    test('match the tokens.css family names (with spaces)', () {
      expect(OAFontFamily.display, 'Pixelify Sans');
      expect(OAFontFamily.caps, 'Silkscreen');
      expect(OAFontFamily.body, 'DM Sans');
      expect(OAFontFamily.mono, 'JetBrains Mono');
    });
  });

  group('Structural equality', () {
    test('two OATypography.standard instances are equal', () {
      const a = OATypography.standard;
      const b = OATypography.standard;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('changing the action style breaks equality', () {
      const a = OATypography.standard;
      final b = a.copyWith(action: const TextStyle(fontSize: 99));
      expect(a, isNot(equals(b)));
    });
  });
}
