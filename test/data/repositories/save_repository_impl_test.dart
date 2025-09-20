import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/save_repository_impl.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveRepositoryImpl', () {
    late Directory tempDir;
    late SaveRepositoryImpl repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('save_repo_impl_test');
      repository = SaveRepositoryImpl(supportDirProvider: () async => tempDir);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('autosave writes file and latest returns the snapshot', () async {
      const snapshot = GameSnapshot(loc: 5, turns: 12, rngSeed: 42);

      await repository.autosave(snapshot);
      final restored = await repository.latest();

      expect(restored, isNotNull);
      expect(restored, equals(snapshot));

      final file = File(
          '${tempDir.path}${Platform.pathSeparator}open_adventure${Platform.pathSeparator}autosave.json');
      expect(await file.exists(), isTrue);
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(decoded['loc'], snapshot.loc);
      expect(decoded['turns'], snapshot.turns);
      expect(decoded['rng_seed'], snapshot.rngSeed);
      expect(decoded['schema_version'], 1);
    });

    test('latest returns null when no autosave exists', () async {
      final result = await repository.latest();
      expect(result, isNull);
    });

    test('latest returns null when autosave is corrupted', () async {
      final autosaveFile = File(
          '${tempDir.path}${Platform.pathSeparator}open_adventure${Platform.pathSeparator}autosave.json');
      await autosaveFile.parent.create(recursive: true);
      await autosaveFile.writeAsString('not-json');

      final restored = await repository.latest();
      expect(restored, isNull);
    });
  });
}
