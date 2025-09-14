import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/core/error/exceptions.dart';
import 'package:open_adventure/core/error/failures.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';

class _MockAssets extends Mock implements AssetDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getLocations throws DataFailure on malformed asset', () async {
    final assets = _MockAssets();
    when(() => assets.getLocations()).thenThrow(const AssetDataFormatException('bad', assetPath: 'assets/data/locations.json'));
    final repo = AdventureRepositoryImpl(assets: assets);
    expect(repo.getLocations, throwsA(isA<DataFailure>()));
  });

  test('getGameObjects throws DataFailure on malformed asset', () async {
    final assets = _MockAssets();
    when(() => assets.loadList(any())).thenThrow(const AssetDataFormatException('bad', assetPath: 'assets/data/objects.json'));
    final repo = AdventureRepositoryImpl(assets: assets);
    expect(repo.getGameObjects, throwsA(isA<DataFailure>()));
  });
}

