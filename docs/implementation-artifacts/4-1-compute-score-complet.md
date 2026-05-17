# Story 4.1: ComputeScore complet — parité `score.c`

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑01 (`docs/EXEC_S4.md`)
Refs : [project-context](../project-context.md), [Dossier_de_Référence §D Scoring](../Dossier_de_Référence.md), `open-adventure-master/score.c`

## Story

**En tant que** joueur, **je veux** un score final fidèle au C upstream (Open Adventure 430 pts) couvrant trésors, exploration, pénalités, indices, morts, bonus et classes, **afin que** la partie soit notée selon la canonique historique.

## Acceptance Criteria

1. **AC1 — Composantes** : `ComputeScore.call(game)` retourne `ScoreBreakdown { treasures, exploration, penalties, hintsPenalty, deathsPenalty, bonus, total }` (étendre la VO actuelle).
2. **AC2 — Parité `score.c`** : pour chaque composante, comportement aligné sur `open-adventure-master/score.c` ; toute divergence justifiée explicitement dans `Completion Notes`.
3. **AC3 — Trésors** : `+2` à la découverte (porté), `+10/+12/+14` au dépôt Well House (avant/avec/après coffre, cf. Dossier §D).
4. **AC4 — Progrès / Closing / Closed** : +25 entrée réelle en grotte, +25 jalons closing, +10/25/30/45 selon issue closed (none/splatter/defeat/victory).
5. **AC5 — Survie** : `(3 - numdie) × 10`, cap 30.
6. **AC6 — Witt's End + Arrondi** : +1 magazine, +2 arrondi final.
7. **AC7 — Malus** : indices (barème), novice -5, indice closing -10, tours `trnluz`, sauvegardes `saved`.
8. **AC8 — Classes** : dérivées de `classes.json` (seuils → ranking novice…master).
9. **AC9 — Tests miroirs** : `test/domain/usecases/compute_score_complete_test.dart` couvre chaque composante isolément + 3 scénarios end-to-end (victoire, mort, abandon) avec seed fixe → score reproductible.
10. **AC10 — Couverture** : nouveau code Domain `compute_score.dart` ≥ 90 %.

## Tasks / Subtasks

- [ ] **Task 1 — Étendre `ScoreBreakdown` VO** (AC: #1)
  - [ ] Ajouter `hintsPenalty`, `deathsPenalty`, `bonus` ; bump `==`/`hashCode` ; tests round-trip.
- [ ] **Task 2 — Implémenter composantes manquantes** (AC: #2-#7)
  - [ ] Trésors étendus, progrès, closing, closed, survie, witt's end, arrondi, malus indices/novice/sauvegardes.
- [ ] **Task 3 — Charger `classes.json` + classement** (AC: #8)
- [ ] **Task 4 — Tests miroirs par composante** (AC: #9)
  - [ ] 1 fichier de test par composante, ≥ 3 cas chacun.
- [ ] **Task 5 — Scénarios end-to-end** (AC: #9)
  - [ ] Reproduire 3 oracles `open-adventure-master/tests/*.chk` (turnpenalties, specials, saveresume.x).
- [ ] **Task 6 — Couverture + doc + completion** (AC: #10)

## Dev Notes

### Architecture cible
`ComputeScore` reste un use case Domain pur, alimenté par `AdventureRepository` (classes.json, turn_thresholds.json) et `Game` (flags `closng/closed/bonus/novice`, `numdie`, `trnluz`, `saved`, `objectStates`, `visitedLocations`).

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/domain/value_objects/score_breakdown.dart` | UPDATE (champs étendus) |
| `lib/domain/usecases/compute_score.dart` | UPDATE (composantes manquantes) |
| `lib/domain/entities/game.dart` | UPDATE possible (flags `numdie`, `trnluz`, `saved` si absents) |
| `test/domain/usecases/compute_score_*_test.dart` | NEW (≥ 6 fichiers) |

### Project Context Rules
- **Domain pur** ; aucune dépendance Flutter.
- **Parité C upstream** : `open-adventure-master/score.c` est l'oracle. Toute divergence = `Completion Notes`.
- **mocktail only**.
- **Couverture Domain ≥ 90 %** sur ce module.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑01
- `open-adventure-master/score.c`
- `open-adventure-master/tests/turnpenalties.chk`, `specials.chk`
- `docs/Dossier_de_Référence.md` §D
- `assets/data/classes.json`, `turn_thresholds.json`

### Previous Story Intelligence
- S3 livré : `ComputeScore` partiel (trésors + exploration + pénalités tours). Cette story étend en gardant l'API.

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
