import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/features/adventure/data/models/game_object_model.dart';
import 'package:open_adventure/features/adventure/domain/entities/game_object.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  List<dynamic>  jsonData = [];

  setUp(() async {
    // Construire le chemin vers le fichier
    final file = File(AssetPaths.objectsJson);

    // Vérifier que le fichier existe
    expect(await file.exists(), true, reason: 'Le fichier objects.json doit exister');

    // Lire le contenu du fichier
    final jsonString = await file.readAsString();

    // Décoder le JSON
    jsonData = jsonDecode(jsonString);
  });

  group('GameObjectModel', ()  {
    test('Charger le fichier objects.json', () async {
      // Vérifier que les données sont chargées
      expect(jsonData, isA<List<dynamic>>());
      expect(jsonData.length, greaterThan(0));

      // Charger les objets en utilisant votre modèle
      List<GameObjectModel> gameObjects = [];

      for (var entry in jsonData) {
        GameObjectModel gameObject = GameObjectModel.fromJson(entry);
        gameObjects.add(gameObject);

        final name = entry[0] as String;
        final Map<String, dynamic> data = entry[1] as Map<String, dynamic>;

        final words = List<String>.from(data['words'] ?? []);
        final inventoryDescription = data['inventory'];
        final locationsData = data['locations'];

        // Gérer le fait que 'locations' peut être une chaîne ou une liste
        List<String> locations;
        if (locationsData is String) {
          locations = [locationsData];
        } else if (locationsData is List) {
          locations = List<String>.from(locationsData);
        } else {
          locations = [];
        }

        final states = List<String>.from(data['states'] ?? []);
        final descriptions = List<String>.from(data['descriptions'] ?? []);
        final sounds = List<String>.from(data['sounds'] ?? []);
        final changes = List<String>.from(data['changes'] ?? []);
        final immovable = data['immovable'] ?? false;
        final isTreasure = data['is_treasure'] ?? false;

        expect(gameObject.id, name);
        expect(gameObject.name, name);
        expect(gameObject.words, words);
        expect(gameObject.inventoryDescription, inventoryDescription);
        expect(gameObject.locations, locations);
        expect(gameObject.states, states.isNotEmpty ? states : null);
        expect(gameObject.descriptions, descriptions.isNotEmpty ? descriptions : null);
        expect(gameObject.sounds, sounds.isNotEmpty ? sounds : null);
        expect(gameObject.changes, changes.isNotEmpty ? changes : null);
        expect(gameObject.immovable, immovable);
        expect(gameObject.isTreasure, isTreasure);
      }

      // Vérifier que les objets sont correctement chargés
      expect(gameObjects.length, jsonData.length);
    });

    test('toEntity should transform JSON correctly', () {
      // Charger les objets en utilisant votre modèle
      List<GameObjectModel> gameObjects = [];
      List<dynamic> dragonJson = [];

      for (var entry in jsonData) {
        GameObjectModel gameObject = GameObjectModel.fromJson(entry);
        gameObjects.add(gameObject);

        if (entry[0] == 'DRAGON') {
          dragonJson = entry;
        }
      }

      final dragonObject = gameObjects.firstWhere((obj) => obj.name == 'DRAGON');
      final dragonConvertedJson = dragonObject.toJson();

      expect(dragonConvertedJson[0], dragonJson[0]);
      expect(dragonConvertedJson[0], dragonJson[0]);
      expect(dragonConvertedJson[1]["words"], dragonJson[1]["words"]);
      expect(dragonConvertedJson[1]["locations"], dragonJson[1]["locations"]);
      expect(dragonConvertedJson[1]["immovable"], dragonJson[1]["immovable"]);
      expect(dragonConvertedJson[1]["states"], dragonJson[1]["states"]);
      expect(dragonConvertedJson[1]["descriptions"], dragonJson[1]["descriptions"]);
      expect(dragonConvertedJson[1]["changes"], dragonJson[1]["changes"]);
      expect(dragonConvertedJson[1]["sounds"], dragonJson[1]["sounds"]);
    });

    test('toEntity should transform JSON correctly', () {
      // Charger les objets en utilisant votre modèle
      List<GameObjectModel> gameObjects = [];
      List<dynamic> dragonJson = [];

      for (var entry in jsonData) {
        GameObjectModel gameObject = GameObjectModel.fromJson(entry);
        gameObjects.add(gameObject);

        if (entry[0] == 'DRAGON') {
          dragonJson = entry;
        }
      }

      final dragonObject = gameObjects.firstWhere((obj) => obj.name == 'DRAGON');
      final dragonEntity = dragonObject.toEntity();

      expect(dragonEntity, isA<GameObject>());
      expect(dragonEntity.id, dragonJson[0]);
      expect(dragonEntity.name, dragonJson[0]);
      expect(dragonEntity.words, dragonJson[1]["words"]);
      expect(dragonEntity.locations, dragonJson[1]["locations"]);
      expect(dragonEntity.immovable, dragonJson[1]["immovable"]);
      expect(dragonEntity.states, dragonJson[1]["states"]);
      expect(dragonEntity.descriptions, dragonJson[1]["descriptions"]);
      expect(dragonEntity.changes, dragonJson[1]["changes"]);
      expect(dragonEntity.sounds, dragonJson[1]["sounds"]);
    });
  });
}
