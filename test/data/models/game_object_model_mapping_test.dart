import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/game_object_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('objects mapping: normalization and flags', () async {
    final ds = BundleAssetDataSource();
    final raw = await ds.loadList(AssetPaths.objectsJson);
    expect(raw, isNotEmpty);

    // Build a few models and verify normalization by known keys.
    final models = <GameObjectModel>[];
    for (var i = 0; i < raw.length && i < 8; i++) {
      models.add(GameObjectModel.fromEntry(raw[i] as List, i));
    }

    // Find KEYS entry
    final keys = models.firstWhere((m) => m.name == 'KEYS', orElse: () => models.first);
    expect(keys.locations.length, 1);
    expect(keys.states, isNull);

    // LAMP has states and changes
    final lamp = models.firstWhere((m) => m.name == 'LAMP', orElse: () => models.first);
    expect(lamp.states, isNotNull);
    expect(lamp.states!.length, greaterThanOrEqualTo(2));
    expect(lamp.changes, isNotNull);

    // GRATE is immovable and has multiple locations
    final grate = models.firstWhere((m) => m.name == 'GRATE', orElse: () => models.first);
    expect(grate.immovable, isTrue);
    expect(grate.locations.length, greaterThanOrEqualTo(2));
  });
}

