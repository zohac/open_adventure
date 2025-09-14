#!/usr/bin/env python3
"""
Extract C-equivalent travel/tkey tables into JSON for cross-validation.

Inputs
- C-derived sources for travel and tkey (defaults: ./travel_c.c, ./tkey_c.c)

Outputs
- JSON files under the output directory (default: assets/data):
  travel_c.json, tkey_c.json

Usage
  python3 scripts/extract_c.py [--out assets/data] [--in-travel path] [--in-tkey path]

Notes
- No network access; works on macOS/Linux; paths resolved via pathlib.
"""
import re
import json
import argparse
from pathlib import Path
C_TRAVEL_FILE = 'travel_c.c'    # C input with 'travel' data (default)
C_TKEY_FILE = 'tkey_c.c'        # C input with 'tkey' data (default)
DEFAULT_TRAVEL_JSON = 'travel_c.json'  # Default (validation) JSON filename for 'travel'
DEFAULT_TKEY_JSON = 'tkey_c.json'      # Default (validation) JSON filename for 'tkey'
def extract_travel(lines, output_json_path: Path):
    travel_entries = []
    current_entry = {}
    entry_pattern = re.compile(r'\{ // from (\d+): (\w+)')
    field_pattern = re.compile(r'\.(\w+)\s*=\s*(.+?),')
    for line in lines:
        line = line.strip()
        if line.startswith('{ // from'):
            # Début d'une nouvelle entrée
            match = entry_pattern.match(line)
            if match:
                if current_entry:
                    travel_entries.append(current_entry)
                current_entry = {
                    'from_index': int(match.group(1)),
                    'from_location': match.group(2),
                }
        elif line.startswith('},'):
            # Fin de l'entrée actuelle
            if current_entry:
                travel_entries.append(current_entry)
                current_entry = {}
        elif line.startswith('}'):
            # Fin de la dernière entrée
            if current_entry:
                travel_entries.append(current_entry)
                current_entry = {}
        else:
            # Extraire les champs de l'entrée
            match = field_pattern.match(line)
            if match:
                key = match.group(1)
                value = match.group(2).strip()
                # Traiter les valeurs spécifiques
                if value.endswith(','):
                    value = value[:-1]
                if value in ['true', 'false']:
                    value = value == 'true'
                elif value.startswith('"') and value.endswith('"'):
                    value = value.strip('"')
                else:
                    try:
                        # Essayer de convertir en entier
                        value = int(value)
                    except ValueError:
                        try:
                            # Essayer de convertir en flottant
                            value = float(value)
                        except ValueError:
                            # Laisser la valeur telle quelle (par exemple, des constantes)
                            pass
                current_entry[key] = value
    # Enregistrer la dernière entrée si elle existe
    if current_entry:
        travel_entries.append(current_entry)
    # Enregistrer les données dans un fichier JSON
    output_json_path.parent.mkdir(parents=True, exist_ok=True)
    with output_json_path.open('w', encoding='utf-8') as f:
        json.dump(travel_entries, f, ensure_ascii=False, indent=4)
    print(f"Données 'travel' extraites dans {output_json_path}.")
def extract_tkey(lines, output_json_path: Path):
    tkey_values = []
    tkey_started = False
    tkey_pattern = re.compile(r'const\s+long\s+tkey\[\]\s*=\s*\{')
    value_pattern = re.compile(r'(-?\d+)')
    for line in lines:
        line = line.strip()
        if tkey_started:
            if line.endswith('};'):
                tkey_started = False
                line = line[:-2]  # Supprimer '};' à la fin
            # Extraire les valeurs numériques de la ligne
            values = value_pattern.findall(line)
            tkey_values.extend([int(v) for v in values])
        elif tkey_pattern.match(line):
            # Début du tableau tkey
            tkey_started = True
    # Enregistrer les données dans un fichier JSON
    output_json_path.parent.mkdir(parents=True, exist_ok=True)
    with output_json_path.open('w', encoding='utf-8') as f:
        json.dump(tkey_values, f, ensure_ascii=False, indent=4)
    print(f"Données 'tkey' extraites dans {output_json_path}.")
def main():
    parser = argparse.ArgumentParser(description="Extract C-equivalent travel/tkey into JSON")
    parser.add_argument("--out", default=str(Path("assets")/"data"), help="Output directory for JSON (default: assets/data)")
    parser.add_argument("--in-travel", default=C_TRAVEL_FILE, help="Path to C travel source (default: ./travel_c.c)")
    parser.add_argument("--in-tkey", default=C_TKEY_FILE, help="Path to C tkey source (default: ./tkey_c.c)")
    parser.add_argument("--canonical", action="store_true", help="Write canonical asset names (travel.json, tkey.json) instead of validation *_c.json")
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    travel_out_name = 'travel.json' if args.canonical else DEFAULT_TRAVEL_JSON
    tkey_out_name = 'tkey.json' if args.canonical else DEFAULT_TKEY_JSON

    # Read and extract 'travel'
    travel_path = Path(args.__dict__["in_travel"])  # hyphen to underscore
    if not travel_path.exists():
        print(f"C travel source not found: {travel_path}")
    else:
        with travel_path.open('r', encoding='utf-8') as f:
            lines = f.readlines()
        extract_travel(lines, out_dir / travel_out_name)

    # Read and extract 'tkey'
    tkey_path = Path(args.__dict__["in_tkey"])  # hyphen to underscore
    if not tkey_path.exists():
        print(f"C tkey source not found: {tkey_path}")
    else:
        with tkey_path.open('r', encoding='utf-8') as f:
            lines = f.readlines()
        extract_tkey(lines, out_dir / tkey_out_name)
if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        import sys
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
