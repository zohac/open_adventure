// lib/features/adventure/data/repositories/adventure_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:open_adventure/features/adventure/data/datasources/game_local_data_source.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_object.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/adventure_repository.dart';
import '../datasources/adventure_local_data_source.dart';
import '../models/game_model.dart';

class AdventureRepositoryImpl implements AdventureRepository {
  final AdventureLocalDataSource localDataSource;
  final GameLocalDataSource gameLocalDataSource;

  AdventureRepositoryImpl({
    required this.localDataSource,
    required this.gameLocalDataSource
  });

  @override
  Future<Either<Failure, Game>> getGame() async {
    try {
      final gameModel = await gameLocalDataSource.getGame();
      return Right(gameModel.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveGame(Game game) async {
    try {
      final gameModel = GameModel(
        // Convertir l'entité Game en GameModel
        lcgX: game.lcgX,
        abbNum: game.abbNum,
        bonus: game.bonus,
        chLoc: game.chLoc,
        chLoc2: game.chLoc2,
        clock1: game.clock1,
        clock2: game.clock2,
        clshnt: game.clshnt,
        closed: game.closed,
        closng: game.closng,
        lmwarn: game.lmwarn,
        novice: game.novice,
        panic: game.panic,
        wzdark: game.wzdark,
        blooded: game.blooded,
        conds: game.conds,
        detail: game.detail,
        dflag: game.dflag,
        dkill: game.dkill,
        dtotal: game.dtotal,
        foobar: game.foobar,
        holdng: game.holdng,
        igo: game.igo,
        iwest: game.iwest,
        knfloc: game.knfloc,
        limit: game.limit,
        loc: game.loc,
        newloc: game.newloc,
        numdie: game.numdie,
        oldloc: game.oldloc,
        oldlc2: game.oldlc2,
        oldobj: game.oldobj,
        saved: game.saved,
        tally: game.tally,
        thresh: game.thresh,
        seenbigwords: game.seenbigwords,
        trnluz: game.trnluz,
        turns: game.turns,
        zzword: '',
        locs: [],
        dwarves: [],
        objects: [],
        hints: [],
        link: [],
      );
      await gameLocalDataSource.saveGame(gameModel);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getLocations() async {
    try {
      final locationModels = await localDataSource.getLocations();
      return Right(locationModels);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<GameObject>>> getGameObjects() async {
    try {
      final gameObjectModels = await localDataSource.getGameObjects();
      return Right(gameObjectModels);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
