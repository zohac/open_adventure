#!/usr/bin/env python3
"""
Generate a Markdown Asset Tracker for game art/audio based on assets/data/*.json.

Outputs
- docs/ASSET_TRACKER.md containing three sections/tables:
  1) Locations (image + optional music key)
  2) Objects (inventory flags + optional SFX keys)
  3) Audio (music + sfx inventories with sizes)

Notes
- No network access. Pure local filesystem and JSON parsing.
- Exit code 0 (informational tool). Missing files are reported in the tables.
"""
from __future__ import annotations
import json
import os
from pathlib import Path
from typing import Any, Dict, List, Tuple, Set


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
DATA = ASSETS / "data"
IMG_LOC_DIR = ASSETS / "images" / "locations"
AUD_MUSIC_DIR = ASSETS / "audio" / "music"
AUD_SFX_DIR = ASSETS / "audio" / "sfx"
OUT_MD = ROOT / "docs" / "ASSET_TRACKER.md"
MANIFEST = ROOT / "docs" / "ASSET_MANIFEST.json"


def load_json(path: Path) -> Any:
  with path.open("r", encoding="utf-8") as f:
    return json.load(f)


def sanitize_md(text: str) -> str:
  """Sanitize free text for Markdown tables: fold newlines and escape pipes.

  - Replace CR/LF with spaces, collapse multiple whitespace to single space.
  - Escape '|' to avoid breaking table cells.
  """
  if not isinstance(text, str):
    return str(text)
  s = text.replace("\r\n", " ").replace("\n", " ").replace("\r", " ")
  # Collapse multiple spaces
  while "  " in s:
    s = s.replace("  ", " ")
  s = s.strip()
  s = s.replace("|", "\\|")
  return s


def to_snake_case(s: str) -> str:
  t = s.strip()
  if not t:
    return ""
  import re
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


def file_info(path: Path) -> Tuple[bool, int]:
  try:
    st = path.stat()
    return True, st.st_size
  except FileNotFoundError:
    return False, 0


def fmt_size(size: int) -> str:
  if size <= 0:
    return "0 KB"
  kb = size / 1024.0
  if kb < 1024:
    return f"{kb:.0f} KB"
  mb = kb / 1024.0
  return f"{mb:.2f} MB"


def collect_locations() -> Tuple[List[List[str]], Set[str]]:
  loc_json = load_json(DATA / "locations.json")
  rows: List[List[str]] = []
  music_keys: Set[str] = set()
  for idx, entry in enumerate(loc_json):
    name, data = entry[0], entry[1]
    k = location_key(name, data, idx)
    img_path = IMG_LOC_DIR / f"{k}.webp"
    exists, size = file_info(img_path)
    sound_key = data.get("sound") or ""
    if isinstance(sound_key, str) and sound_key.strip():
      music_keys.add(sound_key)
    rows.append([
      str(idx), name, (data.get("description") or {}).get("maptag", "") or "",
      str(img_path.relative_to(ROOT)), "yes" if exists else "no", fmt_size(size),
      sound_key,
      str((AUD_MUSIC_DIR / f"{sound_key}.ogg").relative_to(ROOT)) if sound_key else "",
    ])
  return rows, music_keys


def collect_objects() -> Tuple[List[List[str]], Set[str]]:
  obj_json = load_json(DATA / "objects.json")
  rows: List[List[str]] = []
  sfx_keys: Set[str] = set()
  for idx, entry in enumerate(obj_json):
    name, data = entry[0], entry[1]
    inv = sanitize_md(data.get("inventory") or "")
    is_treasure = data.get("is_treasure", False)
    immovable = data.get("immovable", False)
    locs_raw = data.get("locations")
    if isinstance(locs_raw, list):
      loc_count = len(locs_raw)
    elif isinstance(locs_raw, str) and locs_raw:
      loc_count = 1
    else:
      loc_count = 0
    sounds = data.get("sounds") or []
    if isinstance(sounds, list):
      for sk in sounds:
        if isinstance(sk, str) and sk.strip():
          sfx_keys.add(sk)
    # Join SFX keys with a bullet separator to avoid confusion with commas inside sentences.
    sfx_joined = " • ".join([sanitize_md(s) for s in sounds if isinstance(s, str)])
    rows.append([
      str(idx), name, inv, "yes" if is_treasure else "no", "yes" if immovable else "no",
      str(loc_count), sfx_joined
    ])
  return rows, sfx_keys


