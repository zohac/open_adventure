import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_motion_tokens.dart';

void main() {
  group('OAMotionTokens.standard', () {
    test('exposes the three canonical durations from tokens.css', () {
      const m = OAMotionTokens.standard;
      expect(m.durFast, const Duration(milliseconds: 120));
      expect(m.durBase, const Duration(milliseconds: 200));
      expect(m.durSlow, const Duration(milliseconds: 320));
    });
  });

  group('Structural equality', () {
    test('two standards are equal and share hashCode', () {
      const a = OAMotionTokens.standard;
      const b = OAMotionTokens.standard;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith breaks equality when a value changes', () {
      const a = OAMotionTokens.standard;
      final b = a.copyWith(durBase: const Duration(seconds: 1));
      expect(a, isNot(equals(b)));
    });
  });

  group('Lerp', () {
    test('interpolates durations linearly', () {
      const a = OAMotionTokens.standard;
      const b = OAMotionTokens(
        durFast: Duration(milliseconds: 0),
        durBase: Duration(milliseconds: 0),
        durSlow: Duration(milliseconds: 0),
      );
      final mid = a.lerp(b, 0.5);
      expect(mid.durBase, const Duration(milliseconds: 100));
    });

    test('returns this when other is not OAMotionTokens', () {
      const a = OAMotionTokens.standard;
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
