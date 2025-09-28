import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/light_lamp.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdventureRepository repository;
  late LightLamp usecase;

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
    usecase = LightLampImpl(adventureRepository: repository);

    when(repository.getGameObjects).thenAnswer(
      (_) async => const <GameObject>[lampObject],
    );
  });

  group('LightLampImpl', () {
    test('turns the lamp on when battery is available', () async {
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

      expect(result.newGame, isNot(equals(game)));
      final GameObjectState updated = result.newGame.objectStates[2]!;
      expect(updated.state, 'LAMP_BRIGHT');
      expect(updated.prop, 1);
      expect(result.messages, equals(const <String>['journal.lamp.success']));
      expect(result.newGame.lampWarningIssued, isFalse);
      verify(repository.getGameObjects).called(1);
    });

    test('adds warning when lamp limit crosses threshold', () async {
      const GameObjectState lampState = GameObjectState(
        id: 2,
        isCarried: true,
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
        limit: 10,
      );

      final TurnResult result = await usecase(game);

      expect(result.messages, equals(const <String>[
        'journal.lamp.success',
        'journal.lamp.warning',
      ]));
      expect(result.newGame.lampWarningIssued, isTrue);
    });

    test('does not repeat warning if already issued', () async {
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
        limit: 5,
        lampWarningIssued: true,
      );

      final TurnResult result = await usecase(game);

      expect(result.messages, equals(const <String>['journal.lamp.success']));
      expect(result.newGame.lampWarningIssued, isTrue);
    });

    test('fails when battery is depleted', () async {
      const GameObjectState lampState = GameObjectState(
        id: 2,
        isCarried: true,
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
        limit: 0,
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const <String>['journal.lamp.empty']));
    });

    test('returns already message when lamp already lit', () async {
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
        limit: 100,
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const <String>['journal.lamp.already']));
    });

    test('returns not-here message when lamp inaccessible', () async {
      const GameObjectState lampState = GameObjectState(
        id: 2,
        location: 1,
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
        limit: 100,
      );

      final TurnResult result = await usecase(game);

      expect(result.newGame, same(game));
      expect(result.messages, equals(const <String>['journal.lamp.notHere']));
    });
  });
}
