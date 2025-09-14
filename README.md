# open_adventure

Open Adventure - A Colossal Cave Adventure

## Getting Started

Development quickstart

- Requirements: Dart ≥ 3.x, Flutter stable 3.x. Run `flutter doctor`.
- Assets: JSON under `assets/data/` are the runtime source; C/YAML truth lives in `open-adventure-master/`.

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
