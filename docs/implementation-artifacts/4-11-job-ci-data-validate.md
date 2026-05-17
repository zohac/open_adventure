# Story 4.11: Job CI `data-validate` (optionnel, non bloquant mobile)

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑11 (`docs/EXEC_S4.md`)
Refs : [development-guide](../development-guide.md), [deployment-guide](../deployment-guide.md)

## Story

**En tant que** mainteneur de la base, **je veux** un job CI qui exécute `scripts/validate_json.py` et rapporte les divergences YAML↔JSON sans bloquer le pipeline mobile, **afin de** détecter automatiquement toute corruption d'assets.

## Acceptance Criteria

1. **AC1 — Job CI configuré** : workflow GitHub Actions (`.github/workflows/data-validate.yml`) installe Python + PyYAML, exécute `python3 scripts/validate_json.py`.
2. **AC2 — Sortie lisible** : log structuré listant les divergences ; codes exit 0/1 respectés.
3. **AC3 — Non bloquant mobile** : le pipeline principal (Story 4-14) reste vert même si `data-validate` échoue (job indépendant ; PR notification soft).
4. **AC4 — Documentation** : `docs/development-guide.md` § CI mentionne le job ; `docs/deployment-guide.md` aussi.

## Tasks / Subtasks

- [ ] **Task 1 — `.github/workflows/data-validate.yml`** (AC: #1, #2, #3).
- [ ] **Task 2 — Doc CI** (AC: #4).

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `.github/workflows/data-validate.yml` | NEW |
| `docs/development-guide.md`, `deployment-guide.md` | UPDATE |

### Project Context Rules
- Pas de réseau exigé côté app ; ce job tourne uniquement en CI.
- Job indépendant du pipeline mobile (non bloquant).

### References
- `docs/EXEC_S4.md` ADVT‑S4‑11
- `scripts/validate_json.py`

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
