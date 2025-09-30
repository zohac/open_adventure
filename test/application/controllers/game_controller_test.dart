import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
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

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock implements ListAvailableActions {}

class _MockApplyTurn extends Mock implements ApplyTurn {}

class _MockSaveRepository extends Mock implements SaveRepository {}

class _MockDwarfSystem extends Mock implements DwarfSystem {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('init', () {
    test('populates state and triggers autosave', () async {
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

      await controller.init();

      final state = controller.value;
      expect(state.game, equals(initialGame));
      expect(state.locationTitle, equals(location.name));
      expect(state.locationDescription, equals(location.longDescription));
      expect(state.actions, equals(actions));
      expect(state.journal, equals(<String>[location.longDescription!]));
      expect(state.isLoading, isFalse);
      expect(state.flashMessage, isNull);

      verify(
        () => saveRepository.autosave(
          const GameSnapshot(loc: 1, turns: 0, rngSeed: 42),
        ),
      ).called(1);
    });

    test('filters out magic words until unlocked', () async {
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
      );
      const normalAction = ActionOption(
        id: 'travel:1->2:WEST',
        category: 'travel',
        label: 'motion.west.label',
        verb: 'WEST',
        objectId: '2',
      );
      const magicAction = ActionOption(
        id: 'travel:1->3:PLUGH',
        category: 'travel',
        label: 'motion.plugh.label',
        verb: 'PLUGH',
        objectId: '3',
      );

      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => initialGame);
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => location);
      when(
        () => listAvailableActions(initialGame),
      ).thenAnswer((_) async => const [normalAction, magicAction]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.init();

      expect(controller.value.actions, equals(const [normalAction]));
      expect(controller.value.flashMessage, isNull);
    });

