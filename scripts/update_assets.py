#!/usr/bin/env python3
"""
Orchestrate asset updates from upstream YAML/C into repo JSON assets.

Sequence (default)
1) scripts/make_dungeon.py      → generates canonical JSON (assets/data)
2) open-adventure-master/make_dungeon.py (best effort) → generates dungeon.c/h
3) scripts/extract_c.py         → generates validation JSON (_c) or canonical with --canonical
4) scripts/validate_json.py     → validates YAML→JSON (and vs C if present)

Usage
  python3 scripts/update_assets.py [--out assets/data] [--canonical] [--strict]

Notes
- Requires PyYAML installed in the local Python env.
- Works on macOS/Linux; no network access.
"""
from __future__ import annotations
import argparse
import subprocess
import sys
import time
from pathlib import Path


def run_step(cmd: list[str], cwd: Path | None = None, expect_ok: bool = True, name: str = "step") -> int:
    print(f"\n[update-assets] {name}: {' '.join(cmd)}")
    start = time.time()
    proc = subprocess.run(cmd, cwd=str(cwd) if cwd else None)
    dur = (time.time() - start) * 1000.0
    print(f"[update-assets] {name} finished in {dur:.0f} ms with code {proc.returncode}")
    if expect_ok and proc.returncode != 0:
        print(f"[update-assets] ERROR: {name} failed with exit code {proc.returncode}", file=sys.stderr)
        sys.exit(proc.returncode)
    return proc.returncode


def main() -> int:
    parser = argparse.ArgumentParser(description="Update Open Adventure JSON assets from upstream sources")
    parser.add_argument("--out", default=str(Path("assets") / "data"), help="Output directory for JSON files (default: assets/data)")
    parser.add_argument("--canonical", action="store_true", help="Write canonical travel.json/tkey.json from C tables (otherwise *_c.json)")
    parser.add_argument("--strict", action="store_true", help="Fail if validation reports divergences (exit code 1)")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    out_dir = repo_root / args.out
    out_dir.mkdir(parents=True, exist_ok=True)

    py = sys.executable or "python3"

    # 1) Generate canonical JSON from YAML
    run_step([py, str(repo_root / "scripts" / "make_dungeon.py"), "--out", str(out_dir)], name="make_dungeon (YAML→JSON)")

    # 2) Try to generate dungeon.c/h (best effort)
    upstream = repo_root / "open-adventure-master"
    if (upstream / "make_dungeon.py").exists():
        run_step([py, "make_dungeon.py"], cwd=upstream, name="upstream make_dungeon (YAML→C)", expect_ok=False)
    else:
        print("[update-assets] Info: upstream make_dungeon.py not found; skipping C generation")

    # 3) Extract JSON from C tables (if dungeon.c present)
    dungeon_c = upstream / "dungeon.c"
    extract_cmd = [
        py, str(repo_root / "scripts" / "extract_c.py"), "--out", str(out_dir),
        "--in-travel", str(dungeon_c), "--in-tkey", str(dungeon_c),
    ]
    if args.canonical:
        extract_cmd.insert(3, "--canonical")
    run_step(extract_cmd, name="extract_c (C→JSON)", expect_ok=False)

    # 4) Validate YAML↔JSON (and vs C if present)
    code = run_step([py, str(repo_root / "scripts" / "validate_json.py")], name="validate (YAML/JSON)", expect_ok=not args.strict)
    if code != 0:
        print("[update-assets] Validation reported divergences (exit 1). See logs above.")
    else:
        print("[update-assets] Validation successful.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

