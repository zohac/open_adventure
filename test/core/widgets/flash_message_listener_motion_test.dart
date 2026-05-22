// Targeted tests for Story 5-5 finding F6 : the FlashMessageListener must
// honour reduce-motion through OAMotion (centralised resolver), and fall
// back gracefully when the host theme lacks the OAAnimations extension.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/core/theme/app_theme.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/core/widgets/flash_message_listener.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock implements ListAvailableActions {}

class _MockApplyTurn extends Mock implements ApplyTurn {}

class _MockSaveRepository extends Mock implements SaveRepository {}

class _MockDwarfSystem extends Mock implements DwarfSystem {}

GameController _newController() {
  return GameController(
    adventureRepository: _MockAdventureRepository(),
    listAvailableActions: _MockListAvailableActions(),
    applyTurn: _MockApplyTurn(),
    saveRepository: _MockSaveRepository(),
    dwarfSystem: _MockDwarfSystem(),
  );
}

Widget _wrap({
  required GameController controller,
  required ThemeData theme,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: FlashMessageListener(
        controller: controller,
        child: const Scaffold(body: SizedBox()),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlashMessageListener reduce-motion contract (F4/F6)', () {
    testWidgets(
        'AnimatedSwitcher inherits OAAnimations.base under OAThemeData',
        (tester) async {
      final controller = _newController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(controller: controller, theme: OAThemeData.dark()),
      );
      await tester.pump();

      final animatedSwitcher =
          tester.widget<AnimatedSwitcher>(
              find.byKey(FlashMessageListener.flashMessageSwitcherKey));
      expect(animatedSwitcher.duration, const Duration(milliseconds: 200));
    });

    testWidgets(
        'AnimatedSwitcher collapses to Duration.zero when '
        'MediaQuery.disableAnimations == true',
        (tester) async {
      final controller = _newController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          controller: controller,
          theme: OAThemeData.dark(),
          disableAnimations: true,
        ),
      );
      await tester.pump();

      final animatedSwitcher =
          tester.widget<AnimatedSwitcher>(
              find.byKey(FlashMessageListener.flashMessageSwitcherKey));
      expect(animatedSwitcher.duration, Duration.zero);
      expect(animatedSwitcher.reverseDuration, Duration.zero);
    });

    testWidgets(
        'Falls back to OAAnimations.standard under a legacy AppTheme '
        '(no OAAnimations extension required at the call-site)',
        (tester) async {
      final controller = _newController();
      addTearDown(controller.dispose);

      // AppTheme also exposes OAAnimations.standard for cohabitation, but
      // the test bypasses that by using a vanilla Material theme to prove
      // the OAMotion.fallbackOf defensive path works even without it.
      await tester.pumpWidget(
        _wrap(controller: controller, theme: ThemeData.light()),
      );
      await tester.pump();

      // Renders without throwing — fallbackOf returned OAAnimations.standard.
      final animatedSwitcher =
          tester.widget<AnimatedSwitcher>(
              find.byKey(FlashMessageListener.flashMessageSwitcherKey));
      expect(animatedSwitcher.duration, const Duration(milliseconds: 200));
    });

    testWidgets('Legacy AppTheme.dark() exposes OAAnimations.standard too',
        (tester) async {
      final controller = _newController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(controller: controller, theme: AppTheme.dark()),
      );
      await tester.pump();

      final animatedSwitcher =
          tester.widget<AnimatedSwitcher>(
              find.byKey(FlashMessageListener.flashMessageSwitcherKey));
      expect(animatedSwitcher.duration, const Duration(milliseconds: 200));
    });
  });
}
