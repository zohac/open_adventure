# Story 3.19: Lint zéro warning + couverture Domain ≥ 85 %

Status: ready-for-dev
Epic: 3
Source ticket: ADVT‑S3‑19 (`docs/EXEC_S3.md`)
Refs : [project-context](../project-context.md), [architecture](../architecture.md)

## Story

**En tant que** mainteneur de la base de code, **je veux** un état de référence S3 propre (lint zéro warning, couverture Domain ≥ 85 %, tests verts) **avant** de clôturer l'epic 3 et d'entrer en S4, **afin de** capitaliser sur une base saine pour le scoring complet et la finalisation production-ready.

## Acceptance Criteria

1. **AC1 — `flutter analyze` zéro warning** : la commande retourne `No issues found!` sur tout le code actif (exclusions `lib_legacy/`, `test/features/`, `build/`, `coverage/` conservées).
2. **AC2 — Couverture Domain ≥ 85 %** : `flutter test --coverage` produit `coverage/lcov.info` ; mesure manuelle Domain (`lib/domain/`) ≥ 85 % lignes/branches.
3. **AC3 — Tests verts** : `flutter test` complet → 100 % pass, 0 skipped non justifié.
4. **AC4 — Couverture additionnelle** : Data ≥ 75 %, Application ≥ 75 %, Presentation ≥ 50 % (cibles intermédiaires, montées à S4).
5. **AC5 — Rapport lisible** : `coverage/html/` généré via `genhtml coverage/lcov.info -o coverage/html` ; archiver le pourcentage final dans `Completion Notes`.

## Tasks / Subtasks

- [ ] **Task 1 — Audit lint** (AC: #1)
  - [ ] Lancer `flutter analyze` ; lister tous les warnings/infos.
  - [ ] Corriger un par un (préférer la correction au `// ignore`).
- [ ] **Task 2 — Audit couverture Domain** (AC: #2)
  - [ ] `flutter test --coverage` ; analyser `coverage/lcov.info` ; identifier les fichiers Domain < 85 %.
  - [ ] Compléter les tests manquants (chemins erreurs, branches non couvertes).
- [ ] **Task 3 — Couverture Data/Application/Presentation** (AC: #4)
  - [ ] Identifier les modules sous-couverts ; ajouter tests ciblés.
- [ ] **Task 4 — Génération rapport HTML** (AC: #5)
  - [ ] `genhtml coverage/lcov.info -o coverage/html` ; consigner pourcentage final.
- [ ] **Task 5 — Documentation** (AC: trace)
  - [ ] Mettre à jour `docs/EXEC_S3.md` ADVT‑S3‑19 (cocher la case).
  - [ ] Compléter `Dev Agent Record` (note synthèse).

## Dev Notes

### Source tree components to touch

| Path | NEW / UPDATE | Reason |
|---|---|---|
| `lib/**/*.dart` | UPDATE ciblé | Corrections lint |
| `test/domain/**/*.dart` | NEW/UPDATE | Tests manquants |
| `test/data/**`, `test/application/**`, `test/presentation/**` | NEW/UPDATE | Compléments |
| `coverage/html/` | NEW (généré) | Rapport visuel |

### Project Context Rules
- **Test miroir obligatoire** : chaque module `lib/<chemin>.dart` a un test `test/<chemin>_test.dart`.
- **Domain pur** dans tests Domain (`package:test`, pas `flutter_test`).
- **mocktail only**.
- **`flutter analyze` zéro warning** est non-négociable avant merge.

### References
- `docs/EXEC_S3.md` ADVT‑S3‑19
- `analysis_options.yaml`
- `docs/project-context.md` § Testing Rules

### Previous Story Intelligence
- Pattern repris de S2 (ADVT‑S2‑14 zéro warning) : approche par couche, fix au lieu d'`ignore`.

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
