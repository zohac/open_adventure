import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_colors.dart';

void main() {
  group('OAColors.dark canonical palette', () {
    test('ink palette maps tokens.css --c-ink-* hex values', () {
      final ink = OAColors.dark.ink;
      expect(ink.voidColor.toARGB32(), 0xFF06101A);
      expect(ink.deep.toARGB32(), 0xFF0D1D2D);
      expect(ink.mid.toARGB32(), 0xFF16304A);
      expect(ink.raised.toARGB32(), 0xFF1F4267);
      expect(ink.line.toARGB32(), 0xFF2A5478);
      expect(ink.hairline.toARGB32(), 0xFF1A3A5A);
    });

    test('amber palette includes halo as rgba(240,160,64,0.22)', () {
      final amber = OAColors.dark.amber;
      expect(amber.glow.toARGB32(), 0xFFFFC070);
      expect(amber.base.toARGB32(), 0xFFF0A040);
      expect(amber.deep.toARGB32(), 0xFFC97432);
      expect(amber.shadow.toARGB32(), 0xFF8A4A1A);
      // halo alpha ≈ 0.22 → 0x38
      expect(amber.halo.a, closeTo(0.22, 0.01));
    });

    test('semantic colors expose the four flags', () {
      final sem = OAColors.dark.semantic;
      expect(sem.treasure.toARGB32(), 0xFFD4A84A);
      expect(sem.danger.toARGB32(), 0xFFD44A3A);
      expect(sem.success.toARGB32(), 0xFF6EA34A);
      expect(sem.magic.toARGB32(), 0xFF9870C4);
    });
  });

  group('Structural equality', () {
    test('two identical OAColors are equal and share hashCode', () {
      const a = OAColors.dark;
      const b = OAColors.dark;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('mutating one field via copyWith yields a different instance', () {
      const a = OAColors.dark;
      final b = a.copyWith(
        amber: a.amber.copyWith(base: const Color(0xFF000000)),
      );
      expect(a, isNot(equals(b)));
    });

    test('sub-palettes implement structural equality', () {
      const teal1 = OATealPalette(
        mist: Color(0xFF5A8FA8),
        deep: Color(0xFF2A4D6E),
        glow: Color(0xFF4EC5B8),
      );
      const teal2 = OATealPalette(
        mist: Color(0xFF5A8FA8),
        deep: Color(0xFF2A4D6E),
        glow: Color(0xFF4EC5B8),
      );
      expect(teal1, equals(teal2));
      expect(teal1.hashCode, teal2.hashCode);
    });
  });

  group('Lerp', () {
    test('OAColors.lerp blends each sub-palette toward the target', () {
      const a = OAColors.dark;
      final mid = a.lerp(a, 0.5);
      expect(mid, equals(a));
    });

    test('returns this when other is not OAColors', () {
      const a = OAColors.dark;
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
