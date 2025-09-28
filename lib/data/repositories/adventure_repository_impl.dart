import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/core/error/exceptions.dart';
import 'package:open_adventure/core/error/failures.dart';
import 'package:open_adventure/data/datasources/asset_data_source.dart';
import 'package:open_adventure/data/models/game_object_model.dart';
import 'package:open_adventure/data/models/location_model.dart';
import 'package:open_adventure/data/models/travel_rule_model.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/entities/travel_rule.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';

/// Adventure repository implementation backed by JSON assets.
class AdventureRepositoryImpl implements AdventureRepository {
  final AssetDataSource _assets;

  List<Location>? _locations;
  List<GameObject>? _objects;
  Map<String, int>? _locNameToId;
  Map<String, int>? _objNameToId;

  AdventureRepositoryImpl({AssetDataSource? assets})
    : _assets = assets ?? BundleAssetDataSource();

  @override
  Future<List<Location>> getLocations() async {
    if (_locations != null) return _locations!;
    try {
      final flattened = await _assets.getLocations();
      final list = <Location>[];
      final index = <String, int>{};
      for (var i = 0; i < flattened.length; i++) {
        final model = LocationModel.fromJson(flattened[i], i);
        list.add(model);
        index[model.name] = i;
      }
      _locations = list;
      _locNameToId = index;
      return list;
    } on AssetDataFormatException catch (e) {
      throw DataFailure('Invalid locations asset', cause: e);
    } on FormatException catch (e) {
      throw DataFailure('Invalid JSON format for locations', cause: e);
    }
  }

  @override
  Future<List<GameObject>> getGameObjects() async {
    if (_objects != null) return _objects!;
    try {
      final raw = await _assets.loadList(AssetPaths.objectsJson);
      final list = <GameObject>[];
      final index = <String, int>{};
      for (var i = 0; i < raw.length; i++) {
        final entry = raw[i] as List<dynamic>;
        final model = GameObjectModel.fromEntry(entry, i);
        list.add(model);
        index[model.name] = i;
      }
      _objects = list;
      _objNameToId = index;
      return list;
    } on AssetDataFormatException catch (e) {
      throw DataFailure('Invalid objects asset', cause: e);
    } on FormatException catch (e) {
      throw DataFailure('Invalid JSON format for objects', cause: e);
    }
  }

  @override
  Future<Location> locationById(int id) async {
    final locs = await getLocations();
    if (id < 0 || id >= locs.length) {
      throw DataFailure('Location id out of range: $id');
    }
    return locs[id];
  }

  @override
  Future<List<TravelRule>> travelRulesFor(int locationId) async {
    try {
      final raw = await _assets.loadList(AssetPaths.travelJson);
      final rules = <TravelRule>[];
      for (final entry in raw) {
        final model = TravelRuleModel.fromJson(
          Map<String, dynamic>.from(entry as Map),
        );
        if (model.fromId != locationId) continue;
        if (model.stop) continue;
        final condType = model.condType?.toLowerCase();
        if (condType != null &&
            condType.isNotEmpty &&
            condType != 'cond_goto' &&
            condType != '0') {
          continue;
        }
        var resolvedDestId = model.destId;
        if (resolvedDestId == null) {
          final index = await _ensureLocationIndex();
          resolvedDestId = index[model.destName];
        }
        rules.add(
          TravelRule(
            fromId: model.fromId,
            motion: model.motion,
            destName: model.destName,
            destId: resolvedDestId,
            condType: model.condType,
            condArg1: model.condArg1,
            condArg2: model.condArg2,
            noDwarves: model.noDwarves,
            stop: model.stop,
          ),
        );
      }
      return List.unmodifiable(rules);
    } on AssetDataFormatException catch (e) {
      throw DataFailure('Invalid travel asset', cause: e);
    } on FormatException catch (e) {
      throw DataFailure('Invalid JSON format for travel', cause: e);
    }
  }

  Future<Map<String, int>> _ensureLocationIndex() async {
    if (_locNameToId == null) {
      await getLocations();
    }
    return _locNameToId ?? const <String, int>{};
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
          await getLocations();
          final idx = _locNameToId?[name];
          if (idx != null && idx >= 0) startId = idx;
        }
      }
    } on DataFailure {
      // metadata is optional; ignore.
    } catch (_) {
      // metadata.json is optional → fallback below.
    }

    // Fallback: first entry of locations.json as start.
    final locations = await getLocations();
    if (startId < 0 || startId >= locations.length) {
      startId = 0;
    }

    final Map<String, int> locationIndex = await _ensureLocationIndex();
    final List<GameObject> objects = await getGameObjects();
    final Map<int, GameObjectState> objectStates = <int, GameObjectState>{};

    for (final GameObject object in objects) {
      if (object.id == 0) {
        // Skip the NO_OBJECT sentinel.
        continue;
      }

      final List<String> placement = object.locations;
      final int? primaryLocation = placement.isNotEmpty
          ? _resolveLocationId(placement[0], locationIndex)
          : null;
      final int? secondaryLocation = placement.length > 1
          ? _resolveLocationId(placement[1], locationIndex)
          : null;

      Object? stateValue;
      Object? propValue;
      final List<String>? definedStates = object.states;
      if (definedStates != null && definedStates.isNotEmpty) {
        stateValue = definedStates.first;
        propValue = 0;
      }

      objectStates[object.id] = GameObjectState(
        id: object.id,
        location: primaryLocation,
        fixedLocation: secondaryLocation,
        state: stateValue,
        prop: propValue,
      );
    }

    return Game(
      loc: startId,
      oldLoc: startId,
      oldLc2: startId,
      newLoc: startId,
      turns: 0,
      rngSeed: seed,
      visitedLocations: {startId},
      magicWordsUnlocked: false,
      objectStates: Map.unmodifiable(objectStates),
    );
  }

  int? _resolveLocationId(String raw, Map<String, int> index) {
    final int? byName = index[raw];
    if (byName != null) {
      return byName;
    }
    return int.tryParse(raw);
  }
}

// Visible for testing: name↔id lookups
extension AdventureRepositoryImplIndex on AdventureRepositoryImpl {
  int? locationIdForName(String name) => _locNameToId?[name];
  int? objectIdForName(String name) => _objNameToId?[name];
  String? locationNameForId(int id) =>
      (_locations != null && id >= 0 && id < _locations!.length)
      ? _locations![id].name
      : null;
  String? objectNameForId(int id) =>
      (_objects != null && id >= 0 && id < _objects!.length)
      ? _objects![id].name
      : null;
}
