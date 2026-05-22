# Story 5.15: Réécriture `project-context.md` (sections State/DI)

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.1 (A3)
Refs : [epic-5](../planning-artifacts/epic-5.md#story-515-réécriture-project-contextmd-sections-statedi), [project-context.md](../project-context.md), [design.md §5](../design.md)

## Story

**En tant que** agent BMad / nouveau contributeur,
**je veux** que `docs/project-context.md` reflète la stack effective post-Epic 5 (Riverpod 2 + DI via providers + `lib/features/`),
**afin que** les futurs contributeurs et les agents IA produisent du code conforme dès la première session — sans tomber dans les anti-patterns de l'ancienne stack `ValueNotifier`.

## Acceptance Criteria

1. **AC1 — Bandeau `🚧 EN TRANSITION` retiré** en tête de fichier.
2. **AC2 — §Framework-Specific Rules → "Composition root unique"** réécrite :
   - Remplacer « Toute nouvelle dépendance se câble dans `lib/main.dart` (DI manuelle, injection par constructeur). » par « Toute nouvelle dépendance s'expose via un `Provider` ou `StateNotifierProvider` sous `lib/application/providers/`. Le `ProviderScope` racine est dans `lib/main.dart`. La DI s'effectue par lecture de providers via `ref.watch`/`ref.read`. »
   - Conserver la règle anti-singleton mutable.
   - Documenter le pattern overrides pour tests (`ProviderContainer(overrides: [...])`).
3. **AC3 — §State management** réécrite :
   - Remplacer « state management = `ValueNotifier` » par « state management = `flutter_riverpod ^2.x` + `StateNotifier`. Un seul `gameStateProvider` pour l'état de jeu, dérivations via `Provider` ou `select`. »
   - Lister les providers canoniques (`gameStateProvider`, `audioSettingsProvider`, `audioControllerProvider`, `homeStateProvider`).
4. **AC4 — §Code Organization Rules → Layout obligatoire** : section déjà partiellement amendée par 5-2 ; finaliser pour refléter `core/{theme,widgets,motion}/`, `features/<screen>/`, `application/{controllers,providers,services}/`. Préserver Domain et Data tels quels.
5. **AC5 — §Anti-patterns Flutter** mis à jour :
   - **Retirer** : « `setState` dans une page qui dispose déjà d'un `ValueNotifier` — toujours `ValueListenableBuilder` ou écoute directe. » (obsolète post-migration).
   - **Ajouter** : « ❌ `ProviderScope.containerOf(context)` ou `ref.read(provider)` dans le `build` d'un widget — utiliser `ref.watch` (ou `ref.read` dans un callback). »
   - **Ajouter** : « ❌ Lecture d'un provider depuis `main()` avant que le `ProviderScope` ne soit monté. »
   - **Ajouter** : « ❌ Provider qui capture un `BuildContext` (capture les destinations naïves de tear-down de scope). »
   - **Conserver** : toutes les autres règles (mocktail, Random non-seedé, singleton mutable, Domain pur, etc.).
6. **AC6 — §Boucle de tour** : section **intouchée** (gameplay préservé — cf. 5-6 AC6). Préciser que c'est désormais `GameNotifier.perform(...)` (au lieu de `GameController.perform(...)`) qui implémente la séquence.
7. **AC7 — §Testing Rules** mises à jour :
   - **Conserver** : couverture cibles (Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 %).
   - **Conserver** : `mocktail` uniquement, pas de `mockito`.
   - **Ajouter** : « Pour tester un `StateNotifier`, utiliser `ProviderContainer(overrides: [...])` et `container.read(provider.notifier)` ou `container.listen(provider, ...)`. »
   - **Conserver** : règle `autosave` appelée exactement 1 fois par tour réussi.
8. **AC8 — Toutes les autres sections préservées telles quelles** : Domain pur, Data passive, Presentation sans logique, Application = orchestration, immutabilité, i18n, RNG déterministe, PixelCanvas, Performance Rules, Platform & Build Rules, Critical Don't-Miss Rules → Doctrine, Gotchas spécifiques au domaine, Workflow PR, Références.
9. **AC9 — Mise à jour de l'entrée `pubspec` audit** : la table « Dépendances production » ajoute `flutter_riverpod ^2.x` (déjà ajoutée par 5-1, mais à confirmer dans la doc).
10. **AC10 — `Last Updated`** : date du merge de 5-15.

## Tasks / Subtasks

- [ ] **Task 1 — Retirer le bandeau de transition** (AC: #1)
- [ ] **Task 2 — Réécrire §State management** (AC: #3)
- [ ] **Task 3 — Réécrire §Composition root unique** (AC: #2)
- [ ] **Task 4 — Finaliser §Layout obligatoire** (AC: #4)
- [ ] **Task 5 — Mettre à jour §Anti-patterns Flutter** (AC: #5)
- [ ] **Task 6 — Ajuster §Boucle de tour** (AC: #6)
- [ ] **Task 7 — Mettre à jour §Testing Rules** (AC: #7)
- [ ] **Task 8 — Vérifier §Dépendances production** (AC: #9)
- [ ] **Task 9 — `Last Updated`** (AC: #10)
- [ ] **Task 10 — Relecture par diff vs handoff** (AC: #8)

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `docs/project-context.md` | UPDATE chirurgical |

### Project Context Rules

- **Garder le fichier lean** : `project-context.md` est un aide-mémoire LLM, pas une doc exhaustive. Pour les détails, renvoyer vers `architecture.md`, `component-inventory.md`, `data-models.md`.
- **La spec prime sur le code** : si une règle est ajoutée ici, elle s'applique immédiatement au futur code.
- **Pas de réécriture totale** : préserver tout ce qui reste valide. Le diff doit être ciblé sur les sections State/DI et Anti-patterns.

### Coordination

- 5-14 (architecture.md) et 5-15 (project-context.md) sont **complémentaires** — coordonner les PRs.
- Cette story se livre **en dernier** ou en parallèle finale de 5-14.

### References

- `docs/project-context.md` (état actuel — bandeau transition en tête)
- `docs/design.md` §5 (convention Riverpod)
- `docs/dev-notes/riverpod-playbook.md` (livré 5-1)
- `docs/planning-artifacts/epic-5.md` §Story 5.15
- `docs/planning-artifacts/sprint-change-proposal-2026-05-22.md` §4.1 (A3)

### Previous Story Intelligence

- Cette story est la **dernière** d'Epic 5 (avec 5-14). Toutes les autres stories doivent être mergées avant.
- Préserver les anti-patterns existants qui restent valides (`Random()` non-seedé, singleton mutable, mocks `mockito` interdits, etc.).

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
