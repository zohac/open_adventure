# Story 5.12: Pipeline assets 3 tiers (ADR-010)

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2
Refs : [epic-5](../planning-artifacts/epic-5.md#story-512-pipeline-assets-3-tiers-adr-010), [design.md ADR-010](../design.md), [ART_ASSET_BIBLE](../ART_ASSET_BIBLE.md)

## Story

**En tant que** développeur,
**je veux** étendre les scripts `scripts/*.py` et `lib/core/constant/asset_paths.dart` pour gérer les 3 tiers d'assets définis par ADR-010 (scènes 16:9 320×180 WebP, objets 1:1 512² PNG transparent, créatures 1:1 768² PNG transparent),
**afin que** les stories d'art à venir (3-20, 3-23, 4-15, 4-18) et les écrans portés (5-9 Inventory, 5-7 Adventure) puissent référencer les assets via une API stable et que `pubspec.yaml` les déclare correctement pour le bundling.

## Acceptance Criteria

1. **AC1 — `AssetPaths` étendu** : `lib/core/constant/asset_paths.dart` ajoute :
   - `static String sceneImagePath(int locationId) → 'assets/images/scenes/<key>.webp'` (déjà présent — vérifier).
   - `static String objectImagePath(int objectId) → 'assets/images/objects/<object_name>.png'` (snake_case du nom canonique).
   - `static String creatureImagePath(String creatureName) → 'assets/images/creatures/<name>.png'`.
   - Toutes ces méthodes sont `const` ou `static const`. Pas de FS access — pures fonctions de résolution de path.
2. **AC2 — `pubspec.yaml` section `assets:` étendue** : ajout des dossiers `assets/images/scenes/` (s'il n'existe pas déjà), `assets/images/objects/`, `assets/images/creatures/`, `assets/images/map/`. Lignes commentées explicatives (1 ligne par dossier) précisant le tier ADR-010.
3. **AC3 — `scripts/update_assets.py` étendu** : le script détecte et copie les 3 tiers depuis un dossier source (à définir : `art-source/scenes/`, `art-source/objects/`, `art-source/creatures/`) vers `assets/images/<tier>/`. Validation par tier :
   - **Scènes** : 320×180 (ou multiple), `.webp`, lossless ou near-lossless, ≤ 200 KB.
   - **Objets** : 512×512, `.png`, alpha présent (transparent), ≤ 80 KB.
   - **Créatures** : 768×768, `.png`, alpha présent, ≤ 120 KB.
   Refuser un asset hors specs (exit non-zéro avec message clair).
4. **AC4 — `scripts/validate_json.py`** : adapter si nécessaire pour valider que les `image_key` référencés dans `locations.json` / `objects.json` correspondent à un asset présent (warning, pas erreur, tant que la production art n'est pas finie).
5. **AC5 — `docs/ART_ASSET_BIBLE.md` mis à jour** : section dédiée aux 3 tiers (specs format/résolution/budget/naming) ajoutée ou amendée. Référencer `tokens.css` pour la palette imposée.
6. **AC6 — Test d'intégration scripts** (`test/scripts/test_update_assets_three_tiers.py` ou équivalent Dart) :
   - Lance `python3 scripts/update_assets.py --dry-run` et vérifie exit 0.
   - Vérifie que les 3 dossiers cibles sont déclarés dans `pubspec.yaml`.
   - `python3 scripts/validate_json.py` exit 0.
7. **AC7 — Smoke Dart** : `test/core/constant/asset_paths_test.dart` étendu :
   - `AssetPaths.objectImagePath(0) == 'assets/images/objects/keys.png'` (selon ordre canonique de `objects.json`).
   - `AssetPaths.creatureImagePath('dwarf') == 'assets/images/creatures/dwarf.png'`.
   - Aucune erreur si l'asset n'existe pas physiquement (la méthode résout un path, pas un fichier).
8. **AC8 — Fallback graceful** : `lib/core/widgets/oa_item_sprite.dart` (5-4) doit gérer l'absence d'asset sans crasher. Si `Image.asset(path, errorBuilder: ...)` lève, afficher un placeholder texte. (Ce comportement est **vérifié** ici mais implémenté dans 5-4.)
9. **AC9 — Aucune image livrée par cette story** : 5-12 livre le **pipeline**, pas les assets eux-mêmes. La production artistique reste sur les stories art (3-23, 4-18). Les dossiers `assets/images/objects/` et `creatures/` peuvent rester vides à la livraison de 5-12 (un `.gitkeep` accepté).
10. **AC10 — Qualité** : `flutter analyze` 0 warning ; `python3 scripts/validate_json.py` exit 0 ; tests verts ; `flutter build apk --debug` OK (même sans images).

## Tasks / Subtasks

- [ ] **Task 1 — Étendre `AssetPaths`** (AC: #1, #7)
- [ ] **Task 2 — `pubspec.yaml` assets** (AC: #2)
- [ ] **Task 3 — Étendre `scripts/update_assets.py`** (AC: #3)
  - [ ] CLI args `--dry-run`, `--tier=scenes|objects|creatures|all`.
  - [ ] Validation Pillow (`PIL`) pour dimensions + format.
- [ ] **Task 4 — Adapter `scripts/validate_json.py`** (AC: #4)
- [ ] **Task 5 — `ART_ASSET_BIBLE.md`** (AC: #5)
- [ ] **Task 6 — Tests scripts** (AC: #6)
- [ ] **Task 7 — Tests `AssetPaths`** (AC: #7)
- [ ] **Task 8 — `.gitkeep`** (AC: #9)
- [ ] **Task 9 — Lint + build** (AC: #10)

## Dev Notes

### Architecture cible

- Pipeline 3 tiers :
  - **Tier 1 — Scènes** : 16:9 320×180 WebP lossless. Décor d'un lieu. Path `assets/images/scenes/<key>.webp`. Clé = `locationImageKey(Location)` (mapTag → snake_case(name) → id).
  - **Tier 2 — Objets** : 1:1 512×512 PNG transparent. Sprite isolé. Path `assets/images/objects/<object_name>.png` (snake_case du nom canonique de `objects.json`).
  - **Tier 3 — Créatures** : 1:1 768×768 PNG transparent. Plus grand pour les portraits encounter. Path `assets/images/creatures/<name>.png`.
- **Une seule taille master par image** (ADR-010 : pas de @2x/@3x). Flutter downscale au runtime avec `FilterQuality.none`.

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/core/constant/asset_paths.dart` | UPDATE (objet/créature) |
| `pubspec.yaml` | UPDATE (section `assets:`) |
| `scripts/update_assets.py` | UPDATE (3 tiers + validation) |
| `scripts/validate_json.py` | UPDATE (warning asset manquant) |
| `docs/ART_ASSET_BIBLE.md` | UPDATE (specs 3 tiers) |
| `test/core/constant/asset_paths_test.dart` | UPDATE |
| `test/scripts/test_update_assets_three_tiers.py` (ou pytest) | NEW |
| `assets/images/objects/.gitkeep` | NEW |
| `assets/images/creatures/.gitkeep` | NEW |
| `assets/images/map/.gitkeep` | NEW (si pas déjà présent) |

### Project Context Rules

- **Scripts Python** vivent sous `scripts/` ; ne jamais appelés depuis le runtime app.
- **Pas de runtime YAML** : `update_assets.py` peut lire YAML (acceptable côté script).
- **`AssetPaths` est la seule API** pour résoudre un chemin d'asset (pas de `'assets/images/...'` en dur côté UI).
- **Budget total ≤ 10 MB** (cf. `ART_ASSET_BIBLE.md`) — la story 5-12 ne livre pas d'asset mais doit fixer le budget per-tier dans la doc.

### References

- `docs/design.md` ADR-010
- `docs/ART_ASSET_BIBLE.md`
- `docs/planning-artifacts/epic-5.md` §Story 5.12
- `lib/core/utils/location_image.dart` (résolution clé scène existante)
- Code actuel : `lib/core/constant/asset_paths.dart`, `scripts/update_assets.py`

### Previous Story Intelligence

- **1-22-script-update-assets** (done) : a livré la version initiale du script (scènes uniquement). Étendre, ne pas réécrire.
- **1-23-generator-asset-tracker** + **1-24-generator-asset-manifest** : génèrent `ASSET_TRACKER.md` et `ASSET_MANIFEST.json`. Adapter si nécessaire pour inclure les 3 tiers (warning si pas fait — la couverture exhaustive reste optionnelle dans 5-12).

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
