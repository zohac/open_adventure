import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/domain/value_objects/command.dart';

void main() {
  group('Command', () {
    test('is immutable and value-equal', () {
      const c1 = Command(verb: 'NORTH', target: 'LOC_HILL');
      const c2 = Command(verb: 'NORTH', target: 'LOC_HILL');
      const c3 = Command(verb: 'SOUTH');

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1 == c3, isFalse);
    });
  });
}

