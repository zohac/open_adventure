// Application-level Riverpod providers wiring every gameplay dependency.
// Story 5-6 — Migration GameController → Riverpod.
//
// Convention "full Riverpod" (cf. `docs/dev-notes/riverpod-playbook.md`) :
// repositories, use cases and services are exposed as `Provider<T>` and
// composed via `ref.watch`. Domain stays Riverpod-free.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/repositories/save_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
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

/// Async motion normalizer (loads canonical motion table from JSON).
final motionNormalizerProvider = FutureProvider<MotionCanonicalizer>(
  (ref) => MotionNormalizerImpl.load(),
  name: 'motionNormalizerProvider',
);

/// `EvaluateCondition` use case (pure, no dependency).
final evaluateConditionProvider = Provider<EvaluateCondition>(
  (ref) => const EvaluateConditionImpl(),
  name: 'evaluateConditionProvider',
);

/// `ListAvailableActions` orchestrator (depends on motion normalizer).
final listAvailableActionsProvider = FutureProvider<ListAvailableActions>(
  (ref) async {
    final repo = ref.watch(adventureRepositoryProvider);
    final motion = await ref.watch(motionNormalizerProvider.future);
    final evaluate = ref.watch(evaluateConditionProvider);
    final travel = ListAvailableActionsTravel(repo, motion);
    return ListAvailableActions(
      adventureRepository: repo,
      travel: travel,
      evaluateCondition: evaluate,
    );
  },
  name: 'listAvailableActionsProvider',
);

/// `ApplyTurn` router (composes all interaction use cases).
final applyTurnProvider = FutureProvider<ApplyTurn>(
  (ref) async {
    final repo = ref.watch(adventureRepositoryProvider);
    final motion = await ref.watch(motionNormalizerProvider.future);
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
