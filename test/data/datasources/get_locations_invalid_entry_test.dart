import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/core/error/exceptions.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';

class _FakeBundle extends BundleAssetDataSource {
  _FakeBundle();

  @override
  Future<List<dynamic>> loadList(String assetPath) async {
    if (assetPath == AssetPaths.locationsJson) {
      // Invalid entry (not [String, Map])
      return [
        [123, []],
      ];
    }
    return super.loadList(assetPath);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getLocations throws AssetDataFormatException on invalid entry shape', () async {
    final ds = _FakeBundle();
    expect(ds.getLocations, throwsA(isA<AssetDataFormatException>()));
  });
}

