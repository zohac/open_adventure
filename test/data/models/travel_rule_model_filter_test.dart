import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/travel_rule_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('filters travel rules by from_index and maps cond/dest keys', () async {
    final ds = BundleAssetDataSource();
    final list = await ds.loadList(AssetPaths.travelJson);
    // Choose a known from_index present early in the file (e.g., 1).
    final filtered = list
        .map((e) => TravelRuleModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((r) => r.fromId == 1)
        .toList();
    expect(filtered, isNotEmpty);
    // Ensure at least one has non-null cond/dest types when present in JSON.
    final withTypes = filtered.where((r) => r.condType != null || r.destType != null).toList();
    expect(withTypes, isNotEmpty);
  });
}