def collect_audio(music_keys: Set[str], sfx_keys: Set[str]) -> Tuple[List[List[str]], List[List[str]], int, int]:
  music_rows: List[List[str]] = []
  total_music = 0
  for mk in sorted(music_keys):
    display_key = sanitize_md(mk)
    file_key = to_snake_case(mk)
    path = AUD_MUSIC_DIR / f"{file_key}.ogg"
    exists, size = file_info(path)
    total_music += size if exists else 0
    music_rows.append([display_key, str(path.relative_to(ROOT)), "yes" if exists else "no", fmt_size(size)])

  sfx_rows: List[List[str]] = []
  total_sfx = 0
  for sk in sorted(sfx_keys):
    display_key = sanitize_md(sk)
    file_key = to_snake_case(sk)
    path = AUD_SFX_DIR / f"{file_key}.ogg"
    exists, size = file_info(path)
    total_sfx += size if exists else 0
    sfx_rows.append([display_key, str(path.relative_to(ROOT)), "yes" if exists else "no", fmt_size(size)])
  return music_rows, sfx_rows, total_music, total_sfx


def dir_size(path: Path) -> int:
  if not path.exists():
    return 0
  total = 0
  for p in path.rglob('*'):
    if p.is_file():
      try:
        total += p.stat().st_size
      except FileNotFoundError:
        pass
  return total


def md_table(headers: List[str], rows: List[List[str]]) -> str:
  lines = ["| " + " | ".join(headers) + " |", "|" + "|".join([" --- " for _ in headers]) + "|"]
  for r in rows:
    lines.append("| " + " | ".join(r) + " |")
  return "\n".join(lines)


def main() -> int:
  locations_rows, music_keys = collect_locations()
  objects_rows, sfx_keys = collect_objects()

  # If a manifest exists, prefer its declared audio keys (bgm/sfx) for reporting.
  if MANIFEST.exists():
    try:
      manifest = load_json(MANIFEST)
      audio = manifest.get("audio", {}) or {}
      bgm = audio.get("bgm", []) or []
      sfx = audio.get("sfx", []) or []
      mk = set()
      for e in bgm:
        tk = None
        if isinstance(e, dict):
          tk = e.get("trackKey") or e.get("key")
        elif isinstance(e, str):
          tk = e
        if isinstance(tk, str) and tk.strip():
          mk.add(tk.strip())
      sk = set()
      for e in sfx:
        k = None
        if isinstance(e, dict):
          k = e.get("key")
        elif isinstance(e, str):
          k = e
        if isinstance(k, str) and k.strip():
          sk.add(k.strip())
      if mk:
        music_keys = mk
      if sk:
        sfx_keys = sk
    except Exception as e:
      print(f"[AssetTracker] Warning: could not read manifest: {e}")
  music_rows, sfx_rows, total_music, total_sfx = collect_audio(music_keys, sfx_keys)

  total_img = dir_size(IMG_LOC_DIR)

  md: List[str] = []
  md.append("# Asset Tracker")
  md.append("")
  md.append("This report is generated from assets/data/*.json and local files under assets/images and assets/audio.")
  md.append("")
  md.append("## Summary")
  md.append("")
  md.append(f"- Images (locations): {fmt_size(total_img)} (budget ≈ 10 MB)")
  md.append(f"- Audio music: {fmt_size(total_music)} (budget ≈ 6–8 MB total; ≤ 600 KB/track)")
  md.append(f"- Audio SFX: {fmt_size(total_sfx)} (budget ≈ 1 MB total)")
  md.append("")

  md.append("## Locations")
  md.append("")
  md.append(md_table([
    "Id", "Name", "MapTag", "Image", "Exists", "Size", "MusicKey", "MusicPath"
  ], locations_rows))
  md.append("")

  md.append("## Objects")
  md.append("")
  md.append(md_table([
    "Id", "Name", "Inventory", "Treasure", "Immovable", "LocCount", "SfxKeys"
  ], objects_rows))
  md.append("")

  md.append("## Audio")
  md.append("")
  md.append("### Music")
  md.append(md_table(["Key", "Path", "Exists", "Size"], music_rows))
  md.append("")
  md.append("### SFX")
  md.append(md_table(["Key", "Path", "Exists", "Size"], sfx_rows))
  md.append("")

  OUT_MD.parent.mkdir(parents=True, exist_ok=True)
  OUT_MD.write_text("\n".join(md), encoding="utf-8")
  print(f"Asset tracker written to {OUT_MD}")
  return 0


if __name__ == "__main__":
  raise SystemExit(main())
