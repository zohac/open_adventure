
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/game_object_model.dart';
import 'package:open_adventure/data/models/location_model.dart';
import 'package:open_adventure/data/models/travel_rule_model.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/entities/travel_rule.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';

/// Adventure repository implementation backed by JSON assets.
class AdventureRepositoryImpl implements AdventureRepository {
  final AssetDataSource _assets;

  List<Location>? _locations;
  List<GameObject>? _objects;

  AdventureRepositoryImpl({AssetDataSource? assets})
      : _assets = assets ?? BundleAssetDataSource();

  @override
  Future<List<Location>> getLocations() async {
    if (_locations != null) return _locations!;
    final flattened = await _assets.getLocations();
    final list = <Location>[];
    for (var i = 0; i < flattened.length; i++) {
      list.add(LocationModel.fromJson(flattened[i], i));
    }
    _locations = list;
    return list;
  }

  @override
  Future<List<GameObject>> getGameObjects() async {
    if (_objects != null) return _objects!;
    final raw = await _assets.loadList(AssetPaths.objectsJson);
    final list = <GameObject>[];
    for (var i = 0; i < raw.length; i++) {
      final entry = raw[i] as List<dynamic>;
      list.add(GameObjectModel.fromEntry(entry, i));
    }
    _objects = list;
    return list;
  }

  @override
  Future<Location> locationById(int id) async {
    final locs = await getLocations();
    if (id < 0 || id >= locs.length) {
      throw RangeError('Location id out of range: $id');
    }
    return locs[id];
  }

  @override
  Future<List<TravelRule>> travelRulesFor(int locationId) async {
    final raw = await _assets.loadList(AssetPaths.travelJson);
    final rules = raw
        .map((e) => TravelRuleModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((r) => r.fromId == locationId)
        .toList(growable: false);
    return rules;
  }

  @override
  Future<Game> initialGame() async {
    // Seed rng deterministically for tests.
    const seed = 42;

    // Try optional metadata.json → start_location_id or start_location name.
    int startId = 0;
    try {
      final raw = await _assets.loadMap(AssetPaths.metadataJson);
      if (raw.containsKey('start_location_id')) {
        final v = raw['start_location_id'];
        if (v is int) startId = v;
      } else if (raw.containsKey('start_location')) {
        final name = raw['start_location']?.toString();
        if (name != null) {
          final locations = await getLocations();
          final idx = locations.indexWhere((l) => l.name == name);
          if (idx >= 0) startId = idx;
        }
      }
    } catch (_) {
      // metadata.json is optional → fallback below.
    }

    // Fallback: first entry of locations.json as start.
    final locations = await getLocations();
    if (startId < 0 || startId >= locations.length) {
      startId = 0;
    }
    return Game(loc: startId, turns: 0, rngSeed: seed);
  }
}
