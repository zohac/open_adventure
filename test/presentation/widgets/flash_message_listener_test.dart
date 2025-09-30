import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/l10n/app_localizations.dart';
import 'package:open_adventure/presentation/widgets/flash_message_listener.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock implements ListAvailableActions {}

class _MockApplyTurn extends Mock implements ApplyTurn {}

class _MockSaveRepository extends Mock implements SaveRepository {}

class _MockDwarfSystem extends Mock implements DwarfSystem {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlashMessageListener', () {
    late GameController controller;

    setUp(() {
      controller = GameController(
        adventureRepository: _MockAdventureRepository(),
        listAvailableActions: _MockListAvailableActions(),
        applyTurn: _MockApplyTurn(),
        saveRepository: _MockSaveRepository(),
        dwarfSystem: _MockDwarfSystem(),
      );
      controller.value = controller.value.copyWith(isLoading: false);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('defers clearing so stacked listeners can render flash', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FlashMessageListener(
            controller: controller,
            child: const Scaffold(body: SizedBox()),
          ),
        ),
      );

      await tester.pump();

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => FlashMessageListener(
            controller: controller,
            child: const Scaffold(body: SizedBox()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      controller.value = controller.value.copyWith(
        flashMessage: 'You swing the sword.',
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final overlayFinder = find.byKey(FlashMessageListener.flashMessageKey);
      expect(overlayFinder, findsOneWidget);
      expect(find.text('You swing the sword.'), findsOneWidget);
    });
  });
}