    test('exposes cached objects for presentation', () async {
      when(() => adventureRepository.getGameObjects()).thenAnswer(
        (_) async => const <GameObject>[GameObject(id: 5, name: 'LAMP')],
      );
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
      );
      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => initialGame);
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => location);
      when(
        () => listAvailableActions(initialGame),
      ).thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.init();

      expect(controller.objectById(5), isNotNull);
      expect(controller.objectById(5)!.name, equals('LAMP'));
      expect(controller.value.flashMessage, isNull);
    });
  });

  group('perform', () {
    final initialActions = <ActionOption>[
      const ActionOption(
        id: 'travel:1->2:WEST',
        category: 'travel',
        label: 'motion.west.label',
        verb: 'WEST',
        objectId: '2',
      ),
    ];

    const followupActions = <ActionOption>[
      ActionOption(
        id: 'travel:2->1:EAST',
        category: 'travel',
        label: 'motion.east.label',
        verb: 'EAST',
        objectId: '1',
      ),
    ];

    const magicAction = ActionOption(
      id: 'travel:1->3:PLUGH',
      category: 'travel',
      label: 'motion.plugh.label',
      verb: 'PLUGH',
      objectId: '3',
    );

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

    setUp(() async {
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
      );
      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => initialGame);
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => location);
      when(
        () => listAvailableActions(initialGame),
      ).thenAnswer((_) async => initialActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});
      await controller.init();

      clearInteractions(saveRepository);
      clearInteractions(dwarfSystem);
    });

    test(
      'updates state, appends journal, refreshes actions and autosaves',
      () async {
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

        await controller.perform(initialActions.first);

        final state = controller.value;
        expect(state.game, equals(nextGame));
        expect(state.locationTitle, equals(nextLocation.name));
        expect(state.locationDescription, equals('Short west description'));
        expect(state.actions, equals(followupActions));
        expect(state.journal.last, equals('Short west description'));
        expect(
          state.journal,
          equals(const <String>[
            'Long start description',
            'Short west description',
          ]),
        );
        expect(state.flashMessage, isNull);

        controller.clearFlashMessage();
        expect(controller.value.flashMessage, isNull);

        verify(() => applyTurn(any(), any())).called(1);
        verify(
          () => saveRepository.autosave(
            const GameSnapshot(loc: 2, turns: 1, rngSeed: 42),
          ),
        ).called(1);
        verify(() => dwarfSystem.tick(nextGame)).called(1);
      },
    );

    test(
      'keeps full arrival narration when travel emits multiple messages',
      () async {
        const messages = <String>[
          'Short west description',
          'There is a shiny brass lamp here.',
          'There are some keys on the floor.',
        ];

        when(
          () => applyTurn(any(), any()),
        ).thenAnswer((_) async => TurnResult(nextGame, messages));
        when(
          () => adventureRepository.locationById(2),
        ).thenAnswer((_) async => nextLocation);
        when(
          () => listAvailableActions(nextGame),
        ).thenAnswer((_) async => followupActions);
        when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

        await controller.perform(initialActions.first);

        final state = controller.value;
        expect(state.locationDescription, equals(messages.join('\n')));
        expect(
          state.journal.sublist(state.journal.length - 3),
          equals(messages),
        );
        expect(state.flashMessage, equals(messages.sublist(1).join('\n')));
      },
    );

    test('appends dwarf messages and persists tick mutations', () async {
      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async =>
            TurnResult(nextGame, const <String>['Short west description']),
      );
      final Game dwarfGame = nextGame.copyWith(rngSeed: 77);
      when(() => dwarfSystem.tick(nextGame)).thenAnswer(
        (_) async => DwarfTickResult(
          game: dwarfGame,
          messages: const <String>['A dwarf watches you.'],
        ),
      );
      when(
        () => adventureRepository.locationById(2),
      ).thenAnswer((_) async => nextLocation);
      when(
        () => listAvailableActions(dwarfGame),
      ).thenAnswer((_) async => followupActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.perform(initialActions.first);

      final state = controller.value;
      expect(state.game, equals(dwarfGame));
      expect(
        state.journal.sublist(state.journal.length - 2),
        equals(const <String>[
          'Short west description',
          'A dwarf watches you.',
        ]),
      );
      expect(state.flashMessage, equals('A dwarf watches you.'));
      verify(() => dwarfSystem.tick(nextGame)).called(1);
      verify(
        () => saveRepository.autosave(
          const GameSnapshot(loc: 2, turns: 1, rngSeed: 77),
        ),
      ).called(1);
    });

    test(
      'keeps state when BACK is rejected and records the journal entry',
      () async {
        const backAction = ActionOption(
          id: 'travel:1->1:BACK',
          category: 'travel',
          label: 'actions.travel.back',
          verb: 'BACK',
          objectId: '1',
        );

        when(() => applyTurn(any(), any())).thenAnswer(
          (_) async => TurnResult(initialGame, const <String>[
            'You cannot go back from here.',
          ]),
        );
        when(
          () => listAvailableActions(initialGame),
        ).thenAnswer((_) async => initialActions);
        when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

        await controller.perform(backAction);

        final state = controller.value;
        expect(state.game, equals(initialGame));
        expect(state.locationTitle, equals('LOC_START'));
        expect(state.locationDescription, equals('Long start description'));
        expect(state.journal.last, equals('You cannot go back from here.'));
        expect(
          state.journal,
          equals(const <String>[
            'Long start description',
            'You cannot go back from here.',
          ]),
        );
        expect(state.flashMessage, equals('You cannot go back from here.'));
        verify(() => applyTurn(any(), any())).called(1);
        verifyNever(() => saveRepository.autosave(any()));
        verifyNever(() => dwarfSystem.tick(any()));
      },
    );

    test('autosaves when an interaction mutates the game state', () async {
      const takeAction = ActionOption(
        id: 'interaction:take:5',
        category: 'interaction',
        label: 'actions.interaction.take.KEYS',
        verb: 'TAKE',
        objectId: '5',
      );
      const mutatedStates = <int, GameObjectState>{
        5: GameObjectState(id: 5, isCarried: true),
      };
      final Game mutatedGame = initialGame.copyWith(
        objectStates: mutatedStates,
      );

      when(() => applyTurn(any(), any())).thenAnswer((invocation) async {
        final ActionOption option =
            invocation.positionalArguments.first as ActionOption;
        expect(option, equals(takeAction));
        return TurnResult(mutatedGame, const <String>[
          'journal.take.success.KEYS',
        ]);
      });
      when(() => adventureRepository.locationById(mutatedGame.loc)).thenAnswer(
        (_) async => const Location(
          id: 1,
          name: 'LOC_START',
          longDescription: 'Long start description',
        ),
      );
      when(
        () => listAvailableActions(mutatedGame),
      ).thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.perform(takeAction);

      verify(() => applyTurn(any(), any())).called(1);
      verify(
        () => saveRepository.autosave(
          const GameSnapshot(loc: 1, turns: 0, rngSeed: 42),
        ),
      ).called(1);
      expect(controller.value.game, equals(mutatedGame));
      expect(
        controller.value.journal.last,
        equals('journal.take.success.KEYS'),
      );
      expect(
        controller.value.flashMessage,
        equals('journal.take.success.KEYS'),
      );
    });

    test('decrements lamp limit and warns when threshold is reached', () async {
      const GameObjectState lampState = GameObjectState(
        id: 7,
        isCarried: true,
        state: 'LAMP_BRIGHT',
        prop: 1,
      );
      final Game lampGame = initialGame.copyWith(
        limit: 31,
        objectStates: const <int, GameObjectState>{7: lampState},
        lampWarningIssued: false,
      );
      final Game warnedGame = lampGame.copyWith(
        limit: 30,
        lampWarningIssued: true,
      );

      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async => TurnResult(lampGame, const <String>['Nothing happens.']),
      );
      when(
        () => dwarfSystem.tick(lampGame),
      ).thenAnswer((_) async => DwarfTickResult(game: lampGame));
      when(
        () => adventureRepository.arbitraryMessage(
          'LAMP_DIM',
          count: any(named: 'count'),
        ),
      ).thenAnswer((_) async => 'Lamp dim message');
      when(() => adventureRepository.locationById(1)).thenAnswer(
        (_) async => const Location(
          id: 1,
          name: 'LOC_START',
          longDescription: 'Long start description',
        ),
      );
      when(
        () => listAvailableActions(any()),
      ).thenAnswer((_) async => followupActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.perform(initialActions.first);

      final state = controller.value;
      final Game game = state.game!;
      expect(game, equals(warnedGame));
      expect(game.limit, equals(30));
      expect(game.lampWarningIssued, isTrue);
      expect(state.journal.last, equals('Lamp dim message'));
      expect(
        state.flashMessage,
        equals('Nothing happens.\nLamp dim message'),
      );
      verify(
        () => adventureRepository.arbitraryMessage(
          'LAMP_DIM',
          count: any(named: 'count'),
        ),
      ).called(1);
      verifyNever(
        () => adventureRepository.arbitraryMessage(
          'LAMP_OUT',
          count: any(named: 'count'),
        ),
      );
      verify(() => dwarfSystem.tick(lampGame)).called(1);
    });

    test('extinguishes lamp when limit reaches zero', () async {
      const GameObjectState lampState = GameObjectState(
        id: 7,
        isCarried: true,
        state: 'LAMP_BRIGHT',
        prop: 1,
      );
      final Game depletedSource = initialGame.copyWith(
        limit: 1,
        objectStates: const <int, GameObjectState>{7: lampState},
        lampWarningIssued: false,
      );
      final GameObjectState depletedLamp = lampState.copyWith(
        state: 'LAMP_DARK',
        prop: 0,
      );
      final Game depletedGame = depletedSource.copyWith(
        limit: -1,
        lampWarningIssued: true,
        objectStates: Map<int, GameObjectState>.unmodifiable(
          <int, GameObjectState>{7: depletedLamp},
        ),
      );

      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async =>
            TurnResult(depletedSource, const <String>['Nothing happens.']),
      );
      when(
        () => dwarfSystem.tick(depletedSource),
      ).thenAnswer((_) async => DwarfTickResult(game: depletedSource));
      when(
        () => adventureRepository.arbitraryMessage(
          'LAMP_OUT',
          count: any(named: 'count'),
        ),
      ).thenAnswer((_) async => 'Lamp out message');
      when(() => adventureRepository.locationById(1)).thenAnswer(
        (_) async => const Location(
          id: 1,
          name: 'LOC_START',
          longDescription: 'Long start description',
        ),
      );
      when(
        () => listAvailableActions(any()),
      ).thenAnswer((_) async => followupActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.perform(initialActions.first);

      final state = controller.value;
      final Game game = state.game!;
      expect(game, equals(depletedGame));
      expect(game.limit, equals(-1));
      expect(game.lampWarningIssued, isTrue);
      expect(game.objectStates[7], equals(depletedLamp));
      expect(state.journal.last, equals('Lamp out message'));
      expect(
        state.flashMessage,
        equals('Nothing happens.\nLamp out message'),
      );
      verify(
        () => adventureRepository.arbitraryMessage(
          'LAMP_OUT',
          count: any(named: 'count'),
        ),
      ).called(1);
      verify(() => dwarfSystem.tick(depletedSource)).called(1);
    });

    test(
      'meta observer replays description without calling applyTurn',
      () async {
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
        ).thenAnswer((_) async => initialActions);
        when(() => saveRepository.autosave(any())).thenAnswer((_) async {});
        await controller.init();

        clearInteractions(saveRepository);
        clearInteractions(applyTurn);
        clearInteractions(dwarfSystem);

        const observerAction = ActionOption(
          id: 'meta:observer',
          category: 'meta',
          label: 'actions.observer.label',
          icon: 'visibility',
          verb: 'OBSERVER',
        );

        await controller.perform(observerAction);

        final state = controller.value;
        expect(state.locationDescription, equals('Long start description'));
        expect(state.journal.last, equals('Long start description'));
        expect(state.flashMessage, equals('Long start description'));
        verifyNever(() => applyTurn(any(), any()));
        verifyNever(() => saveRepository.autosave(any()));
        verifyNever(() => dwarfSystem.tick(any()));
      },
    );

    test('meta map defers to presentation layer', () async {
      final previousState = controller.value;
      clearInteractions(applyTurn);
      clearInteractions(saveRepository);
      clearInteractions(dwarfSystem);

      const mapAction = ActionOption(
        id: 'meta:map',
        category: 'meta',
        label: 'actions.map.label',
        icon: 'map',
        verb: 'MAP',
      );

      await controller.perform(mapAction);

      expect(controller.value, same(previousState));
      expect(controller.value.flashMessage, isNull);
      verifyNever(() => applyTurn(any(), any()));
      verifyZeroInteractions(saveRepository);
      verifyNever(() => dwarfSystem.tick(any()));
    });

    test('throws StateError if perform is called before init', () async {
      final freshController = GameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
        dwarfSystem: dwarfSystem,
      );

      expect(
        () => freshController.perform(
          const ActionOption(
            id: 'travel:1->2:WEST',
            category: 'travel',
            label: 'motion.west.label',
            verb: 'WEST',
            objectId: '2',
          ),
        ),
        throwsStateError,
      );
    });

    test('ignores magic word actions until unlocked', () async {
      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async =>
            TurnResult(nextGame, const <String>['Teleported elsewhere']),
      );
      when(
        () => listAvailableActions(nextGame),
      ).thenAnswer((_) async => followupActions);

      clearInteractions(dwarfSystem);
      await controller.perform(magicAction);

      verifyNever(() => applyTurn(any(), any()));
      verifyNever(() => dwarfSystem.tick(any()));
      expect(controller.value.game, equals(initialGame));
      expect(controller.value.flashMessage, isNull);
    });
  });

  group('refreshActions', () {
    setUp(() async {
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
      );
      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => initialGame);
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => location);
      when(
        () => listAvailableActions(initialGame),
      ).thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});
      await controller.init();
    });

    test('updates only the actions for the current game', () async {
      when(() => listAvailableActions(initialGame)).thenAnswer(
        (_) async => const <ActionOption>[
          ActionOption(
            id: 'travel:1->2:WEST',
            category: 'travel',
            label: 'motion.west.label',
            verb: 'WEST',
            objectId: '2',
          ),
        ],
      );

      await controller.refreshActions();

      expect(controller.value.actions, hasLength(1));
      expect(controller.value.flashMessage, isNull);
    });
  });
}
