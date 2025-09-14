import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/location_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('locations mapping: sequential ids and default values', () async {
    final ds = BundleAssetDataSource();
    final flattened = await ds.getLocations();
    expect(flattened.length, greaterThan(10));

    final models = <LocationModel>[];
    for (var i = 0; i < flattened.length; i++) {
      final m = LocationModel.fromJson(flattened[i], i);
      models.add(m);
      expect(m.id, i, reason: 'id should be sequential and match index');
    }

    // Check defaults on first entry: loud defaults to false when absent
    final first = models.first;
    expect(first.loud, isFalse);
    expect(first.conditions, isA<Map<String, bool>>());
  });
}

