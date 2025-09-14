import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/error/failures.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('locationById throws DataFailure on out-of-range id', () async {
    final repo = AdventureRepositoryImpl();
    final locs = await repo.getLocations();
    final badId = locs.length + 1;
    expect(() => repo.locationById(badId), throwsA(isA<DataFailure>()));
  });
}

