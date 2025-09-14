#!/usr/bin/env python3
"""
Generate an Asset Manifest for AI pipelines (e.g., ComfyUI) based on assets/data/*.json.

Output
- docs/ASSET_MANIFEST.json with minimal editable fields:
  {
    "locations": [
      { "key", "name", "zone", "priority", "prompt"?, "negative_prompt"?, "loras"?,
        "seed"?, "steps"?, "cfg"?, "sampler"?, "target_size":[320,180],
        "palette_max":64, "vfx":[] }
    ],
    "objects": [
      { "name", "isTreasure", "locations_count", "sfx":{ "pickup"?, "drop"? }, "vfx"?:{} }
    ],
    "audio": {
      "bgm":[ { "zone", "trackKey", "length_sec":45, "loop":true } ],
      "sfx":[ { "key", "length_ms":350 } ]
    }
  }

Notes
- Idempotent, never writes under assets/; only writes docs/ASSET_MANIFEST.json.
- Prompts/seeds/loras left empty for artist to edit.
"""
from __future__ import annotations
import json
from pathlib import Path
from typing import Any, Dict, List, Set

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
DATA = ASSETS / "data"
OUT = ROOT / "docs" / "ASSET_MANIFEST.json"


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def to_snake_case(s: str) -> str:
    import re
    t = s.strip()
    if not t:
        return ""
    lower = re.sub(r"[\s\-]+", "_", t)
    lower = re.sub(r"[^a-zA-Z0-9_]+", "", lower)
    lower = lower.lower()
    return re.sub(r"_+", "_", lower)


def location_key(name: str, data: Dict[str, Any], idx: int) -> str:
    desc = data.get("description") or {}
    maptag = desc.get("maptag")
    if isinstance(maptag, str) and maptag.strip():
        key = to_snake_case(maptag)
        if key:
            return key
    key = to_snake_case(name)
    if key:
        return key
    return str(idx)


def build_manifest() -> Dict[str, Any]:
    loc_src = load_json(DATA / "locations.json")
    obj_src = load_json(DATA / "objects.json")

    # Locations
    locations: List[Dict[str, Any]] = []
    music_keys: Set[str] = set()
    for idx, entry in enumerate(loc_src):
        name, data = entry[0], entry[1]
        k = location_key(name, data, idx)
        zone = "unknown"  # artist to refine
        priority = 0       # artist/producer to adjust
        sound_key = data.get("sound") or ""
        if isinstance(sound_key, str) and sound_key.strip():
            music_keys.add(sound_key)
        locations.append({
            "key": k,
            "name": name,
            "zone": zone,
            "priority": priority,
            # AI/editable fields intentionally left blank for the artist
            # "prompt": "",
            # "negative_prompt": "",
            # "loras": [],
            # "seed": None,
            # "steps": None,
            # "cfg": None,
            # "sampler": None,
            "target_size": [320, 180],
            "palette_max": 64,
            "vfx": [],
        })

    # Objects
    objects: List[Dict[str, Any]] = []
    sfx_keys: Set[str] = set()
    for idx, entry in enumerate(obj_src):
        name, data = entry[0], entry[1]
        is_treasure = bool(data.get("is_treasure", False))
        locs = data.get("locations")
        if isinstance(locs, list):
            locations_count = len(locs)
        elif isinstance(locs, str) and locs:
            locations_count = 1
        else:
            locations_count = 0
        sounds = data.get("sounds") or []
        if isinstance(sounds, list):
            for sk in sounds:
                if isinstance(sk, str) and sk.strip():
                    sfx_keys.add(sk)
        objects.append({
            "name": name,
            "isTreasure": is_treasure,
            "locations_count": locations_count,
            "sfx": {  # artist to fill specific mappings like pickup/drop
                # "pickup": None,
                # "drop": None,
            },
            # "vfx": {},
        })

    # Audio from collected keys (artist to refine zones/lengths)
    audio_bgm = []
    for mk in sorted(music_keys):
        audio_bgm.append({
            "zone": "unknown",      # artist to fill
            "trackKey": mk,
            "length_sec": 45,       # default placeholder
            "loop": True,
        })

    audio_sfx = []
    for sk in sorted(sfx_keys):
        audio_sfx.append({
            "key": sk,
            "length_ms": 350,       # default placeholder
        })

    manifest = {
        "locations": locations,
        "objects": objects,
        "audio": {
            "bgm": audio_bgm,
            "sfx": audio_sfx,
        },
    }
    return manifest


def main() -> int:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    manifest = build_manifest()
    OUT.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Asset manifest written to {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

