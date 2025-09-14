// lib/features/adventure/data/datasources/adventure_local_data_source.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import '../models/game_object_model.dart';
import '../models/location_model.dart';

abstract class AdventureLocalDataSource {
  Future<List<LocationModel>> getLocations();
  Future<List<GameObjectModel>> getGameObjects();
}

class AdventureLocalDataSourceImpl implements AdventureLocalDataSource {
  final AssetBundle assetBundle;

  AdventureLocalDataSourceImpl({AssetBundle? assetBundle})
      : assetBundle = assetBundle ?? rootBundle;

  @override
  Future<List<LocationModel>> getLocations() async {
    final String jsonString = await assetBundle.loadString(AssetPaths.locationsJson);
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LocationModel> locations = [];

    for (int i = 0; i < jsonData.length; i++) {
      final List<dynamic> entry = jsonData[i];
      final String name = entry[0];
      final Map<String, dynamic> data = entry[1];
      data['name'] = name; // Add name to data for the model

      LocationModel location = LocationModel.fromJson(data, i);
      locations.add(location);
    }

    return locations;
  }

  @override
  Future<List<GameObjectModel>> getGameObjects() async {
    final String jsonString = await assetBundle.loadString(AssetPaths.objectsJson);
    final List<dynamic> jsonData = json.decode(jsonString);

    List<GameObjectModel> gameObjects = [];

    for (int i = 0; i < jsonData.length; i++) {
      final List<dynamic> entry = jsonData[i];
      // final String name = entry[0];
      // final Map<String, dynamic> data = {name: entry[1]};

      GameObjectModel gameObject = GameObjectModel.fromJson(entry);
      gameObjects.add(gameObject);
    }

    return gameObjects;
  }
}
