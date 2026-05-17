# Story 4.16: Audio — preload BGM + mémoire < 20 Mo + ducking mixage final

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑16 (`docs/EXEC_S4.md`)
Refs : [project-context](../project-context.md), [architecture](../architecture.md)

## Story

**En tant que** joueur, **je veux** des transitions audio fluides (preload du prochain BGM, ducking BGM lors des SFX importants), avec une empreinte mémoire audio totale < 20 Mo, **afin de** garder une expérience sonore propre sans peser sur l'appareil.

## Acceptance Criteria

1. **AC1 — Preload BGM** : `AudioController.preloadBgm(trackKey)` chauffe le player suivant ; appelé lors d'un changement de zone imminent (détecté via `ZoneAudioRouter`).
2. **AC2 — Mémoire < 20 Mo** : empreinte audio totale (players + buffers) mesurée < 20 Mo sur device.
3. **AC3 — Ducking BGM** : sur SFX majeurs (`dwarf_alert`, `failure`, victoire), BGM ducké -4 dB pendant 200 ms (lissage).
4. **AC4 — Courbes lissées** : pas de clicks ; validation à l'oreille documentée.
5. **AC5 — Tests** : unitaires sur états du manager (préload, duck/unduck) ; validation manuelle documentée.

## Tasks / Subtasks

- [ ] **Task 1 — `AudioController.preloadBgm`** (AC: #1).
- [ ] **Task 2 — `AudioController.duckBgm(amount, duration)`** (AC: #3, #4).
- [ ] **Task 3 — Mesure mémoire** (AC: #2).
- [ ] **Task 4 — Tests + validation** (AC: #5).

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `lib/application/services/audio_controller.dart` | API étendue |
| `lib/application/services/zone_audio_router.dart` | Preload upcoming |
| `lib/application/services/sfx_router.dart` | Déclenche ducking |
| `test/application/services/audio_controller_test.dart` | Étendre |

### Project Context Rules
- mocktail only.
- Pas de réseau.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑16
- Stories 3-21 (ZoneAudioRouter) ; 3-22 (SfxRouter)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
