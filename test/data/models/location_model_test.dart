import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/location_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocationModel.fromJson maps fields with sequential id', () async {
    final ds = BundleAssetDataSource();
    final flattened = await ds.getLocations();
    expect(flattened, isNotEmpty);
    final model = LocationModel.fromJson(flattened.first, 0);
    expect(model.id, 0);
    expect(model.name, isA<String>());
  });
}
