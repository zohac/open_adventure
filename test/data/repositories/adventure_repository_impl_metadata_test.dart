import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';

class _MockAssets extends Mock implements AssetDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initialGame metadata fallback', () {
    test(
      'falls back to first location when metadata has invalid keys',
      () async {
        final assets = _MockAssets();
        when(() => assets.getLocations()).thenAnswer(
          (_) async => [
            {'name': 'LOC_START', 'description': {}},
            {'name': 'LOC_HILL', 'description': {}},
          ],
        );
        when(
          () => assets.loadMap(any()),
        ).thenAnswer((_) async => {'invalid': true});
        when(() => assets.loadList(AssetPaths.objectsJson)).thenAnswer(
          (_) async => [
            ['NO_OBJECT', <String, dynamic>{}],
          ],
        );
        final repo = AdventureRepositoryImpl(assets: assets);

        final game = await repo.initialGame();
        expect(game.loc, 0);
      },
    );

    test('falls back to first location when metadata load throws', () async {
      final assets = _MockAssets();
      when(() => assets.getLocations()).thenAnswer(
        (_) async => [
          {'name': 'LOC_START', 'description': {}},
          {'name': 'LOC_HILL', 'description': {}},
        ],
      );
      when(() => assets.loadMap(any())).thenThrow(Exception('missing'));
      when(() => assets.loadList(AssetPaths.objectsJson)).thenAnswer(
        (_) async => [
          ['NO_OBJECT', <String, dynamic>{}],
        ],
      );
      final repo = AdventureRepositoryImpl(assets: assets);

      final game = await repo.initialGame();
      expect(game.loc, 0);
    });
  });
}
