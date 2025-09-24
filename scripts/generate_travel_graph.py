#!/usr/bin/env python3
"""Generate a Graphviz DOT graph from the travel rules.

The travel graph is derived from the transitions listed in
``assets/data/travel.json``. Each entry produces a directed edge between the
source location and the destination location when the transition results in a
location change (``dest_goto`` or ``dest_special``). For each edge we collect the
motions (and their optional conditions) that allow the player to travel between
the two locations.

Usage
-----
    python scripts/generate_travel_graph.py [-o OUTPUT]

If ``OUTPUT`` is omitted the DOT description is printed to standard output.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Sequence, Tuple

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "assets" / "data"


def load_json(path: Path) -> Any:
    """Return the parsed JSON content located at *path*."""
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def build_location_labels(locations: Sequence[Sequence[Any]]) -> Dict[str, str]:
    """Return a mapping between location keys and human-friendly labels."""
    labels: Dict[str, str] = {}
    for entry in locations:
        if not isinstance(entry, Sequence) or len(entry) != 2:
            continue
        name, meta = entry
        if not isinstance(name, str):
            continue
        label = _label_from_meta(name, meta)
        labels[name] = label
    return labels


def _label_from_meta(name: str, meta: Any) -> str:
    description = {}
    if isinstance(meta, Mapping):
        description = meta.get("description") or {}
    candidate: str | None = None
    if isinstance(description, Mapping):
        for key in ("maptag", "short", "long"):
            value = description.get(key)
            if isinstance(value, str) and value.strip():
                candidate = value.strip()
                break
    if candidate:
        return f"{candidate}\n({name})"
    return name


def collect_edges(travel: Sequence[Mapping[str, Any]]) -> Dict[Tuple[str, str], List[str]]:
    """Group travel entries by ``(source, destination)`` pair."""
    edges: Dict[Tuple[str, str], List[str]] = {}
    for entry in travel:
        if not isinstance(entry, Mapping):
            continue
        src = entry.get("from_location")
        desttype = entry.get("desttype")
        dest = entry.get("destval")
        if not isinstance(src, str) or not isinstance(dest, str):
            continue
        if desttype not in {"dest_goto", "dest_special"}:
            continue
        label = format_motion_label(entry)
        key = (src, dest)
        edges.setdefault(key, []).append(label)
    return edges


def format_motion_label(entry: Mapping[str, Any]) -> str:
    """Return a readable label describing the motion and optional condition."""
    motion = entry.get("motion")
    motion_text = describe_value(motion)
    condition = format_condition(entry)
    if condition:
        return f"{motion_text} ({condition})"
    return motion_text


def format_condition(entry: Mapping[str, Any]) -> str:
    condtype = entry.get("condtype")
    if not isinstance(condtype, str) or condtype == "cond_goto":
        return ""
    parts = [condtype]
    for key in ("condarg1", "condarg2"):
        value = entry.get(key)
        text = describe_value(value)
        if text not in {"", "0"}:
            parts.append(text)
    return " ".join(parts)


def describe_value(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, (int, float)):
        return str(value)
    return repr(value)


def escape_label(text: str) -> str:
    return (
        text.replace("\\", "\\\\")
        .replace("\n", "\\n")
        .replace("\"", "\\\"")
    )


def build_dot_document(labels: Mapping[str, str], edges: Mapping[Tuple[str, str], Iterable[str]]) -> str:
    lines: List[str] = ["digraph travel {", "    rankdir=LR;", "    node [shape=ellipse];"]
    for node in sorted(labels):
        label = escape_label(labels[node])
        lines.append(f'    "{node}" [label="{label}"];')
    for (src, dst) in sorted(edges):
        motions = sorted({m for m in edges[(src, dst)] if m})
        if not motions:
            continue
        label = escape_label("\n".join(motions))
        lines.append(f'    "{src}" -> "{dst}" [label="{label}"];')
    lines.append("}")
    return "\n".join(lines) + "\n"


def generate_travel_graph() -> str:
    travel = load_json(DATA_DIR / "travel.json")
    locations = load_json(DATA_DIR / "locations.json")
    labels = build_location_labels(locations)
    # Ensure every location seen in travel has a node, even if missing from locations.json
    for entry in travel:
        if not isinstance(entry, Mapping):
            continue
        src = entry.get("from_location")
        dest = entry.get("destval")
        if isinstance(src, str) and src not in labels:
            labels[src] = src
        if isinstance(dest, str) and dest not in labels:
            labels[dest] = dest
    edges = collect_edges(travel)
    return build_dot_document(labels, edges)


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate the travel graph as a Graphviz DOT document.")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Path to the output DOT file. If omitted, the graph is printed to stdout.",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    dot = generate_travel_graph()
    if args.output is None:
        print(dot, end="")
    else:
        output_path = args.output
        if not output_path.is_absolute():
            output_path = Path.cwd() / output_path
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(dot, encoding="utf-8")
        print(f"Travel graph written to {output_path}")
    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
