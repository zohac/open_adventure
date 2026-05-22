import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_shadows.dart';

void main() {
  group('OAShadows.standard', () {
    test('exposes the three canonical block offsets from tokens.css', () {
      const s = OAShadows.standard;
      expect(s.blockSmall, const Offset(2, 2));
      expect(s.blockMedium, const Offset(3, 3));
      expect(s.blockLarge, const Offset(4, 4));
    });
  });

  group('Structural equality', () {
    test('two OAShadows.standard instances are equal', () {
      const a = OAShadows.standard;
      const b = OAShadows.standard;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith breaks equality when a value changes', () {
      const a = OAShadows.standard;
      final b = a.copyWith(blockMedium: const Offset(9, 9));
      expect(a, isNot(equals(b)));
    });
  });

  group('Lerp', () {
    test('interpolates each offset linearly', () {
      const a = OAShadows(
        blockSmall: Offset(0, 0),
        blockMedium: Offset(0, 0),
        blockLarge: Offset(0, 0),
      );
      const b = OAShadows(
        blockSmall: Offset(4, 4),
        blockMedium: Offset(6, 6),
        blockLarge: Offset(8, 8),
      );
      final mid = a.lerp(b, 0.5);
      expect(mid.blockSmall, const Offset(2, 2));
      expect(mid.blockMedium, const Offset(3, 3));
      expect(mid.blockLarge, const Offset(4, 4));
    });

    test('returns this when other is not OAShadows', () {
      const a = OAShadows.standard;
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
