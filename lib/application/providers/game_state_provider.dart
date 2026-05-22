// `gameStateProvider` — main Riverpod entry point for the game state.
// Story 5-6 — Migration GameController → Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/game_controller.dart';
import 'dependencies.dart';

/// Synchronous factory that wires the [GameNotifier] from its dependency
/// providers. Exposed only via [gameStateProvider] — kept private so the
/// surface area of the public API stays minimal.
final _gameNotifierFactoryProvider = Provider<GameNotifier>(
  (ref) {
    // No `ref.onDispose(notifier.dispose)` here : the parent
    // [StateNotifierProvider] is responsible for disposing the
    // `StateNotifier` returned by this factory. Doing both leads to a
    // double-dispose error.
    return GameNotifier(
      adventureRepository: ref.watch(adventureRepositoryProvider),
      listAvailableActions: ref.watch(listAvailableActionsProvider),
      applyTurn: ref.watch(applyTurnProvider),
      saveRepository: ref.watch(saveRepositoryProvider),
      dwarfSystem: ref.watch(dwarfSystemProvider),
    );
  },
  name: '_gameNotifierFactoryProvider',
);

/// Main entry point used by the Presentation layer.
///
/// Consumers either :
///   * `ref.watch(gameStateProvider)` to rebuild on every state change ;
///   * `ref.read(gameStateProvider.notifier)` to call methods (`init()`,
///     `perform()`, etc.) without subscribing.
///
/// The `init()` call is **not** triggered automatically — the UI decides
/// when to start the game (cf. Story 5-6 AC5).
final gameStateProvider =
    StateNotifierProvider<GameNotifier, GameViewState>((ref) {
  return ref.watch(_gameNotifierFactoryProvider);
}, name: 'gameStateProvider');
