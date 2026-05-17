# Story 4.18: Art — compléter les scènes restantes (Asset Bible) + QA finale 16-bit

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑18 (`docs/EXEC_S4.md`)
Refs : [ART_ASSET_BIBLE](../ART_ASSET_BIBLE.md), [VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md), [asset-inventory](../asset-inventory.md)

## Story

**En tant que** Directeur Artistique, **je veux** livrer les scènes restantes (au-delà des 15–20 prioritaires de S3) pour couvrir tous les lieux pertinents, **afin de** garantir une présence visuelle complète avant la release V1.

## Acceptance Criteria

1. **AC1 — Couverture** : toutes les scènes planifiées par `docs/ART_ASSET_BIBLE.md` sont livrées (cibles minimales : lieux clés non clusterisés + représentations cluster MAZE_A / MAZE_B).
2. **AC2 — Budgets** : ≤ 200 KB/image, total ≤ 10 MB.
3. **AC3 — Rendu pixel-perfect** validé via `PixelCanvas` sur device.
4. **AC4 — Conformité DA** : palettes, contrastes (mode sombre OK), nommage cohérent.
5. **AC5 — Mise à jour Manifest + Tracker** : `docs/ASSET_MANIFEST.json` et `docs/ASSET_TRACKER.md` régénérés.
6. **AC6 — Revue DA + Game Design** : note de synthèse dans `Completion Notes`.

## Tasks / Subtasks

- [ ] **Task 1 — Sélection résiduelle + production** (AC: #1, #2, #3, #4).
- [ ] **Task 2 — Régénération manifest + tracker** (AC: #5).
- [ ] **Task 3 — Revue + note synthèse** (AC: #6).

## Dev Notes

### Source tree

| Path | NEW |
|---|---|
| `assets/images/locations/*.webp` (delta) | NEW |
| `docs/ASSET_MANIFEST.json` (regénéré) | UPDATE |
| `docs/ASSET_TRACKER.md` (regénéré) | UPDATE |

### Project Context Rules
- Pixel-perfect (FilterQuality.none côté code).
- Budgets non négociables.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑18
- Story 3-23 (15–20 scènes prioritaires)
- `docs/ART_ASSET_BIBLE.md`

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
