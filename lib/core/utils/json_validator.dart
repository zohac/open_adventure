import 'package:open_adventure/core/error/exceptions.dart';

/// Helper utilities to validate decoded JSON structures.
class JsonValidator {
  /// Ensures [decoded] is a JSON List and returns it, otherwise throws
  /// [AssetDataFormatException] with a clear message.
  static List<dynamic> requireList(
    dynamic decoded, {
    String? assetPath,
  }) {
    if (decoded is List<dynamic>) return decoded;
    throw AssetDataFormatException(
      'Expected JSON root to be a List',
      assetPath: assetPath,
      expectedType: 'List',
    );
  }

  /// Ensures [decoded] is a JSON `Map<String, dynamic>` and returns it, otherwise
  /// throws [AssetDataFormatException] with a clear message.
  static Map<String, dynamic> requireMap(
    dynamic decoded, {
    String? assetPath,
  }) {
    if (decoded is Map<String, dynamic>) return decoded;
    throw AssetDataFormatException(
      'Expected JSON root to be a Map',
      assetPath: assetPath,
      expectedType: 'Map',
    );
  }

  /// Validates presence of [requiredKeys] in [map]. Throws
  /// [AssetDataFormatException] if any is missing.
  static void requireKeys(
    Map<String, dynamic> map,
    List<String> requiredKeys, {
    String? assetPath,
  }) {
    final missing = <String>[];
    for (final k in requiredKeys) {
      if (!map.containsKey(k)) missing.add(k);
    }
    if (missing.isNotEmpty) {
      throw AssetDataFormatException(
        'Missing required keys: ${missing.join(', ')}',
        assetPath: assetPath,
      );
    }
  }
}
