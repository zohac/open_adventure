import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/action_model.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ActionModel.fromEntry parses message/words and defaults oldstyle=false', () async {
    final ds = BundleAssetDataSource();
    final list = await ds.loadList(AssetPaths.actionsJson);
    expect(list, isNotEmpty);

    final first = list.first as List<dynamic>; // [ 'ACT_NULL', { message:null, words:null } ]
    final a0 = ActionModel.fromEntry(first);
    expect(a0.name, isA<String>());
    expect(a0.message, isNull);
    expect(a0.words, isNull);
    expect(a0.oldstyle, isFalse);

    final second = list[1] as List<dynamic>; // 'CARRY'
    final a1 = ActionModel.fromEntry(second);
    expect(a1.name, 'CARRY');
    expect(a1.words, isNotNull);
    expect(a1.words!.length, greaterThan(0));
  });
}

