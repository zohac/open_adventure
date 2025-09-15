import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

void main() {
  group('TurnResult', () {
    test('is immutable and value-equal', () {
      const g1 = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      const g2 = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final r1 = TurnResult(g1, ['hello', 'world']);
      final r2 = TurnResult(g2, ['hello', 'world']);
      final r3 = TurnResult(g2, ['another']);

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1 == r3, isFalse);

      // Ensure list is unmodifiable
      expect(() => r1.messages.add('x'), throwsUnsupportedError);
    });
  });
}

