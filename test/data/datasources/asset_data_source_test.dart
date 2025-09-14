import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BundleAssetDataSource', () {
    test('loadList loads locations.json as a List', () async {
      final ds = BundleAssetDataSource();
      final list = await ds.loadList(AssetPaths.locationsJson);
      expect(list, isA<List<dynamic>>());
      expect(list.length, greaterThan(0));
      expect(list.first, isA<List<dynamic>>());
    });

    test('loadList loads travel.json as a List', () async {
      final ds = BundleAssetDataSource();
      final list = await ds.loadList(AssetPaths.travelJson);
      expect(list, isA<List<dynamic>>());
      expect(list.length, greaterThan(0));
      expect(list.first, isA<Map<String, dynamic>>());
    });
  });
}

