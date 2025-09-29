import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/drink_liquid.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late DrinkLiquid usecase;

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = DrinkLiquidImpl(adventureRepository: repository);
  });

  group('DrinkLiquidImpl', () {
    const GameObject bottle = GameObject(
      id: 5,
      name: 'BOTTLE',
      states: <String>[
        'WATER_BOTTLE',
        'EMPTY_BOTTLE',
        'OIL_BOTTLE',
      ],
    );

    test('empties the bottle when water is available and accessible', () async {
      const GameObjectState bottleState = GameObjectState(
        id: 5,
        isCarried: true,
        state: 'WATER_BOTTLE',
        prop: 0,
      );
      final Game game = Game(
        loc: 3,
        oldLoc: 3,
        newLoc: 3,
        turns: 4,
        rngSeed: 1,
        objectStates: const {5: bottleState},
      );

      when(repository.getGameObjects).thenAnswer((_) async => const [bottle]);

      final TurnResult result = await usecase('5', game);

      expect(result.messages, equals(const ['journal.drink.success.BOTTLE']));
      final GameObjectState updated = result.newGame.objectStates[5]!;
      expect(updated.state, 'EMPTY_BOTTLE');
      expect(updated.prop, 1);
      expect(updated.isCarried, isTrue);
      verify(repository.getGameObjects).called(1);
    });

    test('returns not-here when bottle is not accessible', () async {
      const GameObjectState bottleState = GameObjectState(
        id: 5,
        location: 7,
        state: 'WATER_BOTTLE',
        prop: 0,
      );
      final Game game = Game(
        loc: 3,
        oldLoc: 3,
        newLoc: 3,
        turns: 4,
        rngSeed: 1,
        objectStates: const {5: bottleState},
      );

      when(repository.getGameObjects).thenAnswer((_) async => const [bottle]);

      final TurnResult result = await usecase('5', game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const ['journal.drink.notHere.BOTTLE']));
    });

    test('returns empty message when bottle does not contain water', () async {
      const GameObjectState bottleState = GameObjectState(
        id: 5,
        isCarried: true,
        state: 'EMPTY_BOTTLE',
        prop: 1,
      );
      final Game game = Game(
        loc: 3,
        oldLoc: 3,
        newLoc: 3,
        turns: 4,
        rngSeed: 1,
        objectStates: const {5: bottleState},
      );

      when(repository.getGameObjects).thenAnswer((_) async => const [bottle]);

      final TurnResult result = await usecase('5', game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const ['journal.drink.empty.BOTTLE']));
    });
  });
}
