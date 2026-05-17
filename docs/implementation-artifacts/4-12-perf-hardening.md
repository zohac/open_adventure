# Story 4.12: Perf & hardening — Isolate + bench démarrage + jank + mémoire

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑12 (`docs/EXEC_S4.md`)
Refs : [project-context](../project-context.md), [architecture](../architecture.md)

## Story

**En tant que** utilisateur sur smartphone milieu de gamme, **je veux** un démarrage rapide, un parcours sans jank, et une empreinte mémoire raisonnable, **afin de** jouer confortablement sur les golden devices (Samsung Tab A8, POCO F4, iPhone XR/11).

## Acceptance Criteria

1. **AC1 — Cold start < 1,0 s** sur golden devices Android (mesuré via `flutter run --trace-startup`).
2. **AC2 — Aucune frame > 16 ms** sur parcours nominal (Home → Adventure → Map → Inventory → Settings).
3. **AC3 — Mémoire < 150 Mo** au repos après 5 min de jeu (mesurée via DevTools Memory).
4. **AC4 — Isolate parsing** : flag `Settings.parseUseIsolate` activé automatiquement si taille cumulée assets > 1 Mo ; testé.
5. **AC5 — Traces enregistrées** : Timeline + Memory snapshots archivés dans `Dev Agent Record`.

## Tasks / Subtasks

- [ ] **Task 1 — Activer Isolate parsing au-delà du seuil** (AC: #4).
- [ ] **Task 2 — Bench cold start** (AC: #1).
- [ ] **Task 3 — Profilage jank** (AC: #2).
- [ ] **Task 4 — Profil mémoire** (AC: #3).
- [ ] **Task 5 — Correctifs identifiés** (AC: tous).
- [ ] **Task 6 — Archiver traces** (AC: #5).

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `lib/core/settings.dart` | Bascule auto Isolate ? |
| Modules identifiés en jank | UPDATE ciblés |
| `Dev Agent Record` | Traces |

### Project Context Rules
- Pixel-perfect : pas de scaling non entier.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑12
- `docs/project-context.md` §Performance Rules
- DevTools Flutter

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
