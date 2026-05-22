# Story 4.7: AdventurePage v2 — StatusBar (score/tours/lampe) + groupes actions

Status: blocked-by-epic-5
Epic: 4
Source ticket: ADVT‑S4‑07 (`docs/EXEC_S4.md`)
Refs : [design.md](../design.md), [features/adventure.md](../features/adventure.md), [project-context](../project-context.md)
~~Refs obsolètes~~ : ~~[UX_SCREENS](../UX_SCREENS.md)~~ (superseded 2026-05-22)

---
## 📝 Amendement Design Handoff — 2026-05-22

Cette story est antérieure au handoff design. Avant `dev-story`, intégrer :
- **DA** : palette ambre/encre dark-only, fonts Pixelify Sans + Silkscreen + DM Sans (cf. [`docs/design.md`](../design.md) §4 ADR-003/004 ; [`tokens.css`](../../design_handoff_open_adventure/tokens.css))
- **Mockup visuel** : [`design_handoff_open_adventure/screens.jsx`](../../design_handoff_open_adventure/screens.jsx) (AdventureScreen) + [`action-buttons.jsx`](../../design_handoff_open_adventure/action-buttons.jsx) + [`overflow-actions.jsx`](../../design_handoff_open_adventure/overflow-actions.jsx)
- **Spec feature** : [`docs/features/adventure.md`](../features/adventure.md)
- **Atomes UI** : `OAStamp` pour actions, `OAPill` pour StatusBar, `OAIcon` pour batterie lampe (livrés par Epic 5 story 5-4)
- **Motion** : `Curves.stepN` via `OAAnimations` (ADR-006), `MediaQuery.disableAnimations` respecté
- **Path target** : `lib/features/adventure/widgets/status_bar.dart` et `lib/features/adventure/adventure_page.dart` (post-réorg 5-2)
- **State** : `ConsumerWidget` + `gameStateProvider` (post-migration 5-6/5-7) ; plus de `ValueListenableBuilder<GameViewState>`

> ⚠️ **Bloquant** : cette story ne peut entrer en dev qu'après livraison de l'Epic 5 — notamment 5-7 (Migration AdventurePage Riverpod + reskin) qui prépare le terrain. La StatusBar 4-7 sera **un complément** à l'AdventurePage refondue en 5-7.
> La section « Acceptance Criteria » ci-dessous peut nécessiter des compléments — à revoir lors du `Create Story` / `Validate Story`.
---

## Story

**En tant que** joueur, **je veux** voir en permanence le score courant, le nombre de tours et l'état de la lampe (batterie restante), avec les actions regroupées par catégorie et un focus management clavier/lecteur d'écran propre, **afin de** garder le contexte vital sans interrompre la boucle.

## Acceptance Criteria

1. **AC1 — `StatusBar` widget** : `lib/presentation/widgets/status_bar.dart` (NEW) affiche `score`, `turns`, `lampLimit` (icône batterie + chiffre). Mis à jour via `ValueListenableBuilder<GameViewState>`.
2. **AC2 — Intégration AdventurePage** : `StatusBar` placée sous l'AppBar (ou top du body), persistante.
3. **AC3 — Groupes d'actions** : les `ActionOption` rendues sont regroupées par `category` (sécurité, travel, interaction, méta) avec en-têtes localisés.
4. **AC4 — Focus order** : sécurise `image → titre → status_bar → description → groupes actions → journal`.
5. **AC5 — Score temps réel** : utilise `ComputeScore` (Story 4-1) sur l'état courant, **caché** (pas recalculé à chaque rebuild — memoize via clé `(turns, hintsUsed.length, ...)`).
6. **AC6 — Tests** : widget tests valeurs StatusBar ; tests focus traversal ; tests groupes.

## Tasks / Subtasks

- [ ] **Task 1 — `StatusBar` widget** (AC: #1).
- [ ] **Task 2 — Memoize score** dans `GameController` ou un service léger (AC: #5).
- [ ] **Task 3 — Regrouper actions** par `category` côté UI (AC: #3).
- [ ] **Task 4 — Focus management** via `FocusTraversalGroup` (AC: #4).
- [ ] **Task 5 — Tests** (AC: #6).

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/presentation/widgets/status_bar.dart` | NEW |
| `lib/presentation/pages/adventure_page.dart` | UPDATE (intégration + groupement + focus) |
| `lib/application/controllers/game_controller.dart` | UPDATE possible (memoize score) |
| `lib/l10n/app_en.arb`, `app_fr.arb`, `app_localizations.dart` | UPDATE (en-têtes catégories) |
| `test/presentation/widgets/status_bar_test.dart` | NEW |
| `test/presentation/pages/adventure_page_test.dart` | UPDATE |

### Project Context Rules
- ValueNotifier pattern.
- i18n obligatoire pour en-têtes catégories.
- Score = use case Domain, jamais inline.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑07
- `docs/UX_SCREENS.md` (Adventure v2)
- Story 4-1 (ComputeScore complet)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
