# Story 4.3: Système d'indices — GetHints + UseHint avec malus idempotent

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑03 (`docs/EXEC_S4.md`)
Refs : [Dossier_de_Référence §7.7](../Dossier_de_Référence.md), `open-adventure-master/hints.adoc`, `assets/data/hints.json`

## Story

**En tant que** joueur bloqué, **je veux** demander un indice contextuel (avec pénalité de score) lié à la situation courante, **afin de** progresser sans solution complète et sans casser la fidélité historique.

## Acceptance Criteria

1. **AC1 — Use case `GetHints`** : retourne `List<Hint>` disponibles pour `Game` courant (contexte = lieu + objets + flags). Lecture depuis `assets/data/hints.json`.
2. **AC2 — Use case `UseHint(id)`** : applique le malus (barème canonique), marque `Game.hintsUsed` (set), retourne le texte d'indice (niveaux 1→2→solution graduels).
3. **AC3 — Idempotence** : `UseHint(id)` deux fois → malus appliqué **une seule fois** ; le 2e appel retourne le texte sans re-pénaliser.
4. **AC4 — UI opt-in** : `SettingsPage` ou bouton dédié AdventurePage (déterminer en revue UX) ouvre un menu listant les indices disponibles.
5. **AC5 — Intégration score** : malus consommés par `ComputeScore` via `Game.hintsUsed`.
6. **AC6 — Tests** : `GetHints` (disponibilité contextuelle), `UseHint` (idempotence, malus une fois).

## Tasks / Subtasks

- [ ] **Task 1 — Domain entity `Hint` + use cases** (AC: #1, #2, #3)
- [ ] **Task 2 — Persistance `hintsUsed` dans `Game` + snapshot** (AC: #2, #5)
- [ ] **Task 3 — UI hints** (AC: #4)
- [ ] **Task 4 — Intégration `ComputeScore`** (AC: #5)
- [ ] **Task 5 — Tests** (AC: #6)

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/domain/entities/hint.dart` | NEW |
| `lib/domain/usecases/get_hints.dart`, `use_hint.dart` | NEW |
| `lib/domain/entities/game.dart` | UPDATE (`Set<int> hintsUsed`) |
| `lib/domain/value_objects/game_snapshot.dart` | UPDATE (persister hintsUsed) |
| `lib/domain/usecases/compute_score.dart` | UPDATE (consommer hintsUsed) |
| `lib/presentation/pages/adventure_page.dart` ou nouveau dialog | UPDATE |
| `test/domain/usecases/{get_hints,use_hint}_test.dart` | NEW |

### Project Context Rules
- Domain pur.
- mocktail only.
- Snapshot V3 si bump nécessaire (compat ascendante).

### References
- `docs/EXEC_S4.md` ADVT‑S4‑03
- `docs/Dossier_de_Référence.md` §7.7
- `open-adventure-master/hints.adoc`
- `assets/data/hints.json`

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
