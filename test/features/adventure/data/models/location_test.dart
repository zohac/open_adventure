import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/features/adventure/data/models/game_object_model.dart';
import 'package:open_adventure/features/adventure/data/models/location_model.dart';
import 'package:open_adventure/features/adventure/domain/entities/game_object.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  List<dynamic> jsonData = [];

  setUp(() async {
    // Construire le chemin vers le fichier
    final file = File(AssetPaths.locationsJson);

    // Vérifier que le fichier existe
    expect(await file.exists(), true, reason: 'Le fichier locations.json doit exister');

    // Lire le contenu du fichier
    final jsonString = await file.readAsString();

    // Décoder le JSON
    jsonData = jsonDecode(jsonString);
  });

  group('LocationModel', ()  {
    test('Charger le fichier locations.json', () async {
      // Vérifier que les données sont chargées
      expect(jsonData, isA<List<dynamic>>());
      expect(jsonData.length, greaterThan(0));

      // Charger les objets en utilisant votre modèle
      List<LocationModel> locationObjects = [];

      for (int i = 0; i < jsonData.length; i++) {
        LocationModel location = LocationModel.fromJson(jsonData[i], i);
        locationObjects.add(location);

        // final name = jsonData[i][0] as String;
        // final Map<String, dynamic> data = jsonData[i][1] as Map<String, dynamic>;

        // expect(location.name, name);
        // expect(location.mapTag, jsonData[i][1]["description"]["maptag"]);
        // expect(location.shortDescription, jsonData[i][1]["description"]["short"]);
        // expect(location.longDescription, jsonData[i][1]["description"]["long"]);
        // expect(location.descriptions, descriptions.isNotEmpty ? descriptions : null);
        // expect(location.sounds, sounds.isNotEmpty ? sounds : null);
        // expect(location.changes, changes.isNotEmpty ? changes : null);
        // expect(location.immovable, immovable);
        // expect(location.isTreasure, isTreasure);
      }

      // Vérifier que les objets sont correctement chargés
      // expect(locationObjects.length, jsonData.length);
    });
  });
}
