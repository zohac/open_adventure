import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/location_model.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocationModel.fromEntry maps fields with sequential id', () async {
    final ds = BundleAssetDataSource();
    final raw = await ds.loadList(AssetPaths.locationsJson);
    expect(raw, isNotEmpty);
    final first = raw.first as List<dynamic>;
    final model = LocationModel.fromEntry(first, 0);
    expect(model.id, 0);
    expect(model.name, isA<String>());
  });
}

