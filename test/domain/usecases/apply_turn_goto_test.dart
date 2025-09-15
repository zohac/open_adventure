import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/value_objects/command.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApplyTurnGoto', () {
    test('updates location, increments turns and returns description', () async {
      final repo = AdventureRepositoryImpl();
      final motion = MotionNormalizerImpl();
      final usecase = ApplyTurnGoto(repo, motion);
      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final cmd = Command(verb: 'WEST', target: '2');
      final result = await usecase(cmd, game);
      expect(result.newGame.loc, 2);
      expect(result.newGame.oldLoc, 1);
      expect(result.newGame.newLoc, 2);
      expect(result.newGame.turns, 1);
      final dest = await repo.locationById(2);
      final expectedDesc = dest.longDescription ?? dest.shortDescription ?? '';
      expect(result.messages, [expectedDesc]);
    });

    test('canonicalizes command verb aliases', () async {
      final repo = AdventureRepositoryImpl();
      final motion = MotionNormalizerImpl();
      final usecase = ApplyTurnGoto(repo, motion);
      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      // MOT_2 is an alias for WEST in the motion table.
      final cmd = Command(verb: 'MOT_2', target: '2');
      final result = await usecase(cmd, game);
      expect(result.newGame.loc, 2);
    });

    test('throws StateError when no matching rule', () async {
      final repo = AdventureRepositoryImpl();
      final motion = MotionNormalizerImpl();
      final usecase = ApplyTurnGoto(repo, motion);
      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final cmd = Command(verb: 'FOO', target: '2');
      expect(() => usecase(cmd, game), throwsA(isA<StateError>()));
    });
  });
}

