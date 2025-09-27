import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/usecases/evaluate_condition.dart';
import 'package:open_adventure/domain/value_objects/condition.dart';

void main() {
  group('EvaluateConditionImpl', () {
    const evaluator = EvaluateConditionImpl();

    final baseGame = Game(
      loc: 5,
      oldLoc: 4,
      newLoc: 5,
      turns: 10,
      rngSeed: 99,
      visitedLocations: {4, 5},
      magicWordsUnlocked: true,
      objectStates: const {
        1: GameObjectState(
          id: 1,
          isCarried: true,
          state: 'LAMP_BRIGHT',
          prop: 1,
        ),
        2: GameObjectState(id: 2, location: 5, state: 'GRATE_OPEN', prop: 7),
        3: GameObjectState(
          id: 3,
          fixedLocation: 5,
          state: 'STATUE_IDLE',
          prop: 3,
        ),
        4: GameObjectState(
          id: 4,
          location: 42,
          state: 'CHEST_LOCKED',
          prop: 99,
        ),
      },
      flags: const {'HAS_LAMP', 'SEEN_WARNING'},
    );

    test('carry returns true only for carried objects', () {
      expect(evaluator(const Condition.carry(objectId: 1), baseGame), isTrue);
      expect(evaluator(const Condition.carry(objectId: 2), baseGame), isFalse);
      expect(evaluator(const Condition.carry(objectId: 99), baseGame), isFalse);
    });

    test('with matches carried, colocated and fixed-location objects', () {
      expect(
        evaluator(const Condition.withObject(objectId: 1), baseGame),
        isTrue,
      );
      expect(
        evaluator(const Condition.withObject(objectId: 2), baseGame),
        isTrue,
      );
      expect(
        evaluator(const Condition.withObject(objectId: 3), baseGame),
        isTrue,
      );
      expect(
        evaluator(const Condition.withObject(objectId: 4), baseGame),
        isFalse,
      );
    });

    test('not negates the nested condition result', () {
      final openState = const Condition.state(objectId: 2, value: 'GRATE_OPEN');
      final closedState = const Condition.state(
        objectId: 2,
        value: 'GRATE_CLOSED',
      );

      expect(evaluator(Condition.not(openState), baseGame), isFalse);
      expect(evaluator(Condition.not(closedState), baseGame), isTrue);
      expect(evaluator(const Condition.not(null), baseGame), isTrue);
    });

    test('at validates the current location id', () {
      expect(evaluator(const Condition.at(locationId: 5), baseGame), isTrue);
      expect(evaluator(const Condition.at(locationId: 6), baseGame), isFalse);
    });

    test('state compares the logical state of an object', () {
      expect(
        evaluator(
          const Condition.state(objectId: 2, value: 'GRATE_OPEN'),
          baseGame,
        ),
        isTrue,
      );
      expect(
        evaluator(
          const Condition.state(objectId: 2, value: 'GRATE_CLOSED'),
          baseGame,
        ),
        isFalse,
      );
      expect(
        evaluator(
          const Condition.state(objectId: 77, value: 'UNKNOWN'),
          baseGame,
        ),
        isFalse,
      );
    });

    test('prop compares the numeric property of an object', () {
      expect(
        evaluator(const Condition.prop(objectId: 2, value: 7), baseGame),
        isTrue,
      );
      expect(
        evaluator(const Condition.prop(objectId: 2, value: 42), baseGame),
        isFalse,
      );
      expect(
        evaluator(const Condition.prop(objectId: 99, value: 1), baseGame),
        isFalse,
      );
    });

    test('have checks boolean flags on the game state', () {
      expect(
        evaluator(const Condition.have(flagKey: 'HAS_LAMP'), baseGame),
        isTrue,
      );
      expect(
        evaluator(const Condition.have(flagKey: 'UNKNOWN_FLAG'), baseGame),
        isFalse,
      );
      expect(evaluator(const Condition.have(flagKey: ''), baseGame), isFalse);
    });
  });
}
