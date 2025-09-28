import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/extinguish_lamp.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late ExtinguishLamp usecase;

  const GameObject lampObject = GameObject(
    id: 2,
    name: 'LAMP',
    states: <String>['LAMP_DARK', 'LAMP_BRIGHT'],
    stateDescriptions: <String>[
      'There is a shiny brass lamp nearby.',
      'There is a lamp shining nearby.',
    ],
  );

  setUp(() {
    repository = _MockAdventureRepository();
    usecase = ExtinguishLampImpl(adventureRepository: repository);

    when(repository.getGameObjects).thenAnswer(
      (_) async => const <GameObject>[lampObject],
    );
  });

  group('ExtinguishLampImpl', () {
    test('turns the lamp off when it is lit and accessible', () async {
      const GameObjectState lampState = GameObjectState(
        id: 2,
        location: 5,
        state: 'LAMP_BRIGHT',
        prop: 1,
      );
      final Game game = Game(
        loc: 5,
        oldLoc: 4,
        newLoc: 5,
        turns: 12,
        rngSeed: 99,
        objectStates: const <int, GameObjectState>{2: lampState},
        limit: 120,
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, isNot(equals(game)));
      final GameObjectState updated = result.newGame.objectStates[2]!;
      expect(updated.state, 'LAMP_DARK');
      expect(updated.prop, 0);
      expect(result.newGame.limit, game.limit);
      expect(
        result.messages,
        equals(const <String>['journal.lamp.extinguish.success']),
      );
      verify(repository.getGameObjects).called(1);
    });

    test('returns already message when lamp already dark', () async {
      const GameObjectState lampState = GameObjectState(
        id: 2,
        location: 5,
        state: 'LAMP_DARK',
        prop: 0,
      );
      final Game game = Game(
        loc: 5,
        oldLoc: 4,
        newLoc: 5,
        turns: 12,
        rngSeed: 99,
        objectStates: const <int, GameObjectState>{2: lampState},
        limit: 120,
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, same(game));
      expect(
        result.messages,
        equals(const <String>['journal.lamp.extinguish.already']),
      );
    });

    test('returns not-here message when lamp inaccessible', () async {
      const GameObjectState lampState = GameObjectState(
        id: 2,
        location: 1,
        state: 'LAMP_BRIGHT',
        prop: 1,
      );
      final Game game = Game(
        loc: 5,
        oldLoc: 4,
        newLoc: 5,
        turns: 12,
        rngSeed: 99,
        objectStates: const <int, GameObjectState>{2: lampState},
        limit: 120,
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const <String>['journal.lamp.notHere']));
    });
  });
}
