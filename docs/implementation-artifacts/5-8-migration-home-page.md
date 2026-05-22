# Story 5.8: Migration `HomePage` Riverpod + reskin (refonte 2-20)

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2 ; supersède `2-20-home-page-v0`
Refs : [epic-5](../planning-artifacts/epic-5.md#story-58-migration-homepage-riverpod--reskin-refonte-2-20), [design.md](../design.md), [design_handoff_open_adventure/screens.jsx](../../design_handoff_open_adventure/screens.jsx) (section home)

## Story

**En tant que** joueur,
**je veux** un écran d'accueil refondu (titre Pixelify, fond encre profonde, halo ambre, boutons « Nouvelle aventure » / « Continuer » / « Réglages » / « Crédits »),
**afin que** l'entrée dans le jeu colle à la DA finale tout en préservant le comportement existant : « Continuer » désactivé si aucune autosave, autosave restaurée au lancement de la session.

## Acceptance Criteria

1. **AC1 — Localisation** : `lib/features/home/home_page.dart`. Devient `ConsumerWidget`.
2. **AC2 — Consommation provider** : remplacer `HomeController` (`ValueNotifier`) par `homeStateProvider` exposé via `lib/application/providers/home_state_provider.dart` (`StateNotifierProvider<HomeNotifier, HomeViewState>`). `HomeNotifier` lit `saveRepositoryProvider` (introduit par 5-6) ; expose `loadAutosaveStatus()` (à appeler en `initState` côté `ConsumerStatefulWidget` ou via `ref.listen`) et `state` contient `{ hasAutosave: bool, isLoading: bool, error: String? }`.
3. **AC3 — Bouton « Continuer »** : `OAStamp(variant: primary, onPressed: state.hasAutosave ? () => _navigate(...) : null)`. Disabled visuel si `!hasAutosave` (cf. AC1 spec atomes 5-4). Aucune autre logique côté UI — décision de désactivation portée par `state`.
4. **AC4 — Layout DA** : conforme à `design_handoff_open_adventure/screens.jsx` section home :
   - Titre du jeu en grand format `OATypography.display.xl` (Pixelify Sans, 40px), couleur `paper-bright`.
   - Sous-titre/baseline (ex : « Une aventure de Will Crowther & Don Woods, portée mobile en 2026 ») en `OATypography.caps.m`, `paper-faded`.
   - Image décorative centrale (placeholder accepté si l'asset n'est pas livré — ex : silhouette lanterne) sous `OASceneFrame`.
   - 4 stamps : `OAStamp(variant: primary, label: l10n.home.newGame)`, `OAStamp(variant: secondary, label: l10n.home.continue, onPressed: ...)`, `OAStamp(variant: ghost, label: l10n.home.settings)`, `OAStamp(variant: ghost, label: l10n.home.credits)`.
5. **AC5 — Navigation** : taps déclenchent navigations Flutter standard (GoRouter livré dans un Epic ultérieur — pour cette story, `Navigator.push(MaterialPageRoute(...))` est acceptable, mais documenter le TODO `// TODO (post-Epic-5): migrer vers GoRouter`).
6. **AC6 — i18n** : clés ARB `home.newGame`, `home.continue`, `home.settings`, `home.credits`, `home.subtitle` ajoutées dans `app_en.arb` + `app_fr.arb` ; `flutter gen-l10n` regénéré.
7. **AC7 — Tests widgets** (`test/features/home/home_page_test.dart`) :
   - **Autosave absent** : injecter `HomeViewState(hasAutosave: false)` → `find.text('Continuer')` existe mais `onPressed` null (vérifier `tester.widget<OAStamp>(find.byKey(Key('home.continue'))).onPressed == null`).
   - **Autosave présent** : `hasAutosave: true` → bouton actif → `tester.tap` → vérifier navigation (mock).
   - **isLoading** : si `state.isLoading == true`, afficher un loader minimaliste ; vérifier que les 4 stamps sont absents pendant le loading initial (≤ 200ms typique).
8. **AC8 — Story `2-20-home-page-v0` supersedée** : bandeau inline ajouté au fichier `2-20-home-page-v0.md` (cf. story 5-7 pour le modèle).
9. **AC9 — Qualité** : `flutter analyze` 0 warning ; couverture du module `lib/features/home/` ≥ 70 % ; aucun `ValueNotifier` ne subsiste côté home.

## Tasks / Subtasks

- [ ] **Task 1 — `HomeNotifier` + `homeStateProvider`** (AC: #2)
  - [ ] `lib/application/controllers/home_controller.dart` → renommer en `home_notifier.dart` (ou garder le fichier et changer la classe).
  - [ ] `lib/application/providers/home_state_provider.dart`.
- [ ] **Task 2 — `HomePage ConsumerWidget`** (AC: #1, #4)
- [ ] **Task 3 — Bouton Continuer** (AC: #3)
- [ ] **Task 4 — Navigation** (AC: #5)
- [ ] **Task 5 — i18n** (AC: #6)
- [ ] **Task 6 — Tests** (AC: #7)
- [ ] **Task 7 — Superseder 2-20** (AC: #8)
- [ ] **Task 8 — Lint + couverture** (AC: #9)

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/features/home/home_page.dart` | UPDATE (refonte complète) |
| `lib/application/controllers/home_controller.dart` | UPDATE (`ValueNotifier`→`StateNotifier`) |
| `lib/application/providers/home_state_provider.dart` | NEW |
| `lib/l10n/app_en.arb` | UPDATE (clés home.*) |
| `lib/l10n/app_fr.arb` | UPDATE |
| `lib/l10n/app_localizations.dart` | REGEN |
| `test/features/home/home_page_test.dart` | UPDATE |
| `test/application/controllers/home_controller_test.dart` | UPDATE (ProviderContainer) |
| `docs/implementation-artifacts/2-20-home-page-v0.md` | UPDATE (bandeau supersedé) |

### Project Context Rules

- **Tous les boutons via `OAStamp`** ; pas de Material standard.
- **Aucune logique de jeu** : la HomePage ne lit pas `gameStateProvider`. Elle lit uniquement `homeStateProvider` (statut autosave).
- **i18n** : zéro chaîne en dur.
- **Image décorative** : si non livrée, accepter un placeholder (texte centré + bordure). La livraison artistique est gérée par 4-19 (post-5-8) ou par story art dédiée.

### References

- `docs/features/` (pas de spec home dédiée — utiliser `design.md` §3.2 + handoff)
- `design_handoff_open_adventure/screens.jsx` section home
- `docs/planning-artifacts/epic-5.md` §Story 5.8
- Story superseded : `docs/implementation-artifacts/2-20-home-page-v0.md`

### Previous Story Intelligence

- **2-20** (done, superseded) : a livré la home v0 avec `HomeController` et bouton Continuer. La logique de détection autosave est mature — la conserver.
- **5-2** doit être livré avant. **5-1, 5-3, 5-4** également (dépendances explicites).

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
