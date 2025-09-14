import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getLocations flattens entries to Map with name and description', () async {
    final ds = BundleAssetDataSource();
    final items = await ds.getLocations();
    expect(items, isNotEmpty);
    // Check first three samples have the expected basic keys/types.
    final sampleCount = items.length >= 3 ? 3 : items.length;
    for (var i = 0; i < sampleCount; i++) {
      final m = items[i];
      expect(m['name'], isA<String>());
      // description can be null or Map; normalize access defensively.
      final desc = m['description'];
      if (desc != null) {
        expect(desc, isA<Map<String, dynamic>>());
      }
    }
  });
}

