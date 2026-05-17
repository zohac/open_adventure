# Story 4.2: Détection des fins de jeu (victoire / closing / mort / abandon)

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑02 (`docs/EXEC_S4.md`)
Refs : [Dossier_de_Référence](../Dossier_de_Référence.md), `open-adventure-master/score.c`, `actions.c`

## Story

**En tant que** joueur, **je veux** que la partie s'achève proprement lorsqu'une des conditions canoniques est atteinte (victoire, fermeture de la caverne, mort, abandon), avec un récap score, **afin de** clôturer l'expérience et envisager une nouvelle partie.

## Acceptance Criteria

1. **AC1 — VO `EndGame`** : `lib/domain/value_objects/end_game.dart` (NEW) : `{ EndReason reason, ScoreBreakdown score }` ; `enum EndReason { victory, closing, death, quit }`.
2. **AC2 — Use case `DetectEndGame`** : `lib/domain/usecases/detect_end_game.dart` (NEW) prend `Game` et retourne `EndGame?` selon flags (`closed`, `closng`, `clshnt`), seuils tours (`turn_thresholds.json`), états trésors, `numdie`.
3. **AC3 — Closing** : déclenché par `closng=true` après seuils tours canoniques ; messages associés via `arbitrary_messages.json`.
4. **AC4 — Death** : `numdie` incrémenté après une mort ; après seuil mortel, `reason=death`.
5. **AC5 — Quit** : nouvelle action meta `QUIT` côté UI ; tap → confirme + déclenche `EndGame(reason=quit)`.
6. **AC6 — Victoire** : conditions canoniques (`closed=true` + victoire issue) ; bonus +45.
7. **AC7 — Application bridging** : `GameController` reçoit `DetectEndGame` ; après `ApplyTurn`, si `endGame != null`, **gèle** les actions (`actions: const []`), expose `endGame` dans `GameViewState`, déclenche navigation vers `EndGamePage` (Story 4-8).
8. **AC8 — Tests** : 4 scénarios (victory/closing/death/quit) reproductibles avec seed fixe + flags forcés.

## Tasks / Subtasks

- [ ] **Task 1 — VO `EndGame`** (AC: #1)
- [ ] **Task 2 — Use case `DetectEndGame`** (AC: #2-#6)
- [ ] **Task 3 — Intégration `GameController`** (AC: #7)
- [ ] **Task 4 — Action `QUIT` (meta) + UI confirmation** (AC: #5)
- [ ] **Task 5 — Tests** (AC: #8)

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/domain/value_objects/end_game.dart` | NEW |
| `lib/domain/usecases/detect_end_game.dart` | NEW |
| `lib/application/controllers/game_controller.dart` | UPDATE (route endGame) |
| `lib/presentation/pages/adventure_page.dart` | UPDATE (gel actions + navigation) |
| `test/domain/usecases/detect_end_game_test.dart` | NEW |

### Project Context Rules
- Parité `open-adventure-master/{score,actions}.c`.
- Domain pur.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑02
- `docs/Dossier_de_Référence.md` §D
- `assets/data/turn_thresholds.json`, `obituaries.json`

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
