import 'dart:convert';
import 'dart:io';

import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// File-system implementation of the minimal autosave repository.
class SaveRepositoryImpl implements SaveRepository {
  SaveRepositoryImpl({Future<Directory> Function()? supportDirProvider})
      : _supportDirProvider =
            supportDirProvider ?? path_provider.getApplicationSupportDirectory;

  final Future<Directory> Function() _supportDirProvider;

  static const String _folderName = 'open_adventure';
  static const String _fileName = 'autosave.json';

  @override
  Future<void> autosave(GameSnapshot snapshot) async {
    final file = await _resolveFile();
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    final data = jsonEncode(snapshot.toJson());
    await file.writeAsString(data, flush: true);
  }

  @override
  Future<GameSnapshot?> latest() async {
    final file = await _resolveFile();
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return GameSnapshot.fromJson(decoded);
      }
    } catch (_) {
      // fallthrough → null
    }
    return null;
  }

  Future<File> _resolveFile() async {
    final baseDir = await _supportDirProvider();
    final autosaveDir =
        Directory('${baseDir.path}${Platform.pathSeparator}$_folderName');
    return File('${autosaveDir.path}${Platform.pathSeparator}$_fileName');
  }
}
