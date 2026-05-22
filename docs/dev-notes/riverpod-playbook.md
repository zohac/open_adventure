# Riverpod Playbook — open_adventure

> **Statut** : socle posé par la Story 5-1. Aucun contrôleur migré encore.
> Source d'architecture : [`design.md`](../design.md) §3.1 & §5. Règles transverses : [`project-context.md`](../project-context.md).
> **Convention cible (post-Epic 5) tranchée** : full Riverpod — toute dépendance non-Flutter exposée par le composition root devient un Provider. Aucun `overrideWithValue` au bootstrap en régime nominal (sauf cas de test ou de feature toggle).

## 1. Version

- **`flutter_riverpod: ^2.6.0`** (résolu `2.6.1` au 2026-05-22). **Ne pas passer en 3.x** sans DDR : breaking changes API (`Notifier` génériques, `Ref` typé).
- Si une nouvelle mineure 2.x sort (2.7+), elle peut être adoptée sans cérémonie (changelog vérifié, `flutter pub upgrade flutter_riverpod`).

## 2. Convention cible : full Riverpod

Toute dépendance précédemment câblée à la main dans `main()` devient un `Provider<T>` (ou variante) :

| Catégorie | Pré-Epic-5 | Post-Epic-5 (convention B) |
|---|---|---|
| Repositories (`AdventureRepository`, `SaveRepository`, …) | Instance dans `main()` | `Provider<AdventureRepository>` |
| Use cases Domain (`ApplyTurn`, `ListAvailableActions`, …) | Constructor injection | `Provider<ApplyTurn>` qui `ref.watch` ses propres deps |
| Services Application (`AudioController`, `DwarfSystem`, …) | Instance dans `main()` | `Provider<AudioController>` (avec hooks `ref.onDispose`) |
| Contrôleurs (`GameController`, `HomeController`, …) | `ValueNotifier` injecté | `StateNotifierProvider<GameController, GameViewState>` |
| Données async (`MotionNormalizer.load`) | `await` dans `main()` | `FutureProvider<MotionNormalizer>` |

