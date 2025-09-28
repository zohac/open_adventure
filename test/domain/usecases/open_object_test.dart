import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/open_object.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late OpenObject usecase;

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = OpenObjectImpl(adventureRepository: repository);
  });

  group('OpenObjectImpl', () {
    test('opens a supported object when requirements are met', () async {
      const int grateId = 3;
      const GameObjectState grateState = GameObjectState(
        id: grateId,
        location: 5,
        state: 'GRATE_CLOSED',
        prop: 0,
      );
      const GameObjectState keysState = GameObjectState(id: 1, isCarried: true);
      final Game game = Game(
        loc: 5,
        oldLoc: 4,
        newLoc: 5,
        turns: 12,
        rngSeed: 99,
        objectStates: const {grateId: grateState, 1: keysState},
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(
            id: grateId,
            name: 'GRATE',
            immovable: true,
            states: ['GRATE_CLOSED', 'GRATE_OPEN'],
            stateDescriptions: ['The grate is locked.', 'The grate is open.'],
          ),
          GameObject(id: 1, name: 'KEYS'),
        ],
      );

      final TurnResult result = await usecase(grateId.toString(), game);

      expect(result.newGame, isNot(equals(game)));
      final GameObjectState updated = result.newGame.objectStates[grateId]!;
      expect(updated.state, 'GRATE_OPEN');
      expect(updated.prop, 1);
      expect(updated.location, 5);
      expect(
        result.messages,
        equals(const ['journal.open.success.GRATE', 'The grate is open.']),
      );
      verify(repository.getGameObjects).called(1);
    });

    test('fails when the required key is missing', () async {
      const int grateId = 3;
      final Game game = Game(
        loc: 5,
        oldLoc: 4,
        newLoc: 5,
        turns: 12,
        rngSeed: 99,
        objectStates: const {
          grateId: GameObjectState(
            id: grateId,
            location: 5,
            state: 'GRATE_CLOSED',
            prop: 0,
          ),
          1: GameObjectState(id: 1, isCarried: false),
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(
            id: grateId,
            name: 'GRATE',
            immovable: true,
            states: ['GRATE_CLOSED', 'GRATE_OPEN'],
            stateDescriptions: ['The grate is locked.', 'The grate is open.'],
          ),
          GameObject(id: 1, name: 'KEYS'),
        ],
      );

      final TurnResult result = await usecase(grateId.toString(), game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const ['journal.open.requiresKey.GRATE']));
      verify(repository.getGameObjects).called(1);
    });

    test('returns already message when state already open', () async {
      const int grateId = 3;
      final Game game = Game(
        loc: 5,
        oldLoc: 4,
        newLoc: 5,
        turns: 12,
        rngSeed: 99,
        objectStates: const {
          grateId: GameObjectState(
            id: grateId,
            location: 5,
            state: 'GRATE_OPEN',
            prop: 1,
          ),
          1: GameObjectState(id: 1, isCarried: true),
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(
            id: grateId,
            name: 'GRATE',
            immovable: true,
            states: ['GRATE_CLOSED', 'GRATE_OPEN'],
            stateDescriptions: ['The grate is locked.', 'The grate is open.'],
          ),
        ],
      );

      final TurnResult result = await usecase(grateId.toString(), game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const ['journal.open.already.GRATE']));
      verify(repository.getGameObjects).called(1);
    });

    test(
      'returns not here when object is neither carried nor colocated',
      () async {
        const int grateId = 3;
        final Game game = Game(
          loc: 99,
          oldLoc: 5,
          newLoc: 99,
          turns: 12,
          rngSeed: 99,
          objectStates: const {
            grateId: GameObjectState(
              id: grateId,
              location: 5,
              state: 'GRATE_CLOSED',
              prop: 0,
            ),
            1: GameObjectState(id: 1, isCarried: true),
          },
        );

        when(repository.getGameObjects).thenAnswer(
          (_) async => const [
            GameObject(
              id: grateId,
              name: 'GRATE',
              immovable: true,
              states: ['GRATE_CLOSED', 'GRATE_OPEN'],
              stateDescriptions: ['The grate is locked.', 'The grate is open.'],
            ),
          ],
        );

        final TurnResult result = await usecase(grateId.toString(), game);

        expect(result.newGame, same(game));
        expect(result.messages, equals(const ['journal.open.notHere.GRATE']));
        verify(repository.getGameObjects).called(1);
      },
    );

    test('returns not openable when object has no open state', () async {
      const int objectId = 99;
      final Game game = Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 0,
        objectStates: const {
          objectId: GameObjectState(id: objectId, location: 1),
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [GameObject(id: objectId, name: 'OBJ_BARREL')],
      );

      final TurnResult result = await usecase(objectId.toString(), game);

      expect(result.newGame, same(game));
      expect(
        result.messages,
        equals(const ['journal.open.notOpenable.OBJ_BARREL']),
      );
      verify(repository.getGameObjects).called(1);
    });
  });
}
