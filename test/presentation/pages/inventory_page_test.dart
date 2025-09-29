import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/dwarf_tick_result.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/l10n/app_localizations.dart';
import 'package:open_adventure/presentation/pages/inventory_page.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockListAvailableActions extends Mock implements ListAvailableActions {}

class _MockApplyTurn extends Mock implements ApplyTurn {}

class _MockSaveRepository extends Mock implements SaveRepository {}

class _MockDwarfSystem extends Mock implements DwarfSystem {}

class _TestGameController extends GameController {
  _TestGameController({
    required super.adventureRepository,
    required super.listAvailableActions,
    required super.applyTurn,
    required super.saveRepository,
    required super.dwarfSystem,
  });

  ActionOption? performed;

  @override
  Future<void> perform(ActionOption option) async {
    performed = option;
    value = value.copyWith(flashMessage: 'Journal entry for ${option.verb}');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const ActionOption(
        id: 'noop',
        category: 'interaction',
        label: 'actions.interaction.examine.LAMP',
        verb: 'EXAMINE',
        objectId: '0',
      ),
    );
    registerFallbackValue(
      const Game(loc: 0, oldLoc: 0, newLoc: 0, turns: 0, rngSeed: 0),
    );
    registerFallbackValue(const GameSnapshot(loc: 0, turns: 0, rngSeed: 0));
  });

  late _MockAdventureRepository adventureRepository;
  late _MockListAvailableActions listAvailableActions;
  late _MockApplyTurn applyTurn;
  late _MockSaveRepository saveRepository;
  late _MockDwarfSystem dwarfSystem;
  late _TestGameController controller;

  setUp(() {
    adventureRepository = _MockAdventureRepository();
    listAvailableActions = _MockListAvailableActions();
    applyTurn = _MockApplyTurn();
    saveRepository = _MockSaveRepository();
    dwarfSystem = _MockDwarfSystem();

    when(
      () => adventureRepository.getGameObjects(),
    ).thenAnswer((_) async => const <GameObject>[]);
    when(() => adventureRepository.initialGame()).thenAnswer(
      (_) async =>
          const Game(loc: 0, oldLoc: 0, newLoc: 0, turns: 0, rngSeed: 0),
    );
    when(
      () => adventureRepository.locationById(any()),
    ).thenAnswer((_) async => throw UnimplementedError());
    when(
      () => listAvailableActions(any()),
    ).thenAnswer((_) async => const <ActionOption>[]);
    when(() => saveRepository.autosave(any())).thenAnswer((_) async {});
    when(() => dwarfSystem.tick(any())).thenAnswer((invocation) async {
      final Game game = invocation.positionalArguments.first as Game;
      return DwarfTickResult(game: game);
    });

    controller = _TestGameController(
      adventureRepository: adventureRepository,
      listAvailableActions: listAvailableActions,
      applyTurn: applyTurn,
      saveRepository: saveRepository,
      dwarfSystem: dwarfSystem,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  Future<void> pumpInventoryPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: InventoryPage(controller: controller),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders carried items with contextual actions', (tester) async {
    const dropAction = ActionOption(
      id: 'interaction:drop:10',
      category: 'interaction',
      label: 'actions.interaction.drop.LAMP',
      icon: 'file_upload',
      verb: 'DROP',
      objectId: '10',
    );
    const lightAction = ActionOption(
      id: 'interaction:light:10',
      category: 'interaction',
      label: 'actions.interaction.light.LAMP',
      icon: 'flash_on',
      verb: 'LIGHT',
      objectId: '10',
    );
    const extinguishAction = ActionOption(
      id: 'interaction:extinguish:10',
      category: 'interaction',
      label: 'actions.interaction.extinguish.LAMP',
      icon: 'flash_off',
      verb: 'EXTINGUISH',
      objectId: '10',
    );

    controller.debugSeedObjectIndex(const <GameObject>[
      GameObject(id: 10, name: 'LAMP'),
    ]);
    controller.value = GameViewState(
      game: const Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 42,
        objectStates: {10: GameObjectState(id: 10, isCarried: true)},
      ),
      locationTitle: 'LOC_START',
      locationMapTag: null,
      locationId: 1,
      locationDescription: 'desc',
      actions: const <ActionOption>[dropAction, lightAction, extinguishAction],
      journal: const <String>[],
      isLoading: false,
      flashMessage: null,
    );

    await pumpInventoryPage(tester);

    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Brass lantern'), findsOneWidget);
    expect(find.text('Drop Brass lantern'), findsOneWidget);
    expect(find.text('Light Brass lantern'), findsOneWidget);
    expect(find.text('Extinguish Brass lantern'), findsOneWidget);

    await tester.tap(find.text('Drop Brass lantern'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(controller.performed, equals(dropAction));
    final bannerFinder = find.byType(MaterialBanner);
    expect(bannerFinder, findsOneWidget);
    final MaterialBanner banner = tester.widget(bannerFinder);
    final Text content = banner.content as Text;
    expect(content.data, equals('Journal entry for DROP'));
  });

  testWidgets('displays drink action for bottle with water', (tester) async {
    const drinkAction = ActionOption(
      id: 'interaction:drink:11',
      category: 'interaction',
      label: 'actions.interaction.drink.BOTTLE',
      icon: 'local_drink',
      verb: 'DRINK',
      objectId: '11',
    );

    controller.debugSeedObjectIndex(const <GameObject>[
      GameObject(id: 11, name: 'BOTTLE'),
    ]);
    controller.value = GameViewState(
      game: const Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 42,
        objectStates: {11: GameObjectState(id: 11, isCarried: true)},
      ),
      locationTitle: 'LOC_START',
      locationMapTag: null,
      locationId: 1,
      locationDescription: 'desc',
      actions: const <ActionOption>[drinkAction],
      journal: const <String>[],
      isLoading: false,
      flashMessage: null,
    );

    await pumpInventoryPage(tester);

    expect(find.text('Drink Small bottle'), findsOneWidget);

    await tester.tap(find.text('Drink Small bottle'));
    await tester.pump();

    expect(controller.performed, equals(drinkAction));
  });

  testWidgets('shows empty placeholder when nothing is carried', (
    tester,
  ) async {
    controller.value = GameViewState(
      game: const Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 42,
        objectStates: {},
      ),
      locationTitle: 'LOC_START',
      locationMapTag: null,
      locationId: 1,
      locationDescription: 'desc',
      actions: const <ActionOption>[],
      journal: const <String>[],
      isLoading: false,
      flashMessage: null,
    );

    await pumpInventoryPage(tester);

    expect(find.text('You are not carrying anything.'), findsOneWidget);
  });

  testWidgets('renders no-action placeholder when object has no actions', (
    tester,
  ) async {
    controller.debugSeedObjectIndex(const <GameObject>[
      GameObject(id: 25, name: 'COINS'),
    ]);
    controller.value = GameViewState(
      game: const Game(
        loc: 1,
        oldLoc: 1,
        newLoc: 1,
        turns: 0,
        rngSeed: 42,
        objectStates: {25: GameObjectState(id: 25, isCarried: true)},
      ),
      locationTitle: 'LOC_START',
      locationMapTag: null,
      locationId: 1,
      locationDescription: 'desc',
      actions: const <ActionOption>[],
      journal: const <String>[],
      isLoading: false,
      flashMessage: null,
    );

    await pumpInventoryPage(tester);

    expect(find.text('Rare coins'), findsOneWidget);
    expect(find.text('No contextual actions available'), findsOneWidget);
  });
}
