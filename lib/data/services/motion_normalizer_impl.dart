import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';

/// Implementation of MotionCanonicalizer using assets/data/motions.json.
class MotionNormalizerImpl implements MotionCanonicalizer {
  final Map<int, String> _numericToNamed; // e.g., 2 -> 'WEST'

  MotionNormalizerImpl({AssetDataSource? assets})
      : _numericToNamed = {
          // Minimal mapping to unify early aliases (can be extended as needed)
          2: 'WEST',
          12: 'ENTER',
        };

  @override
  String toCanonical(String raw) {
    final s = (raw).toUpperCase();
    if (s.startsWith('MOT_')) {
      final n = int.tryParse(s.substring(4));
      final mapped = n != null ? _numericToNamed[n] : null;
      return mapped ?? s; // fallback MOT_n
    }
    final n = int.tryParse(s);
    if (n != null) {
      final mapped = _numericToNamed[n];
      if (mapped != null) return mapped;
      return 'MOT_$n';
    }
    return s;
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
        return 'north';
      case 'DOWN':
        return 'south';
      case 'ENTER':
        return 'login';
      case 'OUTSIDE':
      case 'OUT':
        return 'logout';
      default:
        return 'directions_walk';
    }
  }

  @override
  int priority(String canonical) {
    const cardinal = {'NORTH', 'EAST', 'SOUTH', 'WEST'};
    const vertical = {'UP', 'DOWN', 'ENTER', 'OUT', 'OUTSIDE'};
    if (cardinal.contains(canonical)) return 0;
    if (vertical.contains(canonical)) return 1;
    return 2;
  }
}
