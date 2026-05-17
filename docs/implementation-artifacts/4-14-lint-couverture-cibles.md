# Story 4.14: Lint zéro warning + couverture cibles Domain ≥ 90 / Data ≥ 80 / App ≥ 80 / UI ≥ 60 (CI enforcer)

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑14 (`docs/EXEC_S4.md`)
Refs : [project-context](../project-context.md), [development-guide](../development-guide.md)

## Story

**En tant que** mainteneur, **je veux** que la CI échoue automatiquement si `flutter analyze` génère un warning ou si la couverture passe sous les seuils par couche, **afin de** verrouiller la qualité du code à la livraison V1.

## Acceptance Criteria

1. **AC1 — Workflow CI principal** : `.github/workflows/ci.yml` (NEW) exécute `flutter analyze --fatal-warnings`, `flutter test --coverage`, et enforce les seuils via outil (ex. `lcov_cobertura` ou script Dart).
2. **AC2 — Seuils** : Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 %.
3. **AC3 — Rapport LCOV** : `coverage/lcov.info` archivé comme artefact CI ; rapport HTML généré (`genhtml`) et téléchargeable.
4. **AC4 — Échec explicite** : message d'erreur clair si seuil non atteint (nom couche, pourcentage actuel, seuil attendu).

## Tasks / Subtasks

- [ ] **Task 1 — Script Dart enforcer couverture** : `scripts/check_coverage.dart` (NEW) parse LCOV et compare aux seuils par préfixe (`lib/domain/`, etc.).
- [ ] **Task 2 — Workflow CI** (AC: #1, #2, #3).
- [ ] **Task 3 — Doc** : `docs/development-guide.md` § CI mise à jour.

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `.github/workflows/ci.yml` | NEW |
| `scripts/check_coverage.dart` | NEW |
| `docs/development-guide.md` | UPDATE |

### Project Context Rules
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑14
- `docs/project-context.md` §Testing Rules

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
