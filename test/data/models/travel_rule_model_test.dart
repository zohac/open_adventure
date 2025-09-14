import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/travel_rule_model.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TravelRuleModel.fromJson parses motion/destination and optional condition/dest types', () async {
    final ds = BundleAssetDataSource();
    final list = await ds.loadList(AssetPaths.travelJson);
    expect(list, isNotEmpty);
    final first = Map<String, dynamic>.from(list[1] as Map);
    final r = TravelRuleModel.fromJson(first);
    expect(r.fromId, isA<int>());
    expect(r.motion, isA<String>());
    expect(r.destName, isA<String>());
    // Optional fields may be present or null; parsing should not throw.
    // Ensure toString-able when present.
    if (first.containsKey('condtype')) {
      expect(r.condType, isA<String?>());
    }
    if (first.containsKey('desttype')) {
      expect(r.destType, isA<String?>());
    }

    // Case with missing condition fields.
    final minimal = Map<String, dynamic>.from(first)
      ..remove('condtype')
      ..remove('condarg1')
      ..remove('condarg2')
      ..remove('desttype');
    final r2 = TravelRuleModel.fromJson(minimal);
    expect(r2.condType, isNull);
    expect(r2.destType, isNull);
  });
}

