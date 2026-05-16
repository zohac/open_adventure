#!/usr/bin/env python3
"""Export per-layer travel graphs for map authoring.

The script reads the canonical location data from ``assets/data/locations.json``
and associates each location with its presentation layer as defined in
``docs/map_layout_plan.yaml``. For every layer, it emits a JSON file containing
the list of nodes and the outgoing travel edges originating from that layer.

The generated files are intended to help the art/UX team build static maps for
each stratum (Surface, Upper Cave, Hall of Mists, Labyrinthes & Rivière,
Sanctuaire & Endgame).
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
LOCATIONS_PATH = ROOT / "assets" / "data" / "locations.json"
PLAN_PATH = ROOT / "docs" / "map_layout_plan.yaml"
OUTPUT_DIR = ROOT / "docs" / "map_layers"

# Canonical order expected by UX/Design specs.
LAYER_ORDER: Tuple[str, ...] = (
    "surface",
    "upper_cave",
    "hall_of_mists",
    "labyrinths_river",
    "sanctuary_endgame",
)


def load_locations() -> List[Tuple[str, Dict[str, Any]]]:
    with LOCATIONS_PATH.open("r", encoding="utf-8") as handle:
        raw = json.load(handle)
    result: List[Tuple[str, Dict[str, Any]]] = []
    for entry in raw:
        if not isinstance(entry, list) or len(entry) != 2:
            continue
        loc_id, payload = entry
        if not isinstance(loc_id, str) or not isinstance(payload, dict):
            continue
        result.append((loc_id, payload))
    return result


def parse_plan_layers() -> Dict[str, Dict[str, Any]]:
    """Lightweight parser extracting per-location metadata from the plan YAML."""

    if not PLAN_PATH.exists():
        raise FileNotFoundError(f"Plan file not found: {PLAN_PATH}")

    nodes: Dict[str, Dict[str, Any]] = {}
    current_id: Optional[str] = None
    in_position = False

    node_pattern = re.compile(r"^\s{2}([A-Z0-9_]+):\s*$")
    field_pattern = re.compile(r"^\s{4}([a-z_]+):\s*(.*)$")
    position_pattern = re.compile(r"^\s{6}([xy]):\s*(.*)$")

    def parse_scalar(value: str) -> Any:
        text = value.strip()
        if text == "" or text.lower() in {"null", "none"}:
            return None
        if text.lower() == "true":
            return True
        if text.lower() == "false":
            return False
        try:
            if "." in text or "e" in text.lower():
                return float(text)
            return int(text)
        except ValueError:
            pass
        if text.startswith("'") and text.endswith("'"):
            return text[1:-1]
        if text.startswith('"') and text.endswith('"'):
            return text[1:-1]
        return text

    with PLAN_PATH.open("r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.rstrip("\n")

            node_match = node_pattern.match(line)
            if node_match:
                current_id = node_match.group(1)
                nodes[current_id] = {}
                in_position = False
                continue

            if current_id is None:
                continue

            field_match = field_pattern.match(line)
            if field_match:
                key, value = field_match.groups()
                if key == "position":
                    nodes[current_id][key] = {"x": None, "y": None}
                    in_position = True
                else:
                    nodes[current_id][key] = parse_scalar(value)
                    in_position = False
                continue

            if in_position:
                position_match = position_pattern.match(line)
                if position_match:
                    axis, value = position_match.groups()
                    numeric = parse_scalar(value)
                    if isinstance(numeric, (int, float)):
                        nodes[current_id]["position"][axis] = float(numeric)
                else:
                    in_position = False

    return nodes


def normalise_map_tag(payload: Dict[str, Any]) -> str:
    description = payload.get("description") or {}
    map_tag = description.get("maptag")
    if isinstance(map_tag, str) and map_tag.strip():
        return map_tag.strip()
    long_desc = description.get("long")
    if isinstance(long_desc, str) and long_desc.strip():
        return long_desc.strip()
    name = payload.get("name")
    if isinstance(name, str) and name.strip():
        return name.strip()
    return ""


def build_layer_graphs() -> Dict[str, Dict[str, Any]]:
    locations = load_locations()
    plan_nodes = parse_plan_layers()

    graphs: Dict[str, Dict[str, Any]] = {
        layer: {"layer": layer, "nodes": []}
        for layer in LAYER_ORDER
    }

    node_lookup: Dict[str, Dict[str, Any]] = {}

    # Populate nodes per layer
    for loc_id, payload in locations:
        plan_info = plan_nodes.get(loc_id, {})
        layer = str(plan_info.get("layer", "unassigned")) if plan_info else "unassigned"
        if layer not in graphs:
            # Skip nodes that are not assigned to the canonical layers.
            continue

        node_entry = {
            "id": loc_id,
            "map_tag": normalise_map_tag(payload),
            "cluster_id": plan_info.get("cluster_id"),
            "is_ambiguous": bool(plan_info.get("is_ambiguous", False)),
            "anchor_tag": plan_info.get("anchor_tag"),
        }

        position = plan_info.get("position")
        if isinstance(position, dict):
            x = position.get("x")
            y = position.get("y")
            node_entry["position"] = {
                "x": float(x) if isinstance(x, (int, float)) else None,
                "y": float(y) if isinstance(y, (int, float)) else None,
            }
        else:
            node_entry["position"] = {"x": None, "y": None}

        graphs[layer]["nodes"].append(node_entry)
        node_lookup[loc_id] = node_entry

    # Populate edges based on travel rules
    plan_layers = {loc_id: info.get("layer") for loc_id, info in plan_nodes.items()}

    for loc_id, payload in locations:
        layer = plan_layers.get(loc_id)
        if layer not in graphs:
            continue

        travels = payload.get("travel") or []
        if not isinstance(travels, list):
            continue

        for rule in travels:
            if not isinstance(rule, dict):
                continue
            action = rule.get("action")
            if (
                not isinstance(action, list)
                or not action
                or action[0] != "goto"
                or len(action) < 2
            ):
                continue
            destination = action[1]
            if not isinstance(destination, str):
                continue
            verbs: Iterable[str]
            raw_verbs = rule.get("verbs")
            verbs: List[str]
            if isinstance(raw_verbs, list):
                verbs = [str(v) for v in raw_verbs]
            elif isinstance(raw_verbs, str):
                verbs = [raw_verbs]
            else:
                verbs = []

            node_entry = node_lookup.get(loc_id)
            if node_entry is None:
                continue
            node_travel = node_entry.setdefault("travel", [])
            node_travel.append(
                {
                    "verbs": verbs,
                    "action": ["goto", destination],
                }
            )

    # Sort nodes/edges for determinism
    for layer in graphs:
        for node in graphs[layer]["nodes"]:
            travels = node.get("travel")
            if isinstance(travels, list):
                travels.sort(key=lambda r: (r.get("verbs") or [""], r.get("action") or []))
        graphs[layer]["nodes"].sort(key=lambda n: n["id"])

    return graphs


def main() -> int:
    graphs = build_layer_graphs()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for layer, payload in graphs.items():
        path = OUTPUT_DIR / f"{layer}.json"
        with path.open("w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2, ensure_ascii=False)
            handle.write("\n")
        print(f"Wrote {path}")

    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
