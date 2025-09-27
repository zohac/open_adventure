import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/models/game_object_model.dart';
import 'package:open_adventure/domain/entities/game_object.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  List<dynamic> jsonData = [];

  setUp(() async {
    final file = File(AssetPaths.objectsJson);
    expect(
      await file.exists(),
      true,
      reason: 'Le fichier objects.json doit exister',
    );
    final jsonString = await file.readAsString();
    jsonData = jsonDecode(jsonString);
  });

  group('GameObjectModel', () {
    test('GameObjectModel.fromEntry maps fields with sequential id', () async {
      expect(jsonData, isA<List<dynamic>>());
      expect(jsonData.length, greaterThan(0));

      List<GameObjectModel> gameObjects = [];

      for (int i = 0; i < jsonData.length; i++) {
        final entry = jsonData[i] as List<dynamic>;
        final name = entry[0] as String;
        final data = entry[1] as Map<String, dynamic>;

        GameObjectModel gameObject = GameObjectModel.fromEntry(entry, i);
        gameObjects.add(gameObject);

        final words = List<String>.from(data['words'] ?? []);
        final inventoryDescription = data['inventory'];
        final locationsData = data['locations'];

        List<String> locations;
        if (locationsData is String) {
          locations = [locationsData];
        } else if (locationsData is List) {
          locations = List<String>.from(locationsData);
        } else {
          locations = [];
        }

        final states = List<String>.from(data['states'] ?? []);
        final descriptions = List<dynamic>.from(data['descriptions'] ?? []);
        final sounds = List<String>.from(data['sounds'] ?? []);
        final changes = List<String>.from(data['changes'] ?? []);
        final immovable = data['immovable'] ?? false;
        final isTreasure = data['is_treasure'] ?? false;

        expect(gameObject.id, i);
        expect(gameObject.name, name);
        expect(gameObject.words, words);
        expect(gameObject.inventory, inventoryDescription);
        expect(gameObject.locations, locations);
        expect(gameObject.states, states.isNotEmpty ? states : null);
        expect(
          gameObject.descriptions,
          descriptions.isNotEmpty ? descriptions : null,
        );
        expect(gameObject.sounds, sounds.isNotEmpty ? sounds : null);
        expect(gameObject.changes, changes.isNotEmpty ? changes : null);
        expect(gameObject.immovable, immovable);
        expect(gameObject.isTreasure, isTreasure);
      }

      expect(gameObjects.length, jsonData.length);
    });

    test('toEntity strips model-specific fields', () {
      final dragonEntry = jsonData.firstWhere((e) => e[0] == 'DRAGON');
      final dragonModel = GameObjectModel.fromEntry(dragonEntry, 1);

      final dragonEntity = dragonModel.toEntity();

      expect(dragonEntity, isA<GameObject>());
      expect(dragonEntity.id, 1);
      expect(dragonEntity.name, 'DRAGON');
      expect(dragonEntity.immovable, isTrue);
      expect(dragonEntity.states, isNotNull);
      expect(dragonEntity.states, isNotEmpty);
      expect(dragonEntity.stateDescriptions, isNotNull);
      expect(
        dragonEntity.stateDescriptions!.length,
        dragonEntity.states!.length,
      );
    });

    test('toJson serializes back to a map', () {
      final dragonEntry = jsonData.firstWhere((e) => e[0] == 'DRAGON');
      final dragonModel = GameObjectModel.fromEntry(dragonEntry, 1);
      final dragonJson = dragonModel.toJson();

      expect(dragonJson['name'], dragonEntry[0]);
      expect(dragonJson['words'], dragonEntry[1]["words"]);
      expect(dragonJson['locations'], dragonEntry[1]["locations"]);
      expect(dragonJson['immovable'], dragonEntry[1]["immovable"]);
      expect(dragonJson['states'], dragonEntry[1]["states"]);
      expect(dragonJson['descriptions'], dragonEntry[1]["descriptions"]);
      expect(dragonJson['changes'], dragonEntry[1]["changes"]);
      expect(dragonJson['sounds'], dragonEntry[1]["sounds"]);
    });
  });
}
