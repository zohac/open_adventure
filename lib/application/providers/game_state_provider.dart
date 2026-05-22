// `gameStateProvider` — main Riverpod entry point for the game state.
// Story 5-6 — Migration GameController → Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/game_controller.dart';
import 'dependencies.dart';

/// Asynchronous factory that wires the [GameNotifier] from its dependency
/// providers. Exposed indirectly via [gameStateProvider] so consumers see
/// a synchronous `StateNotifierProvider`.
final _gameNotifierFactoryProvider = FutureProvider<GameNotifier>(
  (ref) async {
    final repo = ref.watch(adventureRepositoryProvider);
    final listActions = await ref.watch(listAvailableActionsProvider.future);
    final apply = await ref.watch(applyTurnProvider.future);
    final save = ref.watch(saveRepositoryProvider);
    final dwarfs = ref.watch(dwarfSystemProvider);
    final notifier = GameNotifier(
      adventureRepository: repo,
      listAvailableActions: listActions,
      applyTurn: apply,
      saveRepository: save,
      dwarfSystem: dwarfs,
    );
    ref.onDispose(notifier.dispose);
    return notifier;
  },
  name: '_gameNotifierFactoryProvider',
);

/// Main entry point used by the Presentation layer (post 5-7/5-9).
///
/// Resolves only once the async dependencies (motion normalizer parsing)
/// have completed. Consumers that need synchronous state can either :
///  * `ref.watch(gameStateProvider).whenData(...)` to react to the
///    [GameNotifier] becoming ready ;
///  * read the `state` once the `AsyncData` arrives.
///
/// The `init()` call is **not** triggered automatically — the UI decides
/// when to start the game (cf. Story 5-6 AC5).
final gameStateProvider = FutureProvider<GameNotifier>(
  (ref) => ref.watch(_gameNotifierFactoryProvider.future),
  name: 'gameStateProvider',
);
