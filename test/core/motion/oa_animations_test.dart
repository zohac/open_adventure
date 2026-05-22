import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/motion/oa_animations.dart';
import 'package:open_adventure/core/motion/oa_step_curves.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: OAThemeData.dark(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('OAAnimations.raw — direct triplets', () {
    test('instant → Duration.zero + linear', () {
      final r = OAAnimations.standard.raw(OAAnimationSemantic.instant);
      expect(r.duration, Duration.zero);
      expect(r.curve, Curves.linear);
    });

    test('fast → 120ms + step2', () {
      final r = OAAnimations.standard.raw(OAAnimationSemantic.fast);
      expect(r.duration, const Duration(milliseconds: 120));
      expect(r.curve, OAStepCurve.step2);
    });

    test('base → 200ms + step4', () {
      final r = OAAnimations.standard.raw(OAAnimationSemantic.base);
      expect(r.duration, const Duration(milliseconds: 200));
      expect(r.curve, OAStepCurve.step4);
    });

    test('slow → 320ms + step4', () {
      final r = OAAnimations.standard.raw(OAAnimationSemantic.slow);
      expect(r.duration, const Duration(milliseconds: 320));
      expect(r.curve, OAStepCurve.step4);
    });

    test('cinematic → 560ms + step8', () {
      final r = OAAnimations.standard.raw(OAAnimationSemantic.cinematic);
      expect(r.duration, const Duration(milliseconds: 560));
      expect(r.curve, OAStepCurve.step8);
    });
  });

  group('OAMotion.of — disableAnimations', () {
    testWidgets('false → returns the canonical (200ms, step4) for base',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _wrap(Builder(builder: (c) {
          ctx = c;
          return const SizedBox.shrink();
        })),
      );

      final motion = OAMotion.of(ctx);
      expect(motion.disableAnimations, isFalse);

      final r = motion.resolve(OAAnimationSemantic.base);
      expect(r.duration, const Duration(milliseconds: 200));
      expect(r.curve, OAStepCurve.step4);
    });

    testWidgets('true → collapses every semantic to (Duration.zero, linear)',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          }),
          disableAnimations: true,
        ),
      );

      final motion = OAMotion.of(ctx);
      expect(motion.disableAnimations, isTrue);

      for (final s in OAAnimationSemantic.values) {
        final r = motion.resolve(s);
        expect(r.duration, Duration.zero,
            reason: 'duration should collapse for $s');
        expect(r.curve, Curves.linear,
            reason: 'curve should collapse for $s');
      }
    });

    testWidgets('throws StateError when OAAnimations extension missing',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(() => OAMotion.of(ctx), throwsA(isA<StateError>()));
    });
  });

  group('Structural equality', () {
    test('two OAAnimations.standard are equal', () {
      const a = OAAnimations.standard;
      const b = OAAnimations.standard;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith breaks equality when cinematicDuration changes', () {
      const a = OAAnimations.standard;
      final b = a.copyWith(cinematicDuration: const Duration(seconds: 99));
      expect(a, isNot(equals(b)));
    });
  });
}
