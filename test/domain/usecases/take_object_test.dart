import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/take_object.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late TakeObject usecase;

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = TakeObjectImpl(adventureRepository: repository);
  });

  group('TakeObjectImpl', () {
    test('moves object from location to inventory with success message', () async {
      const int objectId = 5;
      const GameObjectState initialState = GameObjectState(
        id: objectId,
        location: 7,
      );
      final Game game = Game(
        loc: 7,
        oldLoc: 7,
        newLoc: 7,
        turns: 3,
        rngSeed: 1,
        objectStates: const {objectId: initialState},
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(id: objectId, name: 'OBJ_TREASURE'),
        ],
      );

      final TurnResult result = await usecase(objectId.toString(), game);

      expect(result.newGame, isNot(equals(game)));
      final GameObjectState carriedState =
          result.newGame.objectStates[objectId]!;
      expect(carriedState.isCarried, isTrue);
      expect(carriedState.location, isNull);
      expect(
        result.messages,
        equals(const ['journal.take.success.OBJ_TREASURE']),
      );
      expect(game.objectStates[objectId], equals(initialState));

      verify(repository.getGameObjects).called(1);
    });

    test('fails with immovable message when object is fixed', () async {
      const int objectId = 9;
      final Game game = Game(
        loc: 3,
        oldLoc: 3,
        newLoc: 3,
        turns: 0,
        rngSeed: 99,
        objectStates: const {
          objectId: GameObjectState(id: objectId, location: 3),
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(id: objectId, name: 'OBJ_STATUE', immovable: true),
        ],
      );

      final TurnResult result = await usecase(objectId.toString(), game);

      expect(result.newGame, same(game));
      expect(
        result.messages,
        equals(const ['journal.take.immovable.OBJ_STATUE']),
      );
      final GameObjectState state = result.newGame.objectStates[objectId]!;
      expect(state.isCarried, isFalse);
      expect(state.location, 3);

      verify(repository.getGameObjects).called(1);
    });
  });
}
