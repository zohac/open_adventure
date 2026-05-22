# Story 5.13: Audit fidélité 430 pts post-migration

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2
Refs : [epic-5](../planning-artifacts/epic-5.md#story-513-audit-fidélité-430-pts-post-migration), [Dossier_de_Référence §7.4](../Dossier_de_Référence.md), [project-context §Doctrine](../project-context.md)

## Story

**En tant que** Tech Lead,
**je veux** un audit comparant l'état pre/post-migration sur les oracle tests O1–O3, la couverture, et un run d'intégration de 50 tours seed fixe,
**afin que** la migration Bloc 2 (stories 5-6 → 5-10) soit prouvée **sans régression gameplay** avant de déverrouiller les stories `blocked-by-epic-5` (3-16, 3-17, 3-20, 3-23, 4-5, 4-6, 4-7, 4-8, 4-15, 4-18, 4-19).

## Acceptance Criteria

1. **AC1 — Snapshot pré-migration** : capturer **avant** le démarrage du code de 5-6 :
   - Sortie complète de `flutter test --reporter expanded > docs/dev-notes/epic-5-pre-tests.txt`.
   - Sortie couverture (`flutter test --coverage` + `genhtml coverage/lcov.info -o coverage/html ; lcov --summary coverage/lcov.info > docs/dev-notes/epic-5-pre-coverage.txt`).
   - Run intégration 50 tours seed=42 (cf. AC4) → `docs/dev-notes/epic-5-pre-50turn-trace.txt`.
   Ces fichiers sont **committés**.
2. **AC2 — Oracle tests O1–O3 verts post-migration** :
   - **O1** : navette mots magiques XYZZY (Building ↔ Debris Room), seed déterministe, séquence canonique → messages identiques au C upstream.
   - **O2** : nain présent/absent — séquence de 30 tours en DEEP avec seed canonique → présence/absence du nain identique au C.
   - **O3** : pirate vol → récup → dépôt — séquence canonique de manipulation d'un trésor → behavior pirate identique.
   Tests sous `test/integration/oracle_o1_xyzzy_test.dart`, `oracle_o2_dwarf_test.dart`, `oracle_o3_pirate_test.dart`. Si certains tests n'existent pas encore, les créer (priorité O1 — les autres peuvent être référencés à un canon `open-adventure-master/tests/*.chk`).
3. **AC3 — Couverture préservée** :
   - Domain ≥ 90 % (pre vs post : delta ≤ 1 point).
   - Data ≥ 80 % (delta ≤ 1).
   - Application ≥ 80 % (delta ≤ 1).
   - Presentation ≥ 60 % (delta ≤ 2 acceptable car refonte UI).
4. **AC4 — Run intégration 50 tours seed=42** : un test d'intégration `test/integration/migration_50turn_test.dart` joue une séquence canonique de 50 tours sur seed=42 et vérifie que la sortie finale est **identique** au snapshot pré-migration (turn, loc, score, journal hash, inventory). Tolérance whitespace OK ; tolérance ordre messages NON.
5. **AC5 — Rapport `epic-5-fidelity-report.md`** : sous `docs/dev-notes/epic-5-fidelity-report.md`. Contenu :
   - Section « Pre-migration baseline » avec couverture + temps de test + nb tests.
   - Section « Post-migration » idem.
   - Section « Diff » : liste exhaustive de tout ce qui a changé (idéalement vide).
   - Section « Verdict » : ✅ Pas de régression ou ❌ Régressions identifiées (avec plan de correction).
6. **AC6 — Communication** : si l'audit révèle une régression, créer immédiatement un ticket de correction (nouveau fichier story `5-13-fix-X.md`) et **bloquer** le démarrage des stories Bloc 3 (`5-7`, `5-9`, `5-11`) tant que la régression n'est pas résorbée.
7. **AC7 — Qualité** : tous les tests verts ; `flutter analyze` 0 warning ; rapport committé.

## Tasks / Subtasks

- [ ] **Task 1 — Snapshot pré-migration** (AC: #1)
  - [ ] À exécuter **avant** que la story 5-6 ne touche au code.
  - [ ] Committer dans une PR dédiée si besoin pour traçabilité.
- [ ] **Task 2 — Implémenter / réviser oracles O1–O3** (AC: #2)
  - [ ] O1 (priorité haute).
  - [ ] O2, O3 si manquants — comparaison vs `open-adventure-master/tests/*.chk`.
- [ ] **Task 3 — Run intégration 50 tours** (AC: #4)
- [ ] **Task 4 — Mesurer couverture post-migration** (AC: #3)
- [ ] **Task 5 — Rédiger `epic-5-fidelity-report.md`** (AC: #5)
- [ ] **Task 6 — Procédure régression** (AC: #6)
- [ ] **Task 7 — Verdict + clôture** (AC: #7)

## Dev Notes

### Architecture cible

- Cette story n'écrit pas de code applicatif. Elle écrit **des tests** et **un rapport**.
- L'objectif est de prouver que la migration Bloc 2 (5-6, 5-10) n'a pas dévié le gameplay.

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `docs/dev-notes/epic-5-pre-tests.txt` | NEW (snapshot avant) |
| `docs/dev-notes/epic-5-pre-coverage.txt` | NEW |
| `docs/dev-notes/epic-5-pre-50turn-trace.txt` | NEW |
| `docs/dev-notes/epic-5-post-*.txt` | NEW (équivalents après) |
| `docs/dev-notes/epic-5-fidelity-report.md` | NEW |
| `test/integration/oracle_o1_xyzzy_test.dart` | NEW / UPDATE |
| `test/integration/oracle_o2_dwarf_test.dart` | NEW / UPDATE |
| `test/integration/oracle_o3_pirate_test.dart` | NEW / UPDATE |
| `test/integration/migration_50turn_test.dart` | NEW |

### Project Context Rules

- **Doctrine § fidélité gameplay 430 pts** : intouchable. Toute divergence vs `open-adventure-master/{actions,score,saveresume,init}.c` doit être justifiée.
- **Seed déterministe** : utiliser seed=42 (défaut S1).
- **Whitespace tolerance OK** ; **ordre messages NON**.
- **mocktail** : ces tests d'intégration utilisent les vraies implémentations (pas de mock) sauf pour `SaveRepository` (mocké pour éviter FS).

### References

- `docs/Dossier_de_Référence.md` §7.4 (oracles O1–O3)
- `open-adventure-master/tests/turnpenalties.chk`, `specials.chk`, etc.
- `docs/planning-artifacts/epic-5.md` §Story 5.13
- `docs/project-context.md` §Doctrine + §Testing Rules

### Previous Story Intelligence

- Pas de story d'audit précédente. Cette story est la **garantie de non-régression** d'Epic 5.

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
