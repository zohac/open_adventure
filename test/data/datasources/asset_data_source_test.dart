import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/core/error/exceptions.dart';

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

    test('loadMap loads metadata.json as a Map', () async {
      final ds = BundleAssetDataSource();
      final map = await ds.loadMap(AssetPaths.metadataJson);
      expect(map, isA<Map<String, dynamic>>());
      expect(map['schema_version'], 1);
    });

    test('loadMap throws AssetDataFormatException when JSON root is a List', () async {
      final ds = BundleAssetDataSource();
      expect(
        () => ds.loadMap(AssetPaths.travelJson),
        throwsA(isA<AssetDataFormatException>()),
      );
    });

    test('loadList throws AssetDataFormatException when JSON root is a Map', () async {
      final ds = BundleAssetDataSource();
      expect(
        () => ds.loadList(AssetPaths.metadataJson),
        throwsA(isA<AssetDataFormatException>()),
      );
    });
  });
}
