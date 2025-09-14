import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_model.dart';

abstract class GameLocalDataSource {
  Future<GameModel> getGame();
  Future<void> saveGame(GameModel gameModel);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  final String gameDataPath = 'assets/data/game.json';

  @override
  Future<GameModel> getGame() async {
    final String jsonString = await rootBundle.loadString(gameDataPath);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return GameModel.fromJson(jsonData);
  }

  @override
  Future<void> saveGame(GameModel gameModel) async {
    // Implémenter la sauvegarde du jeu si nécessaire
    // Note : L'écriture dans les assets n'est pas possible,
    // il faudrait utiliser le système de fichiers local
  }
}
