import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/evaluate_condition.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActionsTravel extends Mock
    implements ListAvailableActionsTravel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAdventureRepository adventureRepository;
  late _MockListAvailableActionsTravel travel;
  late ListAvailableActions usecase;

  setUp(() {
    adventureRepository = _MockAdventureRepository();
    travel = _MockListAvailableActionsTravel();
    usecase = ListAvailableActions(
      adventureRepository: adventureRepository,
      travel: travel,
      evaluateCondition: const EvaluateConditionImpl(),
    );
  });

  group('ListAvailableActions', () {
    const carriedKeys = GameObjectState(id: 1, isCarried: true);
    const nearbyStone = GameObjectState(id: 2, location: 5);
    const grateState = GameObjectState(
      id: 3,
      location: 5,
      state: 'GRATE_CLOSED',
    );

    test(
      'combines travel, interactions and meta with priority ordering',
      () async {
        final game = Game(
          loc: 5,
          oldLoc: 5,
          newLoc: 5,
          turns: 0,
          rngSeed: 42,
          objectStates: const {1: carriedKeys, 2: nearbyStone, 3: grateState},
        );

        when(() => travel(game)).thenAnswer(
          (_) async => const [
            ActionOption(
              id: 'travel:5->6:NORTH',
              category: 'travel',
              label: 'motion.north.label',
              verb: 'NORTH',
              objectId: '6',
            ),
            ActionOption(
              id: 'meta:observer',
              category: 'meta',
              label: 'actions.observer.label',
              verb: 'OBSERVER',
            ),
          ],
        );

        when(() => adventureRepository.getGameObjects()).thenAnswer(
          (_) async => const [
            GameObject(id: 0, name: 'OBJ_UNUSED'),
            GameObject(id: 1, name: 'KEYS'),
            GameObject(id: 2, name: 'OBJ_STONE'),
            GameObject(
              id: 3,
              name: 'GRATE',
              states: <String>['GRATE_CLOSED', 'GRATE_OPEN'],
            ),
          ],
        );

        final options = await usecase(game);

        final ids = options.map((option) => option.id).toList();
        expect(ids.toSet(), hasLength(ids.length));

        final categories = options.map((option) => option.category).toList();
        final lastTravelIndex = categories.lastIndexOf('travel');
        final firstInteractionIndex = categories.indexOf('interaction');
        final firstMetaIndex = categories.indexOf('meta');
        expect(lastTravelIndex, isNonNegative);
        expect(firstInteractionIndex, isNonNegative);
        expect(firstMetaIndex, isNonNegative);
        expect(firstInteractionIndex, greaterThan(lastTravelIndex));
        expect(firstMetaIndex, greaterThan(firstInteractionIndex));

        final metaIds = options
            .where((option) => option.category == 'meta')
            .map((option) => option.id)
            .toSet();
        expect(
          metaIds,
          equals(const {'meta:inventory', 'meta:observer', 'meta:map'}),
        );

        final interactionOptions = options
            .where((option) => option.category == 'interaction')
            .toList();
        expect(interactionOptions.length, greaterThanOrEqualTo(4));
        expect(
          interactionOptions.map((option) => option.verb).toSet(),
          containsAll({'EXAMINE', 'DROP', 'TAKE', 'OPEN'}),
        );

        final dropAction = interactionOptions.firstWhere(
          (option) => option.id == 'interaction:drop:1',
        );
        expect(dropAction.objectId, '1');
        final takeAction = interactionOptions.firstWhere(
          (option) => option.id == 'interaction:take:2',
        );
        expect(takeAction.objectId, '2');
        final openAction = interactionOptions.firstWhere(
          (option) => option.id == 'interaction:open:3',
        );
        expect(openAction.objectId, '3');

        final observerCount = options
            .where((option) => option.id == 'meta:observer')
            .length;
        expect(observerCount, 1);
      },
    );

    test('hides open when required key is not carried', () async {
      final game = Game(
        loc: 5,
        oldLoc: 5,
        newLoc: 5,
        turns: 0,
        rngSeed: 42,
        objectStates: const {
          1: GameObjectState(id: 1, location: 8),
          3: grateState,
        },
      );

      when(() => travel(game)).thenAnswer((_) async => const <ActionOption>[]);

      when(() => adventureRepository.getGameObjects()).thenAnswer(
        (_) async => const [
          GameObject(id: 1, name: 'KEYS'),
          GameObject(
            id: 3,
            name: 'GRATE',
            states: <String>['GRATE_CLOSED', 'GRATE_OPEN'],
          ),
        ],
      );

      final options = await usecase(game);

      expect(
        options.where((option) => option.id == 'interaction:open:3'),
        isEmpty,
      );
    });

    test('exposes close when object is open and accessible', () async {
      final game = Game(
        loc: 5,
        oldLoc: 5,
        newLoc: 5,
        turns: 0,
        rngSeed: 42,
        objectStates: const {
          3: GameObjectState(id: 3, location: 5, state: 'GRATE_OPEN'),
        },
      );

      when(() => travel(game)).thenAnswer((_) async => const <ActionOption>[]);

      when(() => adventureRepository.getGameObjects()).thenAnswer(
        (_) async => const [
          GameObject(
            id: 3,
            name: 'GRATE',
            states: <String>['GRATE_CLOSED', 'GRATE_OPEN'],
          ),
        ],
      );

      final options = await usecase(game);

      expect(
        options.where((option) => option.id == 'interaction:open:3'),
        isEmpty,
      );

      final closeOption = options.firstWhere(
        (option) => option.id == 'interaction:close:3',
      );
      expect(closeOption.category, 'interaction');
      expect(closeOption.verb, 'CLOSE');
      expect(closeOption.objectId, '3');
    });

    test(
      'omits interaction lookup when no object states are tracked',
      () async {
        const game = Game(loc: 3, oldLoc: 3, newLoc: 3, turns: 0, rngSeed: 1);

        when(() => travel(game)).thenAnswer(
          (_) async => const [
            ActionOption(
              id: 'travel:3->4:EAST',
              category: 'travel',
              label: 'motion.east.label',
              verb: 'EAST',
              objectId: '4',
            ),
          ],
        );

        final options = await usecase(game);

        expect(
          options.where((option) => option.category == 'interaction'),
          isEmpty,
        );
        expect(options.where((option) => option.category == 'meta').length, 3);

        verifyNever(() => adventureRepository.getGameObjects());
      },
    );
  });
}
