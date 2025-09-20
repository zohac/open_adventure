import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';
import 'package:open_adventure/data/models/location_model.dart';
import 'package:open_adventure/domain/entities/location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  List<dynamic> jsonData = [];

  setUp(() async {
    final file = File(AssetPaths.locationsJson);
    expect(await file.exists(), true, reason: 'Le fichier locations.json doit exister');
    final jsonString = await file.readAsString();
    jsonData = jsonDecode(jsonString);
  });

  group('LocationModel', ()  {
    test('LocationModel.fromEntry maps fields with sequential id', () async {
      expect(jsonData, isA<List<dynamic>>());
      expect(jsonData.length, greaterThan(0));

      List<LocationModel> locationObjects = [];

      for (int i = 0; i < jsonData.length; i++) {
        final entry = jsonData[i] as List<dynamic>;
        final name = entry[0] as String;
        final data = entry[1] as Map<String, dynamic>;
        final description = data['description'] as Map<String, dynamic>?;

        LocationModel location = LocationModel.fromEntry(entry, i);
        locationObjects.add(location);

        expect(location, isA<Location>());
        expect(location.id, i);
        expect(location.name, name);
        expect(location.mapTag, description?['maptag']);
        expect(location.shortDescription, description?['short']);
        expect(location.longDescription, description?['long']);
      }

      expect(locationObjects.length, jsonData.length);
    });
  });
}
