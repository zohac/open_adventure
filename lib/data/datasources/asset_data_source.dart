import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle; 

/// Abstraction over asset loading to facilitate testing.
abstract class AssetDataSource {
  /// Loads a JSON list from the given asset path.
  Future<List<dynamic>> loadList(String assetPath);

  /// Loads a JSON map from the given asset path.
  Future<Map<String, dynamic>> loadMap(String assetPath);
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
    if (decoded is! List<dynamic>) {
      throw const FormatException('Expected a JSON List');
    }
    return decoded;
  }

  @override
  Future<Map<String, dynamic>> loadMap(String assetPath) async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = json.decode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON Map');
    }
    return decoded;
  }
}

// In tests, prefer to use `BundleAssetDataSource()` with `flutter_test`, as
// assets listed in `pubspec.yaml` are available to the rootBundle.
