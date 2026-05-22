import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/application/providers/dependencies.dart';
import 'package:open_adventure/application/providers/game_state_provider.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/core/theme/oa_theme.dart';
import 'package:open_adventure/data/repositories/audio_settings_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';
import 'package:open_adventure/features/debug/widget_gallery.dart';
import 'package:open_adventure/features/home/home_page.dart';
import 'package:open_adventure/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The only async dependency at boot is the motion canonicalizer (JSON
  // parse). Once resolved, every gameplay provider is synchronous and
  // wired via the standard `ProviderScope` (cf. Story 5-6 AC4).
  final motion = await MotionNormalizerImpl.load();

  // Legacy controllers — migrated in subsequent stories (5-10 etc.).
  // They still receive their dependencies by constructor for now.
  final audioController = AudioController();
  final audioSettingsRepository = AudioSettingsRepositoryImpl();
  final audioSettingsController = AudioSettingsController(
    loadAudioSettings: LoadAudioSettings(audioSettingsRepository),
    saveAudioSettings: SaveAudioSettings(audioSettingsRepository),
    audioOutput: audioController,
  );
  await audioSettingsController.init();

  runApp(
    ProviderScope(
      overrides: <Override>[
        motionNormalizerProvider.overrideWithValue(motion),
      ],
      child: OpenAdventureApp(
        audioController: audioController,
        audioSettingsController: audioSettingsController,
      ),
    ),
  );
}

class OpenAdventureApp extends StatefulWidget {
  const OpenAdventureApp({
    super.key,
    required this.audioController,
    required this.audioSettingsController,
  });

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
    // `gameController` lifecycle is owned by the Riverpod container (cf.
    // `gameStateProvider` ref.onDispose). HomeController is created inside
    // the Consumer below and disposed when the widget tree is torn down.
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
      home: _AppHome(
        audioSettingsController: widget.audioSettingsController,
      ),
    );
  }
}

/// Resolves the gameplay notifier + spawns the legacy `HomeController` via
/// Riverpod, then builds [HomePage]. Kept private because it's a pure
/// composition shim — once 5-7/5-8 land, [HomePage] becomes a
/// `ConsumerWidget` itself and this shim disappears.
class _AppHome extends ConsumerStatefulWidget {
  const _AppHome({required this.audioSettingsController});

  final AudioSettingsController audioSettingsController;

  @override
  ConsumerState<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends ConsumerState<_AppHome> {
  late final HomeController _homeController = HomeController(
    saveRepository: ref.read(saveRepositoryProvider),
  );

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameController = ref.watch(gameStateProvider.notifier);
    return HomePage(
      gameController: gameController,
      homeController: _homeController,
      audioSettingsController: widget.audioSettingsController,
    );
  }
}
