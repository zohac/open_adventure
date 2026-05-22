// Tests the Riverpod wiring introduced by Story 5-6 :
//   - dependency providers can be overridden via `ProviderContainer`
//   - `gameStateProvider` resolves to a fully-wired `GameNotifier`
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
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
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

class _MockMotion extends Mock implements MotionCanonicalizer {}

const _initial = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);

const _location = Location(
  id: 1,
  name: 'Test Loc',
);

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
  required MotionCanonicalizer motion,
}) {
  return ProviderContainer(
    overrides: <Override>[
      adventureRepositoryProvider.overrideWithValue(repo),
      saveRepositoryProvider.overrideWithValue(save),
      motionNormalizerProvider.overrideWith((ref) async => motion),
      listAvailableActionsProvider.overrideWith((ref) async => actions),
      applyTurnProvider.overrideWith((ref) async => apply),
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
    late _MockMotion motion;

    setUp(() {
      repo = _MockAdventureRepository();
      save = _MockSaveRepository();
      list = _MockListAvailableActions();
      apply = _MockApplyTurn();
      dwarfs = _MockDwarfSystem();
      motion = _MockMotion();

      when(() => repo.getGameObjects()).thenAnswer((_) async => <GameObject>[]);
      when(() => repo.initialGame()).thenAnswer((_) async => _initial);
      when(() => repo.locationById(any())).thenAnswer((_) async => _location);
      when(() => save.autosave(any())).thenAnswer((_) async {});
      when(() => list(any())).thenAnswer((_) async => const <ActionOption>[]);
      when(() => dwarfs.tick(any()))
          .thenAnswer((invocation) async => DwarfTickResult(
                game: invocation.positionalArguments[0] as Game,
                messages: const <String>[],
              ));
    });

    test('gameStateProvider resolves to a wired GameNotifier', () async {
      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
        motion: motion,
      );
      addTearDown(container.dispose);

      final notifier = await container.read(gameStateProvider.future);
      expect(notifier, isA<GameNotifier>());
      expect(notifier.state.isLoading, isTrue,
          reason: 'init() not auto-invoked — UI decides (AC5).');
    });

    test('init() through provider triggers autosave exactly once', () async {
      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
        motion: motion,
      );
      addTearDown(container.dispose);

      final notifier = await container.read(gameStateProvider.future);
      await notifier.init();

      verify(() => save.autosave(any())).called(1);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.game, equals(_initial));
    });

    test('perform() through provider triggers autosave exactly once on '
        'successful turn (AC6 boucle de tour préservée)', () async {
      const nextGame = Game(loc: 2, oldLoc: 1, newLoc: 2, turns: 1, rngSeed: 42);
      when(() => apply(_gotoAction, _initial))
          .thenAnswer((_) async => TurnResult(nextGame, const <String>[]));

      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
        motion: motion,
      );
      addTearDown(container.dispose);

      final notifier = await container.read(gameStateProvider.future);
      await notifier.init();
      // Reset call counter to assert only the perform-triggered autosave.
      clearInteractions(save);

      await notifier.perform(_gotoAction);

      verify(() => save.autosave(any())).called(1);
      expect(notifier.state.game, equals(nextGame));
    });

    test('listenable adapter receives state updates (AC10 transitional)',
        () async {
      final container = _buildContainer(
        repo: repo,
        actions: list,
        apply: apply,
        save: save,
        dwarfs: dwarfs,
        motion: motion,
      );
      addTearDown(container.dispose);

      final notifier = await container.read(gameStateProvider.future);
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
