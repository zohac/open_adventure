// lib/features/adventure/domain/usecases/get_locations.dart

import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../repositories/adventure_repository.dart';

class GetLocations implements UseCase<List<Location>, NoParams> {
  final AdventureRepository repository;

  GetLocations(this.repository);

  @override
  Future<Either<Failure, List<Location>>> call(NoParams params) async {
    return await repository.getLocations();
  }
}
