import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/close_object.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late CloseObject usecase;

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = CloseObjectImpl(adventureRepository: repository);
  });

  group('CloseObjectImpl', () {
    test('closes a supported object when currently open', () async {
      const int grateId = 3;
      const GameObjectState grateState = GameObjectState(
        id: grateId,
        location: 5,
        state: 'GRATE_OPEN',
        prop: 1,
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
      expect(updated.state, 'GRATE_CLOSED');
      expect(updated.prop, 0);
      expect(updated.location, 5);
      expect(
        result.messages,
        equals(const ['journal.close.success.GRATE', 'The grate is locked.']),
      );
      verify(repository.getGameObjects).called(1);
    });

    test('returns already message when state already closed', () async {
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
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(
            id: grateId,
            name: 'GRATE',
            immovable: true,
            states: ['GRATE_CLOSED', 'GRATE_OPEN'],
          ),
        ],
      );

      final TurnResult result = await usecase(grateId.toString(), game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const ['journal.close.already.GRATE']));
      verify(repository.getGameObjects).called(1);
    });

    test('returns not closeable when object has no close state', () async {
      const int objectId = 42;
      final Game game = Game(
        loc: 5,
        oldLoc: 5,
        newLoc: 5,
        turns: 0,
        rngSeed: 0,
        objectStates: const {
          objectId: GameObjectState(id: objectId, location: 5),
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(id: objectId, name: 'OBJ', states: ['OBJ_DEFAULT']),
        ],
      );

      final TurnResult result = await usecase(objectId.toString(), game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const ['journal.close.notCloseable.OBJ']));
      verify(repository.getGameObjects).called(1);
    });

    test(
      'returns not here when object is neither carried nor colocated',
      () async {
        const int objectId = 5;
        final Game game = Game(
          loc: 1,
          oldLoc: 5,
          newLoc: 1,
          turns: 1,
          rngSeed: 7,
          objectStates: const {
            objectId: GameObjectState(
              id: objectId,
              location: 2,
              state: 'GRATE_OPEN',
            ),
          },
        );

        when(repository.getGameObjects).thenAnswer(
          (_) async => const [
            GameObject(
              id: objectId,
              name: 'GRATE',
              states: ['GRATE_CLOSED', 'GRATE_OPEN'],
            ),
          ],
        );

        final TurnResult result = await usecase(objectId.toString(), game);

        expect(result.newGame, same(game));
        expect(result.messages, equals(const ['journal.close.notHere.GRATE']));
        verify(repository.getGameObjects).called(1);
      },
    );
  });
}
