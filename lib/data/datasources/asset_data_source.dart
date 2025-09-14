import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle; 
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/core/error/exceptions.dart';
import 'package:open_adventure/core/utils/json_validator.dart';

/// Abstraction over asset loading to facilitate testing.
abstract class AssetDataSource {
  /// Loads a JSON list from the given asset path.
  Future<List<dynamic>> loadList(String assetPath);

  /// Loads a JSON map from the given asset path.
  Future<Map<String, dynamic>> loadMap(String assetPath);

  /// Loads and flattens locations from assets/data/locations.json into a list
  /// of maps shaped as `{ 'name': String, ...data }`.
  Future<List<Map<String, dynamic>>> getLocations();
}

/// Default implementation using Flutter's [rootBundle].
class BundleAssetDataSource implements AssetDataSource {
  final AssetBundle _bundle;

  /// Creates a data source backed by the provided [bundle] (defaults to [rootBundle]).
  BundleAssetDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  @override
  Future<List<dynamic>> loadList(String assetPath) async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = json.decode(raw);
    // Dedicated type validation + consistent exception for tests/callers.
    return JsonValidator.requireList(decoded, assetPath: assetPath);
  }

  @override
  Future<Map<String, dynamic>> loadMap(String assetPath) async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = json.decode(raw);
    return JsonValidator.requireMap(decoded, assetPath: assetPath);
  }

  @override
  Future<List<Map<String, dynamic>>> getLocations() async {
    final list = await loadList(AssetPaths.locationsJson);
    final flattened = <Map<String, dynamic>>[];
    for (final entry in list) {
      if (entry is List && entry.length == 2) {
        final name = entry[0];
        final data = entry[1];
        if (name is String && data is Map) {
          flattened.add(<String, dynamic>{'name': name, ...Map<String, dynamic>.from(data)});
          continue;
        }
      }
      throw const AssetDataFormatException(
        'Invalid locations entry: expected [String, Map] pair',
        assetPath: AssetPaths.locationsJson,
      );
    }
    return flattened;
  }
}

// In tests, prefer to use `BundleAssetDataSource()` with `flutter_test`, as
// assets listed in `pubspec.yaml` are available to the rootBundle.
