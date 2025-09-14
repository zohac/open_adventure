import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';

/// Use case returning all game objects from the repository.
class GetGameObjects {
  final AdventureRepository _repository;
  const GetGameObjects(this._repository);

  /// Retrieves all game objects available in the adventure dataset.
  Future<List<GameObject>> call() => _repository.getGameObjects();
}

