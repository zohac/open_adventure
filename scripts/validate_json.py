#!/usr/bin/env python3
"""
Validation YAML→JSON pour Open Adventure.

Objectif:
- Vérifier que les JSON embarqués sous assets/data/ sont cohérents avec la
  source de vérité YAML (open-adventure-master/adventure.yaml).
- Comparer optionnellement avec des extraits dérivés du C si disponibles.

Usage:
  python3 scripts/validate_json.py

Sortie:
- Code de sortie 0 si tout est cohérent, 1 sinon.
"""

from __future__ import annotations
import json
import os
import sys
from pathlib import Path
from collections import OrderedDict

try:
    import yaml  # type: ignore
except Exception as e:
    print("PyYAML requis: pip install pyyaml", file=sys.stderr)
    raise


ROOT = Path(__file__).resolve().parents[1]
ASSETS_DATA = ROOT / "assets" / "data"
YAML_FILE = ROOT / "open-adventure-master" / "adventure.yaml"

# Fichiers JSON à valider
JSON_FILES = OrderedDict(
    arbitrary_messages=ASSETS_DATA / "arbitrary_messages.json",
    classes=ASSETS_DATA / "classes.json",
    turn_thresholds=ASSETS_DATA / "turn_thresholds.json",
    locations=ASSETS_DATA / "locations.json",
    objects=ASSETS_DATA / "objects.json",
    obituaries=ASSETS_DATA / "obituaries.json",
    hints=ASSETS_DATA / "hints.json",
    motions=ASSETS_DATA / "motions.json",
    actions=ASSETS_DATA / "actions.json",
)

# Comparaisons optionnelles contre des dérivés du C si présents
C_TRAVEL_JSON = ASSETS_DATA / "travel_c.json"
C_TKEY_JSON = ASSETS_DATA / "tkey_c.json"


def _construct_omap(loader, node):
    omap = OrderedDict()
    for subnode in node.value:
        if isinstance(subnode, yaml.MappingNode):
            if len(subnode.value) != 1:
                raise ValueError("Expected single kv in omap node")
            key_node, value_node = subnode.value[0]
            key = loader.construct_object(key_node)
            value = loader.construct_object(value_node)
            omap[key] = value
        else:
            raise TypeError("Expected mapping node in omap sequence")
    return omap


yaml.add_constructor(u"tag:yaml.org,2002:omap", _construct_omap)


def normalize_data(data):
    """Return a canonical, comparable representation of nested data.

    - Dict keys are coerced to strings and items are sorted by key to avoid
      Python 3 comparison errors on mixed-type keys (e.g., bool vs str).
    - Lists are normalized element-wise (order preserved).
    - Scalars returned as-is.
    """
    if isinstance(data, (dict, OrderedDict)):
        items = []
        for k, v in data.items():
            items.append((str(k), normalize_data(v)))
        items.sort(key=lambda kv: kv[0])
        return {k: v for k, v in items}
    if isinstance(data, list):
        return [normalize_data(x) for x in data]
    return data


def get_yaml_section(yaml_root, key: str):
    # Map les clés à leurs sections YAML
    mapping = {
        "arbitrary_messages": "arbitrary_messages",
        "classes": "classes",
        "turn_thresholds": "turn_thresholds",
        "locations": "locations",
        "objects": "objects",
        "obituaries": "obituaries",
        "hints": "hints",
        "motions": "motions",
        "actions": "actions",
    }
    section = mapping.get(key)
    return yaml_root.get(section, []) if section else []


def compare_data(lhs, rhs, label: str) -> bool:
    if lhs == rhs:
        return True
    print(f"Divergence trouvée dans {label}.")
    return False


def main() -> int:
    if not YAML_FILE.exists():
        print(f"YAML introuvable: {YAML_FILE}", file=sys.stderr)
        return 1

    with YAML_FILE.open("r", encoding="utf-8") as f:
        yaml_data = yaml.load(f, Loader=yaml.Loader)

    all_valid = True

    for key, json_path in JSON_FILES.items():
        if not json_path.exists():
            print(f"Fichier JSON manquant: {json_path}")
            all_valid = False
            continue
        with json_path.open("r", encoding="utf-8") as f:
            json_data = json.load(f)
        yaml_section = get_yaml_section(yaml_data, key)
        if yaml_section is None:
            print(f"Section YAML inconnue pour {key}")
            all_valid = False
            continue
        yaml_norm = normalize_data(yaml_section)
        json_norm = normalize_data(json_data)
        if not compare_data(yaml_norm, json_norm, key):
            all_valid = False

    # Comparaisons optionnelles contre des dérivés du C
    if (ASSETS_DATA / "tkey.json").exists() and C_TKEY_JSON.exists():
        with (ASSETS_DATA / "tkey.json").open("r", encoding="utf-8") as f:
            json_data = json.load(f)
        with C_TKEY_JSON.open("r", encoding="utf-8") as f:
            c_data = json.load(f)
        if not compare_data(normalize_data(json_data), normalize_data(c_data), "tkey"):
            all_valid = False
    else:
        print("(Info) Comparaison tkey ignorée (fichiers manquants)")

    if (ASSETS_DATA / "travel.json").exists() and C_TRAVEL_JSON.exists():
        with (ASSETS_DATA / "travel.json").open("r", encoding="utf-8") as f:
            json_data = json.load(f)
        with C_TRAVEL_JSON.open("r", encoding="utf-8") as f:
            c_data = json.load(f)
        if not compare_data(normalize_data(json_data), normalize_data(c_data), "travel"):
            all_valid = False
    else:
        print("(Info) Comparaison travel ignorée (fichiers manquants)")

    print("Tous les fichiers JSON sont valides et correspondent aux données YAML." if all_valid else "Validation terminée avec des divergences.")
    return 0 if all_valid else 1


if __name__ == "__main__":
    sys.exit(main())
