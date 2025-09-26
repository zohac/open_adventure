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

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock
    implements ListAvailableActionsTravel {}

class _MockApplyTurnGoto extends Mock implements ApplyTurnGoto {}

class _MockSaveRepository extends Mock implements SaveRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => initialGame);
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => location);
      when(() => listAvailableActions(initialGame))
          .thenAnswer((_) async => actions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.init();

      final state = controller.value;
      expect(state.game, equals(initialGame));
      expect(state.locationTitle, equals(location.name));
      expect(state.locationDescription, equals(location.longDescription));
      expect(state.actions, equals(actions));
      expect(state.journal, equals(<String>[location.longDescription!]));
      expect(state.isLoading, isFalse);

      verify(() => saveRepository.autosave(
          const GameSnapshot(loc: 1, turns: 0, rngSeed: 42))).called(1);
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
      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => initialGame);
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => location);
      when(() => listAvailableActions(initialGame))
          .thenAnswer((_) async => initialActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});
      await controller.init();

      clearInteractions(saveRepository);
    });

    test('updates state, appends journal, refreshes actions and autosaves',
        () async {
      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async =>
            TurnResult(nextGame, const <String>['Short west description']),
      );
      when(() => adventureRepository.locationById(2))
          .thenAnswer((_) async => nextLocation);
      when(() => listAvailableActions(nextGame))
          .thenAnswer((_) async => followupActions);
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
        equals(const <String>['Long start description', 'Short west description']),
      );

      verify(() => applyTurn(any(), any())).called(1);
      verify(() => saveRepository.autosave(
          const GameSnapshot(loc: 2, turns: 1, rngSeed: 42))).called(1);
    });

    test('keeps state when BACK is rejected and records the journal entry',
        () async {
      const backAction = ActionOption(
        id: 'travel:1->1:BACK',
        category: 'travel',
        label: 'actions.travel.back',
        verb: 'BACK',
        objectId: '1',
      );

      when(() => applyTurn(any(), any())).thenAnswer(
        (_) async =>
            TurnResult(initialGame, const <String>['You cannot go back from here.']),
      );
      when(() => listAvailableActions(initialGame))
          .thenAnswer((_) async => initialActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      await controller.perform(backAction);

      final state = controller.value;
      expect(state.game, equals(initialGame));
      expect(state.locationTitle, equals('LOC_START'));
      expect(state.locationDescription, equals('Long start description'));
      expect(state.journal.last, equals('You cannot go back from here.'));
      expect(
        state.journal,
        equals(
          const <String>['Long start description', 'You cannot go back from here.'],
        ),
      );
      verify(() => applyTurn(any(), any())).called(1);
      verifyNever(() => saveRepository.autosave(any()));
    });

    test('meta observer replays description without calling applyTurn',
        () async {
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
          .thenAnswer((_) async => initialActions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});
      await controller.init();

      clearInteractions(saveRepository);
      clearInteractions(applyTurn);

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
      verifyNever(() => applyTurn(any(), any()));
      verifyNever(() => saveRepository.autosave(any()));
    });

    test('throws StateError if perform is called before init', () async {
      final freshController = GameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
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
  });

  group('refreshActions', () {
    setUp(() async {
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
      );
      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => initialGame);
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => location);
      when(() => listAvailableActions(initialGame))
          .thenAnswer((_) async => const <ActionOption>[]);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});
      await controller.init();
    });

    test('updates only the actions for the current game', () async {
      when(() => listAvailableActions(initialGame))
          .thenAnswer((_) async => const <ActionOption>[
                ActionOption(
                  id: 'travel:1->2:WEST',
                  category: 'travel',
                  label: 'motion.west.label',
                  verb: 'WEST',
                  objectId: '2',
                ),
              ]);

      await controller.refreshActions();

      expect(controller.value.actions, hasLength(1));
    });
  });
}
