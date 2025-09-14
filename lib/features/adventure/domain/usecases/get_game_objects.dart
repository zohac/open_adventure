import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_object.dart';
import '../repositories/adventure_repository.dart';

class GetGameObjects implements UseCase<List<GameObject>, NoParams> {
  final AdventureRepository repository;

  GetGameObjects(this.repository);

  @override
  Future<Either<Failure, List<GameObject>>> call(NoParams params) async {
    return await repository.getGameObjects();
  }
}
