import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/application/providers/dependencies.dart';
import 'package:open_adventure/application/providers/game_state_provider.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/data/repositories/audio_settings_repository_impl.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';
import 'package:open_adventure/features/debug/widget_gallery.dart';
import 'package:open_adventure/features/home/home_page.dart';
import 'package:open_adventure/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Container Riverpod racine — résout tous les providers gameplay
  // (adventureRepository, applyTurn, saveRepository, dwarfSystem, etc.)
  // exposés par `lib/application/providers/dependencies.dart` (Story 5-6).
  final container = ProviderContainer();

  // Pré-résoudre les FutureProviders pour que les pages legacy non encore
  // refondues (cohabitation transitoire) reçoivent un `GameNotifier` prêt
  // par constructeur. Les pages refondues (5-7/5-9) consommeront
  // `ref.watch(gameStateProvider)` et géreront elles-mêmes l'AsyncValue.
  final gameController = await container.read(gameStateProvider.future);
  final saveRepository = container.read(saveRepositoryProvider);

  // Audio + Home controllers : migrés en Stories 5-10 (audio settings)
  // et lots futurs (Home). Pour l'instant DI manuelle.
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

  final homeController = HomeController(saveRepository: saveRepository);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: OpenAdventureApp(
        gameController: gameController,
        audioController: audioController,
        audioSettingsController: audioSettingsController,
        homeController: homeController,
      ),
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

  final GameNotifier gameController;
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
    // `gameController` lifecycle is owned by the Riverpod container (cf.
    // `gameStateProvider` ref.onDispose). No manual dispose needed here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: OAThemeData.dark(),
      darkTheme: OAThemeData.dark(),
      themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: <String, WidgetBuilder>{
        // `!kReleaseMode` ⇒ debug + profile (incluant DevTools / benchmarks).
        // En release, l'entrée est absente : navigation impossible.
        if (!kReleaseMode)
          WidgetGalleryPage.routeName: (_) => const WidgetGalleryPage(),
      },
      home: HomePage(
        gameController: widget.gameController,
        homeController: widget.homeController,
        audioSettingsController: widget.audioSettingsController,
      ),
    );
  }
}
