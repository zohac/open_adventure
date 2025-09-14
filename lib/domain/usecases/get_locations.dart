import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';

/// Use case returning all locations from the repository.
class GetLocations {
  final AdventureRepository _repository;
  const GetLocations(this._repository);

  /// Retrieves all locations available in the adventure dataset.
  Future<List<Location>> call() => _repository.getLocations();
}

