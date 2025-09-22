import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';

/// Implementation of [MotionCanonicalizer] backed by `assets/data/motions.json`.
class MotionNormalizerImpl implements MotionCanonicalizer {
  MotionNormalizerImpl._(this._tokenToCanonical);

  final Map<String, String> _tokenToCanonical;

  /// Loads the motion vocabulary from assets and returns a ready-to-use normalizer.
  static Future<MotionNormalizerImpl> load({AssetDataSource? assets}) async {
    final dataSource = assets ?? BundleAssetDataSource();
    final raw = await dataSource.loadList(AssetPaths.motionsJson);
    final tokenToCanonical = <String, String>{};

    for (final entry in raw) {
      if (entry is List && entry.length == 2) {
        final canonical = entry.first.toString().toUpperCase();
        tokenToCanonical[canonical] = canonical;
        final payload = entry.last;
        if (payload is Map) {
          final words = payload['words'];
          if (words is List) {
            for (final word in words) {
              if (word == null) continue;
              final token = word.toString().toUpperCase();
              tokenToCanonical[token] = canonical;
            }
          }
        }
      }
    }

    return MotionNormalizerImpl._(tokenToCanonical);
  }

  static const Map<String, String> _renames = {
    'INSIDE': 'ENTER',
    'IN': 'ENTER',
    'INWARD': 'ENTER',
    'ENTER': 'ENTER',
    'OUTSIDE': 'OUT',
    'OUT': 'OUT',
    'OUTSI': 'OUT',
    'U': 'UP',
    'UPWARD': 'UP',
    'UPWARDS': 'UP',
    'D': 'DOWN',
    'DOWNWARD': 'DOWN',
    'DOWNWARDS': 'DOWN',
    'N': 'NORTH',
    'S': 'SOUTH',
    'E': 'EAST',
    'W': 'WEST',
    'NORTHEAST': 'NE',
    'NORTH-EAST': 'NE',
    'NORTHWEST': 'NW',
    'NORTH-WEST': 'NW',
    'SOUTHEAST': 'SE',
    'SOUTH-EAST': 'SE',
    'SOUTHWEST': 'SW',
    'SOUTH-WEST': 'SW',
  };

  static const Set<String> _blockedCanonicals = {'MOT_0', 'HERE', 'NUL'};

  @override
  String toCanonical(String raw) {
    final token = raw.trim().toUpperCase();
    if (token.isEmpty) return '';
    final canonical = _tokenToCanonical[token] ?? token;
    return _normalizeCanonical(canonical);
  }

  @override
  String uiKey(String canonical) => 'motion.${canonical.toLowerCase()}.label';

  @override
  String iconName(String canonical) {
    switch (canonical) {
      case 'NORTH':
        return 'arrow_upward';
      case 'SOUTH':
        return 'arrow_downward';
      case 'EAST':
        return 'arrow_forward';
      case 'WEST':
        return 'arrow_back';
      case 'UP':
        return 'arrow_upward';
      case 'DOWN':
        return 'arrow_downward';
      case 'ENTER':
        return 'login';
      case 'IN':
        return 'login';
      case 'OUT':
        return 'logout';
      case 'BACK':
        return 'undo';
      case 'FORWARD':
        return 'redo';
      case 'NE':
        return 'north_east';
      case 'NW':
        return 'north_west';
      case 'SE':
        return 'south_east';
      case 'SW':
        return 'south_west';
      default:
        return 'directions_walk';
    }
  }

  @override
  int priority(String canonical) {
    const contextual = {'ENTER', 'IN', 'OUT', 'UP', 'DOWN'};
    const cardinal = {'NORTH', 'EAST', 'SOUTH', 'WEST', 'NE', 'NW', 'SE', 'SW'};
    if (contextual.contains(canonical)) return 0;
    if (cardinal.contains(canonical)) return 1;
    return 2;
  }

  String _normalizeCanonical(String canonicalRaw) {
    final upper = canonicalRaw.toUpperCase();
    if (_blockedCanonicals.contains(upper)) {
      return 'UNKNOWN';
    }
    if (upper.startsWith('MOT_')) {
      return 'UNKNOWN';
    }
    final renamed = _renames[upper];
    if (renamed != null) {
      return renamed;
    }
    return upper;
  }
}
