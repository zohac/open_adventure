import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';

class _MockSaveRepository extends Mock implements SaveRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeController', () {
    late _MockSaveRepository repository;
    late HomeController controller;

    setUp(() {
      repository = _MockSaveRepository();
      controller = HomeController(saveRepository: repository);
    });

    test('refreshAutosave stores snapshot when available', () async {
      const snapshot = GameSnapshot(loc: 10, turns: 25, rngSeed: 7);
      when(() => repository.latest()).thenAnswer((_) async => snapshot);

      await controller.refreshAutosave();

      verify(() => repository.latest()).called(1);
      expect(controller.value.isLoading, isFalse);
      expect(controller.value.autosave, equals(snapshot));
    });

    test('refreshAutosave clears snapshot when none present', () async {
      when(() => repository.latest()).thenAnswer((_) async => null);

      controller.value = controller.value.copyWith(autosave: const GameSnapshot(loc: 1, turns: 2, rngSeed: 3));

      await controller.refreshAutosave();

      verify(() => repository.latest()).called(1);
      expect(controller.value.isLoading, isFalse);
      expect(controller.value.autosave, isNull);
    });
  });
}
