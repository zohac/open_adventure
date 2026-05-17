# Story 4.13: Résilience sauvegardes — rollback + corruption + fallback autosave

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑13 (`docs/EXEC_S4.md`)
Refs : [data-models](../data-models.md), [Dossier_de_Référence](../Dossier_de_Référence.md)

## Story

**En tant que** joueur, **je veux** que l'app survive à une sauvegarde corrompue ou inattendue (panne, processus killed) en repartant du dernier autosave sain, **afin de** ne jamais perdre une session complète.

## Acceptance Criteria

1. **AC1 — Détection corruption** : lecture d'un slot/autosave avec JSON invalide → `SaveRepository` retourne `null` (sans crash) et log informatif.
2. **AC2 — Fallback** : `GameController.loadAutosave()` essaie `autosave.json` ; en cas d'échec, essaie le slot le plus récent (`SaveRepository.list().first`) ; sinon démarre une nouvelle partie.
3. **AC3 — Rollback** : écriture atomique (déjà couverte par Story 4-4) garantit qu'une panne ne corrompt pas un fichier existant.
4. **AC4 — Tests** : corruption simulée (fichier tronqué, JSON invalide, schema_version inconnue) → comportement attendu sans crash.
5. **AC5 — Logs** : `debugPrint` en cas de fallback ; pas en release.

## Tasks / Subtasks

- [ ] **Task 1 — Robustifier `SaveRepository.latest()` et `load()`** (AC: #1).
- [ ] **Task 2 — `GameController.loadAutosave()`** fallback chain (AC: #2).
- [ ] **Task 3 — Tests corruption** (AC: #4).
- [ ] **Task 4 — Logging** (AC: #5).

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `lib/data/repositories/save_repository_impl.dart` | Hardening |
| `lib/application/controllers/game_controller.dart` | Fallback chain |
| `test/data/repositories/save_repository_impl_test.dart` | Étendre |

### Project Context Rules
- Lecture tolérante champs inconnus (déjà règle).
- Pas de crash sur fichier corrompu.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑13
- Story 4-4 (atomicité écriture)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
