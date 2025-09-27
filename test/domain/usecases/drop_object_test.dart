import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/drop_object.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late DropObject usecase;

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = DropObjectImpl(adventureRepository: repository);
  });

  group('DropObjectImpl', () {
    test('moves object from inventory to current location with success message',
        () async {
      const int objectId = 11;
      const GameObjectState initialState = GameObjectState(
        id: objectId,
        isCarried: true,
      );
      final Game game = Game(
        loc: 42,
        oldLoc: 41,
        newLoc: 42,
        turns: 12,
        rngSeed: 13,
        objectStates: const {objectId: initialState},
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(id: objectId, name: 'OBJ_GEMSTONE'),
        ],
      );

      final TurnResult result = await usecase(objectId.toString(), game);

      expect(result.newGame, isNot(equals(game)));
      final GameObjectState droppedState =
          result.newGame.objectStates[objectId]!;
      expect(droppedState.isCarried, isFalse);
      expect(droppedState.location, game.loc);
      expect(
        result.messages,
        equals(const ['journal.drop.success.OBJ_GEMSTONE']),
      );
      expect(game.objectStates[objectId], equals(initialState));

      verify(repository.getGameObjects).called(1);
    });

    test('returns not carrying message when object is not in inventory',
        () async {
      const int objectId = 4;
      final Game game = Game(
        loc: 2,
        oldLoc: 2,
        newLoc: 2,
        turns: 8,
        rngSeed: 5,
        objectStates: const {
          objectId: GameObjectState(id: objectId, location: 2, isCarried: false),
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const [
          GameObject(id: objectId, name: 'OBJ_KEY'),
        ],
      );

      final TurnResult result = await usecase(objectId.toString(), game);

      expect(result.newGame, same(game));
      expect(
        result.messages,
        equals(const ['journal.drop.notCarrying.OBJ_KEY']),
      );
      final GameObjectState state = result.newGame.objectStates[objectId]!;
      expect(state.isCarried, isFalse);
      expect(state.location, 2);

      verify(repository.getGameObjects).called(1);
    });
  });
}
