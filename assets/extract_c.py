#!/usr/bin/env python3
import re
import json

C_TRAVEL_FILE = 'travel_c.c'    # Le fichier C contenant les données 'travel'
C_TKEY_FILE = 'tkey_c.c'    # Le fichier C contenant les données 'tkey'
OUTPUT_TRAVEL_JSON = 'data/travel_c.json'  # Fichier JSON de sortie pour 'travel'
OUTPUT_TKEY_JSON = 'data/tkey_c.json'      # Fichier JSON de sortie pour 'tkey'

def extract_travel(lines):
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
    with open(OUTPUT_TRAVEL_JSON, 'w', encoding='utf-8') as f:
        json.dump(travel_entries, f, ensure_ascii=False, indent=4)

    print(f"Données 'travel' extraites dans {OUTPUT_TRAVEL_JSON}.")

def extract_tkey(lines):
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
    with open(OUTPUT_TKEY_JSON, 'w', encoding='utf-8') as f:
        json.dump(tkey_values, f, ensure_ascii=False, indent=4)

    print(f"Données 'tkey' extraites dans {OUTPUT_TKEY_JSON}.")

def main():
    # Lire le fichier source C
    with open(C_TRAVEL_FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Extraire les données 'travel'
    extract_travel(lines)

    # Lire le fichier source C
    with open(C_TKEY_FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Extraire les données 'tkey'
    extract_tkey(lines)

if __name__ == '__main__':
    main()
