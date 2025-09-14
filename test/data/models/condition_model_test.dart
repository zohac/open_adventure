import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/condition_model.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ConditionModel.fromJson parses location and conditions; handles missing conditions', () async {
    final ds = BundleAssetDataSource();
    final list = await ds.loadList(AssetPaths.conditionsJson);
    expect(list, isNotEmpty);
    final m = Map<String, dynamic>.from(list.first as Map);
    final c0 = ConditionModel.fromJson(m);
    expect(c0.location, isA<String>());
    expect(c0.conditions, isA<List<String>>());

    // Remove conditions field to simulate missing key.
    final m2 = Map<String, dynamic>.from(m)..remove('conditions');
    final c1 = ConditionModel.fromJson(m2);
    expect(c1.conditions, isEmpty);
  });
}

