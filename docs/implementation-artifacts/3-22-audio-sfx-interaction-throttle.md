# Story 3.22: Audio — SFX d'interaction (prendre/poser/lampe/danger) + throttle

Status: ready-for-dev
Epic: 3
Source ticket: ADVT‑S3‑22 (`docs/EXEC_S3.md`)
Refs : [design.md](../design.md), [project-context](../project-context.md), [architecture](../architecture.md), [asset-inventory](../asset-inventory.md)

---
## 📝 Amendement Design Handoff — 2026-05-22

Intégrer durant le dev :
- **Stack audio confirmée** : `just_audio` + `audio_session` (cf. [`docs/design.md`](../design.md) §3.1 patché 2026-05-22)
- **SFX list** : tap stamp, take, drop, lamp on/off, dwarf alert, treasure sparkle, magic word, death (cf. [`docs/design.md`](../design.md) §8)
- **Throttle 150 ms** : préservé (cf. `project-context.md` §Performance Rules)
- **Migration** : si l'Epic 5 story 5-10 est déjà livrée, `AudioController` est consommé via `audioControllerProvider`

> ℹ️ Non bloquant : la story peut progresser indépendamment d'Epic 5.
---

## Story

**En tant que** joueur, **je veux** un retour sonore court (clic, prendre, poser, lampe on/off, alerte nain, succès/échec) sur chaque interaction, **afin de** rendre les actions tactiles satisfaisantes sans devenir intrusives.

## Acceptance Criteria

1. **AC1 — Table `eventKey → sfxKey`** : implémentée dans `lib/application/services/sfx_router.dart` (NEW). Événements minimum : `take`, `drop`, `open`, `close`, `light`, `extinguish`, `dwarf_alert`, `success`, `failure`.
2. **AC2 — Déclenchement** : `GameController.perform` notifie le router après l'application du use case ; le router résout `eventKey` à partir du verbe (`TAKE`→`take`, `LIGHT`→`light`, etc.).
3. **AC3 — Throttle 150 ms** : `AudioController.playSfx` (existant) déjà throttle à 150 ms ; vérifier qu'on n'inhibe pas indésirablement (test).
4. **AC4 — Volume utilisateur** : appliqué via `AudioSettingsController.sfxVolume`.
5. **AC5 — Pas de spam** : si plusieurs SFX dans le même tour (ex : take + lampe on), respecter le throttle (le dernier prime ou queue selon design — décision documentée).
6. **AC6 — Livrables OGG** : ≤ 60 KB/SFX, total ≤ 1 Mo, 48 kHz mono ; déclarés dans `pubspec.yaml`.
7. **AC7 — Tests unitaires** : `test/application/services/sfx_router_test.dart` : mapping verbe→SFX, fallback unknown (no-op), throttle ON/OFF testé.
8. **AC8 — Tests intégration** : `GameController` déclenche `playSfx(take)` après TakeObject, `playSfx(light)` après LightLamp, etc.

## Tasks / Subtasks

- [ ] **Task 1 — `SfxRouter` service** (AC: #1, #5)
- [ ] **Task 2 — Intégration `GameController`** (AC: #2, #4)
- [ ] **Task 3 — Vérifier throttle `AudioController`** (AC: #3)
- [ ] **Task 4 — Livrer OGG SFX (9 événements min.)** (AC: #6)
- [ ] **Task 5 — Tests unitaires + intégration** (AC: #7, #8)
- [ ] **Task 6 — Doc + completion**

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/application/services/sfx_router.dart` | NEW |
| `lib/application/controllers/game_controller.dart` | UPDATE |
| `assets/audio/sfx/*.ogg` | NEW |
| `pubspec.yaml` | UPDATE |
| `test/application/services/sfx_router_test.dart` | NEW |

### Project Context Rules
- **Application orchestration** ; mapping verb→SFX ici, jamais dans Domain.
- **mocktail only**.

### References
- `docs/EXEC_S3.md` ADVT‑S3‑22
- `lib/application/services/audio_controller.dart` (`playSfx` + throttle)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
