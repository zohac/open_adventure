import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/inventory.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late InventoryUseCase usecase;

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = InventoryUseCaseImpl(adventureRepository: repository);
  });

  group('InventoryUseCaseImpl', () {
    test('returns empty message when nothing is carried', () async {
      const Game game = Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 42,
        objectStates: <int, GameObjectState>{},
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const ['You are not carrying anything.']));
      verifyNever(() => repository.getGameObjects());
    });

    test('lists carried objects sorted by normalized label', () async {
      const int lampId = 1;
      const int keysId = 2;
      const int goldId = 3;
      const Game game = Game(
        loc: 5,
        oldLoc: 5,
        newLoc: 5,
        turns: 12,
        rngSeed: 87,
        objectStates: <int, GameObjectState>{
          lampId: GameObjectState(id: lampId, isCarried: true),
          keysId: GameObjectState(id: keysId, isCarried: true),
          goldId: GameObjectState(id: goldId, isCarried: true),
        },
      );

      when(repository.getGameObjects).thenAnswer(
        (_) async => const <GameObject>[
          GameObject(
            id: lampId,
            name: 'LAMP',
            inventoryDescription: '*Brass lantern',
          ),
          GameObject(
            id: keysId,
            name: 'KEYS',
            inventoryDescription: 'Set of keys',
          ),
          GameObject(id: goldId, name: 'GOLD', inventoryDescription: null),
        ],
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, same(game));
      expect(
        result.messages,
        equals(const <String>[
          'You are carrying:',
          '• Brass lantern',
          '• Gold',
          '• Set of keys',
        ]),
      );
      verify(() => repository.getGameObjects()).called(1);
    });
  });
}
