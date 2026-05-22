// Tests the Riverpod wiring introduced by Story 5-6 :
//   - dependency providers can be overridden via `ProviderContainer`
//   - `gameStateProvider` resolves synchronously to a fully-wired
//     `GameNotifier` exposed as `StateNotifierProvider<GameNotifier,
//     GameViewState>` (AC2)
//   - autosave is triggered exactly once per successful turn through the
//     notifier obtained from the provider (AC7 — règle non négociable)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/providers/dependencies.dart';
import 'package:open_adventure/application/providers/game_state_provider.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/dwarf_tick_result.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';
import 'package:open_adventure/domain/value_objects/turn_result.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

class _MockSaveRepository extends Mock implements SaveRepository {}

class _MockListAvailableActions extends Mock implements ListAvailableActions {}

class _MockApplyTurn extends Mock implements ApplyTurn {}

class _MockDwarfSystem extends Mock implements DwarfSystem {}

const _initial = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);

const _location = Location(id: 1, name: 'Test Loc');

const _gotoAction = ActionOption(
  id: 'travel.north',
  category: 'travel',
  label: 'actions.travel.north',
  verb: 'NORTH',
);

ProviderContainer _buildContainer({
  required AdventureRepository repo,
  required ListAvailableActions actions,
  required ApplyTurn apply,
  required SaveRepository save,
  required DwarfSystem dwarfs,
}) {
  return ProviderContainer(
    overrides: <Override>[
      adventureRepositoryProvider.overrideWithValue(repo),
      saveRepositoryProvider.overrideWithValue(save),
      listAvailableActionsProvider.overrideWithValue(actions),
      applyTurnProvider.overrideWithValue(apply),
      dwarfSystemProvider.overrideWithValue(dwarfs),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_initial);
    registerFallbackValue(const GameSnapshot(loc: 0, turns: 0, rngSeed: 0));
    registerFallbackValue(_gotoAction);
  });

  group('Story 5-6 — Riverpod wiring', () {
    late _MockAdventureRepository repo;
    late _MockSaveRepository save;
    late _MockListAvailableActions list;
    late _MockApplyTurn apply;
    late _MockDwarfSystem dwarfs;

    setUp(() {
      repo = _MockAdventureRepository();
      save = _MockSaveRepository();
      list = _MockListAvailableActions();
      apply = _MockApplyTurn();
      dwarfs = _MockDwarfSystem();

      when(() => repo.getGameObjects()).thenAnswer((_) async => <GameObject>[]);
      when(() => repo.initialGame()).thenAnswer((_) async => _initial);
      when(() => repo.locationById(any())).thenAnswer((_) async => _location);
      when(() => save.autosave(any())).thenAnswer((_) async {});
      when(() => list(any())).thenAnswer((_) async => const <ActionOption>[]);
      when(() => dwarfs.tick(any())).thenAnswer(
        (invocation) async => DwarfTickResult(
          game: invocation.positionalArguments[0] as Game,
          messages: const <String>[],
        ),
      );
    });

    test('gameStateProvider exposes a StateNotifierProvider and resolves '
        'synchronously to a GameNotifier (AC2)', () {
      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
      );
      addTearDown(container.dispose);

      // Reading via `.notifier` returns the GameNotifier instance.
      final notifier = container.read(gameStateProvider.notifier);
      expect(notifier, isA<GameNotifier>());

      // Reading the provider directly returns the GameViewState (initial).
      final state = container.read(gameStateProvider);
      expect(state, isA<GameViewState>());
      expect(state.isLoading, isTrue,
          reason: 'init() not auto-invoked — UI decides (AC5).');
      expect(state.game, isNull);
    });

    test('init() triggers autosave exactly once (AC7 règle non négociable)',
        () async {
      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameStateProvider.notifier);
      await notifier.init();

      verify(() => save.autosave(any())).called(1);
      expect(container.read(gameStateProvider).isLoading, isFalse);
      expect(container.read(gameStateProvider).game, equals(_initial));
    });

    test('perform() triggers autosave exactly once on successful turn '
        '(AC6 boucle de tour 1→11 préservée)', () async {
      const nextGame = Game(loc: 2, oldLoc: 1, newLoc: 2, turns: 1, rngSeed: 42);
      when(() => apply(_gotoAction, _initial))
          .thenAnswer((_) async => TurnResult(nextGame, const <String>[]));

      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameStateProvider.notifier);
      await notifier.init();
      // Reset call counter to assert only the perform-triggered autosave.
      clearInteractions(save);

      await notifier.perform(_gotoAction);

      verify(() => save.autosave(any())).called(1);
      expect(container.read(gameStateProvider).game, equals(nextGame));
    });

    test('ref.watch(gameStateProvider) rebuilds emit on state change',
        () async {
      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
      );
      addTearDown(container.dispose);

      final received = <bool>[];
      final sub = container.listen<GameViewState>(
        gameStateProvider,
        (_, next) => received.add(next.isLoading),
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container.read(gameStateProvider.notifier).init();

      // At least one update should have been received with isLoading == false.
      expect(received, contains(false));
    });

    test('listenable adapter receives state updates (AC10 transitional)',
        () async {
      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameStateProvider.notifier);
      // ignore: deprecated_member_use_from_same_package
      final listenable = notifier.listenable;
      final received = <bool>[];
      listener() => received.add(listenable.value.isLoading);
      listenable.addListener(listener);
      addTearDown(() => listenable.removeListener(listener));

      await notifier.init();
      // At least one update should have been received with isLoading == false.
      expect(received, contains(false));
    });
  });
}
