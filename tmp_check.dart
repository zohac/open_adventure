import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';

Future<void> main() async {
  final motion = await MotionNormalizerImpl.load();
  final repo = AdventureRepositoryImpl();
  final usecase = ListAvailableActionsTravel(repo, motion);
  const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
  final opts = await usecase(game);
  for (final opt in opts) {
    print('${opt.label} | verb=${opt.verb} | icon=${opt.icon} | id=${opt.id}');
  }
}
