// lib/core/usecases/usecase.dart
// Generic use case contract (no external dependency).

abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

class NoParams {}
