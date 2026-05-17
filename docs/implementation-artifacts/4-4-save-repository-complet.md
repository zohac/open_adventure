# Story 4.4: SaveRepository complet — save/load/list/delete + atomique

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑04 (`docs/EXEC_S4.md`)
Refs : [Dossier_de_Référence §7.3](../Dossier_de_Référence.md), [data-models](../data-models.md), `open-adventure-master/saveresume.c`

## Story

**En tant que** joueur, **je veux** plusieurs slots de sauvegarde manuels (en plus de l'autosave) avec liste / chargement / suppression depuis l'app, **afin de** gérer mes progressions multiples sans crainte de perdre ma partie.

## Acceptance Criteria

1. **AC1 — API étendue** : `SaveRepository` ajoute `save(slot, snapshot)`, `load(slot)`, `list()`, `delete(slot)` ; `latest()`/`autosave()` conservés.
2. **AC2 — Fichiers** : `save_v{schemaVersion}_{slot}.json` sous `applicationSupportDirectory/open_adventure/saves/` ; conserver `autosave.json` au même niveau.
3. **AC3 — Métadonnées slot** : `{ updated_at, turns, score, locationName }` dans chaque slot pour `SavesPage` (Story 4-5).
4. **AC4 — Écriture atomique** : `save` écrit un fichier temporaire puis `rename` (interdit corruption mid-write).
5. **AC5 — Rétention** : politique FIFO simple, N=10 slots max + autosave ; supprimer les plus anciens si dépassement.
6. **AC6 — Lecture tolérante** : ignore les champs inconnus ; compatibilité V1↔V2↔V3.
7. **AC7 — Tests** : round-trip save→list→load→delete ; lecture V1 dans V2 ; corruption simulée → fallback dernier autosave sain.

## Tasks / Subtasks

- [ ] **Task 1 — Étendre interface `SaveRepository`** (AC: #1)
- [ ] **Task 2 — `SaveRepositoryImpl` étendu** (AC: #2-#6)
- [ ] **Task 3 — Tests exhaustifs** (AC: #7)
- [ ] **Task 4 — Mettre à jour `GameController`** (consommer multi-slots dans Story 4-5)

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `lib/domain/repositories/save_repository.dart` | API étendue |
| `lib/data/repositories/save_repository_impl.dart` | Impl FS atomique |
| `test/data/repositories/save_repository_impl_test.dart` | Étendre tests |

### Project Context Rules
- Atomicité écriture obligatoire (temp+rename).
- Lecture tolérante champs inconnus.
- Pas de réseau.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑04
- `docs/Dossier_de_Référence.md` §7.3 (snapshot V1)
- `open-adventure-master/saveresume.c`

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
