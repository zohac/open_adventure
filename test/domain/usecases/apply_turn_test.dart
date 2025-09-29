import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/entities/travel_rule.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/close_object.dart';
import 'package:open_adventure/domain/usecases/drop_object.dart';
import 'package:open_adventure/domain/usecases/examine.dart';
import 'package:open_adventure/domain/usecases/extinguish_lamp.dart';
import 'package:open_adventure/domain/usecases/drink_liquid.dart';
import 'package:open_adventure/domain/usecases/light_lamp.dart';
import 'package:open_adventure/domain/usecases/open_object.dart';
import 'package:open_adventure/domain/usecases/take_object.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/command.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockApplyTurnGoto extends Mock implements ApplyTurnGoto {}

class _FakeAdventureRepository implements AdventureRepository {
  _FakeAdventureRepository({this.objects = const <GameObject>[]});

  final List<GameObject> objects;

  @override
  Future<Game> initialGame() async =>
      throw UnimplementedError('initialGame not required for tests');

  @override
  Future<List<Location>> getLocations() async =>
      throw UnimplementedError('getLocations not required for tests');

  @override
  Future<List<GameObject>> getGameObjects() async => objects;

  @override
  Future<Location> locationById(int id) async =>
      throw UnimplementedError('locationById not required for tests');

  @override
  Future<List<TravelRule>> travelRulesFor(int locationId) async =>
      throw UnimplementedError('travelRulesFor not required for tests');

  @override
  Future<String> arbitraryMessage(String key, {int? count}) async =>
      throw UnimplementedError('arbitraryMessage not required for tests');
}

ApplyTurn _createApplyTurn({
  required AdventureRepository repository,
  required ApplyTurnGoto travel,
}) {
  return ApplyTurn(
    travel: travel,
    examine: ExamineImpl(adventureRepository: repository),
    takeObject: TakeObjectImpl(adventureRepository: repository),
    dropObject: DropObjectImpl(adventureRepository: repository),
    openObject: OpenObjectImpl(adventureRepository: repository),
    closeObject: CloseObjectImpl(adventureRepository: repository),
    lightLamp: LightLampImpl(adventureRepository: repository),
    extinguishLamp: ExtinguishLampImpl(adventureRepository: repository),
    drinkLiquid: DrinkLiquidImpl(adventureRepository: repository),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const Command(verb: 'WEST', target: '2'));
    registerFallbackValue(
      const Game(loc: 0, oldLoc: 0, newLoc: 0, turns: 0, rngSeed: 0),
    );
  });

  group('ApplyTurn', () {
    test('routes travel actions to ApplyTurnGoto', () async {
      final travel = _MockApplyTurnGoto();
      final repository = _FakeAdventureRepository();
      final applyTurn = _createApplyTurn(
        repository: repository,
        travel: travel,
      );
      const ActionOption action = ActionOption(
        id: 'travel:1->2:WEST',
        category: 'travel',
        label: 'motion.west.label',
        verb: 'WEST',
        objectId: '2',
      );
      const Game game = Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 7,
      );
      final TurnResult expected = TurnResult(game, const <String>[
        'You move west.',
      ]);

      when(() => travel(any(), any())).thenAnswer((_) async => expected);

      final TurnResult result = await applyTurn(action, game);

      expect(result, same(expected));
      verify(
        () => travel(const Command(verb: 'WEST', target: '2'), game),
      ).called(1);
    });

    test('delegates TAKE interaction to TakeObject', () async {
      final repository = _FakeAdventureRepository(
        objects: const <GameObject>[GameObject(id: 5, name: 'OBJ_KEYS')],
      );
      final travel = _MockApplyTurnGoto();
      final applyTurn = _createApplyTurn(
        repository: repository,
        travel: travel,
      );
      const ActionOption action = ActionOption(
        id: 'interaction:take:5',
        category: 'interaction',
        label: 'actions.interaction.take.OBJ_KEYS',
        verb: 'TAKE',
        objectId: '5',
      );
      const Game game = Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 99,
        objectStates: {5: GameObjectState(id: 5, location: 1)},
      );

      final TurnResult result = await applyTurn(action, game);

      final GameObjectState state = result.newGame.objectStates[5]!;
      expect(state.isCarried, isTrue);
      expect(state.location, isNull);
      expect(result.messages, equals(const ['journal.take.success.OBJ_KEYS']));
      verifyZeroInteractions(travel);
    });

    test('delegates LIGHT interaction to LightLamp', () async {
      final repository = _FakeAdventureRepository(
        objects: const <GameObject>[
          GameObject(
            id: 7,
            name: 'LAMP',
            states: <String>['LAMP_DARK', 'LAMP_BRIGHT'],
            stateDescriptions: <String>['It is dark.', 'It is shining.'],
          ),
        ],
      );
      final travel = _MockApplyTurnGoto();
      final applyTurn = _createApplyTurn(
        repository: repository,
        travel: travel,
      );
      const ActionOption action = ActionOption(
        id: 'interaction:light:7',
        category: 'interaction',
        label: 'actions.interaction.light.LAMP',
        verb: 'LIGHT',
        objectId: '7',
      );
      const Game game = Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 12,
        rngSeed: 13,
        limit: 40,
        objectStates: {
          7: GameObjectState(id: 7, location: 1, state: 'LAMP_DARK', prop: 0),
        },
      );

      final TurnResult result = await applyTurn(action, game);

      final GameObjectState state = result.newGame.objectStates[7]!;
      expect(state.state, equals('LAMP_BRIGHT'));
      expect(state.prop, equals(1));
      expect(result.messages, contains('journal.lamp.success'));
      verifyZeroInteractions(travel);
    });

    test('delegates DRINK interaction to DrinkLiquid', () async {
      final repository = _FakeAdventureRepository(
        objects: const <GameObject>[
          GameObject(
            id: 5,
            name: 'BOTTLE',
            states: <String>[
              'WATER_BOTTLE',
              'EMPTY_BOTTLE',
            ],
          ),
        ],
      );
      final travel = _MockApplyTurnGoto();
      final applyTurn = _createApplyTurn(
        repository: repository,
        travel: travel,
      );
      const ActionOption action = ActionOption(
        id: 'interaction:drink:5',
        category: 'interaction',
        label: 'actions.interaction.drink.BOTTLE',
        verb: 'DRINK',
        objectId: '5',
      );
      const Game game = Game(
        loc: 2,
        oldLoc: 2,
        newLoc: 2,
        turns: 5,
        rngSeed: 77,
        objectStates: {
          5: GameObjectState(
            id: 5,
            isCarried: true,
            state: 'WATER_BOTTLE',
            prop: 0,
          ),
        },
      );

      final TurnResult result = await applyTurn(action, game);

      final GameObjectState updated = result.newGame.objectStates[5]!;
      expect(updated.state, 'EMPTY_BOTTLE');
      expect(result.messages, equals(const ['journal.drink.success.BOTTLE']));
      verifyZeroInteractions(travel);
    });
  });
}
