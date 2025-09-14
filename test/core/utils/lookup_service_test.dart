import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/error/exceptions.dart';
import 'package:open_adventure/core/utils/lookup_service.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final locations = [
    const Location(id: 0, name: 'LOC_START'),
    const Location(id: 1, name: 'LOC_HILL'),
  ];
  final objects = [
    const GameObject(id: 2, name: 'LAMP'),
    const GameObject(id: 3, name: 'GRATE'),
  ];
  final svc = LookupService(locations: locations, objects: objects);

  group('LookupService', () {
    test('location id/name round-trip', () {
      expect(svc.locationIdFromName('LOC_START'), 0);
      expect(svc.locationNameFromId(1), 'LOC_HILL');
    });

    test('object id/name round-trip', () {
      expect(svc.objectIdFromName('LAMP'), 2);
      expect(svc.objectNameFromId(3), 'GRATE');
    });

    test('throws LookupNotFoundException on unknown location', () {
      expect(() => svc.locationIdFromName('LOC_UNKNOWN'), throwsA(isA<LookupNotFoundException>()));
      expect(() => svc.locationNameFromId(99), throwsA(isA<LookupNotFoundException>()));
    });

    test('throws LookupNotFoundException on unknown object', () {
      expect(() => svc.objectIdFromName('NOPE'), throwsA(isA<LookupNotFoundException>()));
      expect(() => svc.objectNameFromId(99), throwsA(isA<LookupNotFoundException>()));
    });
  });
}

