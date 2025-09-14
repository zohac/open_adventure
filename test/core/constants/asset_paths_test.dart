// test/core/constants/asset_paths_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/constant/asset_paths.dart';

void main() {
  group('AssetPaths', () {
    test('Tous les fichiers d\'assets doivent exister', () async {
      final List<String> assetFiles = [
        AssetPaths.objectsJson,
        AssetPaths.locationsJson,
        // Ajoutez d'autres chemins d'assets ici
      ];

      for (var assetPath in assetFiles) {
        final file = File(assetPath);
        expect(await file.exists(), true, reason: 'Le fichier $assetPath doit exister');
      }
    });
  });
}
