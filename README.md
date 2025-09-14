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

Local save directories (runtime):

- iOS: `NSApplicationSupportDirectory/open_adventure/saves/`
- Android: `<appFilesDir>/open_adventure/saves/`

Notes audio/images:

- Images: `assets/images/locations/<key>.webp` (16:9, ≤ 200 KB). Pixel‑art rendering via `PixelCanvas` (integer scaling, no filtering).
- Audio: OGG/Opus offline only. Use `just_audio` + `audio_session` for playback and audio focus. BGM loops gapless with short crossfades.
