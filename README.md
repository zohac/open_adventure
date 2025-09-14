# open_adventure

Open Adventure - A Colossal Cave Adventure

## Getting Started

Development quickstart

- Requirements: Flutter stable 3.35.x, Dart ≥ 3.9 (Flutter tools). Run `flutter doctor`.
- Assets: JSON under `assets/data/` are the runtime source; C/YAML truth lives in `open-adventure-master/`.
- Install deps and validate:
  - `flutter pub get`
  - `flutter analyze` (no warnings)
  - `flutter test` (targeted data/domain tests green)

Update assets from upstream (optional):

```bash
python3 scripts/make_dungeon.py --out assets/data     # generates travel.json + tkey.json
python3 scripts/extract_c.py --out assets/data        # generates travel_c.json + tkey_c.json (for validation)
 python3 scripts/validate_json.py                      # validates YAML → JSON consistency
```

Generate asset tracker (art/audio progress):

```bash
python3 scripts/generate_asset_tracker.py             # writes docs/ASSET_TRACKER.md
```

Local save directories (runtime):

- iOS: `NSApplicationSupportDirectory/open_adventure/saves/`
- Android: `<appFilesDir>/open_adventure/saves/`

Notes audio/images:

- Images: `assets/images/locations/<key>.webp` (16:9, ≤ 200 KB). Pixel‑art rendering via `PixelCanvas` (integer scaling, no filtering).
- Audio: OGG/Opus offline only. Use `just_audio` + `audio_session` for playback and audio focus. BGM loops gapless with short crossfades.

Design & UX — source de vérité

- Spécification: `docs/CONVERSION_SPEC.md` (normatif). Voir §17–§19 pour UX mobile, heuristiques d’actions, direction artistique.
- Annexe: `docs/DESIGN_ADDENDUM.md` (checklists Dev/Artist/CTO) — rattachements normatifs à la spec.
- Bible assets: `docs/ART_ASSET_BIBLE.md` — briefs scènes/objets/créatures, VFX/SFX et palettes prioritaires.
- Règle d’or UX: proposer 3–7 actions utiles sans saisie texte; prioriser sécurité → travel → interaction → méta; première visite = description longue, revisites = courte.
- Écrans: `docs/UX_SCREENS.md` — mandat, entrées/sorties, DoD et tests par écran (Home/Adventure/Inventory/Map/Journal/Saves/Settings/EndGame/etc.).

## Architecture (Clean Architecture)

- Domain: entités immuables (`Game`, `Location`, `GameObject`), ports (`AdventureRepository`), use cases (S2+).
- Data: `AssetDataSource` (assets JSON), modèles (`LocationModel`, `GameObjectModel`, `TravelRuleModel`, `ActionModel`, `ConditionModel`), repo impl (`AdventureRepositoryImpl`).
- Application: orchestrateurs (`GameController`, routing).
- Presentation: pages/widgets (S2+ UI v0/v1), pixel‑art helpers (`PixelCanvas`, `LocationImage`).

Flow de dépendances: Presentation → Application → Domain ← Data (impl). La dépendance pointe toujours vers le domaine.

## Python dev environment (for scripts)

The Python scripts under `scripts/` are tooling only (not part of the app). They require PyYAML to run locally.

- Option A — Virtual environment (recommended)
  - macOS/Linux:
    - `python3 -m venv .venv`
    - `source .venv/bin/activate`
    - `pip install -r requirements-dev.txt`
  - Windows (PowerShell):
    - `py -m venv .venv`
    - `.\.venv\Scripts\Activate.ps1`
    - `pip install -r requirements-dev.txt`

- Option B — User install (quick)
  - `python3 -m pip install --user PyYAML`

Verify install:

- `python3 -c "import yaml; print(yaml.__version__)"`

Run scripts:

- Generate JSON from YAML (repo tooling): `python3 scripts/make_dungeon.py --out assets/data`
- Extract C-equivalent JSON (optional, for cross‑validation):
  1) Generate C tables from the upstream YAML (run inside upstream dir):
     - `cd open-adventure-master`
     - `python3 make_dungeon.py`   # produces dungeon.c and dungeon.h
     - `cd ..`
  2) Extract JSON from the generated C tables:
     - Validation files (kept out of Git/app):
       - `python3 scripts/extract_c.py --out assets/data --in-travel open-adventure-master/dungeon.c --in-tkey open-adventure-master/dungeon.c`
     - Or overwrite canonical assets directly (use with care):
       - `python3 scripts/extract_c.py --canonical --out assets/data --in-travel open-adventure-master/dungeon.c --in-tkey open-adventure-master/dungeon.c`
  3) Validate JSON vs YAML (and vs C if present):
     - `python3 scripts/validate_json.py`

Troubleshooting

- FileNotFoundError: 'adventure.yaml' when running `open-adventure-master/make_dungeon.py` → the script must be run from within `open-adventure-master` (it looks for `adventure.yaml` in the current directory). Use the exact steps above.

## Feature flags & performances

- Parsing JSON en isolate (option): `Settings.parseUseIsolate` (par défaut false en S1).
- Seuil de bascule: `Settings.parseIsolateThresholdBytes` (1 MiB par défaut).

## Commandes utiles

- Analyse: `flutter analyze`
- Tests ciblés: `flutter test test/data test/domain test/core`
- Build (plus tard): `flutter build apk` / `flutter build ipa`

## Offline & privacy

- 100% offline: le jeu n’utilise aucun réseau. Données de jeu embarquées, sauvegardes locales uniquement.
