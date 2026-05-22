import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/motion/oa_page_pixel_transition.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';

void main() {
  testWidgets(
      'OAThemeData.dark() wires OAPagePixelTransition for every platform',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OAThemeData.dark(),
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    final builders = theme.pageTransitionsTheme.builders;
    expect(builders[TargetPlatform.android], isA<OAPagePixelTransition>());
    expect(builders[TargetPlatform.iOS], isA<OAPagePixelTransition>());
  });

  testWidgets('OAPagePixelTransition renders FadeTransition with curved opacity',
      (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: OAThemeData.dark(),
        home: const Scaffold(body: Text('A')),
      ),
    );

    expect(find.text('A'), findsOneWidget);

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('B')),
      ),
    );
    await tester.pump(); // start transition
    await tester.pump(oaPageTransitionDuration ~/ 2);

    // FadeTransition is inserted by OAPagePixelTransition.
    expect(find.byType(FadeTransition), findsWidgets);

    await tester.pump(oaPageTransitionDuration);
    expect(find.text('B'), findsOneWidget);
  });
}
