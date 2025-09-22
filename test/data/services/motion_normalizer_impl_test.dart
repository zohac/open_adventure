import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';

class _FakeAssetDataSource implements AssetDataSource {
  _FakeAssetDataSource(this.motions);

  final List<dynamic> motions;

  @override
  Future<List<dynamic>> loadList(String assetPath) async {
    if (assetPath == AssetPaths.motionsJson) {
      return motions;
    }
    throw UnimplementedError('loadList not implemented for $assetPath');
  }

  @override
  Future<Map<String, dynamic>> loadMap(String assetPath) async {
    throw UnimplementedError('loadMap not required for this test');
  }

  @override
  Future<List<Map<String, dynamic>>> getLocations() async {
    throw UnimplementedError('getLocations not required for this test');
  }
}

void main() {
  group('MotionNormalizerImpl', () {
    late MotionNormalizerImpl normalizer;

    setUp(() async {
      normalizer = await MotionNormalizerImpl.load(
        assets: _FakeAssetDataSource([
          ['WEST', {'words': ['w']}],
          ['NORTH', {'words': ['n']}],
          ['SOUTH', {'words': ['s']}],
          ['EAST', {'words': ['e']}],
          ['NE', {'words': ['ne']}],
          ['NW', {'words': ['nw']}],
          ['SE', {'words': ['se']}],
          ['SW', {'words': ['sw']}],
          ['UP', {'words': ['up']}],
          ['DOWN', {'words': ['down']}],
          ['ENTER', {'words': ['enter']}],
          ['OUT', {'words': ['out']}],
          ['FORWARD', {'words': []}],
          ['BACK', {'words': []}],
        ]),
      );
    });

    test('canonicalises aliases for the main compass directions', () {
      expect(normalizer.toCanonical('west'), equals('WEST'));
      expect(normalizer.toCanonical('w'), equals('WEST'));
      expect(normalizer.toCanonical('N'), equals('NORTH'));
      expect(normalizer.toCanonical('s'), equals('SOUTH'));
      expect(normalizer.toCanonical('e'), equals('EAST'));
    });

    test('canonicalises diagonals and vertical/contextual motions', () {
      expect(normalizer.toCanonical('ne'), equals('NE'));
      expect(normalizer.toCanonical('northeast'), equals('NE'));
      expect(normalizer.toCanonical('north-west'), equals('NW'));
      expect(normalizer.toCanonical('southwest'), equals('SW'));
      expect(normalizer.toCanonical('u'), equals('UP'));
      expect(normalizer.toCanonical('upwards'), equals('UP'));
      expect(normalizer.toCanonical('d'), equals('DOWN'));
      expect(normalizer.toCanonical('downwards'), equals('DOWN'));
      expect(normalizer.toCanonical('inside'), equals('ENTER'));
      expect(normalizer.toCanonical('Outside'), equals('OUT'));
    });

    test('blocks unsupported MOT_* tokens and returns UNKNOWN', () async {
      final blocked = await MotionNormalizerImpl.load(
        assets: _FakeAssetDataSource([
          ['MOT_23', {'words': ['tunnel']}],
        ]),
      );
      expect(blocked.toCanonical('MOT_23'), equals('UNKNOWN'));
    });

    test('provides ui keys and icon names for canonical motions', () {
      expect(normalizer.iconName('NORTH'), equals('arrow_upward'));
      expect(normalizer.iconName('SOUTH'), equals('arrow_downward'));
      expect(normalizer.iconName('EAST'), equals('arrow_forward'));
      expect(normalizer.iconName('WEST'), equals('arrow_back'));
      expect(normalizer.iconName('NE'), equals('north_east'));
      expect(normalizer.iconName('NW'), equals('north_west'));
      expect(normalizer.iconName('SE'), equals('south_east'));
      expect(normalizer.iconName('SW'), equals('south_west'));
      expect(normalizer.iconName('UP'), equals('arrow_upward'));
      expect(normalizer.iconName('DOWN'), equals('arrow_downward'));
      expect(normalizer.iconName('ENTER'), equals('login'));
      expect(normalizer.iconName('OUT'), equals('logout'));

      for (final motion in [
        'NORTH',
        'SOUTH',
        'EAST',
        'WEST',
        'NE',
        'NW',
        'SE',
        'SW',
        'UP',
        'DOWN',
        'ENTER',
        'OUT'
      ]) {
        expect(normalizer.uiKey(motion), 'motion.${motion.toLowerCase()}.label');
      }
    });
  });
}
