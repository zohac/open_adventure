// lib/features/adventure/domain/repositories/adventure_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game.dart';
import '../entities/game_object.dart';
import '../entities/location.dart';

abstract class AdventureRepository {
  Future<Either<Failure, Game>> getGame();
  Future<Either<Failure, void>> saveGame(Game game);
  Future<Either<Failure, List<Location>>> getLocations();
  Future<Either<Failure, List<GameObject>>> getGameObjects();
// Define other methods as needed
}
