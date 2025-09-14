import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle; 
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/core/error/exceptions.dart';
import 'package:open_adventure/core/utils/json_validator.dart';
import 'package:open_adventure/core/utils/isolate_executor.dart';
import 'package:open_adventure/core/settings.dart';

/// Abstraction over asset loading and JSON decoding for the Data layer.
///
/// Provides typed helpers to load JSON Lists and Maps with consistent
/// validation and exceptions, and a convenience method to flatten
/// locations entries.
abstract class AssetDataSource {
  /// Loads and decodes a JSON List from the given asset [assetPath].
  Future<List<dynamic>> loadList(String assetPath);

  /// Loads and decodes a JSON `Map<String,dynamic>` from the given [assetPath].
  Future<Map<String, dynamic>> loadMap(String assetPath);

  /// Loads and flattens locations from assets/data/locations.json into a list
  /// of maps shaped as `{ 'name': String, ...data }`.
  Future<List<Map<String, dynamic>>> getLocations();
}

/// Default implementation using Flutter's [rootBundle].
///
/// Decoding can be offloaded to a background isolate when
/// `Settings.parseUseIsolate` is true, or forced via the constructor flag
/// (used in tests). Otherwise decoding happens on the calling isolate.
class BundleAssetDataSource implements AssetDataSource {
  final AssetBundle _bundle;
  final IsolateExecutor _executor;
  final bool _forceIsolateParsing;

  /// Creates a data source backed by the provided [bundle] (defaults to [rootBundle]).
  BundleAssetDataSource({AssetBundle? bundle, IsolateExecutor? executor, bool forceIsolateParsing = false})
      : _bundle = bundle ?? rootBundle,
        _executor = executor ?? const FlutterIsolateExecutor(),
        _forceIsolateParsing = forceIsolateParsing;

  @override
  Future<List<dynamic>> loadList(String assetPath) async {
    if (_forceIsolateParsing || Settings.parseUseIsolate) {
      final raw = await _bundle.loadString(assetPath);
      final decoded = await _executor.compute<String, dynamic>(_decodeJson, raw, debugLabel: 'decode:$assetPath');
      return JsonValidator.requireList(decoded, assetPath: assetPath);
    } else {
      final raw = await _bundle.loadString(assetPath);
      final decoded = json.decode(raw);
      return JsonValidator.requireList(decoded, assetPath: assetPath);
    }
  }

  @override
  Future<Map<String, dynamic>> loadMap(String assetPath) async {
    if (_forceIsolateParsing || Settings.parseUseIsolate) {
      final raw = await _bundle.loadString(assetPath);
      final decoded = await _executor.compute<String, dynamic>(_decodeJson, raw, debugLabel: 'decode:$assetPath');
      return JsonValidator.requireMap(decoded, assetPath: assetPath);
    } else {
      final raw = await _bundle.loadString(assetPath);
      final decoded = json.decode(raw);
      return JsonValidator.requireMap(decoded, assetPath: assetPath);
    }
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

// Top-level function required by Flutter compute.
dynamic _decodeJson(String raw) => json.decode(raw);

// In tests, prefer to use `BundleAssetDataSource()` with `flutter_test`, as
// assets listed in `pubspec.yaml` are available to the rootBundle.
