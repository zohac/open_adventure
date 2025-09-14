import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart' show ComputeCallback;
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/core/utils/isolate_executor.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';

class _SpyExecutor implements IsolateExecutor {
  int calls = 0;
  @override
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel}) async {
    calls++;
    // Execute synchronously in test isolate.
    return callback(message);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('BundleAssetDataSource uses compute() when forced', () async {
    final spy = _SpyExecutor();
    final ds = BundleAssetDataSource(executor: spy, forceIsolateParsing: true);
    // Trigger list and map decoding to exercise both branches.
    final list = await ds.loadList(AssetPaths.locationsJson);
    expect(list, isNotEmpty);
    final map = await ds.loadMap(AssetPaths.metadataJson);
    expect(map, isA<Map<String, dynamic>>());
    expect(spy.calls, greaterThanOrEqualTo(2));
  });
}
