import 'package:flutter/material.dart';
import 'package:open_adventure/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/audio_settings_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/domain/value_objects/dwarf_tick_result.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';
import 'package:open_adventure/presentation/pages/credits_page.dart';
import 'package:open_adventure/presentation/pages/home_page.dart';
import 'package:open_adventure/presentation/pages/saves_page.dart';
import 'package:open_adventure/presentation/pages/settings_page.dart';
import 'package:open_adventure/presentation/theme/app_colors.dart';
import 'package:open_adventure/presentation/theme/app_theme.dart';
import 'package:open_adventure/presentation/widgets/pixel_canvas.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock implements ListAvailableActions {}

class _MockApplyTurn extends Mock implements ApplyTurn {}

class _MockSaveRepository extends Mock implements SaveRepository {}


class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _FakeRoute<T> extends Fake implements Route<T> {}

class _MockAudioOutput extends Mock implements AudioOutput {}

class _MockDwarfSystem extends Mock implements DwarfSystem {}

class _InMemoryAudioSettingsRepository implements AudioSettingsRepository {
  AudioSettings _settings = AudioSettings.defaults();

  @override
  Future<AudioSettings> load() async => _settings;

  @override
  Future<void> save(AudioSettings settings) async {
    _settings = settings;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const ActionOption(
        id: 'travel:1->2:NORTH',
        category: 'travel',
        label: 'motion.north.label',
        verb: 'NORTH',
        objectId: '2',
      ),
    );
    registerFallbackValue(
      const Game(loc: 0, oldLoc: 0, newLoc: 0, turns: 0, rngSeed: 0),
    );
    registerFallbackValue(const GameSnapshot(loc: 0, turns: 0, rngSeed: 0));
    registerFallbackValue(_FakeRoute<dynamic>());
  });

  HomeController buildHomeController(
    SaveRepository repository, {
    HomeViewState? state,
  }) {
    final controller = HomeController(saveRepository: repository);
    if (state != null) {
      controller.value = state;
    }
    return controller;
  }

  AudioSettingsController buildAudioSettingsController() {
    final repository = _InMemoryAudioSettingsRepository();
    final load = LoadAudioSettings(repository);
    final save = SaveAudioSettings(repository);
    final audioOutput = _MockAudioOutput();
    when(
      () => audioOutput.setVolumes(
        bgm: any(named: 'bgm'),
        sfx: any(named: 'sfx'),
      ),
    ).thenAnswer((_) async {});
    return AudioSettingsController(
      loadAudioSettings: load,
      saveAudioSettings: save,
      audioOutput: audioOutput,
    );
  }

  GameController buildGameController({
    required AdventureRepository adventureRepository,
    required ListAvailableActions listAvailableActions,
    required ApplyTurn applyTurn,
    required SaveRepository saveRepository,
    DwarfSystem? dwarfSystem,
  }) {
    when(
      () => adventureRepository.getGameObjects(),
    ).thenAnswer((_) async => const <GameObject>[]);
    final DwarfSystem dwarf = dwarfSystem ?? _MockDwarfSystem();
    if (dwarf is _MockDwarfSystem) {
      when(() => dwarf.tick(any())).thenAnswer((invocation) async {
        final Game game = invocation.positionalArguments.first as Game;
        return DwarfTickResult(game: game);
      });
    }
    return GameController(
      adventureRepository: adventureRepository,
      listAvailableActions: listAvailableActions,
      applyTurn: applyTurn,
      saveRepository: saveRepository,
      dwarfSystem: dwarf,
    );
  }

  _MockNavigatorObserver buildNavigatorObserver() {
    final observer = _MockNavigatorObserver();
    when(() => observer.navigator).thenReturn(null);
    when(() => observer.didPush(any(), any())).thenAnswer((_) {});
    when(() => observer.didChangeTop(any(), any())).thenAnswer((_) {});
    return observer;
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    required GameController gameController,
    required HomeController homeController,
    required AudioSettingsController audioSettingsController,
    bool initializeOnMount = false,
    NavigatorObserver? observer,
    Locale locale = const Locale('fr'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: HomePage(
          gameController: gameController,
          homeController: homeController,
          audioSettingsController: audioSettingsController,
          initializeOnMount: initializeOnMount,
        ),
        navigatorObservers: observer != null
            ? <NavigatorObserver>[observer]
            : const <NavigatorObserver>[],
      ),
    );
    await tester.pump();
  }

  Future<AppLocalizations> loadL10n([Locale locale = const Locale('fr')]) {
    return AppLocalizations.delegate.load(locale);
  }

  group('HomePage', () {
    late _MockAdventureRepository adventureRepository;
    late _MockListAvailableActions listAvailableActions;
    late _MockApplyTurn applyTurn;
    late _MockSaveRepository saveRepository;

    setUp(() {
      adventureRepository = _MockAdventureRepository();
      listAvailableActions = _MockListAvailableActions();
      applyTurn = _MockApplyTurn();
      saveRepository = _MockSaveRepository();
    });

    testWidgets('shows a progress indicator while loading', (tester) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(isLoading: true, autosave: null),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables continue button when no autosave is present', (
      tester,
    ) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(isLoading: false, autosave: null),
      );
      final audioSettingsController = buildAudioSettingsController();
      final observer = buildNavigatorObserver();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
        observer: observer,
      );

      final l10n = await loadL10n();
      final continueLabel = l10n.homeMenuContinueLabel;
      clearInteractions(observer);
      await tester.ensureVisible(find.text(continueLabel));
      await tester.tap(find.text(continueLabel));
      await tester.pumpAndSettle();

      verifyNever(() => observer.didPush(any(), any()));
      expect(find.byType(AdventurePage), findsNothing);
    });

    testWidgets('accented buttons tint icons with their accent color', (
      tester,
    ) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(
          isLoading: false,
          autosave: GameSnapshot(loc: 1, turns: 12, rngSeed: 7),
        ),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      final l10n = await loadL10n();
      final newGameLabel = l10n.homeMenuNewGameLabel;
      final newGameContext = tester.element(find.text(newGameLabel));
      final scheme = Theme.of(newGameContext).colorScheme;
      final Container accentContainer = tester.widget(
        find.byKey(ValueKey('homeMenuAccent-$newGameLabel')),
      );
      final BoxDecoration decoration =
          accentContainer.decoration! as BoxDecoration;
      expect(decoration.color, scheme.primary);

      final Icon icon = tester.widget(find.byIcon(Icons.play_arrow_rounded));
      expect(icon.color, scheme.primary);
    });

    testWidgets('options and credits paint meta accent stripe and tint icons', (
      tester,
    ) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(
          isLoading: false,
          autosave: GameSnapshot(loc: 1, turns: 12, rngSeed: 7),
        ),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      final l10n = await loadL10n();
      final optionsLabel = l10n.homeMenuOptionsLabel;
      final creditsLabel = l10n.homeMenuCreditsLabel;
      final AppActionAccents metaAccents = Theme.of(
        tester.element(find.text(optionsLabel)),
      ).extension<AppActionAccents>()!;

      final Container optionsAccent = tester.widget(
        find.byKey(ValueKey('homeMenuAccent-$optionsLabel')),
      );
      final BoxDecoration optionsDecoration =
          optionsAccent.decoration! as BoxDecoration;
      expect(optionsDecoration.color, metaAccents.meta);

      final Icon optionsIcon = tester.widget(find.byIcon(Icons.tune_rounded));
      expect(optionsIcon.color, metaAccents.meta);

      final Container creditsAccent = tester.widget(
        find.byKey(ValueKey('homeMenuAccent-$creditsLabel')),
      );
      final BoxDecoration creditsDecoration =
          creditsAccent.decoration! as BoxDecoration;
      expect(creditsDecoration.color, metaAccents.meta);

      final Icon creditsIcon = tester.widget(
        find.byIcon(Icons.info_outline_rounded),
      );
      expect(creditsIcon.color, metaAccents.meta);
    });

    testWidgets('disabled accent buttons dim surfaces and typography', (
      tester,
    ) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(isLoading: false, autosave: null),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      final l10n = await loadL10n();
      final continueLabel = l10n.homeMenuContinueLabel;
      final continuerContext = tester.element(find.text(continueLabel));
      final scheme = Theme.of(continuerContext).colorScheme;
      final Color expectedAccent = scheme.secondary.withValues(alpha: 0.3);
      final Color expectedText = scheme.onSurface.withValues(alpha: 0.38);
      final Color expectedBackground = scheme.onSurface.withValues(alpha: 0.12);

      final Container accentContainer = tester.widget(
        find.byKey(ValueKey('homeMenuAccent-$continueLabel')),
      );
      final BoxDecoration decoration =
          accentContainer.decoration! as BoxDecoration;
      expect(decoration.color, expectedAccent);

      final Icon icon = tester.widget(find.byIcon(Icons.bookmark_rounded));
      expect(icon.color, expectedAccent);

      final Ink ink = tester.widget(
        find.ancestor(of: find.text(continueLabel), matching: find.byType(Ink)),
      );
      final BoxDecoration inkDecoration = ink.decoration! as BoxDecoration;
      expect(inkDecoration.color, expectedBackground);

      final Text label = tester.widget(find.text(continueLabel));
      expect(label.style?.color, expectedText);
    });

    testWidgets('hero banner renders through PixelCanvas', (tester) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(
          isLoading: false,
          autosave: GameSnapshot(loc: 1, turns: 12, rngSeed: 7),
        ),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      expect(find.byType(PixelCanvas), findsOneWidget);
    });

    testWidgets('navigates to AdventurePage when new game is tapped', (
      tester,
    ) async {
      const initialGame = Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 42,
        visitedLocations: {1},
      );
      final location = Location(
        id: 1,
        name: 'LOC_START',
        longDescription: 'Long start description',
        shortDescription: 'Short description',
      );
      final actions = <ActionOption>[
        const ActionOption(
          id: 'travel:1->2:WEST',
          category: 'travel',
          label: 'motion.west.label',
          verb: 'WEST',
          objectId: '2',
          icon: 'arrow_back',
        ),
      ];

      when(
        () => adventureRepository.initialGame(),
      ).thenAnswer((_) async => initialGame);
      when(
        () => adventureRepository.locationById(1),
      ).thenAnswer((_) async => location);
      when(
        () => listAvailableActions(initialGame),
      ).thenAnswer((_) async => actions);
      when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(isLoading: false, autosave: null),
      );
      final audioSettingsController = buildAudioSettingsController();
      final observer = buildNavigatorObserver();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
        observer: observer,
      );

      final l10n = await loadL10n();
      final newGameLabel = l10n.homeMenuNewGameLabel;
      clearInteractions(observer);
      await tester.ensureVisible(find.text(newGameLabel));
      await tester.tap(find.text(newGameLabel));
      await tester.pumpAndSettle();

      verify(() => observer.didPush(any(), any())).called(greaterThan(0));
      expect(find.byType(AdventurePage), findsOneWidget);
    });

    testWidgets(
      'navigates to AdventurePage when continue is tapped with autosave',
      (tester) async {
        const snapshot = GameSnapshot(loc: 5, turns: 12, rngSeed: 9);
        const initialGame = Game(
          loc: 1,
          oldLoc: 1,
          newLoc: 1,
          turns: 0,
          rngSeed: 42,
          visitedLocations: {1},
        );
        final location = Location(
          id: 1,
          name: 'LOC_START',
          longDescription: 'Long start description',
        );
        final actions = <ActionOption>[
          const ActionOption(
            id: 'travel:1->2:WEST',
            category: 'travel',
            label: 'motion.west.label',
            verb: 'WEST',
            objectId: '2',
            icon: 'arrow_back',
          ),
        ];

        when(
          () => adventureRepository.initialGame(),
        ).thenAnswer((_) async => initialGame);
        when(
          () => adventureRepository.locationById(1),
        ).thenAnswer((_) async => location);
        when(
          () => listAvailableActions(initialGame),
        ).thenAnswer((_) async => actions);
        when(() => saveRepository.autosave(any())).thenAnswer((_) async {});

        final gameController = buildGameController(
          adventureRepository: adventureRepository,
          listAvailableActions: listAvailableActions,
          applyTurn: applyTurn,
          saveRepository: saveRepository,
        );
        final homeController = buildHomeController(
          saveRepository,
          state: const HomeViewState(isLoading: false, autosave: snapshot),
        );
        final audioSettingsController = buildAudioSettingsController();
        final observer = _MockNavigatorObserver();
        when(() => observer.didPush(any(), any())).thenAnswer((_) {});

        await pumpHome(
          tester,
          gameController: gameController,
          homeController: homeController,
          audioSettingsController: audioSettingsController,
          observer: observer,
        );

        final l10n = await loadL10n();
        final continueLabel = l10n.homeMenuContinueLabel;
        clearInteractions(observer);
        await tester.ensureVisible(find.text(continueLabel));
        await tester.tap(find.text(continueLabel));
        await tester.pumpAndSettle();

        verify(() => observer.didPush(any(), any())).called(greaterThan(0));
        expect(find.byType(AdventurePage), findsOneWidget);
      },
    );

    testWidgets('navigates to SavesPage when load is tapped', (tester) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(isLoading: false, autosave: null),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      final l10n = await loadL10n();
      final loadLabel = l10n.homeMenuLoadLabel;
      await tester.ensureVisible(find.text(loadLabel));
      await tester.tap(find.text(loadLabel));
      await tester.pumpAndSettle();

      expect(find.byType(SavesPage), findsOneWidget);
    });

    testWidgets('navigates to SettingsPage when options is tapped', (
      tester,
    ) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(isLoading: false, autosave: null),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      final l10n = await loadL10n();
      final optionsLabel = l10n.homeMenuOptionsLabel;
      await tester.ensureVisible(find.text(optionsLabel));
      await tester.tap(find.text(optionsLabel));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('navigates to CreditsPage when credits is tapped', (
      tester,
    ) async {
      final gameController = buildGameController(
        adventureRepository: adventureRepository,
        listAvailableActions: listAvailableActions,
        applyTurn: applyTurn,
        saveRepository: saveRepository,
      );
      final homeController = buildHomeController(
        saveRepository,
        state: const HomeViewState(isLoading: false, autosave: null),
      );
      final audioSettingsController = buildAudioSettingsController();

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
      );

      final l10n = await loadL10n();
      final creditsLabel = l10n.homeMenuCreditsLabel;
      await tester.ensureVisible(find.text(creditsLabel));
      await tester.tap(find.text(creditsLabel));
      await tester.pumpAndSettle();

      expect(find.byType(CreditsPage), findsOneWidget);
    });
  });
}
