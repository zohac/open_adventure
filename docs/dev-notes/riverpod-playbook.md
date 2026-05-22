# Riverpod Playbook — open_adventure

> **Statut** : socle posé par la Story 5-1. Aucune migration de contrôleur encore.
> Source d'architecture : [`design.md`](../design.md) §3.1 & §5. Règles transverses : [`project-context.md`](../project-context.md).

## 1. Version et périmètre

- **`flutter_riverpod: ^2.6.0`** (résolu `2.6.1` au 2026-05-22). **Ne pas passer en 3.x** sans DDR : breaking changes API (`Notifier` génériques, `Ref` typé).
- Epic 5 migre uniquement les contrôleurs `ValueNotifier` existants. Les use cases Domain, repositories Data et services **restent injectés par constructeur** dans les `StateNotifier` — ils ne deviennent pas des providers.
- Aucun provider ne capture `BuildContext`, n'expose un widget, ou ne lit un asset directement.

## 2. Quand utiliser quoi

| Besoin | Type Riverpod |
|---|---|
| Valeur immuable / dépendance câblée | `Provider<T>` |
| État mutable réactif piloté par méthodes | `StateNotifierProvider<N, S>` |
| Chargement asynchrone unique | `FutureProvider<T>` |
| Flux d'événements externes | `StreamProvider<T>` |
| Paramètres dynamiques | `*Provider.family<T, P>` |

**Règle d'or** : état immuable calculé une fois → `Provider`. Méthodes qui mutent → `StateNotifierProvider`. `await` initial → `FutureProvider`. Ne pas mélanger.

**Nommage** : suffixe `Provider` obligatoire, `final` top-level dans `*_provider.dart`, toujours passer `name: '<id>'` pour DevTools.

## 3. Composition root

- `ProviderScope` racine **dans `lib/main.dart` uniquement**. Pas de scope imbriqué sans justification (preview, override de feature).
- Pendant la migration, les dépendances déjà instanciées dans `main()` restent créées par DI manuelle puis injectées via overrides :

```dart
runApp(
  ProviderScope(
    overrides: [
      adventureRepositoryProvider.overrideWithValue(adventureRepository),
      saveRepositoryProvider.overrideWithValue(saveRepository),
    ],
    child: OpenAdventureApp(...),
  ),
);
```

- **Pas de service locator** (`get_it`, `injectable`). Le `ProviderContainer` est la source unique à terme.

## 4. Family providers

Préférer une `family` à un paramètre stocké en `state` interne. Paramètre **immutable** avec `==` stable (int, String, Enum, ou VO Equatable). Garder le paramètre **minimal** — un `int locationId` plutôt qu'une `Location`.

```dart
final locationByIdProvider = Provider.family<Location, int>(
  (ref, id) => ref.watch(adventureRepositoryProvider).locationByIdSync(id),
  name: 'locationByIdProvider',
);
```

Anti-pattern : `family<T, ComplexMutableObject>` — `==` instable casse le cache.

## 5. Tests (overrides via ProviderContainer)

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
- Pour un `StateNotifierProvider`, tester le notifier **directement** quand possible — le provider n'est qu'un câblage.
- Tests Domain : **jamais** de Riverpod dans `test/domain/` (pur Dart `package:test`).
- Widget tests : `pumpWidget(ProviderScope(overrides: [...], child: MaterialApp(...)))`. Préférer `overrideWith` (factory) à `overrideWithValue` pour les `StateNotifierProvider`.

## 6. Anti-patterns refusés

- ❌ **`ProviderScope.containerOf(context)`** hors widgets utilitaires identifiés (logger, navigation imperative) — casse l'inversion de dépendance, tests fragiles.
- ❌ **`ref.read` dans le `build`** d'un widget — pas de rebuild, bug silencieux. Utiliser `ref.watch`. `ref.read` réservé aux callbacks.
- ❌ **Provider qui capture un `BuildContext`** — context lié au widget tree, pas au scope ; fuite/crash garantis.
- ❌ **Lire un Provider dans `main()`** avant que le `ProviderScope` ne soit monté — `ProviderContainer` n'existe pas encore.
- ❌ **Logique métier dans un notifier** — brise Clean Architecture. Le notifier orchestre, les use cases Domain calculent.
- ❌ **`Random()` / `DateTime.now()` dans un notifier** — casse le déterminisme RNG (cf. `project-context.md`). Re-seeder depuis `Game.rngSeed`.
- ❌ **Méga-provider qui détient tout l'état** — rebuilds incontrôlés. Un provider = un état cohérent (Game, Audio, Home).

## 7. Squelette migration `ValueNotifier → StateNotifier`

À utiliser dans **Story 5-6** (GameController) puis 5-7 → 5-10. Les signatures publiques ne changent pas — seul le mécanisme de notification bascule.

### Avant (Epic 1-4)

```dart
class GameController {
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
class GameController extends StateNotifier<GameViewState> {
  GameController({required this.applyTurn, /* ... */})
      : super(const GameViewState.initial());

  Future<void> perform(ActionOption option) async {
    // boucle de tour IDENTIQUE (ordre non négociable)
    state = state.copyWith(/* ... */);
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, GameViewState>(
  (ref) => GameController(
    applyTurn: ref.watch(applyTurnProvider),
    // autres deps via providers OU via overrides au ProviderScope
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
- **Dispose** : `StateNotifier` gère son cycle via `ProviderContainer`. Plus de `dispose()` manuel dans `OpenAdventureApp`.
- **Couverture** : Application ≥ 80 %, Domain ≥ 90 % à préserver.

## 8. Références

- Story socle : [`5-1-riverpod-foundation.md`](../implementation-artifacts/5-1-riverpod-foundation.md)
- Epic 5 : [`epic-5.md`](../planning-artifacts/epic-5.md)
- Sprint Change Proposal : [`sprint-change-proposal-2026-05-22.md`](../planning-artifacts/sprint-change-proposal-2026-05-22.md)
- Architecture : [`design.md`](../design.md) §3.1 & §5
- Règles transverses : [`project-context.md`](../project-context.md)
- Doc Riverpod 2.x : https://riverpod.dev/docs/concepts/providers

_Last Updated: 2026-05-22 — Story 5-1_
