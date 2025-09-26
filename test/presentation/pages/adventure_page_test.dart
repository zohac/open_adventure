import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/command.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock
    implements ListAvailableActionsTravel {}

class _MockApplyTurnGoto extends Mock implements ApplyTurnGoto {}

class _MockSaveRepository extends Mock implements SaveRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const Command(verb: 'WEST', target: '2'));
    registerFallbackValue(const Game(
      loc: 0,
      oldLoc: 0,
      newLoc: 0,
      turns: 0,
      rngSeed: 0,
    ));
    registerFallbackValue(const GameSnapshot(loc: 0, turns: 0, rngSeed: 0));
  });

  group('AdventurePage', () {
    late _MockAdventureRepository adventureRepository;
    late _MockListAvailableActions listAvailableActions;
    late _MockApplyTurnGoto applyTurn;
    late _MockSaveRepository saveRepository;
    late GameController controller;

    const initialGame = Game(
      loc: 1,
      oldLoc: 1,
      newLoc: 1,
      turns: 0,
      rngSeed: 42,
      visitedLocations: {1},
    );

    setUp(() {
      adventureRepository = _MockAdventureRepository();
      listAvailableActions = _MockListAvailableActions();
      applyTurn = _MockApplyTurnGoto();
      saveRepository = _MockSaveRepository();

      controller = GameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
    });

    Future<void> pumpInitialState(WidgetTester tester,
        {AssetBundle? bundle}) async {
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
        shortDescription: 'Short start description',
      );
      final actions = <ActionOption>[
        const ActionOption(
          id: 'travel:1->2:WEST',
          category: 'travel',
          label: 'motion.west.label',
          verb: 'WEST',
          objectId: '2',
          icon: 'arrow_back',
        ),
      ];

      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => initialGame);
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => location);
      when(() => listAvailableActions(initialGame))
          .thenAnswer((_) async => actions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      Widget app = MaterialApp(
        home: AdventurePage(controller: controller),
      );
      if (bundle != null) {
        app = DefaultAssetBundle(bundle: bundle, child: app);
      }

      await tester.pumpWidget(app);

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      verify(() => saveRepository.autosave(
            const GameSnapshot(loc: 1, turns: 0, rngSeed: 42),
          )).called(1);
      clearInteractions(saveRepository);

      expect(controller.value.actions, isNotEmpty);
    }

    testWidgets('shows initial state after init', (tester) async {
      await pumpInitialState(tester);

      expect(find.text('LOC_START'), findsOneWidget);
      expect(find.text('Long start description'), findsWidgets);
      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Aller Ouest'), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_ActionsSection',
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not show Revenir when no back history exists',
        (tester) async {
      await pumpInitialState(tester);

      expect(find.text('Revenir'), findsNothing);
    });

    testWidgets('tapping a travel action updates title and description',
        (tester) async {
      await pumpInitialState(tester);

      const nextGame = Game(
        loc: 2,
        oldLoc: 1,
        newLoc: 2,
        turns: 1,
        rngSeed: 42,
        visitedLocations: {1, 2},
      );
      final nextLocation = Location(
        id: 2,
        name: 'LOC_WEST',
        shortDescription: 'Short west description',
      );
      const followupActions = <ActionOption>[
        ActionOption(
          id: 'travel:2->1:EAST',
          category: 'travel',
          label: 'motion.east.label',
          verb: 'EAST',
          objectId: '1',
          icon: 'arrow_forward',
        ),
      ];

      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async =>
            TurnResult(nextGame, const <String>['Short west description']),
      );
      when(() => adventureRepository.locationById(2))
          .thenAnswer((_) async => nextLocation);
      when(() => listAvailableActions(nextGame))
          .thenAnswer((_) async => followupActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.tap(find.text('Aller Ouest'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('LOC_WEST'), findsOneWidget);
      expect(find.text('Short west description'), findsWidgets);
      expect(find.text('Aller Est'), findsOneWidget);

      verify(() => saveRepository.autosave(
            const GameSnapshot(loc: 2, turns: 1, rngSeed: 42),
          )).called(1);
    });

    testWidgets('renders placeholder when asset is missing without errors',
        (tester) async {
      await pumpInitialState(tester, bundle: _FailingAssetBundle());

      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows observer fallback when no travel actions', (tester) async {
      const observerAction = ActionOption(
        id: 'meta:observer',
        category: 'meta',
        label: 'actions.observer.label',
        icon: 'visibility',
        verb: 'OBSERVER',
      );

      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
        shortDescription: 'Short start description',
      );

      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => initialGame);
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => location);
      when(() => listAvailableActions(initialGame))
          .thenAnswer((_) async => const [observerAction]);
      when(() => applyTurn(any(), any())).thenThrow(Exception('Should not be called'));
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: AdventurePage(controller: controller),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Observer'), findsOneWidget);

      await tester.tap(find.text('Observer'));
      await tester.pump();
      await tester.pumpAndSettle();

      verifyNever(() => applyTurn(any(), any()));
    });

    testWidgets('shows Revenir button and performs BACK', (tester) async {
      const historyGame = Game(
        loc: 2,
        oldLoc: 1,
        oldLc2: 1,
        newLoc: 2,
        turns: 3,
        rngSeed: 42,
        visitedLocations: {1, 2},
      );
      final currentLocation = Location(
        id: 2,
        name: 'LOC_CHAMBER',
        longDescription: 'A quiet chamber.',
      );
      final previousLocation = Location(
        id: 1,
        name: 'LOC_START',
        shortDescription: 'Back at the start.',
      );
      const backAction = ActionOption(
        id: 'travel:2->1:BACK',
        category: 'travel',
        label: 'actions.travel.back',
        icon: 'undo',
        verb: 'BACK',
        objectId: '1',
      );
      const returnedGame = Game(
        loc: 1,
        oldLoc: 2,
        oldLc2: 1,
        newLoc: 1,
        turns: 4,
        rngSeed: 42,
        visitedLocations: {1, 2},
      );

      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => historyGame);
      when(() => adventureRepository.locationById(2))
          .thenAnswer((_) async => currentLocation);
      when(() => listAvailableActions(historyGame))
          .thenAnswer((_) async => const [backAction]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: AdventurePage(controller: controller),
      ));
      await tester.pumpAndSettle();

      clearInteractions(saveRepository);

      expect(find.text('Revenir'), findsOneWidget);

      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async => TurnResult(returnedGame, const ['Back at the start.']),
      );
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => previousLocation);
      when(() => listAvailableActions(returnedGame))
          .thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.tap(find.text('Revenir'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('LOC_START'), findsOneWidget);
      expect(find.text('Back at the start.'), findsWidgets);
      verify(() => applyTurn(const Command(verb: 'BACK', target: '1'), historyGame))
          .called(1);
      verify(() => saveRepository.autosave(
            const GameSnapshot(loc: 1, turns: 4, rngSeed: 42),
          )).called(1);
    });
  });
}

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    return Future<ByteData>.error(FlutterError('missing asset: $key'));
  }
}
