# Story 3.23: Art — livrer 15–20 scènes prioritaires (Asset Bible)

Status: blocked-by-epic-5
Epic: 3
Source ticket: ADVT‑S3‑23 (`docs/EXEC_S3.md`)
Refs : [design.md](../design.md), [ART_ASSET_BIBLE](../ART_ASSET_BIBLE.md), [asset-inventory](../asset-inventory.md), [ASSET_MANIFEST.json](../ASSET_MANIFEST.json)
~~Refs obsolètes~~ : ~~[VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md)~~ (superseded 2026-05-22)

---
## 📝 Amendement Design Handoff — 2026-05-22

Cette story est antérieure au handoff design. Avant `dev-story`, intégrer :
- **Palette imposée** : encre profonde × halo ambre × papier vieilli (cf. [`docs/design.md`](../design.md) §4 ADR-003 ; [`tokens.css`](../../design_handoff_open_adventure/tokens.css))
- **Cohérence visuelle** : les scènes doivent harmoniser leurs palettes avec les tokens de l'UI (chrome ambre, fond encre) — pas de scènes saturées qui rompent la signature lumineuse
- **QA** : check de contraste WCAG AA pour les éléments porteurs d'info (signalisation visuelle des sorties, objets interactifs)
- **ART_ASSET_BIBLE.md** doit être mis à jour en amont (story 5-12 ou en parallèle) pour intégrer les directives ADR-010 (3 tiers d'assets)

> ⚠️ **Bloquant** : cette story ne peut entrer en dev qu'après livraison de Epic 5 story 5-3 (tokens) — pour caler la palette de référence.
---

## Story

**En tant que** Directeur Artistique / artiste pixel-art, **je veux** livrer 15–20 scènes prioritaires conformes à l'`ART_ASSET_BIBLE.md` (Building, Forest, Valley, Hill, Roadend, Grate, Slit, Cliff, Hall of Mists, Dragon room, Maze entrance, Sanctuary, etc.), **afin que** la Story 3-20 puisse les déclarer dans `pubspec.yaml` et que la Story 3-16 MapPage puisse utiliser le blob FOREST.

## Acceptance Criteria

1. **AC1 — Liste prioritaire** : 15–20 lieux validés via `docs/ART_ASSET_BIBLE.md` ; clés `<key>` conformes au calcul `locationImageKey(Location)` (`mapTag` → `snake_case(name)` → `id`).
2. **AC2 — Format & budget** : chaque `.webp` lossless, 320×180 ou multiple, ≤ 200 KB, palette ≤ 64 couleurs ; total ≤ 10 MB.
3. **AC3 — Rendu pixel-perfect** : valider à l'œil via `PixelCanvas` (scale entier ×2/×3 sur device) ; aucun flou ; alignement pixel-grid.
4. **AC4 — Naming** : chemin `assets/images/locations/<key>.webp` ; clé en `snake_case` strict.
5. **AC5 — Blob FOREST spécifique** : 1 image dédiée `assets/images/map/forest_blob.webp` (≤ 200 KB) tons verts/ocres, utilisée par MapPainter (Story 3-16).
6. **AC6 — Revue croisée** : note de synthèse Game Design + Dev validant DA 16-bit (palette, contrastes, fidélité).
7. **AC7 — Mise à jour Manifest** : `docs/ASSET_MANIFEST.json` reflète les images livrées (statut + chemin) via `python3 scripts/generate_asset_manifest.py`.
8. **AC8 — Asset Tracker** : `python3 scripts/generate_asset_tracker.py` produit `docs/ASSET_TRACKER.md` mettant à jour le compteur images livrées/total et tailles.

## Tasks / Subtasks

- [ ] **Task 1 — Sélection prioritaire** (AC: #1)
  - [ ] Croiser `docs/ART_ASSET_BIBLE.md` + `docs/ASSET_MANIFEST.json` ; finaliser la liste 15–20.
- [ ] **Task 2 — Production + relecture DA** (AC: #2, #3, #4, #5)
- [ ] **Task 3 — Conversion WebP + vérification budget** (AC: #2)
- [ ] **Task 4 — Dépôt sous `assets/images/locations/` et `assets/images/map/`** (AC: #4, #5)
- [ ] **Task 5 — Revue croisée Game Design / Dev** (AC: #6)
- [ ] **Task 6 — Régénération manifest + tracker** (AC: #7, #8)
- [ ] **Task 7 — Note de synthèse + completion**

## Dev Notes

### Source tree

| Path | NEW |
|---|---|
| `assets/images/locations/<key>.webp` × 15–20 | NEW |
| `assets/images/map/forest_blob.webp` | NEW |
| `docs/ASSET_MANIFEST.json` (regénéré) | UPDATE |
| `docs/ASSET_TRACKER.md` (regénéré) | UPDATE |

### Project Context Rules
- **Pixel-perfect** : `FilterQuality.none` côté code ; validation visuelle à l'œil sur device.
- **Pas de réseau** ; tous assets embarqués.
- **Budget total ≤ 10 MB** non négociable.

### References
- `docs/EXEC_S3.md` ADVT‑S3‑23
- `docs/ART_ASSET_BIBLE.md` (briefs scènes/palettes/VFX)
- `docs/VISUAL_STYLE_GUIDE.md`
- `lib/core/utils/location_image.dart` (résolution clé)
- `lib/presentation/widgets/pixel_canvas.dart`

### Previous Story Intelligence
- Pas de story art précédente. Cette story alimente directement **Story 3-20** (déclaration dans pubspec) et **Story 3-16** (blob FOREST).

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
