# Asset Tracker — Locations / Objects / Audio

Statut: généré par outillage (ne pas éditer à la main). Source: `scripts/generate_asset_tracker.py`.

Contrat de génération (normatif)

- L’Asset Tracker reflète la réalité de production (images/audio) et se conforme aux normes: `docs/CONVERSION_SPEC.md` (§17–§19) et `docs/ART_ASSET_BIBLE.md`.
- Ce fichier contient deux parties: (1) un préambule normatif (humain) que l’outil DOIT préserver; (2) des tableaux générés (remplacés à chaque exécution) entre balises dédiées.
- Balises réservées: ne pas modifier les lignes marquées `<!-- GENERATED_START -->` et `<!-- GENERATED_END -->`.

Schéma et conventions (normatif)

- Priorité: `P0` (S3 must-have), `P1` (S3 nice-to-have), `P2` (S4/polish).
- Owner: `ART` (Game Artist), `AUDIO`, `DEV` (intégration), `GD` (validation design).
- Status: `briefed`, `in_progress`, `ready_for_review`, `approved`, `integrated`, `needs_rework`, `blocked`.
- Zone (scènes): `surface`, `grotte`, `river`, `sanctuary`, `danger`.
- Budgets: image ≤ 200 KB, pack images ≤ 10 Mo; BGM loop ≤ 600 KB, pack BGM ≤ 8 Mo; SFX pack ≤ 1 Mo.

Colonnes attendues (générateur)

- Scenes: `key` (locationImageKey), `name` (Location.name), `zone`, `palette` (palette zone/scene), `image_path` (assets/images/locations/<key>.webp), `image_sizeKB`, `vfx`, `bgm`, `priority`, `owner`, `status`, `notes`.
- Objects: `id/name`, `isTreasure`, `locations` (keys), `sfx` (cue ids), `vfx` (overlays), `owner`, `status`, `notes`.
- Audio: `type` (bgm|sfx), `key`, `file` (path), `sizeKB`, `loop/throttle` (bgm loop ms | sfx throttle ms), `owner`, `status`, `notes`.

Résumé budgets (à jour lors de génération)

- Images (pack): … / ≤ 10 Mo
- BGM (pack): … / ≤ 8 Mo — SFX (pack): … / ≤ 1 Mo

Liens utiles

- Bible assets (briefs, palettes, VFX/SFX): `docs/ART_ASSET_BIBLE.md`
- Spécification UX et écrans: `docs/UX_SCREENS.md`

<!-- GENERATED_START -->

## Locations (Scenes)

| key | name | zone | image | vfx | bgm | priority | owner | status | notes |
|-----|------|------|-------|-----|-----|----------|-------|--------|-------|

## Objects

| id/name | isTreasure | locations | sfx | vfx | owner | status | notes |
|---------|------------|-----------|-----|-----|-------|--------|-------|

## Audio

| type | key | file | sizeKB | loop/throttle | owner | status | notes |
|------|-----|------|--------|---------------|-------|--------|-------|

<!-- GENERATED_END -->
