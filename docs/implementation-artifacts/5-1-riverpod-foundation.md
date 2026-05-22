# Story 5.1: Riverpod foundation — `ProviderScope` racine + playbook

Status: done
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 (`docs/planning-artifacts/sprint-change-proposal-2026-05-22.md` §4.2)
Refs : [epic-5](../planning-artifacts/epic-5.md#story-51-riverpod-foundation), [design.md §3.1 / §5](../design.md), [project-context](../project-context.md)

## Story

**En tant que** développeur,
**je veux** disposer d'un socle Riverpod 2 (dépendance verrouillée, `ProviderScope` racine, conventions documentées),
**afin que** les stories suivantes (5-6 → 5-10) puissent migrer les contrôleurs `ValueNotifier` vers `StateNotifierProvider` sans réinventer la convention à chaque PR.

## Acceptance Criteria

1. **AC1 — Dépendance verrouillée** : `pubspec.yaml` ajoute `flutter_riverpod: ^2.6.0` (ou dernière mineure 2.x ; verrouiller la mineure exacte, pas `^2.0.0`). `flutter pub get` exit 0, `pubspec.lock` committé.
2. **AC2 — `ProviderScope` racine** : `lib/main.dart` wrappe `OpenAdventureApp` dans un `ProviderScope` ; le scope est le **seul** endroit où les overrides sont déclarés (la signature publique de `OpenAdventureApp` continue de recevoir ses contrôleurs par constructeur — pas de breaking change dans cette story).
3. **AC3 — Convention documentée** : nouveau fichier `docs/dev-notes/riverpod-playbook.md` (≈ 80–150 lignes) couvre : (a) quand utiliser `Provider` vs `StateNotifierProvider` vs `FutureProvider`, (b) family providers, (c) overrides via `ProviderContainer` dans les tests, (d) anti-patterns refusés (`ProviderScope.containerOf` hors widgets, lecture `read` dans le build d'un widget, providers stateful capturant `BuildContext`), (e) exemple migration `ValueNotifier → StateNotifier` (squelette à utiliser dans 5-6).
4. **AC4 — Aucune migration métier** : aucun contrôleur existant n'est migré dans cette story. `GameController`, `HomeController`, `AudioSettingsController`, `AudioController` restent inchangés et restent passés par constructeur depuis `main()`.
5. **AC5 — Smoke provider** : un provider minimaliste `appBootstrapProvider` (`Provider<bool>((ref) => true)`) existe sous `lib/application/providers/app_bootstrap_provider.dart` et un test `test/application/providers/app_bootstrap_provider_test.dart` valide qu'un `ProviderContainer()` retourne `true` — preuve que le wiring fonctionne.
6. **AC6 — Qualité** : `flutter analyze` zéro warning ; tous les tests existants verts (Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 % préservés) ; `flutter build apk --debug` OK.
7. **AC7 — Mise à jour `pubspec`** : commentaire inline « introduit Story 5-1 — Riverpod foundation ; conventions documentées dans `docs/dev-notes/riverpod-playbook.md` » au-dessus de la dépendance.

## Tasks / Subtasks

- [x] **Task 1 — Ajouter la dépendance** (AC: #1, #7)
  - [x] Vérifier la dernière mineure stable de `flutter_riverpod` ≥ 2.6.
  - [x] Ajouter `flutter_riverpod: ^2.6.0` dans `pubspec.yaml` (section `dependencies:`) avec commentaire inline.
  - [x] `flutter pub get` ; committer `pubspec.lock`.
- [x] **Task 2 — Wrapper `ProviderScope`** (AC: #2, #4)
  - [x] Modifier `lib/main.dart` : `runApp(ProviderScope(child: OpenAdventureApp(...)))` — préserver la signature `OpenAdventureApp`.
  - [x] Aucun autre fichier touché côté contrôleurs.
- [x] **Task 3 — Créer le smoke provider** (AC: #5)
  - [x] `lib/application/providers/app_bootstrap_provider.dart` (≤ 20 lignes).
  - [x] `test/application/providers/app_bootstrap_provider_test.dart` (≤ 30 lignes, `ProviderContainer()` + `container.read(appBootstrapProvider) == true`).
- [x] **Task 4 — Documenter le playbook** (AC: #3)
  - [x] Créer `docs/dev-notes/riverpod-playbook.md`.
  - [x] Sections obligatoires : Décisions / Conventions / Tests / Anti-patterns / Squelette migration `ValueNotifier→StateNotifier`.
  - [x] Lier depuis `docs/index.md` (section « Dev notes »).
- [x] **Task 5 — Vérifications finales** (AC: #6)
  - [x] `flutter analyze` → 0 warning.
  - [x] `flutter test` → tous verts.
  - [x] `flutter build apk --debug` → succès.
  - [x] Vérifier qu'aucune story `done` (Epic 1 → 4) ne casse.

### Review Findings

- [x] [Review][Decision] Clarifier la convention Riverpod DI/lifecycle avant 5-6 — AC3 demande un playbook exploitable, mais `docs/dev-notes/riverpod-playbook.md` dit à la fois que repositories/use cases/services restent injectés par constructeur et "ne deviennent pas des providers" (l.8-10), puis montre des overrides de repository providers (l.29-37), un `GameController` qui `watch(applyTurnProvider)` (l.122-127), et la suppression du `dispose()` manuel dans `OpenAdventureApp` (l.152) alors que la signature publique reste censée ne pas changer. Il faut choisir la convention cible avant de patcher la doc.
  - **R1 — Résolu (2026-05-22)** : Convention **B (full Riverpod)** tranchée par l'utilisateur. Playbook entièrement refondu : §2 expose la convention cible (toute dépendance non-Flutter devient un Provider, `main()` se réduit à `runApp(ProviderScope(child: OpenAdventureApp()))`), §4 détaille le lifecycle (`OpenAdventureApp` rétrécit story-par-story, `dispose` manuel retiré au coup-par-coup, services I/O exposent `ref.onDispose`), §5 confirme zéro `overrideWithValue` au bootstrap en régime nominal, §9 réécrit le squelette migration en consommant tout via `ref.watch(*Provider)`. Le rétrécissement de signature de `OpenAdventureApp` est explicitement délégué aux stories 5-6 → 5-10 (donc hors Story 5-1, qui ne change rien).
- [x] [Review][Patch] Regénérer `pubspec.lock` sans upgrades transitoires hors scope ou aligner explicitement la montée de toolchain [`pubspec.lock`:750]
  - **R2 — Résolu (2026-05-22)** : Documentation explicite ajoutée. `docs/dev-notes/riverpod-playbook.md` §10 (« Lockfile & toolchain ») recense les bumps transitive observés (`_fe_analyzer_shared` 85→93, `analyzer` 7.7.1→10.0.1, `characters` 1.4.0→1.4.1, `matcher` 0.12.17→0.12.19, suppression `js 0.7.2`) et acte la décision d'accepter ces conséquences toolchain (Flutter 3.41.9 / Dart 3.11.5) plutôt que de forcer des `dependency_overrides` (risque de masquer un problème de résolution). `pubspec.yaml`, `README.md` et `docs/project-context.md` sont alignés sur Dart `>=3.11.0` / Flutter 3.41.x. Les trois infos révélées par `analyzer 10.x` (`use_null_aware_elements`, `unnecessary_underscores`) sont corrigées ; `flutter analyze` repasse à zéro issue. Le commit `02998cc` (`chore(deps): refresh lockfile`) consolide.
- [x] [Review][Patch] Ne pas passer 5-2 → 5-15 en `ready-for-dev` dans le commit 5-1 sans artefacts story committés [`docs/implementation-artifacts/sprint-status.yaml`:175]
  - **R3 — Résolu (2026-05-22)** : Les 13 fichiers `5-3-port-tokens-design-system.md` → `5-15-reecriture-project-context-md.md` (artefacts existants issus du sprint change proposal) ont été committés en parallèle par l'utilisateur dans `bb50313 docs(epic-5): draft stories 5-3 to 5-15 (Foundation Refresh)`. `5-2-reorganisation-features.md` était déjà couvert par le commit `198112a`. Sprint-status désormais cohérent : chaque story marquée `ready-for-dev` ou plus a bien son fichier tracké dans le repo.

## Dev Notes

### Architecture cible

- Cette story pose **uniquement** le socle. Aucun contrôleur n'est migré ici.
- Le `ProviderScope` enveloppe l'app entière. Les contrôleurs existants (`GameController`, `HomeController`, `AudioSettingsController`, `AudioController`) restent injectés via constructeur depuis `main()` — la migration de chacun arrive dans 5-6 / 5-10.
- L'objectif est de garantir que les stories suivantes peuvent introduire des `*Provider` sans avoir à toucher au bootstrap.

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `pubspec.yaml` | UPDATE (ajout `flutter_riverpod`) |
| `pubspec.lock` | UPDATE (regen) |
| `lib/main.dart` | UPDATE (`ProviderScope` racine) |
| `lib/application/providers/app_bootstrap_provider.dart` | NEW |
| `test/application/providers/app_bootstrap_provider_test.dart` | NEW |
| `docs/dev-notes/riverpod-playbook.md` | NEW |
| `docs/index.md` | UPDATE (lien playbook) |

### Project Context Rules

- **DI par constructeur préservée** dans cette story (cf. `project-context.md` §Composition root). La règle évoluera dans 5-15 — pas avant.
- **mocktail uniquement** pour les tests (pas `mockito`, pas `build_runner`).
- **Pas de breaking API** côté `OpenAdventureApp` : la signature actuelle (`gameController`, `audioController`, `audioSettingsController`, `homeController`) reste identique.
- **`flutter_lints ^6.0.0`** : `flutter_riverpod` 2.x est compatible — aucun warning attendu.

### Anti-patterns à refuser dès cette story

- ❌ `ProviderScope.containerOf(context)` hors widgets utilitaires identifiés (logger, navigation imperative).
- ❌ `ref.read` dans le `build` d'un widget (utiliser `ref.watch`).
- ❌ Providers qui capturent un `BuildContext`.
- ❌ Lire un `Provider<...>` dans `main()` avant que le `ProviderScope` ne soit monté.

### Choix de version

- Au moment de l'écriture (2026-05), la 2.x stable est largement adoptée. Si une 2.7 ou 2.8 est sortie, prendre la dernière mineure stable ; **ne pas** sauter sur la 3.x avant audit (breaking changes API). Documenter le choix précis dans `riverpod-playbook.md`.

### References

- `docs/design.md` §3.1 (stack) & §5 (state management — convention Riverpod)
- `docs/planning-artifacts/epic-5.md` §Story 5.1
- `docs/planning-artifacts/sprint-change-proposal-2026-05-22.md` §4.2
- Code actuel : `lib/main.dart`, `lib/application/controllers/game_controller.dart`

### Previous Story Intelligence

- Aucune story Riverpod précédente. Cette story est la **première** d'Epic 5.
- Cohérence avec `1-16-lint-analyze-null-safety` : préserver l'invariant zéro warning.

## Dev Agent Record

### Agent Model Used

- `claude-opus-4-7[1m]` (Claude Code, mode bmad-dev-story) — 2026-05-22.

### Debug Log References

- `flutter pub get` → exit 0, `flutter_riverpod 2.6.1` résolu.
- `flutter analyze` → `No issues found! (ran in 1.1s)`.
- `flutter test` → `+203: All tests passed!` (suite complète Domain/Data/Application/Presentation préservée).
- `flutter build apk --debug` → `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (~126s, installation Android SDK 35 + CMake 3.22.1 incluse car premier build sur cette machine).

### Completion Notes List

- **AC1 — Dépendance** : `flutter_riverpod: ^2.6.0` ajoutée ; résolution `2.6.1`, `pubspec.lock` mis à jour.
- **AC2 — `ProviderScope` racine** : `runApp(ProviderScope(child: OpenAdventureApp(...)))` ; signature `OpenAdventureApp` inchangée (zéro breaking change). Aucun override déclaré pour l'instant (overrides seront introduits en 5-6 quand les notifiers consommeront les repositories existants).
- **AC3 — Playbook** : `docs/dev-notes/riverpod-playbook.md` créé (164 lignes — légèrement au-delà de la cible 80-150 mais reste dans la plage approximative ; couvre Provider vs StateNotifierProvider vs FutureProvider, family, overrides en tests via `ProviderContainer`, anti-patterns, et squelette migration `ValueNotifier → StateNotifier` exploitable tel quel en 5-6).
- **AC4 — Aucune migration métier** : `GameController`, `HomeController`, `AudioSettingsController`, `AudioController` strictement inchangés. Toujours injectés par constructeur depuis `main()`.
- **AC5 — Smoke provider** : `appBootstrapProvider` (`Provider<bool>` retournant `true`, 11 lignes) + test (13 lignes utiles) validant `ProviderContainer().read(appBootstrapProvider) == true`. Cycle red-green vérifié : RED initial (provider absent), GREEN après création.
- **AC6 — Qualité** : `flutter analyze` 0 warning, 203 tests verts (vs 202 avant la story — +1 nouveau test), `flutter build apk --debug` OK. Aucune régression Epic 1 → 4.
- **AC7 — Commentaire pubspec** : ligne inline « introduit Story 5-1 — Riverpod foundation ; conventions documentées dans docs/dev-notes/riverpod-playbook.md » au-dessus de `flutter_riverpod: ^2.6.0`.
- **Choix de version** : `^2.6.0` (résolu 2.6.1) ; Riverpod 3.x volontairement écarté (breaking changes API non auditées), comme stipulé par la story et confirmé via `resolve-library-id` (3.x existe mais hors scope sans DDR).
- **Lien dans `docs/index.md`** : nouvelle section « Dev notes » insérée entre les artefacts générés et la référence amont.
- **Sprint status** : `5-1-riverpod-foundation` passé `backlog → in-progress → review → done` ; `last_updated` mis à jour au 2026-05-22.

### File List

- `pubspec.yaml` — UPDATE (ajout `flutter_riverpod: ^2.6.0` + commentaire inline AC7).
- `pubspec.lock` — UPDATE (régénéré par `flutter pub get`).
- `lib/main.dart` — UPDATE (import `flutter_riverpod`, `runApp(ProviderScope(child: ...))`).
- `lib/application/providers/app_bootstrap_provider.dart` — NEW (smoke provider, AC5).
- `test/application/providers/app_bootstrap_provider_test.dart` — NEW (test smoke provider, AC5).
- `docs/dev-notes/riverpod-playbook.md` — NEW (playbook, AC3).
- `docs/index.md` — UPDATE (section « Dev notes » + lien playbook).
- `docs/implementation-artifacts/sprint-status.yaml` — UPDATE (`5-1-riverpod-foundation` → `done`, `last_updated` 2026-05-22).
- `docs/implementation-artifacts/5-1-riverpod-foundation.md` — UPDATE (tâches cochées, Review Findings résolus, Dev Agent Record rempli, Status `done`).

## Change Log

| Date       | Author        | Change                                                                              |
|------------|---------------|-------------------------------------------------------------------------------------|
| 2026-05-22 | Claude (dev)  | Implémentation initiale Story 5-1 : dépendance Riverpod 2.6.1, `ProviderScope` racine, smoke provider + test, playbook, lien index, statut → review. |
| 2026-05-22 | Claude (dev)  | Review findings R1/R2/R3 adressés. R1 : convention Riverpod tranchée **Full Riverpod (B)** ; playbook entièrement réécrit (§§2/4/5/9 cohérents, §3 grille de typage, §10 nouvelle section lockfile). R2 : §10 du playbook documente les bumps transitive toolchain. R3 : résolu indépendamment par l'utilisateur via `bb50313`. |
| 2026-05-22 | Codex (review) | Clôture review : toolchain alignée dans `pubspec.yaml` / README / project-context, lints `analyzer 10.x` corrigés, `flutter analyze`, `flutter test`, `flutter build apk --debug` verts, statut → done. |
