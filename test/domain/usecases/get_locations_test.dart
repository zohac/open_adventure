import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/get_locations.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GetLocations calls repository and returns list', () async {
    final repo = _MockAdventureRepository();
    final usecase = GetLocations(repo);
    final sample = [
      const Location(id: 0, name: 'LOC_START'),
      const Location(id: 1, name: 'LOC_HILL'),
    ];
    when(() => repo.getLocations()).thenAnswer((_) async => sample);

    final result = await usecase();
    expect(result, sample);
    verify(() => repo.getLocations()).called(1);
  });
}

