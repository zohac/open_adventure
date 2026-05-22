import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_spacing.dart';

void main() {
  group('OASpacing.standard', () {
    test('4dp grid s0..s10 follows tokens.css scale', () {
      final s = OASpacing.standard;
      expect(s.s0, 0);
      expect(s.s1, 4);
      expect(s.s2, 8);
      expect(s.s3, 12);
      expect(s.s4, 16);
      expect(s.s5, 20);
      expect(s.s6, 24);
      expect(s.s7, 32);
      expect(s.s8, 40);
      expect(s.s9, 48);
      expect(s.s10, 64);
    });

    test('radii are pixel-friendly: 0/2/4/8', () {
      final r = OASpacing.standard.radii;
      expect(r.r0, 0);
      expect(r.r1, 2);
      expect(r.r2, 4);
      expect(r.r3, 8);
    });

    test('borderWidths are 1/2/3', () {
      final b = OASpacing.standard.borderWidths;
      expect(b.b1, 1);
      expect(b.b2, 2);
      expect(b.b3, 3);
    });

    test('hit targets follow mobile minimums (44/48/56)', () {
      final h = OASpacing.standard.hitTargets;
      expect(h.min, 44);
      expect(h.comfy, 48);
      expect(h.large, 56);
    });
  });

  group('Structural equality', () {
    test('OASpacing.standard is equal to itself', () {
      const a = OASpacing.standard;
      const b = OASpacing.standard;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('changing one spacing value breaks equality', () {
      const a = OASpacing.standard;
      final b = a.copyWith(s4: 99);
      expect(a, isNot(equals(b)));
    });
  });

  group('lerp helpers', () {
    test('lerpDouble interpolates linearly', () {
      expect(lerpDouble(0, 10, 0.5), 5);
      expect(lerpDouble(10, 20, 1.0), 20);
    });

    test('OARadii.lerp interpolates each field', () {
      const a = OARadii(r0: 0, r1: 0, r2: 0, r3: 0);
      const b = OARadii(r0: 10, r1: 10, r2: 10, r3: 10);
      final mid = OARadii.lerp(a, b, 0.5);
      expect(mid.r0, 5);
      expect(mid.r3, 5);
    });
  });
}
