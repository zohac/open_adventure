import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/examine.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late Examine usecase;

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = ExamineImpl(adventureRepository: repository);
  });

  group('ExamineImpl', () {
    test(
      'returns carried description when the object is in inventory',
      () async {
        const int lampId = 2;
        const GameObjectState lampState = GameObjectState(
          id: lampId,
          isCarried: true,
          state: 'LAMP_BRIGHT',
        );
        final Game game = Game(
          loc: 1,
          oldLoc: 1,
          newLoc: 1,
          turns: 3,
          rngSeed: 42,
          objectStates: const {lampId: lampState},
        );

        when(repository.getGameObjects).thenAnswer(
          (_) async => const [
            GameObject(
              id: lampId,
              name: 'LAMP',
              inventoryDescription: 'Brass lantern',
              states: ['LAMP_DARK', 'LAMP_BRIGHT'],
              stateDescriptions: [
                'There is a shiny brass lamp nearby.',
                'There is a lamp shining nearby.',
              ],
            ),
          ],
        );

        final TurnResult result = await usecase(lampId.toString(), game);

        expect(result.newGame, same(game));
        expect(
          result.messages,
          equals(const [
            'journal.examine.success.LAMP',
            'You are carrying Brass lantern.',
          ]),
        );
        verify(repository.getGameObjects).called(1);
      },
    );

    test(
      'returns contextual description when object is visible on location',
      () async {
        const int grateId = 3;
        const GameObjectState grateState = GameObjectState(
          id: grateId,
          location: 5,
          state: 'GRATE_CLOSED',
        );
        final Game game = Game(
          loc: 5,
          oldLoc: 4,
          newLoc: 5,
          turns: 12,
          rngSeed: 99,
          objectStates: const {grateId: grateState},
        );

        when(repository.getGameObjects).thenAnswer(
          (_) async => const [
            GameObject(
              id: grateId,
              name: 'GRATE',
              states: ['GRATE_CLOSED', 'GRATE_OPEN'],
              stateDescriptions: ['The grate is locked.', 'The grate is open.'],
            ),
          ],
        );

        final TurnResult result = await usecase(grateId.toString(), game);

        expect(result.newGame, same(game));
        expect(
          result.messages,
          equals(const [
            'journal.examine.success.GRATE',
            'The grate is locked.',
          ]),
        );
        verify(repository.getGameObjects).called(1);
      },
    );

    test(
      'falls back to generic text when state descriptions are empty',
      () async {
        const int snakeId = 7;
        const GameObjectState snakeState = GameObjectState(
          id: snakeId,
          location: 8,
          state: 'SNAKE_CHASED',
        );
        final Game game = Game(
          loc: 8,
          oldLoc: 8,
          newLoc: 8,
          turns: 4,
          rngSeed: 64,
          objectStates: const {snakeId: snakeState},
        );

        when(repository.getGameObjects).thenAnswer(
          (_) async => const [
            GameObject(
              id: snakeId,
              name: 'SNAKE',
              inventoryDescription: '*snake',
              states: ['SNAKE_BLOCKS', 'SNAKE_CHASED'],
              stateDescriptions: [
                'A huge green fierce snake bars the way!',
                '',
              ],
            ),
          ],
        );

        final TurnResult result = await usecase(snakeId.toString(), game);

        expect(result.newGame, same(game));
        expect(
          result.messages,
          equals(const [
            'journal.examine.success.SNAKE',
            'You see snake here.',
          ]),
        );
        verify(repository.getGameObjects).called(1);
      },
    );

    test(
      'returns not here when object is neither carried nor colocated',
      () async {
        const int lampId = 2;
        const GameObjectState lampState = GameObjectState(
          id: lampId,
          location: 10,
        );
        final Game game = Game(
          loc: 1,
          oldLoc: 1,
          newLoc: 1,
          turns: 0,
          rngSeed: 1,
          objectStates: const {lampId: lampState},
        );

        when(repository.getGameObjects).thenAnswer(
          (_) async => const [
            GameObject(
              id: lampId,
              name: 'LAMP',
              inventoryDescription: 'Brass lantern',
            ),
          ],
        );

        final TurnResult result = await usecase(lampId.toString(), game);

        expect(result.newGame, same(game));
        expect(result.messages, equals(const ['journal.examine.notHere.LAMP']));
        verify(repository.getGameObjects).called(1);
      },
    );

    test('throws when target identifier is null', () async {
      final Game game = Game(
        loc: 0,
        oldLoc: 0,
        newLoc: 0,
        turns: 0,
        rngSeed: 0,
      );

      expect(() => usecase(null, game), throwsArgumentError);
    });
  });
}
