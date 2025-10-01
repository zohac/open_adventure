#!/usr/bin/env python3
"""Generate the static map layout metadata consumed by the MapPage.

This script merges three sources of truth:

* `assets/data/locations.json` for the canonical list of locations and their
  heritage `maptag` labels.
* A curator-maintained plan file (YAML) that assigns each location to one of the
  five stratified layers and provides 2D coordinates on the MapPage canvas.
* Optional canvas metadata (width/height) defined in the same plan file.

The output is a deterministic JSON document (`assets/data/map_layout.json`) that
exposes, for every location, the layer identifier, absolute coordinates in
Flutter logical pixels, and the heritage label to render on the map. The JSON is
strictly a data artefact; it does not contain gameplay state, edges, or
discoverability flags (those are handled at runtime by `GameController.mapGraph`).

The plan file can be generated in scaffold form via `--write-plan-skeleton` and
edited by UX/Game Design to position elements precisely. The script validates
that every location present in `locations.json` appears in the plan and that the
referenced layers are defined.
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, MutableMapping, Optional

import yaml

ROOT_DIR = Path(__file__).resolve().parents[1]
ASSETS_DIR = ROOT_DIR / "assets"
DATA_DIR = ASSETS_DIR / "data"
DEFAULT_PLAN_PATH = ROOT_DIR / "docs" / "map_layout_plan.yaml"
DEFAULT_OUTPUT_PATH = DATA_DIR / "map_layout.json"


class LayoutValidationError(Exception):
    """Raised when the curated plan is invalid or inconsistent."""


@dataclass(frozen=True)
class Layer:
    """Presentation layer in the atlas.

    Attributes:
        identifier: Stable identifier (e.g., ``"surface"``).
        name: Human-readable label.
        order: Sorting hint; lower values appear first in the selector.
    """

    identifier: str
    name: str
    order: int


@dataclass(frozen=True)
class NodeLayout:
    """Curated position for a location node.

    Attributes:
        location_id: Canonical location identifier (e.g., ``"LOC_START"``).
        layer_id: Identifier of the layer hosting the node.
        x: Horizontal coordinate in Flutter logical pixels.
        y: Vertical coordinate in Flutter logical pixels.
        map_tag: Heritage label to render; falls back to the JSON ``maptag`` or
            the location name when omitted in the plan.
    """

    location_id: str
    layer_id: str
    x: float
    y: float
    map_tag: str


def load_locations() -> List[Dict[str, Any]]:
    """Load the canonical locations JSON document.

    Returns:
        list[dict[str, Any]]: Raw ``[location_id, payload]`` entries.
    """

    locations_path = DATA_DIR / "locations.json"
    with locations_path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def default_layers() -> Dict[str, Layer]:
    """Return the five canonical layers defined by Game Design.

    Returns:
        dict[str, Layer]: Mapping of layer identifiers to layer descriptors.
    """

    return {
        "surface": Layer("surface", "Surface & Well House", 0),
        "upper_cave": Layer("upper_cave", "Upper Cave", 1),
        "hall_of_mists": Layer("hall_of_mists", "Hall of Mists", 2),
        "labyrinths_river": Layer(
            "labyrinths_river", "Labyrinthes & Rivière", 3
        ),
        "sanctuary_endgame": Layer(
            "sanctuary_endgame", "Sanctuaire & Endgame", 4
        ),
    }


def load_plan(path: Path) -> MutableMapping[str, Any]:
    """Load the curator plan YAML file.

    Args:
        path: Location of the YAML document.

    Returns:
        MutableMapping[str, Any]: Parsed YAML content.
    """

    if not path.exists():
        raise LayoutValidationError(
            f"Plan file {path} does not exist. Use --write-plan-skeleton to create one."
        )
    with path.open("r", encoding="utf-8") as handle:
        content = yaml.safe_load(handle) or {}
    if not isinstance(content, MutableMapping):
        raise LayoutValidationError(
            f"Plan file {path} must define a YAML mapping at the root."
        )
    return content


def _ensure_layers(raw_layers: Optional[Mapping[str, Any]]) -> Dict[str, Layer]:
    layers = default_layers()
    if not raw_layers:
        return layers
    for identifier, payload in raw_layers.items():
        if not isinstance(payload, Mapping):
            raise LayoutValidationError(
                f"Layer entry '{identifier}' must be a mapping with 'name' and 'order'."
            )
        name = str(payload.get("name", layers.get(identifier, Layer(identifier, identifier, 0)).name))
        order_raw = payload.get("order")
        if order_raw is None:
            order = layers.get(identifier, Layer(identifier, name, 0)).order
        elif isinstance(order_raw, (int, float)):
            order = int(order_raw)
        else:
            raise LayoutValidationError(
                f"Layer '{identifier}' has an invalid 'order' value: {order_raw!r}."
            )
        layers[identifier] = Layer(identifier=identifier, name=name, order=order)
    return layers


def derive_map_tag(location_payload: Mapping[str, Any]) -> str:
    """Derive the heritage label for a location.

    Args:
        location_payload: Payload dictionary associated with a location.

    Returns:
        str: Canonical map tag or fallback name.
    """

    description = location_payload.get("description") or {}
    map_tag = description.get("maptag")
    if isinstance(map_tag, str) and map_tag.strip():
        return map_tag.strip()
    name = location_payload.get("name")
    if isinstance(name, str) and name.strip():
        return name.strip()
    return "Unknown"


def _node_from_plan(
    location_id: str,
    location_payload: Mapping[str, Any],
    plan_entry: Mapping[str, Any],
    known_layers: Mapping[str, Layer],
) -> NodeLayout:
    if not isinstance(plan_entry, Mapping):
        raise LayoutValidationError(
            f"Plan entry for {location_id} must be a mapping with 'layer' and 'position'."
        )
    layer_id = plan_entry.get("layer")
    if not isinstance(layer_id, str) or not layer_id.strip():
        raise LayoutValidationError(
            f"Plan entry for {location_id} is missing a valid 'layer'."
        )
    layer_id = layer_id.strip()
    if layer_id not in known_layers:
        available = ", ".join(sorted(known_layers))
        raise LayoutValidationError(
            f"Location {location_id} references unknown layer '{layer_id}'. "
            f"Available layers: {available}."
        )
    position = plan_entry.get("position")
    if isinstance(position, Mapping):
        x_val = position.get("x")
        y_val = position.get("y")
    elif isinstance(position, Iterable):
        pos_list = list(position)
        if len(pos_list) != 2:
            raise LayoutValidationError(
                f"Location {location_id} position must contain exactly two elements."
            )
        x_val, y_val = pos_list
    else:
        raise LayoutValidationError(
            f"Location {location_id} must define a 'position' mapping or sequence."
        )
    try:
        x_coord = float(x_val)
        y_coord = float(y_val)
    except (TypeError, ValueError) as exc:
        raise LayoutValidationError(
            f"Location {location_id} has non-numeric coordinates: {position!r}."
        ) from exc
    tag = plan_entry.get("map_tag")
    if isinstance(tag, str) and tag.strip():
        map_tag = tag.strip()
    else:
        map_tag = derive_map_tag({"name": location_id, **location_payload})
    return NodeLayout(
        location_id=location_id,
        layer_id=layer_id,
        x=x_coord,
        y=y_coord,
        map_tag=map_tag,
    )


def build_layout(plan: Mapping[str, Any]) -> Dict[str, Any]:
    """Compose the serialized layout structure from the plan and locations.

    Args:
        plan: Parsed curator plan.

    Returns:
        dict[str, Any]: JSON-serialisable layout content.
    """

    raw_layers = plan.get("layers")
    layers = _ensure_layers(raw_layers if isinstance(raw_layers, Mapping) else None)

    canvas = plan.get("canvas") or {}
    if canvas and not isinstance(canvas, Mapping):
        raise LayoutValidationError("The 'canvas' entry must be a mapping if provided.")
    canvas_width = canvas.get("width", 1024)
    canvas_height = canvas.get("height", 768)
    try:
        canvas_width = float(canvas_width)
        canvas_height = float(canvas_height)
    except (TypeError, ValueError) as exc:
        raise LayoutValidationError("Canvas width and height must be numeric.") from exc

    plan_nodes = plan.get("nodes")
    if not isinstance(plan_nodes, Mapping):
        raise LayoutValidationError(
            "Plan must contain a top-level 'nodes' mapping (location_id → spec)."
        )

    locations = load_locations()
    node_layouts: List[NodeLayout] = []

    for entry in locations:
        if not isinstance(entry, list) or len(entry) != 2:
            raise LayoutValidationError(
                "Every entry in locations.json must be a [id, payload] pair."
            )
        location_id, payload = entry
        if location_id == "LOC_NOWHERE":
            # LOC_NOWHERE is a sentinel not shown on the map.
            continue
        plan_entry = plan_nodes.get(location_id)
        if plan_entry is None:
            raise LayoutValidationError(
                f"Missing plan entry for location {location_id}."
            )
        node_layouts.append(
            _node_from_plan(
                location_id=location_id,
                location_payload=payload,
                plan_entry=plan_entry,
                known_layers=layers,
            )
        )

    unknown_plan_nodes = set(plan_nodes.keys()) - {n.location_id for n in node_layouts}
    if unknown_plan_nodes:
        print(
            "Warning: The plan defines entries for unknown locations: "
            + ", ".join(sorted(unknown_plan_nodes)),
            file=sys.stderr,
        )

    layout_dict = {
        "canvas": {
            "width": canvas_width,
            "height": canvas_height,
        },
        "layers": [
            {
                "id": layer.identifier,
                "name": layer.name,
                "order": layer.order,
            }
            for layer in sorted(layers.values(), key=lambda layer: layer.order)
        ],
        "nodes": {
            node.location_id: {
                "layer": node.layer_id,
                "position": {"x": node.x, "y": node.y},
                "map_tag": node.map_tag,
            }
            for node in node_layouts
        },
    }
    return layout_dict


def write_json(output_path: Path, payload: Mapping[str, Any]) -> None:
    """Persist the layout dictionary as pretty-printed JSON.

    Args:
        output_path: Destination file path.
        payload: Layout content to serialise.
    """

    output_path.parent.mkdir(parents=True, exist_ok=True)
    serialized = json.dumps(payload, indent=2, ensure_ascii=False) + "\n"
    output_path.write_text(serialized, encoding="utf-8")
    print(f"Map layout written to {output_path}")


def write_plan_skeleton(path: Path, force: bool = False) -> None:
    """Create a YAML scaffold covering every location.

    Args:
        path: Destination file for the scaffold.
        force: Whether to overwrite an existing plan.
    """

    if path.exists() and not force:
        raise LayoutValidationError(
            f"Refusing to overwrite existing plan {path}. Pass --force to overwrite."
        )

    layers = default_layers()
    locations = load_locations()

    scaffold = {
        "canvas": {"width": 1024, "height": 768},
        "layers": {
            identifier: {"name": layer.name, "order": layer.order}
            for identifier, layer in layers.items()
        },
        "nodes": {},
        "_notes": (
            "Assign each location to a layer and provide x/y coordinates in Flutter "
            "logical pixels. Replace 'unassigned' with one of the layer identifiers."
        ),
    }

    for entry in locations:
        if not isinstance(entry, list) or len(entry) != 2:
            raise LayoutValidationError(
                "Every entry in locations.json must be a [id, payload] pair."
            )
        location_id, payload = entry
        if location_id == "LOC_NOWHERE":
            continue
        scaffold["nodes"][location_id] = {
            "layer": "unassigned",
            "position": {"x": 0.0, "y": 0.0},
            "map_tag": derive_map_tag({"name": location_id, **payload}),
        }

    with path.open("w", encoding="utf-8") as handle:
        yaml.safe_dump(scaffold, handle, sort_keys=True, allow_unicode=True)
    print(f"Skeleton plan written to {path}")


def parse_args(argv: Optional[Iterable[str]] = None) -> argparse.Namespace:
    """Parse CLI arguments.

    Args:
        argv: Optional iterable of argument strings.

    Returns:
        argparse.Namespace: Parsed CLI arguments.
    """

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--plan",
        type=Path,
        default=DEFAULT_PLAN_PATH,
        help="YAML file describing layers and node positions"
        f" (default: {DEFAULT_PLAN_PATH})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT_PATH,
        help="Destination JSON path (default: assets/data/map_layout.json)",
    )
    parser.add_argument(
        "--write-plan-skeleton",
        action="store_true",
        help="Generate a skeleton plan file covering every location",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Allow overwriting the plan when used with --write-plan-skeleton",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Iterable[str]] = None) -> int:
    """Entry point for the CLI.

    Args:
        argv: Optional iterable of argument strings.

    Returns:
        int: Exit status code.
    """

    args = parse_args(argv)
    try:
        if args.write_plan_skeleton:
            write_plan_skeleton(args.plan, force=args.force)
            return 0
        plan = load_plan(args.plan)
        layout = build_layout(plan)
        write_json(args.output, layout)
        return 0
    except LayoutValidationError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":  # pragma: no cover - CLI entry point
    sys.exit(main())
