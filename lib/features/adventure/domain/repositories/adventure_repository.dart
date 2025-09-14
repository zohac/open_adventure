// lib/features/adventure/domain/repositories/adventure_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';

abstract class AdventureRepository {
  Future<Either<Failure, List<Location>>> getLocations();
// Define other methods as needed
}