`main()` se réduit à terme à :

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: OpenAdventureApp()));
}
```

> **Note Domain** : `flutter_riverpod` n'est jamais importé depuis `lib/domain/`. Les providers vivent **uniquement** sous `lib/application/providers/`. Les use cases et entités restent agnostiques.

## 3. Quand utiliser quoi

| Besoin | Type Riverpod |
|---|---|
| Valeur immuable / dépendance câblée (repo, use case, service singleton) | `Provider<T>` |
| État mutable réactif piloté par méthodes (contrôleurs) | `StateNotifierProvider<N, S>` |
| Chargement asynchrone unique (parsing JSON initial, calibration) | `FutureProvider<T>` |
| Flux d'événements externes | `StreamProvider<T>` |
| Paramètres dynamiques | `*Provider.family<T, P>` |

**Règle d'or** : état immuable calculé une fois → `Provider`. Méthodes qui mutent → `StateNotifierProvider`. `await` initial → `FutureProvider`.

**Nommage** : suffixe `Provider` obligatoire, `final` top-level dans `*_provider.dart`, toujours passer `name: '<id>'` pour DevTools.

## 4. Lifecycle et `dispose`

- **Avant Epic 5** : `OpenAdventureApp.dispose()` appelle manuellement `controller.dispose()` pour chaque `ValueNotifier`.
- **Pendant Epic 5** : à chaque story (5-6, 5-7, 5-8, 5-9, 5-10) qui migre un contrôleur :
  - Le contrôleur quitte le constructeur de `OpenAdventureApp` (**signature change attendue** dans la story de migration — pas avant).
  - Sa ligne `dispose()` correspondante est retirée de `_OpenAdventureAppState.dispose()`.
  - Riverpod garantit le `dispose` du `StateNotifier` quand le `ProviderContainer` est démonté (fin de l'app) ou que le provider devient inutilisé (`autoDispose`).
- **Services avec ressources I/O** (audio, save…) : utiliser `ref.onDispose(() => service.dispose())` dans le `Provider` correspondant pour garantir la libération.

> ⚠️ La signature publique de `OpenAdventureApp` **ne change pas dans la Story 5-1**. Elle rétrécit story-par-story à partir de 5-6. Une fois 5-10 livrée, `OpenAdventureApp` ne reçoit plus aucun contrôleur.

## 5. Composition root

- Le `ProviderScope` racine est **dans `lib/main.dart` uniquement**. Pas de scope imbriqué sans justification (preview, override de feature, A/B test).
- **Pas d'overrides au bootstrap en régime nominal** : tous les providers se résolvent par eux-mêmes. Les overrides sont réservés aux tests et aux scopes spécialisés (ex. preview Storybook d'une scène).
- **Pas de service locator** (`get_it`, `injectable`). Le `ProviderContainer` est la source unique.

## 6. Family providers

Préférer une `family` à un paramètre stocké en `state` interne. Paramètre **immutable** avec `==` stable (int, String, Enum, ou VO Equatable). Garder le paramètre **minimal** — un `int locationId` plutôt qu'une `Location`.

```dart
final locationByIdProvider = Provider.family<Location, int>(
  (ref, id) => ref.watch(adventureRepositoryProvider).locationByIdSync(id),
  name: 'locationByIdProvider',
);
```

Anti-pattern : `family<T, ComplexMutableObject>` — `==` instable casse le cache.

## 7. Tests (overrides via ProviderContainer)

```dart
test('myProvider returns expected value', () {
  final container = ProviderContainer(
    overrides: [
      adventureRepositoryProvider.overrideWithValue(MockAdventureRepository()),
    ],
  );
  addTearDown(container.dispose);

  expect(container.read(myProvider), isA<MyState>());
});
```

- Toujours `addTearDown(container.dispose)`.
- **`mocktail` uniquement** (pas de `mockito`, pas de `build_runner`).
- Pour un `StateNotifierProvider`, tester le notifier **directement** quand la logique métier le permet (`final notifier = MyNotifier(...); expect(notifier.state, ...);`). Le provider lui-même n'est qu'un câblage.
- Tests Domain : **jamais** de Riverpod dans `test/domain/` (pur Dart `package:test`).
- Widget tests : `pumpWidget(ProviderScope(overrides: [...], child: MaterialApp(...)))`. Préférer `overrideWith` (factory) à `overrideWithValue` pour les `StateNotifierProvider`.

## 8. Anti-patterns refusés

- ❌ **`ProviderScope.containerOf(context)`** hors widgets utilitaires identifiés (logger, navigation imperative) — casse l'inversion de dépendance, tests fragiles.
- ❌ **`ref.read` dans le `build`** d'un widget — pas de rebuild, bug silencieux. Utiliser `ref.watch`. `ref.read` réservé aux callbacks.
- ❌ **Provider qui capture un `BuildContext`** — context lié au widget tree, pas au scope ; fuite/crash garantis.
- ❌ **Lire un Provider dans `main()`** avant que le `ProviderScope` ne soit monté — `ProviderContainer` n'existe pas encore.
- ❌ **Logique métier dans un notifier** — brise Clean Architecture. Le notifier orchestre, les use cases Domain calculent.
- ❌ **Import `flutter_riverpod` dans `lib/domain/`** — Domain reste pur Dart. Les providers vivent sous `lib/application/providers/`.
- ❌ **`Random()` / `DateTime.now()` dans un notifier** — casse le déterminisme RNG (cf. `project-context.md`). Re-seeder depuis `Game.rngSeed`.
- ❌ **Méga-provider qui détient tout l'état** — rebuilds incontrôlés. Un provider = un état cohérent (Game, Audio, Home).

## 9. Squelette migration `ValueNotifier → StateNotifier`

À utiliser dans **Story 5-6** (GameController) puis 5-7 → 5-10. Convention B : toutes les deps sont elles-mêmes des providers, le notifier les consomme via `ref.watch`.

### Avant (Epic 1-4)

```dart
class GameController {
  GameController({required this.applyTurn, /* ... */});

  final ValueNotifier<GameViewState> viewState =
      ValueNotifier(const GameViewState.initial());

  Future<void> perform(ActionOption option) async {
    // boucle de tour (voir project-context.md §Boucle de tour)
    viewState.value = viewState.value.copyWith(/* ... */);
  }

  void dispose() => viewState.dispose();
}
```

### Après (cible 5-6)

```dart
// lib/application/providers/adventure_repository_provider.dart (5-6)
final adventureRepositoryProvider = Provider<AdventureRepository>(
  (ref) => AdventureRepositoryImpl(),
  name: 'adventureRepositoryProvider',
);

// lib/application/providers/apply_turn_provider.dart (5-6)
final applyTurnProvider = Provider<ApplyTurn>((ref) {
  final repo = ref.watch(adventureRepositoryProvider);
  final motion = ref.watch(motionNormalizerProvider);
  return ApplyTurn(
    travel: ApplyTurnGoto(repo, motion),
    examine: ExamineImpl(adventureRepository: repo),
    takeObject: TakeObjectImpl(adventureRepository: repo),
    // ... toutes les deps via providers
  );
}, name: 'applyTurnProvider');

