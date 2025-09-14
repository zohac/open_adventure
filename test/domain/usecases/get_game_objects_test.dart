import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/get_game_objects.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GetGameObjects calls repository and returns list', () async {
    final repo = _MockAdventureRepository();
    final usecase = GetGameObjects(repo);
    final sample = [
      const GameObject(id: 2, name: 'LAMP'),
    ];
    when(() => repo.getGameObjects()).thenAnswer((_) async => sample);

    final result = await usecase();
    expect(result, sample);
    verify(() => repo.getGameObjects()).called(1);
  });
}

