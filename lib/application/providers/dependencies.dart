// Application-level Riverpod providers wiring every gameplay dependency.
// Story 5-6 — Migration GameController → Riverpod.
//
// Convention "full Riverpod" (cf. `docs/dev-notes/riverpod-playbook.md`) :
// repositories, use cases and services are exposed as `Provider<T>` and
// composed via `ref.watch`. Domain stays Riverpod-free.
//
// All providers are **synchronous** : the only async dependency
// (`MotionCanonicalizer` loaded from JSON) is resolved before the
// `ProviderScope` is mounted and injected via an `overrideWithValue`
// at the root (cf. `lib/main.dart`). Test harnesses do the same with
// `MotionCanonicalizer` mocks.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/repositories/save_repository_impl.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
import 'package:open_adventure/domain/usecases/apply_turn.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/usecases/close_object.dart';
import 'package:open_adventure/domain/usecases/drink_liquid.dart';
import 'package:open_adventure/domain/usecases/drop_object.dart';
import 'package:open_adventure/domain/usecases/evaluate_condition.dart';
import 'package:open_adventure/domain/usecases/examine.dart';
import 'package:open_adventure/domain/usecases/extinguish_lamp.dart';
import 'package:open_adventure/domain/usecases/light_lamp.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/usecases/open_object.dart';
import 'package:open_adventure/domain/usecases/take_object.dart';

/// Adventure repository (JSON assets + caches).
final adventureRepositoryProvider = Provider<AdventureRepository>(
  (ref) => AdventureRepositoryImpl(),
  name: 'adventureRepositoryProvider',
);

/// Save repository (autosave + future multi-save).
final saveRepositoryProvider = Provider<SaveRepository>(
  (ref) => SaveRepositoryImpl(),
  name: 'saveRepositoryProvider',
);

/// Motion canonicalizer. **Always overridden** at the root [ProviderScope]
/// because the concrete `MotionNormalizerImpl.load()` is async (JSON parse).
/// The override happens once at app bootstrap (`lib/main.dart`) — all
/// downstream providers are synchronous from that point on.
final motionNormalizerProvider = Provider<MotionCanonicalizer>(
  (ref) {
    throw StateError(
      'motionNormalizerProvider must be overridden at the ProviderScope root. '
      'Bootstrap should call `MotionNormalizerImpl.load()` and inject the '
      'instance via `overrideWithValue` (see lib/main.dart).',
    );
  },
  name: 'motionNormalizerProvider',
);

/// `EvaluateCondition` use case (pure, no dependency).
final evaluateConditionProvider = Provider<EvaluateCondition>(
  (ref) => const EvaluateConditionImpl(),
  name: 'evaluateConditionProvider',
);

/// `ListAvailableActions` orchestrator (synchronous — depends on motion
/// resolved at root).
final listAvailableActionsProvider = Provider<ListAvailableActions>(
  (ref) {
    final repo = ref.watch(adventureRepositoryProvider);
    final motion = ref.watch(motionNormalizerProvider);
    final evaluate = ref.watch(evaluateConditionProvider);
    return ListAvailableActions(
      adventureRepository: repo,
      travel: ListAvailableActionsTravel(repo, motion),
      evaluateCondition: evaluate,
    );
  },
  name: 'listAvailableActionsProvider',
);

/// `ApplyTurn` router (synchronous — composes all interaction use cases).
final applyTurnProvider = Provider<ApplyTurn>(
  (ref) {
    final repo = ref.watch(adventureRepositoryProvider);
    final motion = ref.watch(motionNormalizerProvider);
    return ApplyTurn(
      travel: ApplyTurnGoto(repo, motion),
      examine: ExamineImpl(adventureRepository: repo),
      takeObject: TakeObjectImpl(adventureRepository: repo),
      dropObject: DropObjectImpl(adventureRepository: repo),
      openObject: OpenObjectImpl(adventureRepository: repo),
      closeObject: CloseObjectImpl(adventureRepository: repo),
      lightLamp: LightLampImpl(adventureRepository: repo),
      extinguishLamp: ExtinguishLampImpl(adventureRepository: repo),
      drinkLiquid: DrinkLiquidImpl(adventureRepository: repo),
    );
  },
  name: 'applyTurnProvider',
);

/// Dwarf system (depends on adventure repository for arbitrary messages).
final dwarfSystemProvider = Provider<DwarfSystem>(
  (ref) => DwarfSystem(ref.watch(adventureRepositoryProvider)),
  name: 'dwarfSystemProvider',
);