// lib/application/controllers/game_controller.dart (refondu en 5-6)
class GameController extends StateNotifier<GameViewState> {
  GameController({
    required this.applyTurn,
    required this.adventureRepository,
    /* ... */
  }) : super(const GameViewState.initial());

  Future<void> perform(ActionOption option) async {
    // boucle de tour IDENTIQUE (ordre non négociable)
    state = state.copyWith(/* ... */);
  }
}

// lib/application/providers/game_controller_provider.dart (5-6)
final gameControllerProvider =
    StateNotifierProvider<GameController, GameViewState>(
  (ref) => GameController(
    applyTurn: ref.watch(applyTurnProvider),
    adventureRepository: ref.watch(adventureRepositoryProvider),
    listAvailableActions: ref.watch(listAvailableActionsProvider),
    saveRepository: ref.watch(saveRepositoryProvider),
    dwarfSystem: ref.watch(dwarfSystemProvider),
  ),
  name: 'gameControllerProvider',
);
```

### Côté UI (cible 5-7)

```dart
class AdventurePage extends ConsumerWidget {
  const AdventurePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    // même UI qu'avec ValueListenableBuilder, sans le builder
  }
}
```

### Points de vigilance

- **Ordre de la boucle de tour** : strictement préservé (cf. `project-context.md`). Ne pas refactorer en passant.
- **Autosave** : appelée **exactement 1 fois** par tour réussi (`verify(...).called(1)` doit passer sans modification).
- **`flashMessage`** : convention `clearFlashMessage()` après consommation inchangée.
- **Async deps** (`MotionNormalizer.load`) : exposer en `FutureProvider`. Les notifiers qui en dépendent : soit `await ref.watch(...future)`, soit dépendance d'un autre `FutureProvider`.
- **Services I/O** (audio, save, path_provider) : déclarer `ref.onDispose(() => service.dispose())` dans leur Provider pour libérer ressources.
- **`OpenAdventureApp` rétrécit** : à chaque story 5-6 → 5-10, retirer le contrôleur migré du constructeur ET sa ligne `dispose()` correspondante. La signature finale (post-5-10) ne reçoit plus aucun contrôleur.
- **Couverture** : Application ≥ 80 %, Domain ≥ 90 % à préserver. Les tests de notifier peuvent rester avec mocktail (cf. §7).

## 10. Lockfile & toolchain (note Story 5-1)

L'ajout de `flutter_riverpod ^2.6.0` sur la toolchain **Flutter 3.41.9 / Dart 3.11.5** a produit, lors du `flutter pub get` initial, des bumps transitive **hors scope direct** de Riverpod :

- `_fe_analyzer_shared` 85.0.0 → 93.0.0
- `analyzer` 7.7.1 → 10.0.1
- `characters` 1.4.0 → 1.4.1
- `matcher` 0.12.17 → 0.12.19
- Suppression de `js 0.7.2` (devenu inutile)

Ces bumps **ne sont pas explicitement requis par `flutter_riverpod`** (sa pubspec ne contraint pas `analyzer`), mais le résolveur Pub les a déclenchés pour satisfaire le graphe complet. Ce sont des **conséquences toolchain** d'une exécution `flutter pub get` après ajout d'une dépendance non triviale sur cette version de Flutter.

**Décision (Story 5-1)** : accepter ces bumps. Pas de `dependency_overrides` pour les forcer en arrière (risque de blocage de résolution, masquage de problèmes). Le commit `chore(deps): refresh lockfile to latest patches within current constraints` (`02998cc`) consolide la résolution.

**Audit recommandé post-Epic 5** : si `analyzer` 10.x introduit un warning lint en CI ou un comportement inattendu, ouvrir une story `chore: investigate analyzer 10.x impact` plutôt que de réintroduire un override.

## 11. Références

- Story socle : [`5-1-riverpod-foundation.md`](../implementation-artifacts/5-1-riverpod-foundation.md)
- Epic 5 : [`epic-5.md`](../planning-artifacts/epic-5.md)
- Sprint Change Proposal : [`sprint-change-proposal-2026-05-22.md`](../planning-artifacts/sprint-change-proposal-2026-05-22.md)
- Architecture : [`design.md`](../design.md) §3.1 & §5
- Règles transverses : [`project-context.md`](../project-context.md)
- Doc Riverpod 2.x : https://riverpod.dev/docs/concepts/providers

_Last Updated: 2026-05-22 — Story 5-1 + review findings R1/R2_
