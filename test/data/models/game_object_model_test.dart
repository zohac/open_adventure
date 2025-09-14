import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/models/game_object_model.dart';
import 'package:open_adventure/domain/entities/game_object.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameObjectModel.fromJson normalization', () {
    test('locations string normalizes to list; optional arrays null if empty', () {
      final json = <String, dynamic>{
        'name': 'LAMP',
        'words': ['lamp', 'lante'],
        'inventory': 'Brass lantern',
        'locations': 'LOC_BUILDING',
        'states': <String>[],
        'descriptions': <dynamic>[],
        'sounds': <String>[],
        'changes': <String>[],
        'immovable': false,
        'is_treasure': false,
      };
      final model = GameObjectModel.fromJson(json, 2);
      expect(model.locations, ['LOC_BUILDING']);
      expect(model.states, isNull);
      expect(model.descriptions, isNull);
      expect(model.sounds, isNull);
      expect(model.changes, isNull);
    });

    test('round-trip toEntity/toJson preserves normalized data for complex object', () {
      final json = <String, dynamic>{
        'name': 'GRATE',
        'words': ['grate'],
        'inventory': '*grate',
        'locations': ['LOC_GRATE', 'LOC_BELOWGRATE'],
        'immovable': true,
        'states': ['GRATE_CLOSED', 'GRATE_OPEN'],
        'descriptions': [
          'The grate is locked.',
          'The grate is open.',
        ],
        'changes': [
          'The grate is now locked.',
          'The grate is now unlocked.',
        ],
      };

      final model = GameObjectModel.fromJson(json, 3);
      // toEntity mapping (subset).
      final GameObject entity = model.toEntity();
      expect(entity.id, 3);
      expect(entity.name, 'GRATE');
      expect(entity.words, ['grate']);
      expect(entity.locations, ['LOC_GRATE', 'LOC_BELOWGRATE']);
      expect(entity.immovable, true);

      // toJson mapping (flattened map with normalized locations).
      final back = model.toJson();
      expect(back['name'], 'GRATE');
      expect(back['words'], ['grate']);
      expect(back['inventory'], '*grate');
      expect(back['locations'], ['LOC_GRATE', 'LOC_BELOWGRATE']);
      expect(back['immovable'], true);
      expect(back['states'], ['GRATE_CLOSED', 'GRATE_OPEN']);
      expect(back['descriptions'], isA<List<dynamic>>());
      expect((back['descriptions'] as List).length, 2);
      expect(back['changes'], ['The grate is now locked.', 'The grate is now unlocked.']);
    });
  });
}

