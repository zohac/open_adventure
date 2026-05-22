# Story 4.5: SavesPage — liste slots + charger/supprimer avec confirmations

Status: blocked-by-epic-5
Epic: 4
Source ticket: ADVT‑S4‑05 (`docs/EXEC_S4.md`)
Refs : [design.md](../design.md), [features/saves.md](../features/saves.md), [project-context](../project-context.md)
~~Refs obsolètes~~ : ~~[UX_SCREENS](../UX_SCREENS.md)~~ (superseded 2026-05-22)

---
## 📝 Amendement Design Handoff — 2026-05-22

Cette story est antérieure au handoff design. Avant `dev-story`, intégrer :
- **DA** : palette ambre/encre dark-only, fonts Pixelify/Silkscreen + DM Sans (cf. [`docs/design.md`](../design.md) §4 ADR-003/004 ; [`tokens.css`](../../design_handoff_open_adventure/tokens.css))
- **Mockup visuel** : [`design_handoff_open_adventure/saves.jsx`](../../design_handoff_open_adventure/saves.jsx)
- **Spec feature** : [`docs/features/saves.md`](../features/saves.md)
- **Atomes UI** : `OAStamp` pour Charger/Supprimer, `OAPill` pour metadata slot, `OAIcon` pour actions secondaires (livrés par Epic 5 story 5-4)
- **Motion** : transitions de suppression respectent `Curves.stepN` (ADR-006)
- **Path target** : `lib/features/saves/saves_page.dart` (post-réorg 5-2)
- **State** : `ConsumerWidget` + `saveSlotsProvider` (post-migration 5-6/5-10)

> ⚠️ **Bloquant** : cette story ne peut entrer en dev qu'après livraison de l'Epic 5 (5-2, 5-3, 5-4, 5-5, 5-10).
> Les AC ci-dessous peuvent nécessiter des compléments — à revoir lors du `Create Story` / `Validate Story`.
---

## Story

**En tant que** joueur, **je veux** une page Sauvegardes listant mes slots (titre/progression/date), avec actions Charger et Supprimer (confirmation obligatoire), **afin de** gérer mes parties sans manipuler les fichiers manuellement.

## Acceptance Criteria

1. **AC1 — Liste** : `SavesPage` charge `SaveRepository.list()` et affiche chaque slot avec `title` (lieu), `progression` (tours + score), `date` (updated_at) ; tri par `updated_at` décroissant.
2. **AC2 — Vide** : si aucun slot, message i18n + bouton "Nouvelle partie".
3. **AC3 — Charger** : tap "Charger" → `SaveRepository.load(slot)` → `GameController.restoreFrom(snapshot)` → navigation `AdventurePage`. Désactivé pendant chargement.
4. **AC4 — Supprimer** : tap "Supprimer" → dialog confirmation → `SaveRepository.delete(slot)` → refresh liste.
5. **AC5 — i18n + a11y** : labels via ARB ; cibles ≥ 48 dp ; semantics annoncées.
6. **AC6 — Tests** : widget tests tap → callbacks ; cas vide ; confirmation suppression (cancel/confirm).

## Tasks / Subtasks

- [ ] **Task 1 — `SavesController` (Application)** : expose `SavesViewState { slots, isLoading }` + `load()/delete()`.
- [ ] **Task 2 — `SavesPage` UI** (AC: #1, #2, #3, #4).
- [ ] **Task 3 — Intégration `GameController.restoreFrom(snapshot)`** (AC: #3).
- [ ] **Task 4 — i18n + a11y** (AC: #5).
- [ ] **Task 5 — Tests widget** (AC: #6).

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/application/controllers/saves_controller.dart` | NEW |
| `lib/presentation/pages/saves_page.dart` | UPDATE (remplace stub S2) |
| `lib/application/controllers/game_controller.dart` | UPDATE (méthode `restoreFrom`) |
| `lib/l10n/app_en.arb`, `app_fr.arb`, `app_localizations.dart` | UPDATE |
| `test/presentation/pages/saves_page_test.dart` | NEW/UPDATE |

### Project Context Rules
- ValueNotifier pattern.
- i18n obligatoire.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑05
- `docs/UX_SCREENS.md` (Saves)
- Story 4-4 (SaveRepository étendu)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
