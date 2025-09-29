import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_adventure/l10n/app_localizations.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/repositories/audio_settings_repository_impl.dart';
import 'package:open_adventure/data/repositories/save_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/close_object.dart';
import 'package:open_adventure/domain/usecases/drop_object.dart';
import 'package:open_adventure/domain/usecases/evaluate_condition.dart';
import 'package:open_adventure/domain/usecases/examine.dart';
import 'package:open_adventure/domain/usecases/extinguish_lamp.dart';
import 'package:open_adventure/domain/usecases/inventory.dart';
import 'package:open_adventure/domain/usecases/light_lamp.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/open_object.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';
import 'package:open_adventure/domain/usecases/take_object.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/presentation/pages/home_page.dart';
import 'package:open_adventure/presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final motionNormalizer = await MotionNormalizerImpl.load();
  final adventureRepository = AdventureRepositoryImpl();
  final listAvailableActionsTravel = ListAvailableActionsTravel(
    adventureRepository,
    motionNormalizer,
  );
  const evaluateCondition = EvaluateConditionImpl();
  final listAvailableActions = ListAvailableActions(
    adventureRepository: adventureRepository,
    travel: listAvailableActionsTravel,
    evaluateCondition: evaluateCondition,
  );
  final inventoryUseCase = InventoryUseCaseImpl(
    adventureRepository: adventureRepository,
  );
  final examine = ExamineImpl(adventureRepository: adventureRepository);
  final takeObject = TakeObjectImpl(adventureRepository: adventureRepository);
  final dropObject = DropObjectImpl(adventureRepository: adventureRepository);
  final openObject = OpenObjectImpl(adventureRepository: adventureRepository);
  final closeObject = CloseObjectImpl(adventureRepository: adventureRepository);
  final lightLamp = LightLampImpl(adventureRepository: adventureRepository);
  final extinguishLamp = ExtinguishLampImpl(
    adventureRepository: adventureRepository,
  );
  final applyTurnGoto = ApplyTurnGoto(adventureRepository, motionNormalizer);
  final applyTurn = ApplyTurn(
    travel: applyTurnGoto,
    examine: examine,
    takeObject: takeObject,
    dropObject: dropObject,
    openObject: openObject,
    closeObject: closeObject,
    lightLamp: lightLamp,
    extinguishLamp: extinguishLamp,
  );
  final saveRepository = SaveRepositoryImpl();
  final dwarfSystem = DwarfSystem(adventureRepository);

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
    inventoryUseCase: inventoryUseCase,
    applyTurn: applyTurn,
    saveRepository: saveRepository,
    dwarfSystem: dwarfSystem,
  );
  final homeController = HomeController(saveRepository: saveRepository);

  runApp(
    OpenAdventureApp(
      gameController: controller,
      audioController: audioController,
      audioSettingsController: audioSettingsController,
      homeController: homeController,
    ),
  );
}

class OpenAdventureApp extends StatefulWidget {
  const OpenAdventureApp({
    super.key,
    required this.gameController,
    required this.audioController,
    required this.audioSettingsController,
    required this.homeController,
  });

  final GameController gameController;
  final AudioController audioController;
  final AudioSettingsController audioSettingsController;
  final HomeController homeController;

  @override
  State<OpenAdventureApp> createState() => _OpenAdventureAppState();
}

class _OpenAdventureAppState extends State<OpenAdventureApp> {
  @override
  void dispose() {
    unawaited(widget.audioController.dispose());
    widget.audioSettingsController.dispose();
    widget.homeController.dispose();
    widget.gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(
        gameController: widget.gameController,
        homeController: widget.homeController,
        audioSettingsController: widget.audioSettingsController,
      ),
    );
  }
}
