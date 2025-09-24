import 'package:flutter/material.dart';
import 'dart:async';

import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/repositories/audio_settings_repository_impl.dart';
import 'package:open_adventure/data/repositories/save_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';
import 'package:open_adventure/presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final motionNormalizer = await MotionNormalizerImpl.load();
  final adventureRepository = AdventureRepositoryImpl();
  final listAvailableActions =
      ListAvailableActionsTravel(adventureRepository, motionNormalizer);
  final applyTurn = ApplyTurnGoto(adventureRepository, motionNormalizer);
  final saveRepository = SaveRepositoryImpl();

  final audioController = AudioController();
  final audioSettingsRepository = AudioSettingsRepositoryImpl();
  final loadAudioSettings = LoadAudioSettings(audioSettingsRepository);
  final saveAudioSettings = SaveAudioSettings(audioSettingsRepository);
  final audioSettingsController = AudioSettingsController(
    loadAudioSettings: loadAudioSettings,
    saveAudioSettings: saveAudioSettings,
    audioOutput: audioController,
  );
  await audioSettingsController.init();

  final controller = GameController(
    adventureRepository: adventureRepository,
    listAvailableActions: listAvailableActions,
    applyTurn: applyTurn,
    saveRepository: saveRepository,
  );

  runApp(
    OpenAdventureApp(
      gameController: controller,
      audioController: audioController,
      audioSettingsController: audioSettingsController,
    ),
  );
}

class OpenAdventureApp extends StatefulWidget {
  const OpenAdventureApp({
    super.key,
    required this.gameController,
    required this.audioController,
    required this.audioSettingsController,
  });

  final GameController gameController;
  final AudioController audioController;
  final AudioSettingsController audioSettingsController;

  @override
  State<OpenAdventureApp> createState() => _OpenAdventureAppState();
}

class _OpenAdventureAppState extends State<OpenAdventureApp> {
  @override
  void dispose() {
    unawaited(widget.audioController.dispose());
    widget.audioSettingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Adventure',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: AdventurePage(
        controller: widget.gameController,
        audioSettingsController: widget.audioSettingsController,
        initializeOnMount: true,
        disposeController: true,
      ),
    );
  }
}
