import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/widgets/oa_icon.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: OAThemeData.dark(), home: Scaffold(body: child));

void main() {
  group('OAIcon', () {
    testWidgets('renders an Icon with the size matching OAIconSize', (tester) async {
      await tester.pumpWidget(_wrap(const OAIcon(Icons.star, size: OAIconSize.l)));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 24);
      expect(icon.icon, Icons.star);
    });

    testWidgets('without semanticsLabel is decorative (no semantics node)',
        (tester) async {
      await tester.pumpWidget(_wrap(const OAIcon(Icons.star)));

      // ExcludeSemantics + no wrapping Semantics → no descriptive node.
      expect(find.bySemanticsLabel('star'), findsNothing);
    });

    testWidgets('with semanticsLabel publishes an image semantics node',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const OAIcon(Icons.star, semanticsLabel: 'Étoile')),
      );

      expect(find.bySemanticsLabel('Étoile'), findsOneWidget);
    });
  });

  test('oaIconSizeValue returns the expected pixel size', () {
    expect(oaIconSizeValue(OAIconSize.s), 16);
    expect(oaIconSizeValue(OAIconSize.m), 20);
    expect(oaIconSizeValue(OAIconSize.l), 24);
    expect(oaIconSizeValue(OAIconSize.xl), 32);
  });
}
