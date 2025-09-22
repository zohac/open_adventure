import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/repositories/save_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final motionNormalizer = await MotionNormalizerImpl.load();
  final adventureRepository = AdventureRepositoryImpl();
  final listAvailableActions =
      ListAvailableActionsTravel(adventureRepository, motionNormalizer);
  final applyTurn = ApplyTurnGoto(adventureRepository, motionNormalizer);
  final saveRepository = SaveRepositoryImpl();

  final controller = GameController(
    adventureRepository: adventureRepository,
    listAvailableActions: listAvailableActions,
    applyTurn: applyTurn,
    saveRepository: saveRepository,
  );

  runApp(OpenAdventureApp(controller: controller));
}

class OpenAdventureApp extends StatelessWidget {
  const OpenAdventureApp({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Adventure',
      theme: ThemeData.from(colorScheme: const ColorScheme.light()),
      home: AdventurePage(
        controller: controller,
        initializeOnMount: true,
        disposeController: true,
      ),
    );
  }
}
