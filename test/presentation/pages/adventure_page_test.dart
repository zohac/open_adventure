import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';
import 'package:open_adventure/domain/value_objects/dwarf_tick_result.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';
import 'package:open_adventure/presentation/pages/inventory_page.dart';
import 'package:open_adventure/presentation/widgets/flash_message_listener.dart';
import 'package:open_adventure/l10n/app_localizations.dart';

const _testL10nFr = AppLocalizations(Locale('fr'));

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock implements ListAvailableActions {}

class _MockApplyTurn extends Mock implements ApplyTurn {}

class _MockSaveRepository extends Mock implements SaveRepository {}

class _MockDwarfSystem extends Mock implements DwarfSystem {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const ActionOption(
        id: 'travel:1->2:WEST',
        category: 'travel',
        label: 'motion.west.label',
        verb: 'WEST',
        objectId: '2',
      ),
    );
    registerFallbackValue(
      const Game(loc: 0, oldLoc: 0, newLoc: 0, turns: 0, rngSeed: 0),
    );
    registerFallbackValue(const GameSnapshot(loc: 0, turns: 0, rngSeed: 0));
  });

  group('AdventurePage', () {
    late _MockAdventureRepository adventureRepository;
    late _MockListAvailableActions listAvailableActions;
    late _MockApplyTurn applyTurn;
    late _MockSaveRepository saveRepository;
    late _MockDwarfSystem dwarfSystem;
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
      applyTurn = _MockApplyTurn();
      saveRepository = _MockSaveRepository();

      dwarfSystem = _MockDwarfSystem();

      when(
        () => adventureRepository.getGameObjects(),
      ).thenAnswer((_) async => const <GameObject>[]);
      when(() => dwarfSystem.tick(any())).thenAnswer((invocation) async {
        final Game game = invocation.positionalArguments.first as Game;
        return DwarfTickResult(game: game);
      });

      controller = GameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
        dwarfSystem: dwarfSystem,
      );
    });

    Future<void> pumpInitialState(
      WidgetTester tester, {
      AssetBundle? bundle,
      List<ActionOption>? actionsOverride,
    }) async {
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
        shortDescription: 'Short start description',
      );
      final actions = actionsOverride ??
          <ActionOption>[
            const ActionOption(
              id: 'travel:1->2:WEST',
              category: 'travel',
              label: 'motion.west.label',
              verb: 'WEST',
              objectId: '2',
              icon: 'arrow_back',
            ),
          ];

      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => initialGame);
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => location);
      when(
        () => listAvailableActions(initialGame),
      ).thenAnswer((_) async => actions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      Widget app = MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: AdventurePage(controller: controller),
      );
      if (bundle != null) {
        app = DefaultAssetBundle(bundle: bundle, child: app);
      }

      await tester.pumpWidget(app);

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      verify(
        () => saveRepository.autosave(
          const GameSnapshot(loc: 1, turns: 0, rngSeed: 42),
        ),
      ).called(1);
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

    testWidgets('hides incantation actions before unlock', (tester) async {
      await pumpInitialState(
        tester,
        actionsOverride: const [
          ActionOption(
            id: 'travel:1->3:PLUGH',
            category: 'travel',
            label: 'motion.plugh.label',
            verb: 'PLUGH',
            objectId: '3',
          ),
          ActionOption(
            id: 'travel:1->2:WEST',
            category: 'travel',
            label: 'motion.west.label',
            verb: 'WEST',
            objectId: '2',
          ),
        ],
      );

      expect(
        find.text(_testL10nFr.resolveActionLabel('motion.plugh.label')),
        findsNothing,
      );
      expect(find.text('Aller Ouest'), findsOneWidget);
    });

    testWidgets('limits visible actions and exposes overflow modal', (
      tester,
    ) async {
      const overflowActions = [
        ActionOption(
          id: 'travel:1->2:NORTH',
          category: 'travel',
          label: 'motion.north.label',
          verb: 'NORTH',
          objectId: '2',
        ),
        ActionOption(
          id: 'travel:1->3:SOUTH',
          category: 'travel',
          label: 'motion.south.label',
          verb: 'SOUTH',
          objectId: '3',
        ),
        ActionOption(
          id: 'travel:1->4:EAST',
          category: 'travel',
          label: 'motion.east.label',
          verb: 'EAST',
          objectId: '4',
        ),
        ActionOption(
          id: 'travel:1->5:WEST',
          category: 'travel',
          label: 'motion.west.label',
          verb: 'WEST',
          objectId: '5',
        ),
        ActionOption(
          id: 'travel:1->6:UP',
          category: 'travel',
          label: 'motion.up.label',
          verb: 'UP',
          objectId: '6',
        ),
        ActionOption(
          id: 'travel:1->7:DOWN',
          category: 'travel',
          label: 'motion.down.label',
          verb: 'DOWN',
          objectId: '7',
        ),
        ActionOption(
          id: 'travel:1->8:NE',
          category: 'travel',
          label: 'motion.ne.label',
          verb: 'NE',
          objectId: '8',
        ),
        ActionOption(
          id: 'travel:1->9:SW',
          category: 'travel',
          label: 'motion.sw.label',
          verb: 'SW',
          objectId: '9',
        ),
      ];

      const movedGame = Game(
        loc: 2,
        oldLoc: 1,
        newLoc: 2,
        turns: 1,
        rngSeed: 42,
        visitedLocations: {1, 2},
      );

      when(
        () => applyTurn(any(), any()),
      ).thenAnswer((_) async => TurnResult(movedGame, const ['Vous avancez.']));
      when(() => listAvailableActions(movedGame)).thenAnswer(
        (_) async => overflowActions.take(3).toList(growable: false),
      );
      when(() => adventureRepository.locationById(2)).thenAnswer(
        (_) async => const Location(
          id: 2,
          name: 'LOC_FOREST',
          shortDescription: 'Un chemin bordé de mousse.',
        ),
      );

      await pumpInitialState(tester, actionsOverride: overflowActions);

      final plusButtonFinder = find.text('Plus…');
      expect(plusButtonFinder, findsOneWidget);
      expect(find.text('Aller Nord-Est'), findsNothing);

      await tester.dragUntilVisible(
        plusButtonFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -120),
      );

      await tester.tap(plusButtonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Actions supplémentaires'), findsOneWidget);
      expect(find.text('Aller Nord-Est'), findsOneWidget);

      await tester.tap(find.text('Aller Nord-Est'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Actions supplémentaires'), findsNothing);
      verify(() => applyTurn(any(), any())).called(1);
    });

    testWidgets('tapping inventory meta action navigates to InventoryPage', (
      tester,
    ) async {
      const inventoryAction = ActionOption(
        id: 'meta:inventory',
        category: 'meta',
        label: 'actions.inventory.label',
        icon: 'inventory',
        verb: 'INVENTORY',
      );

      await pumpInitialState(
        tester,
        actionsOverride: const <ActionOption>[
          ActionOption(
            id: 'travel:1->2:WEST',
            category: 'travel',
            label: 'motion.west.label',
            verb: 'WEST',
            objectId: '2',
          ),
          inventoryAction,
        ],
      );

      clearInteractions(applyTurn);

      await tester.tap(find.text('Inventaire'));
      await tester.pumpAndSettle();

      expect(find.byType(InventoryPage), findsOneWidget);
      verifyNever(() => applyTurn(any(), any()));
    });

    testWidgets(
      'shows incantation buttons only after unlock and hides them elsewhere',
      (tester) async {
        const baseTravel = ActionOption(
          id: 'travel:1->2:WEST',
          category: 'travel',
          label: 'motion.west.label',
          verb: 'WEST',
          objectId: '2',
        );
        const incantationOption = ActionOption(
          id: 'travel:2->5:PLUGH',
          category: 'travel',
          label: 'motion.plugh.label',
          verb: 'PLUGH',
          objectId: '5',
        );
        const exitOption = ActionOption(
          id: 'travel:2->3:EAST',
          category: 'travel',
          label: 'motion.east.label',
          verb: 'EAST',
          objectId: '3',
        );
        const remoteOption = ActionOption(
          id: 'travel:3->2:WEST',
          category: 'travel',
          label: 'motion.west.label',
          verb: 'WEST',
          objectId: '2',
        );

        const unlockedGame = Game(
          loc: 2,
          oldLoc: 1,
          newLoc: 2,
          turns: 1,
          rngSeed: 42,
          visitedLocations: {1, 2},
          magicWordsUnlocked: true,
        );
        const remoteGame = Game(
          loc: 3,
          oldLoc: 2,
          newLoc: 3,
          turns: 2,
          rngSeed: 42,
          visitedLocations: {1, 2, 3},
          magicWordsUnlocked: true,
        );

        when(
          () => listAvailableActions(unlockedGame),
        ).thenAnswer((_) async => const [incantationOption, exitOption]);
        when(
          () => listAvailableActions(remoteGame),
        ).thenAnswer((_) async => const [remoteOption]);
        when(() => applyTurn(any(), any())).thenAnswer((invocation) async {
          final ActionOption option =
              invocation.positionalArguments.first as ActionOption;
          if (option.verb == 'WEST') {
            return TurnResult(unlockedGame, const <String>[
              'Un bourdonnement magique retentit.',
            ]);
          }
          if (option.verb == 'EAST') {
            return TurnResult(remoteGame, const <String>[
              'Le passage se referme derrière vous.',
            ]);
          }
          throw StateError('Unexpected action: ${option.verb}');
        });
        when(() => adventureRepository.locationById(2)).thenAnswer(
          (_) async => const Location(
            id: 2,
            name: 'LOC_SHRINE',
            shortDescription: 'Une salle sacrée.',
          ),
        );
        when(() => adventureRepository.locationById(3)).thenAnswer(
          (_) async => const Location(
            id: 3,
            name: 'LOC_CAVERN',
            shortDescription: 'Un tunnel sombre.',
          ),
        );
        when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

        await pumpInitialState(tester, actionsOverride: const [baseTravel]);

        expect(
          find.text(_testL10nFr.resolveActionLabel('motion.plugh.label')),
          findsNothing,
        );

        await tester.tap(find.text('Aller Ouest'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(
          find.text(_testL10nFr.resolveActionLabel('motion.plugh.label')),
          findsOneWidget,
        );
        verify(
          () => saveRepository.autosave(
            const GameSnapshot(loc: 2, turns: 1, rngSeed: 42),
          ),
        ).called(1);
        clearInteractions(saveRepository);

        await tester.tap(find.text('Aller Est'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(
          find.text(_testL10nFr.resolveActionLabel('motion.plugh.label')),
          findsNothing,
        );
        verify(
          () => saveRepository.autosave(
            const GameSnapshot(loc: 3, turns: 2, rngSeed: 42),
          ),
        ).called(1);
      },
    );

    testWidgets('does not render a back action without navigation history', (
      tester,
    ) async {
      await pumpInitialState(tester);

      expect(find.text('Revenir'), findsNothing);
    });

    testWidgets('tapping a travel action updates title and description', (
      tester,
    ) async {
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
      when(
        () => adventureRepository.locationById(2),
      ).thenAnswer((_) async => nextLocation);
      when(
        () => listAvailableActions(nextGame),
      ).thenAnswer((_) async => followupActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.tap(find.text('Aller Ouest'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('LOC_WEST'), findsOneWidget);
      expect(find.text('Short west description'), findsWidgets);
      expect(find.text('Aller Est'), findsOneWidget);

      verify(
        () => saveRepository.autosave(
          const GameSnapshot(loc: 2, turns: 1, rngSeed: 42),
        ),
      ).called(1);
    });

    testWidgets('displays supplemental flash message when action is performed', (
      tester,
    ) async {
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
      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async => TurnResult(nextGame, const <String>[
          'Short west description',
          'There is a shiny brass lamp nearby.',
        ]),
      );
      when(
        () => adventureRepository.locationById(2),
      ).thenAnswer((_) async => nextLocation);
      when(
        () => listAvailableActions(nextGame),
      ).thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.tap(find.text('Aller Ouest'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final overlayFinder = find.byKey(FlashMessageListener.flashMessageKey);
      expect(overlayFinder, findsOneWidget);
      expect(
        find.descendant(
          of: overlayFinder,
          matching: find.text('There is a shiny brass lamp nearby.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('aggregates multi-line flash message when provided', (
      tester,
    ) async {
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
      const messages = <String>[
        'Short west description',
        'There is a shiny brass lamp nearby.',
        'There are some keys on the floor.',
      ];
      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async => TurnResult(nextGame, messages),
      );
      when(
        () => adventureRepository.locationById(2),
      ).thenAnswer((_) async => nextLocation);
      when(
        () => listAvailableActions(nextGame),
      ).thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.tap(find.text('Aller Ouest'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final overlayFinder = find.byKey(FlashMessageListener.flashMessageKey);
      expect(overlayFinder, findsOneWidget);
      expect(
        find.descendant(
          of: overlayFinder,
          matching: find.text(
            messages.sublist(1).join('\n'),
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders placeholder when asset is missing without errors', (
      tester,
    ) async {
      await pumpInitialState(tester, bundle: _FailingAssetBundle());

      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows observer fallback when no travel actions', (
      tester,
    ) async {
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

      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => initialGame);
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => location);
      when(
        () => listAvailableActions(initialGame),
      ).thenAnswer((_) async => const [observerAction]);
      when(
        () => applyTurn(any(), any()),
      ).thenThrow(Exception('Should not be called'));
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: AdventurePage(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Observer'), findsOneWidget);

      await tester.tap(find.text('Observer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

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

      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => historyGame);
      when(
        () => adventureRepository.locationById(2),
      ).thenAnswer((_) async => currentLocation);
      when(
        () => listAvailableActions(historyGame),
      ).thenAnswer((_) async => const [backAction]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: AdventurePage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      clearInteractions(saveRepository);

      expect(find.text('Revenir'), findsOneWidget);

      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async => TurnResult(returnedGame, const ['Back at the start.']),
      );
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => previousLocation);
      when(
        () => listAvailableActions(returnedGame),
      ).thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await tester.tap(find.text('Revenir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('LOC_START'), findsOneWidget);
      expect(find.text('Back at the start.'), findsWidgets);
      verify(() => applyTurn(backAction, historyGame)).called(1);
      verify(
        () => saveRepository.autosave(
          const GameSnapshot(loc: 1, turns: 4, rngSeed: 42),
        ),
      ).called(1);
    });
  });
}

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    return Future<ByteData>.error(FlutterError('missing asset: $key'));
  }
}
