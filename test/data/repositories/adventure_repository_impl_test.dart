import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdventureRepositoryImpl', () {
    test('getLocations returns non-empty list with sequential ids', () async {
      final repo = AdventureRepositoryImpl();
      final locs = await repo.getLocations();
      expect(locs, isNotEmpty);
      expect(locs.first.id, 0);
      expect(locs[0].name, isA<String>());
    });

    test('travelRulesFor returns at least one rule for LOC_START (id 1)', () async {
      final repo = AdventureRepositoryImpl();
      final rules = await repo.travelRulesFor(1);
      expect(rules, isNotEmpty);
    });

    test('getGameObjects returns non-empty list', () async {
      final repo = AdventureRepositoryImpl();
      final objs = await repo.getGameObjects();
      expect(objs, isNotEmpty);
      expect(objs.first.id, 0);
      expect(objs.first.name, isA<String>());
    });

    test('locationById returns the same as indexing into getLocations', () async {
      final repo = AdventureRepositoryImpl();
      final locs = await repo.getLocations();
      final loc3 = await repo.locationById(3);
      expect(loc3.name, locs[3].name);
      expect(loc3.id, 3);
    });
  });
}
