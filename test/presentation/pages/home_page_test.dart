import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/audio_settings_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/command.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';
import 'package:open_adventure/presentation/pages/credits_page.dart';
import 'package:open_adventure/presentation/pages/home_page.dart';
import 'package:open_adventure/presentation/pages/saves_page.dart';
import 'package:open_adventure/presentation/pages/settings_page.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock
    implements ListAvailableActionsTravel {}

class _MockApplyTurnGoto extends Mock implements ApplyTurnGoto {}

class _MockSaveRepository extends Mock implements SaveRepository {}

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _FakeRoute<T> extends Fake implements Route<T> {}

class _MockAudioOutput extends Mock implements AudioOutput {}

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
    registerFallbackValue(const Command(verb: 'NORTH'));
    registerFallbackValue(const Game(
      loc: 0,
      oldLoc: 0,
      newLoc: 0,
      turns: 0,
      rngSeed: 0,
    ));
    registerFallbackValue(const GameSnapshot(loc: 0, turns: 0, rngSeed: 0));
    registerFallbackValue(_FakeRoute<dynamic>());
  });

  HomeController buildHomeController(SaveRepository repository,
      {HomeViewState? state}) {
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
    when(() => audioOutput.setVolumes(bgm: any(named: 'bgm'), sfx: any(named: 'sfx')))
        .thenAnswer((_) async {});
    return AudioSettingsController(
      loadAudioSettings: load,
      saveAudioSettings: save,
      audioOutput: audioOutput,
    );
  }

  GameController buildGameController({
    required AdventureRepository adventureRepository,
    required ListAvailableActionsTravel listAvailableActions,
    required ApplyTurnGoto applyTurn,
    required SaveRepository saveRepository,
  }) {
    return GameController(
      adventureRepository: adventureRepository,
      listAvailableActions: listAvailableActions,
      applyTurn: applyTurn,
      saveRepository: saveRepository,
    );
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    required GameController gameController,
    required HomeController homeController,
    required AudioSettingsController audioSettingsController,
    bool initializeOnMount = false,
    NavigatorObserver? observer,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          gameController: gameController,
          homeController: homeController,
          audioSettingsController: audioSettingsController,
          initializeOnMount: initializeOnMount,
        ),
        navigatorObservers: observer != null ? <NavigatorObserver>[observer] : const <NavigatorObserver>[],
      ),
    );
  }

  group('HomePage', () {
    late _MockAdventureRepository adventureRepository;
    late _MockListAvailableActions listAvailableActions;
    late _MockApplyTurnGoto applyTurn;
    late _MockSaveRepository saveRepository;

    setUp(() {
      adventureRepository = _MockAdventureRepository();
      listAvailableActions = _MockListAvailableActions();
      applyTurn = _MockApplyTurnGoto();
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

    testWidgets('disables Continuer button when no autosave is present',
        (tester) async {
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
      final observer = _MockNavigatorObserver();
      when(() => observer.didPush(any(), any())).thenAnswer((_) {});

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
        observer: observer,
      );

      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      verifyNever(() => observer.didPush(any(), any()));
      expect(find.byType(AdventurePage), findsNothing);
    });

    testWidgets('navigates to AdventurePage when Nouvelle partie is tapped',
        (tester) async {
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

      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => initialGame);
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => location);
      when(() => listAvailableActions(initialGame)).thenAnswer((_) async => actions);
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
      final observer = _MockNavigatorObserver();
      when(() => observer.didPush(any(), any())).thenAnswer((_) {});

      await pumpHome(
        tester,
        gameController: gameController,
        homeController: homeController,
        audioSettingsController: audioSettingsController,
        observer: observer,
      );

      await tester.tap(find.text('Nouvelle partie'));
      await tester.pumpAndSettle();

      verify(() => observer.didPush(any(), any())).called(greaterThan(0));
      expect(find.byType(AdventurePage), findsOneWidget);
    });

    testWidgets('navigates to AdventurePage when Continuer is tapped with autosave',
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

      when(() => adventureRepository.initialGame())
          .thenAnswer((_) async => initialGame);
      when(() => adventureRepository.locationById(1))
          .thenAnswer((_) async => location);
      when(() => listAvailableActions(initialGame)).thenAnswer((_) async => actions);
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

      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      verify(() => observer.didPush(any(), any())).called(greaterThan(0));
      expect(find.byType(AdventurePage), findsOneWidget);
    });

    testWidgets('navigates to SavesPage when Charger is tapped', (tester) async {
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

      await tester.tap(find.text('Charger'));
      await tester.pumpAndSettle();

      expect(find.byType(SavesPage), findsOneWidget);
    });

    testWidgets('navigates to SettingsPage when Options is tapped', (tester) async {
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

      await tester.tap(find.text('Options'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('navigates to CreditsPage when Crédits is tapped', (tester) async {
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

      await tester.tap(find.text('Crédits'));
      await tester.pumpAndSettle();

      expect(find.byType(CreditsPage), findsOneWidget);
    });
  });
}
