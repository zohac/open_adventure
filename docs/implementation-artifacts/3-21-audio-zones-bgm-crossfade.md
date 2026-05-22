# Story 3.21: Audio — mapping zones → BGM + crossfade

Status: ready-for-dev
Epic: 3
Source ticket: ADVT‑S3‑21 (`docs/EXEC_S3.md`)
Refs : [design.md](../design.md), [project-context](../project-context.md), [architecture](../architecture.md), [asset-inventory](../asset-inventory.md)

---
## 📝 Amendement Design Handoff — 2026-05-22

Intégrer durant le dev :
- **Stack audio confirmée** : `just_audio` + `audio_session` (cf. [`docs/design.md`](../design.md) §3.1 patché 2026-05-22 ; ADR audio noté en `docs/dev-notes/` si besoin)
- **5 zones BGM** : `surface_loop.ogg` / `cave_loop.ogg` / `river_loop.ogg` / `sanctuary_loop.ogg` / `danger_loop.ogg` (cf. [`docs/design.md`](../design.md) §8)
- **Mapping zones** : aligner sur la matrice de [`docs/design.md`](../design.md) §8 si elle diffère de l'inventaire actuel
- **Migration** : si l'Epic 5 story 5-10 est déjà livrée, `AudioController` est consommé via `audioControllerProvider` (Riverpod)

> ℹ️ Non bloquant : la story peut progresser indépendamment d'Epic 5. Si l'audio controller migre avant la fin de cette story, adapter les call sites.
---

## Story

**En tant que** joueur, **je veux** qu'une musique d'ambiance se lance dans chaque zone du jeu (surface, grotte, danger, sanctuaire…) et bascule en crossfade lors d'un changement de zone, **afin de** ressentir une immersion sonore cohérente sans coupures abruptes.

## Acceptance Criteria

1. **AC1 — Table de mapping `zoneKey → trackKey`** : implémentée dans `lib/application/services/zone_audio_router.dart` (NEW) ; couvre au minimum les 5 strates Map (`surface`, `upper_cave`, `hall_of_mists`, `labyrinths_river`, `sanctuary_endgame`) + clé spéciale `danger` (déclenchée par un flag, S4 plus tard).
2. **AC2 — Bascule sur changement de zone** : `GameController.perform` détecte un changement de strate (via `MapLayoutRepository.layerOf(loc)` ou équivalent) et appelle `AudioController.playBgm(trackKey)` avec crossfade.
3. **AC3 — Crossfade 250–500 ms** : `AudioController` crossfade actuellement à 350 ms par défaut ; conserver ; tests d'écoute manuels documentés.
4. **AC4 — Loops gapless** : les fichiers `assets/audio/music/<trackKey>.ogg` ont `loopStart`/`loopEnd` calibrés ; validation à l'oreille.
5. **AC5 — Latence < 50 ms** : démarrage du player BGM perçu < 50 ms.
6. **AC6 — Pas de spam** : si la zone n'a pas changé, ne pas redéclencher `playBgm`.
7. **AC7 — Tests unitaires** : `test/application/services/zone_audio_router_test.dart` : sélection track par zone, robustesse zone inconnue (fallback `surface`).
8. **AC8 — Tests d'intégration GameController** : vérifier que `playBgm` est appelé exactement 1× sur changement de zone, 0× si même zone.
9. **AC9 — Volumes** : applique le volume utilisateur (`AudioSettingsController`) ; ne pas hardcoder.

## Tasks / Subtasks

- [ ] **Task 1 — `ZoneAudioRouter` (Application service)** (AC: #1, #6)
- [ ] **Task 2 — Intégration `GameController`** (AC: #2, #6)
- [ ] **Task 3 — Vérifier crossfade `AudioController`** (AC: #3, #5)
- [ ] **Task 4 — Livrer les OGG BGM (5 zones min.)** (AC: #4, #5)
  - [ ] Conformes à `docs/ART_ASSET_BIBLE.md` (loops gapless, ≤ 600 KB, 48 kHz stéréo) ; déclarés dans `pubspec.yaml`.
- [ ] **Task 5 — Tests unitaires + intégration** (AC: #7, #8, #9)
- [ ] **Task 6 — Doc + completion**
  - [ ] MAJ `docs/asset-inventory.md` (statut BGM).

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/application/services/zone_audio_router.dart` | NEW |
| `lib/application/controllers/game_controller.dart` | UPDATE (hook zone change) |
| `lib/application/services/audio_controller.dart` | (lecture, déjà OK) |
| `assets/audio/music/*.ogg` (5 zones) | NEW |
| `pubspec.yaml` | UPDATE (déclaration audio) |
| `test/application/services/zone_audio_router_test.dart` | NEW |
| `test/application/controllers/game_controller_test.dart` | UPDATE (cas zone change) |

### Project Context Rules
- **Application = orchestration** ; le router est un service Application, pas Domain.
- **DI manuelle** dans `main.dart`.
- **Pas de réseau** ; tous OGG embarqués.
- **mocktail only**.

### References
- `docs/EXEC_S3.md` ADVT‑S3‑21
- `lib/application/services/audio_controller.dart` (API `playBgm`/`stopBgm` + crossfade existant)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
