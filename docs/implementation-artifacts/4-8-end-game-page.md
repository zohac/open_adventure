# Story 4.8: EndGamePage/Dialog — breakdown + classe + actions

Status: blocked-by-epic-5
Epic: 4
Source ticket: ADVT‑S4‑08 (`docs/EXEC_S4.md`)
Refs : [design.md](../design.md), [Dossier_de_Référence](../Dossier_de_Référence.md)
~~Refs obsolètes~~ : ~~[UX_SCREENS](../UX_SCREENS.md)~~ (superseded 2026-05-22)

---
## 📝 Amendement Design Handoff — 2026-05-22

Cette story est antérieure au handoff design. Avant `dev-story`, intégrer :
- **DA** : palette ambre/encre dark-only, fonts Pixelify/Silkscreen + DM Sans (cf. [`docs/design.md`](../design.md) §4 ADR-003/004 ; [`tokens.css`](../../design_handoff_open_adventure/tokens.css))
- **Mockups visuels** : [`design_handoff_open_adventure/endgame.jsx`](../../design_handoff_open_adventure/endgame.jsx) (victoire/closing) + [`death.jsx`](../../design_handoff_open_adventure/death.jsx) (mort/abandon)
- **Atomes UI** : `OAStamp` (Rejouer/Charger/Crédits), `OAPill` (composantes de score) (livrés par Epic 5 story 5-4)
- **Motion** : entrée de l'écran respecte `Curves.stepN` (ADR-006) ; `MediaQuery.disableAnimations` respecté
- **Path target** : `lib/features/endgame/endgame_page.dart` + `lib/features/endgame/death_page.dart` (post-réorg 5-2)
- **State** : `ConsumerWidget` + `endGameStateProvider` (post-migration 5-6)

> ⚠️ **Bloquant** : cette story ne peut entrer en dev qu'après livraison de l'Epic 5 (5-2, 5-3, 5-4, 5-5, 5-6).
> Les AC ci-dessous peuvent nécessiter des compléments — à revoir lors du `Create Story` / `Validate Story`.
---

## Story

**En tant que** joueur ayant atteint une fin de jeu, **je veux** voir un écran récap (raison, score détaillé par composante, classe atteinte, options Rejouer/Charger/Crédits), **afin de** clôturer ma session avec satisfaction et fluidité.

## Acceptance Criteria

1. **AC1 — Page dédiée** : `lib/presentation/pages/end_game_page.dart` (NEW) reçoit `EndGame` via constructeur ; affiche `reason` (clé ARB), `ScoreBreakdown` (composantes), `class` (novice…master).
2. **AC2 — Actions** : 3 boutons : "Rejouer" (nouvelle partie + reset GameController), "Charger" (→ SavesPage), "Crédits" (→ CreditsPage).
3. **AC3 — Routage depuis AdventurePage** : quand `GameViewState.endGame != null`, navigation automatique en `pushReplacement` vers `EndGamePage`.
4. **AC4 — i18n + a11y** : labels via ARB ; semantics ; cibles ≥ 48 dp.
5. **AC5 — Tests** : widget tests valeurs breakdown ; tap boutons → navigation correcte.

## Tasks / Subtasks

- [ ] **Task 1 — `EndGamePage` UI** (AC: #1, #2).
- [ ] **Task 2 — Routage** depuis AdventurePage (AC: #3).
- [ ] **Task 3 — i18n** (AC: #4).
- [ ] **Task 4 — Tests** (AC: #5).

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/presentation/pages/end_game_page.dart` | NEW |
| `lib/presentation/pages/adventure_page.dart` | UPDATE (route si endGame) |
| `lib/application/controllers/game_controller.dart` | UPDATE possible (méthode `reset()`) |
| `lib/l10n/app_en.arb`, `app_fr.arb`, `app_localizations.dart` | UPDATE |
| `test/presentation/pages/end_game_page_test.dart` | NEW |

### Project Context Rules
- ValueNotifier pattern.
- i18n obligatoire.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑08
- Story 4-2 (DetectEndGame) ; Story 4-1 (ComputeScore complet)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
