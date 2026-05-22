import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/motion/oa_step_curves.dart';

void main() {
  group('OAStepCurve.step4 canonical samples (AC4)', () {
    const c = OAStepCurve.step4;

    test('transform(0.0) == 0.0', () {
      expect(c.transform(0.0), 0.0);
    });

    test('transform(0.24) == 0.25', () {
      expect(c.transform(0.24), closeTo(0.25, 1e-9));
    });

    test('transform(0.25) == 0.25', () {
      expect(c.transform(0.25), closeTo(0.25, 1e-9));
    });

    test('transform(1.0) == 1.0', () {
      expect(c.transform(1.0), 1.0);
    });
  });

  group('OAStepCurve.step2 canonical samples', () {
    const c = OAStepCurve.step2;

    test('transform(0.0) == 0.0', () => expect(c.transform(0.0), 0.0));
    test('transform(0.4) == 0.5', () {
      expect(c.transform(0.4), closeTo(0.5, 1e-9));
    });
    test('transform(0.5) == 0.5', () {
      expect(c.transform(0.5), closeTo(0.5, 1e-9));
    });
    test('transform(1.0) == 1.0', () => expect(c.transform(1.0), 1.0));
  });

  group('OAStepCurve.step8 canonical samples', () {
    const c = OAStepCurve.step8;

    test('transform(0.0) == 0.0', () => expect(c.transform(0.0), 0.0));
    test('transform(0.12) == 0.125', () {
      expect(c.transform(0.12), closeTo(0.125, 1e-9));
    });
    test('transform(0.5) == 0.5', () {
      expect(c.transform(0.5), closeTo(0.5, 1e-9));
    });
    test('transform(1.0) == 1.0', () => expect(c.transform(1.0), 1.0));
  });

  group('Discrétisation (100 samples uniformément répartis)', () {
    for (final c in <OAStepCurve>[
      OAStepCurve.step2,
      OAStepCurve.step4,
      OAStepCurve.step8,
    ]) {
      test('step${c.steps} produit uniquement des plateaux 0..N/N', () {
        final allowed = <double>{
          for (int i = 0; i <= c.steps; i++) i / c.steps,
        };
        for (int i = 0; i <= 100; i++) {
          final t = i / 100.0;
          final v = c.transform(t);
          // tolerate floating point error
          final ok = allowed.any((a) => (a - v).abs() < 1e-9);
          expect(ok, isTrue,
              reason: 'step${c.steps}.transform($t) = $v not in $allowed');
        }
      });
    }
  });

  group('Equality', () {
    test('step4 is equal to itself', () {
      expect(OAStepCurve.step4, equals(OAStepCurve.step4));
      expect(OAStepCurve.step4.hashCode, OAStepCurve.step4.hashCode);
    });

    test('step2 != step4', () {
      expect(OAStepCurve.step2, isNot(equals(OAStepCurve.step4)));
    });

    test('toString reveals step count', () {
      expect(OAStepCurve.step4.toString(), contains('4'));
    });
  });

  test('step curves are Curve instances and usable with CurvedAnimation', () {
    expect(OAStepCurve.step4, isA<Curve>());
  });
}
