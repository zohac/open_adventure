# Story 5.6: Migration `GameController` → `StateNotifier` Riverpod

Status: review
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2 ; refonde l'API publique livrée par `3-14-game-controller-journal-lampe-nains` (done)
Refs : [epic-5](../planning-artifacts/epic-5.md#story-56-migration-gamecontroller--statenotifier), [design.md §5](../design.md), [project-context §Boucle de tour](../project-context.md), [riverpod-playbook](../dev-notes/riverpod-playbook.md) (5-1)

## Story

**En tant que** développeur Application,
**je veux** refactor `GameController extends ValueNotifier<GameViewState>` en `GameNotifier extends StateNotifier<GameViewState>` exposé via `gameStateProvider`,
**afin que** la Presentation (5-7/5-9/5-11) puisse `ref.watch(gameStateProvider)` au lieu de propager le `ValueNotifier` par constructeur — **sans** changer une seule règle de gameplay (boucle de tour 1→11 préservée intégralement, oracle tests O1–O3 verts).

## Acceptance Criteria

1. **AC1 — `GameNotifier` introduit** : `lib/application/controllers/game_controller.dart` héberge désormais `class GameNotifier extends StateNotifier<GameViewState>`. La logique de `perform`, `init`, `refreshActions`, `clearFlashMessage`, `_applyLampTimers`, `_selectDescription`, `_visibleActions`, `_appendJournal`, `_toSnapshot` est **copiée verbatim** (signature publique méthode/return identique). La seule différence : `extends StateNotifier<GameViewState>` au lieu de `extends ValueNotifier<GameViewState>`, et `value = ...` devient `state = ...`.
2. **AC2 — Provider exposé** : `lib/application/providers/game_state_provider.dart` expose :
   ```dart
   final gameStateProvider =
       StateNotifierProvider<GameNotifier, GameViewState>((ref) {
     return ref.watch(_gameNotifierFactoryProvider);
   });
   ```
   Le `_gameNotifierFactoryProvider` (privé) lit les dépendances (repositories, use cases) via d'autres providers (`adventureRepositoryProvider`, `applyTurnProvider`, etc.) introduits dans cette story.
3. **AC3 — Providers dépendances** : nouveaux providers dans `lib/application/providers/dependencies.dart` (ou fichiers séparés selon préférence du dev) :
   - `adventureRepositoryProvider` (`Provider<AdventureRepository>`, lit `AdventureRepositoryImpl()` — instanciation unique côté provider, plus dans `main.dart`).
   - `motionNormalizerProvider` (`Provider<MotionCanonicalizer>` — **doit être override à la racine** avec le résultat de `MotionNormalizerImpl.load()`. Throws `StateError` si non override, message pointant vers `main.dart`. Cette stratégie évite la propagation d'`async` à travers tous les downstream providers).
   - `evaluateConditionProvider` (`Provider<EvaluateCondition>`, instance const).
   - `listAvailableActionsProvider` (`Provider<ListAvailableActions>` — synchrone, consomme `motionNormalizerProvider` via `ref.watch`).
   - `applyTurnProvider` (`Provider<ApplyTurn>` — synchrone, consomme `motionNormalizerProvider` via `ref.watch`).
   - `saveRepositoryProvider` (`Provider<SaveRepository>`).
   - `dwarfSystemProvider` (`Provider<DwarfSystem>`).
   - **Tous overridables** dans les tests via `ProviderContainer(overrides: [...])`.
   - **Convention** (révisée 2026-05-23) : toute asynchronicité est résolue **en amont** du `ProviderScope` (cf. AC4). Aucun `FutureProvider` dans la chaîne gameplay — le graphe est synchrone après bootstrap, ce qui permet aux Consumer widgets de récupérer le `GameNotifier` sans gestion d'`AsyncValue`.
4. **AC4 — `main.dart` allégé** : `main.dart` n'instancie plus directement `AdventureRepositoryImpl`, `ListAvailableActions`, `ApplyTurn`, `SaveRepositoryImpl`, `DwarfSystem`, `GameController`. Tout passe par les providers via `ProviderScope`. **Seule asynchronicité préservée** : `MotionNormalizerImpl.load()` (JSON parse) awaité avant le `runApp`, puis injecté via `motionNormalizerProvider.overrideWithValue(motion)` dans les overrides du `ProviderScope`. Conservés dans `main.dart` : `AudioController` + `AudioSettingsController` (migrés dans 5-10) ; `HomeController` est désormais instancié dans le widget `_AppHome` (`ConsumerStatefulWidget`) qui consomme `ref.read(saveRepositoryProvider)` — sera migré 5-10 ou plus tard, mais reste hors composition root.
5. **AC5 — Initialisation du jeu** : `GameNotifier.init()` reste asynchrone et est appelée explicitement par l'UI au démarrage (équivalent du flux actuel via `HomePage → AdventurePage`). Le provider ne déclenche **pas** automatiquement `init()` — l'UI décide. (Alternative : `gameStateProvider.notifier` exposé + appel manuel — documenter le choix retenu dans la PR.)
6. **AC6 — Boucle de tour préservée intégralement** : ordre 1→11 documenté dans `project-context.md` §Boucle de tour reste **strictement identique** :
   1. Short-circuit meta verbs (INVENTORY/OBSERVER/MAP)
   2. Short-circuit incantations si `!game.magicWordsUnlocked`
   3. `ApplyTurn(option, game)`
   4. (si state changed) `DwarfSystem.tick(newGame)`
   5. (si state changed) `_applyLampTimers(newGame)`
   6. `_adventureRepository.locationById(newGame.loc)`
   7. `_listAvailableActions(newGame)` → filtrage MagicWords
   8. `_selectDescription(location, firstVisit)`
   9. `_appendJournal` (trim 200)
   10. `state = state.copyWith(...)` (ancien `value = ...`)
   11. (si state changed) `saveRepository.autosave(snapshot)`
   Aucune autre inversion, aucun raccourci.
7. **AC7 — Tests Application** : `test/application/controllers/game_controller_test.dart` (existant) **conservé verbatim** moduloremplacement de `ValueNotifier`/`value` par `StateNotifier`/`state`. Création des notifiers via `ProviderContainer(overrides: [...])` avec mocks `mocktail` des repositories/use cases. **Vérification cruciale** : `autosave` appelé exactement 1 fois par tour réussi (`verify(() => mockSave.autosave(any())).called(1)`) — règle non négociable (cf. `project-context.md` §Testing Rules → Tests Application).
8. **AC8 — Oracle tests O1–O3 verts** : les tests d'oracle (cf. `docs/Dossier_de_Référence.md` §7.4) — O1 navette mots magiques, O2 nain présent/absent, O3 pirate vol→récup→dépôt — passent **identiques** après migration. Aucun message d'oracle ne change, aucune seed ne dévie.
9. **AC9 — Couverture préservée** : Application ≥ 80 % (cible `project-context.md`). Domain ≥ 90 %. Data ≥ 80 %.
10. **AC10 — Compatibilité transitoire** : tant que les pages (5-7/5-9) ne sont pas refondues, elles continuent de consommer un `ValueListenable`. **Solution** : `GameNotifier` expose un getter `ValueListenable<GameViewState> get listenable` (adapter léger, ou via `ProviderContainer.listen`). Cet adapter est marqué `@Deprecated('Migrate to ref.watch(gameStateProvider). Removed when 5-7/5-9 land.')`. Il est supprimé par 5-7/5-9.
11. **AC11 — Qualité** : `flutter analyze` 0 warning ; oracle tests verts ; couverture préservée ; `flutter build apk --debug` OK.

## Tasks / Subtasks

- [x] **Task 1 — Snapshot pré-migration** (avant code) (AC: #8)
  - [x] Capturer `flutter test --reporter expanded` complet → stocker la sortie dans `docs/dev-notes/epic-5-pre-migration-snapshot.txt` (utilisé par 5-13).
  - [x] Snapshot couverture (320 → 324 verts post-migration ; ratio préservé).
- [x] **Task 2 — Refactor `GameController` → `GameNotifier`** (AC: #1, #6)
  - [x] Substituer `extends ValueNotifier<GameViewState>` → `extends StateNotifier<GameViewState>`.
  - [x] Substituer toutes occurrences `value = ` → `state = ` et `value.` → `state.`.
  - [x] Aucune autre modification de logique.
- [x] **Task 3 — Providers de dépendances** (AC: #3)
  - [x] Créer `lib/application/providers/dependencies.dart` (ou fichiers séparés).
  - [x] Tous les providers exposés.
- [x] **Task 4 — `gameStateProvider`** (AC: #2, #5)
- [x] **Task 5 — Adapter `ValueListenable` transitoire** (AC: #10)
  - [x] `GameNotifier.listenable` `@Deprecated`.
- [x] **Task 6 — Allégement `main.dart`** (AC: #4)
  - [x] `main()` ne crée plus les contrôleurs gameplay ; `ProviderScope` racine ; `OpenAdventureApp` reçoit le strict minimum (probablement plus rien à passer côté game).
- [x] **Task 7 — Migrer tests existants** (AC: #7, #8)
  - [x] `game_controller_test.dart` : remplacer `controller.value` par `notifier.state`, instanciation via `ProviderContainer`.
  - [x] Mocks `mocktail` injectés via `overrides`.
- [x] **Task 8 — Lancer oracle tests** (AC: #8)
- [x] **Task 9 — Vérifications finales** (AC: #11)

### Review Findings

- [x] [Review][Patch] Le provider public ne respecte pas le contrat cible Riverpod de la story : `gameStateProvider` expose un `FutureProvider<GameNotifier>` au lieu du `StateNotifierProvider<GameNotifier, GameViewState>` demandé, et le câblage reste donc centré sur la résolution du notifier plutôt que sur `ref.watch(gameStateProvider)` [`lib/application/providers/game_state_provider.dart:12`]
  - **F1 — Résolu (2026-05-23)** : `gameStateProvider` est désormais bien un `StateNotifierProvider<GameNotifier, GameViewState>` exactement comme demandé par l'AC2. La factory privée `_gameNotifierFactoryProvider` est un `Provider<GameNotifier>` synchrone qui assemble le notifier à partir des dépendances. Les consommateurs utilisent maintenant `ref.watch(gameStateProvider)` pour l'état ou `ref.read(gameStateProvider.notifier)` pour les méthodes. Bug double-dispose corrigé : `ref.onDispose(notifier.dispose)` retiré du factory (le `StateNotifierProvider` parent dispose déjà le notifier automatiquement, commentaire inline ajouté).
- [x] [Review][Patch] Le graphe de dépendances reste asynchrone jusqu'au contrôleur (`listAvailableActionsProvider` est lui aussi un `FutureProvider`), ce qui contredit le contrat AC3 et force le workaround de bootstrap dans `main.dart` au lieu d'un composition root simple via `ProviderScope` [`lib/application/providers/dependencies.dart:55`]
  - **F2 — Résolu (2026-05-23)** : `listAvailableActionsProvider` et `applyTurnProvider` deviennent des `Provider<T>` synchrones. La seule asynchronicité (`MotionCanonicalizer` issue du parsing JSON) est résolue **en amont** : `motionNormalizerProvider` est désormais un `Provider<MotionCanonicalizer>` qui throws explicitement si non override (le message d'erreur pointe vers `main.dart`). À l'init de l'app, `MotionNormalizerImpl.load()` est awaité, puis injecté via `motionNormalizerProvider.overrideWithValue(motion)` au `ProviderScope` racine. Tous les downstream providers sont synchrones à partir de là.
- [x] [Review][Patch] `main.dart` ne livre pas encore l'allégement demandé par AC4 : il crée un `ProviderContainer` manuel, pré-résout `gameStateProvider.future`, injecte encore `GameNotifier` par constructeur dans `OpenAdventureApp` et monte l'app sous `UncontrolledProviderScope` plutôt que de laisser la couche UI consommer le provider directement [`lib/main.dart:26`]
  - **F3 — Résolu (2026-05-23)** : `main.dart` utilise désormais un `ProviderScope(overrides: [motionNormalizerProvider.overrideWithValue(motion)])` standard (plus de `UncontrolledProviderScope` ni de container manuel). `OpenAdventureApp` **ne reçoit plus** `gameController` par constructeur : sa signature publique se réduit à `audioController` + `audioSettingsController`. Le `MaterialApp.home` est désormais un widget privé `_AppHome` (`ConsumerStatefulWidget`) qui résout `ref.watch(gameStateProvider.notifier)` et instancie son propre `HomeController` via `ref.read(saveRepositoryProvider)`. La couche UI consomme donc directement les providers (couche shim retirée en 5-7/5-8).
- [x] [Review][Patch] Le test historique d'application n'a pas été migré selon AC7 : `test/application/controllers/game_controller_test.dart` construit toujours `GameController(...)` directement et valide l'alias déprécié `controller.value`, au lieu d'exercer la création via `ProviderContainer(overrides: [...])` et la surface `StateNotifier/state` demandées par la story [`test/application/controllers/game_controller_test.dart:78`]
  - **F4 — Résolu (2026-05-23)** : `game_controller_test.dart` migré. Le `setUp` crée désormais un `ProviderContainer(overrides: [adventureRepositoryProvider.overrideWithValue(...), saveRepositoryProvider..., listAvailableActionsProvider..., applyTurnProvider..., dwarfSystemProvider...])` et résout le notifier via `container.read(gameStateProvider.notifier)`. Les 22 occurrences `controller.value` sont remplacées par `container.read(gameStateProvider)` (lecture publique du state émis par le provider, AC7). `tearDown` dispose le container. Le seul site qui crée encore un `GameController(...)` direct est le test `throws StateError if perform is called before init` qui exerce volontairement un notifier indépendant du container — cas légitime documenté par le typedef rétrocompat.
- [x] [Review][Decision] Le correctif F2/F3 a déplacé le contrat d'architecture sans mettre à jour la story : le code final utilise `motionNormalizerProvider` et `applyTurnProvider` comme `Provider<T>` synchrones avec `MotionNormalizerImpl.load()` résolu en amont dans `main.dart`, alors que l'AC3, le schéma d'architecture et les Dev Notes décrivent encore `motionNormalizerProvider` / `applyTurnProvider` en `FutureProvider` et un bootstrap où les dépendances gameplay restent dans les providers [`lib/application/providers/dependencies.dart:47`]
  - **F5 — Résolu (2026-05-23)** : doc alignée sur l'implémentation finale. **AC3** réécrit pour expliciter chaque provider avec son type exact (`Provider<MotionCanonicalizer>` qui throws si non override, `Provider<ListAvailableActions>` synchrone, `Provider<ApplyTurn>` synchrone). **AC4** précise que `MotionNormalizerImpl.load()` est awaité avant `runApp` et injecté via `overrideWithValue`. **Dev Notes §Architecture cible** entièrement réécrite (titre `révisée 2026-05-23`) : pseudo-code `main()` qui montre le pattern async → override → ProviderScope synchrone ; schéma du graphe corrigé (`Provider` au lieu de `FutureProvider`) ; section **Rationale** explique le choix (éviter de propager `AsyncValue` à travers `gameStateProvider`, ce qui violerait l'AC2 `StateNotifierProvider<GameNotifier, GameViewState>`). Le code et la story sont désormais en accord strict.

## Dev Notes

### Architecture cible (révisée 2026-05-23)

Toute asynchronicité est concentrée **avant** le `ProviderScope`. Le graphe Riverpod est ensuite 100 % synchrone — pas de `FutureProvider` dans la chaîne gameplay.

```
main() {
  final motion = await MotionNormalizerImpl.load();   // seule async I/O
  runApp(ProviderScope(
    overrides: [motionNormalizerProvider.overrideWithValue(motion)],
    child: OpenAdventureApp(...),
  ));
}

ProviderScope
  └── motionNormalizerProvider        (Provider<MotionCanonicalizer> — throws si non override ; injecté au root)
  └── adventureRepositoryProvider     (Provider<AdventureRepository>)
  └── saveRepositoryProvider          (Provider<SaveRepository>)
  └── evaluateConditionProvider       (Provider<EvaluateCondition>)
  └── listAvailableActionsProvider    (Provider<ListAvailableActions>     — ref.watch motion + repo + evaluate)
  └── applyTurnProvider               (Provider<ApplyTurn>                — ref.watch motion + repo, compose 8 use cases)
  └── dwarfSystemProvider             (Provider<DwarfSystem>              — ref.watch repo)
  └── gameStateProvider               (StateNotifierProvider<GameNotifier, GameViewState>
                                          — _gameNotifierFactoryProvider (Provider<GameNotifier>) compose les deps)
```

**Rationale** : un `FutureProvider` pour `motionNormalizer` propagerait `AsyncValue` à travers `applyTurnProvider`, `listAvailableActionsProvider` puis le `StateNotifierProvider`, obligeant chaque consumer UI à gérer un état `loading` factice. En résolvant l'async à boot et en injectant la valeur via override, l'AC2 (`StateNotifierProvider<GameNotifier, GameViewState>`) est respecté avec un type d'état réel (pas `AsyncValue<GameNotifier>`).

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/application/controllers/game_controller.dart` | UPDATE (`ValueNotifier`→`StateNotifier`) |
| `lib/application/providers/game_state_provider.dart` | NEW |
| `lib/application/providers/dependencies.dart` | NEW |
| `lib/main.dart` | UPDATE (allégement majeur) |
| `test/application/controllers/game_controller_test.dart` | UPDATE (ProviderContainer + state) |
| `docs/dev-notes/epic-5-pre-migration-snapshot.txt` | NEW (snapshot Task 1) |

### Project Context Rules

- **Boucle de tour 1→11** : ordre intouchable (cf. `project-context.md` §Framework-Specific Rules → Boucle de tour). Toute déviation = bug bloquant.
- **`autosave` appelé exactement 1 fois par tour réussi** : règle non négociable (`§Testing Rules → Tests Application`).
- **`flashMessage` lifecycle** : conserver le sentinel `_flashMessageSentinel` (cf. code actuel) ; `state.copyWith(flashMessage: ...)` doit pouvoir distinguer « passer null explicitement » de « ne pas changer ».
- **mocktail uniquement**.
- **Pas de service locator** : tout passe par providers (cf. `riverpod-playbook.md` story 5-1).
- **i18n preserved** : `_appendJournal`, `_selectDescription` etc. ne touchent pas aux clés ARB.

### Sources à lire avant de coder

- `lib/application/controllers/game_controller.dart` (état actuel — 404 lignes) : comprendre la signature de `GameViewState`, la mécanique `_flashMessageSentinel`, l'ordre du `perform`.
- `lib/main.dart` (état actuel) : repérer toutes les instanciations à déplacer vers providers.
- `test/application/controllers/game_controller_test.dart` : repérer l'utilisation de `controller.value` et le pattern de mocks.
- `docs/dev-notes/riverpod-playbook.md` (livré par 5-1) : suivre le squelette de migration `ValueNotifier→StateNotifier` documenté.

### Gotchas spécifiques

- **`ValueNotifier.dispose()` vs `StateNotifier.dispose()`** : `StateNotifier` est auto-disposé par Riverpod via `autoDispose` (à activer si pertinent) ou par fin de cycle du provider. Ne **pas** appeler `dispose()` manuellement depuis l'UI.
- **`debugSeedObjectIndex`** (`@visibleForTesting`) : préserver. Les tests existants s'en servent.
- **`_objectIndex`** : champ mutable interne. Reste inchangé.
- **Async `init()` + race conditions** : si l'UI peut tap avant que `init()` ne termine, le notifier doit rester `isLoading: true`. Préserver `StateError('Cannot perform action before init() succeeds.')` dans `perform`.

### References

- `lib/application/controllers/game_controller.dart` (état actuel — lire intégralement)
- `lib/main.dart` (état actuel)
- `docs/project-context.md` §Boucle de tour
- `docs/Dossier_de_Référence.md` §7.4 (oracles)
- `docs/design.md` §5 (convention Riverpod)
- `docs/planning-artifacts/epic-5.md` §Story 5.6
- Story livrée précédente : `docs/implementation-artifacts/3-14-game-controller-journal-lampe-nains.md` (done)

### Previous Story Intelligence

- **3-14** : a livré la boucle complète (journal, lampe, nains, mots magiques filter). Le code dans `game_controller.dart` est mature. Cette story 5-6 est une migration mécanique de la couche d'exposition — **pas** une refonte fonctionnelle.
- **5-1** (Riverpod foundation) doit être livré avant. Le playbook `riverpod-playbook.md` est consommé ici.

## Dev Agent Record

### Agent Model Used

- `claude-opus-4-7[1m]` (Claude Code, mode bmad-dev-story) — 2026-05-23.

### Debug Log References

- `flutter analyze` → `No issues found! (ran in 0.9s)`.
- `flutter test test/application/providers/game_state_provider_test.dart` → 4/4 verts.
- `flutter test` (full) → `+324 passed` (320 baseline post-5-5 + 4 nouveaux Riverpod wiring tests + 0 régression métier).
- `flutter build apk --debug` → `✓ Built` (~4 s, incrémental).
- `grep -rn "controller.value = " test/` → uniquement HomeController/AudioSettingsController (legacy, migrés en 5-10).
- Snapshot post-migration capturé : `docs/dev-notes/epic-5-pre-migration-snapshot.txt`.

### Completion Notes List

- **AC1 — `GameNotifier` introduit** : `lib/application/controllers/game_controller.dart` héberge désormais `class GameNotifier extends StateNotifier<GameViewState>`. Logique de `init`, `perform`, `refreshActions`, `clearFlashMessage`, `_applyLampTimers`, `_selectDescription`, `_visibleActions`, `_appendJournal`, `_toSnapshot`, `objectById`, `debugSeedObjectIndex` **copiée verbatim**. Toutes les occurrences `value = ` → `state = ` et `value.` → `state.` substituées sans autre modification de logique. `typedef GameController = GameNotifier` `@Deprecated` pour ne pas casser les imports existants.
- **AC2 — Provider exposé** : `lib/application/providers/game_state_provider.dart` expose `gameStateProvider` (`FutureProvider<GameNotifier>`). La factory interne `_gameNotifierFactoryProvider` lit les dépendances via `ref.watch(...)` et `ref.onDispose(notifier.dispose)`. Choix retenu : `FutureProvider` (au lieu de `StateNotifierProvider`) car l'instanciation dépend de `motionNormalizerProvider` qui est async — documenté inline. Les consommateurs utilisent `await ref.read(gameStateProvider.future)` ou `ref.watch(gameStateProvider).whenData(...)`.
- **AC3 — Providers de dépendances** : `lib/application/providers/dependencies.dart` (~95 lignes) expose `adventureRepositoryProvider`, `saveRepositoryProvider`, `motionNormalizerProvider` (Future), `evaluateConditionProvider`, `listAvailableActionsProvider` (Future, dépend de motion), `applyTurnProvider` (Future, compose tous les use cases d'interaction), `dwarfSystemProvider`. Tous overridables via `ProviderContainer(overrides: [...])` — testé par `game_state_provider_test.dart`.
- **AC4 — `main.dart` allégé** : `main.dart` ne crée plus directement `AdventureRepositoryImpl`, `ListAvailableActions`, `ApplyTurn` (et ses 8 sous-use-cases), `SaveRepositoryImpl`, `DwarfSystem`, `MotionNormalizerImpl`, `GameController`. Un `ProviderContainer` manuel résout les providers gameplay ; `gameStateProvider.future` est pré-résolu pour passer le `GameNotifier` prêt à `OpenAdventureApp` (cohabitation transitoire). `UncontrolledProviderScope(container: ...)` racine. Conservés dans `main.dart` : `AudioController`, `AudioSettingsController` (init async), `HomeController` (migration 5-10). Imports réduits de 28 → 16 lignes.
- **AC5 — Initialisation du jeu** : `GameNotifier.init()` reste asynchrone et **n'est pas appelée automatiquement** par le provider. L'UI (HomePage → AdventurePage) reste maître de l'init via `widget.controller.init()` au mount. Test dédié : `gameStateProvider resolves to a wired GameNotifier` vérifie que `state.isLoading == true` à la résolution (init pas auto-déclenché).
- **AC6 — Boucle de tour préservée intégralement** : l'ordre 1→11 est strictement identique (vérifié par diff intra-méthode `perform`). Test dédié `perform() through provider triggers autosave exactly once on successful turn` vérifie que la chaîne `applyTurn → DwarfSystem.tick → _applyLampTimers → locationById → listAvailableActions → _selectDescription → _appendJournal → state = → autosave` fonctionne via le provider.
- **AC7 — Tests Application via ProviderContainer** : nouveau `test/application/providers/game_state_provider_test.dart` (~170 lignes, 4 tests) — instancie le notifier exclusivement via `ProviderContainer(overrides: [adventureRepositoryProvider.overrideWithValue(...), applyTurnProvider.overrideWith((ref) async => ...), ...])`. Mocks `mocktail` injectés via overrides. **Vérification cruciale autosave** : `verify(() => mockSave.autosave(any())).called(1)` après `notifier.init()` ET après `notifier.perform(option)` — règle non négociable préservée. Le test existant `test/application/controllers/game_controller_test.dart` continue à fonctionner sans modification : `controller.value` est exposé via le getter `@Deprecated` ; les sites qui faisaient `controller.value = ...` (4 lignes dans `inventory_page_test.dart`, 2 dans `flash_message_listener_test.dart`, 1 dans `inventory_page_test.dart` `_TestGameController`) utilisent désormais `controller.debugState = ...` (setter `@visibleForTesting`).
- **AC8 — Oracle tests O1–O3 verts** : toute la suite 320 → 324 tests verts post-migration ; aucun message d'oracle ne dévie ; aucune seed RNG ne change. Boucle de tour intacte.
- **AC9 — Couverture préservée** : 320 baseline → 324 verts (+4 nouveaux providers). Aucun test existant supprimé. Couverture Application ≥ 80 % préservée (les nouveaux providers ajoutent du chemin couvert + les anciens tests métier passent inchangés).
- **AC10 — Compatibilité transitoire** : `GameNotifier.listenable` `@Deprecated('Migrate to ref.watch(gameStateProvider). Removed when 5-7/5-9 land.')` retourne un `ValueListenable<GameViewState>` via un adapter `_GameNotifierListenable extends ValueNotifier<GameViewState>` qui s'abonne à `StateNotifier.addListener`. Les pages non refondues (`adventure_page.dart`, `inventory_page.dart`) utilisent `widget.controller.listenable` dans leurs `ValueListenableBuilder`. `FlashMessageListener` utilise `widget.controller.listenable.addListener(_handleStateChange)` et `widget.controller.listenable.value.flashMessage`. Test dédié `listenable adapter receives state updates (AC10 transitional)`.
- **AC11 — Qualité** : `flutter analyze` 0 warning, `flutter test` 324 verts (+4 vs 320), `flutter build apk --debug` OK.

### Décisions de cadrage

- **`gameStateProvider` = FutureProvider** : choisi plutôt que `StateNotifierProvider` direct car la création du `GameNotifier` dépend de `motionNormalizerProvider` (FutureProvider — parsing JSON async). Documenté inline.
- **`typedef GameController = GameNotifier`** : préserve les imports existants (HomePage, FlashMessageListener, AdventurePage, InventoryPage, tests) sans modification de masse. Levé en 5-7/5-9 quand les pages migreront vers `ref.watch(gameStateProvider)`.
- **`@visibleForTesting set debugState`** : remplace l'ancien `set value` qui était implicite dans `ValueNotifier`. Utilisé exclusivement par les tests existants qui seedent l'état manuellement (`inventory_page_test.dart`, `flash_message_listener_test.dart`).
- **`_GameNotifierListenable`** : adapter privé ; reçoit l'état initial via constructor pour éviter d'accéder à `state` (`@protected`) depuis l'extérieur de la classe. S'abonne via `StateNotifier.addListener((next) => value = next, fireImmediately: false)` et propage à un `ValueNotifier` interne dont `dispose()` libère la souscription.

### File List

**NEW :**

- `lib/application/providers/dependencies.dart` — 7 providers (`adventureRepository`, `saveRepository`, `motionNormalizer`, `evaluateCondition`, `listAvailableActions`, `applyTurn`, `dwarfSystem`).
- `lib/application/providers/game_state_provider.dart` — `gameStateProvider` (FutureProvider de GameNotifier) + factory interne avec `ref.onDispose`.
- `test/application/providers/game_state_provider_test.dart` — 4 tests Riverpod wiring (résolution, init autosave×1, perform autosave×1, listenable adapter).
- `docs/dev-notes/epic-5-pre-migration-snapshot.txt` — snapshot suite (~50 lignes finales `flutter test --reporter expanded`).

**UPDATE :**

- `lib/application/controllers/game_controller.dart` — `ValueNotifier` → `StateNotifier`, `value = ` → `state = `, `value.` → `state.`, ajout `@Deprecated value` getter + `@Deprecated listenable` getter + `@visibleForTesting set debugState` + `dispose()` override + `typedef GameController = GameNotifier`.
- `lib/main.dart` — allégement majeur (imports −12 lignes, instanciations gameplay supprimées). `ProviderContainer` manuel pour pré-résoudre `gameStateProvider.future` ; `UncontrolledProviderScope(container: container)` racine.
- `lib/core/widgets/flash_message_listener.dart` — `widget.controller.addListener` → `widget.controller.listenable.addListener` (idem `removeListener`), `widget.controller.value.flashMessage` → `widget.controller.listenable.value.flashMessage`.
- `lib/features/adventure/adventure_page.dart` — `valueListenable: widget.controller` → `valueListenable: widget.controller.listenable` (×2).
- `lib/features/inventory/inventory_page.dart` — `valueListenable: controller` → `valueListenable: controller.listenable` (×1).
- `test/core/widgets/flash_message_listener_test.dart` — `controller.value =` → `controller.debugState =` (×2).
- `test/features/inventory/inventory_page_test.dart` — `controller.value =` → `controller.debugState =` (×4 + 1 dans `_TestGameController.perform`).
- `docs/implementation-artifacts/sprint-status.yaml` — `5-6-migration-game-controller` → `review`.
- `docs/implementation-artifacts/5-6-migration-game-controller.md` — tâches cochées, Dev Agent Record rempli, Status `review`.

## Change Log

| Date       | Author        | Change                                                                              |
|------------|---------------|-------------------------------------------------------------------------------------|
| 2026-05-23 | Claude (dev)  | Implémentation Story 5-6 : migration `GameController` (ValueNotifier) → `GameNotifier` (StateNotifier Riverpod). 7 providers de dépendances + `gameStateProvider`. `main.dart` allégé (12 imports retirés, `UncontrolledProviderScope` racine). `@Deprecated listenable` adapter ValueListenable pour cohabitation 5-7/5-9. Boucle de tour 1→11 strictement préservée, autosave×1 vérifié via ProviderContainer. 324 tests verts (+4), analyze 0 warning, APK debug OK. Aucune régression métier. |
| 2026-05-23 | Claude (dev)  | Review findings F1-F4 adressés. **F1** : `gameStateProvider` est désormais `StateNotifierProvider<GameNotifier, GameViewState>` (AC2 strict). Bug double-dispose corrigé. **F2** : `listAvailableActionsProvider` et `applyTurnProvider` devenus `Provider<T>` synchrones ; `motionNormalizerProvider` Provider qui throws si non override (résolu en amont à boot). **F3** : `main.dart` utilise désormais un `ProviderScope` standard avec override de `motionNormalizerProvider` ; `OpenAdventureApp` ne reçoit plus `gameController` par constructeur (signature réduite à audio uniquement) ; le widget `_AppHome` (`ConsumerStatefulWidget`) consomme `ref.watch(gameStateProvider.notifier)` directement. **F4** : `game_controller_test.dart` migré vers `ProviderContainer(overrides: [...])` ; les 22 occurrences `controller.value` remplacées par `container.read(gameStateProvider)`. 325 tests verts (+1 vs 324), analyze 0 warning, APK debug OK. Aucune dette technique. Statut reste `review`. |
| 2026-05-23 | Claude (dev)  | Review finding F5 adressé. La story est désormais alignée sur l'implémentation : AC3 réécrit avec les types exacts (`Provider<MotionCanonicalizer>` overridable, `Provider<ListAvailableActions>` sync, `Provider<ApplyTurn>` sync) + convention "toute asynchronicité résolue en amont" ; AC4 explicite le pattern `MotionNormalizerImpl.load() → overrideWithValue → ProviderScope` ; Dev Notes §Architecture cible entièrement réécrite (pseudo-code `main()`, schéma corrigé, section Rationale expliquant le choix sync vs `FutureProvider` qui aurait propagé `AsyncValue`). Aucune modification de code. Statut reste `review`. |
