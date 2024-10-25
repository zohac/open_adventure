#!/usr/bin/env python3
"""
Script pour valider les fichiers JSON générés à partir de adventure.yaml.
"""

import yaml
import json
import os
import sys
from collections import OrderedDict

YAML_FILE = "adventure.yaml"
JSON_FILES = {
    'arbitrary_messages': 'data/arbitrary_messages.json',
    'classes': 'data/classes.json',
    'turn_thresholds': 'data/turn_thresholds.json',
    'locations': 'data/locations.json',
    'objects': 'data/objects.json',
    'obituaries': 'data/obituaries.json',
    'hints': 'data/hints.json',
    'motions': 'data/motions.json',
    'actions': 'data/actions.json',
    # 'tkey': 'data/tkey.json',
    # 'travel': 'data/travel.json',
    # 'ignore': 'data/ignore.json',
}

# Le fichier contenant les données travel du code C
C_TRAVEL_FILE = 'data/travel_c.json'
C_TKEY_FILE = 'data/tkey_c.json'

def construct_omap(loader, node):
    omap = OrderedDict()
    for subnode in node.value:
        # Chaque subnode est un MappingNode avec une seule paire clé-valeur
        if isinstance(subnode, yaml.MappingNode):
            if len(subnode.value) != 1:
                raise ValueError("Expected a single key-value pair in omap mapping")
            key_node, value_node = subnode.value[0]
            key = loader.construct_object(key_node)
            value = loader.construct_object(value_node)
            omap[key] = value
        else:
            raise TypeError("Expected a mapping node in omap sequence")
    return omap

# Ajouter le constructeur personnalisé au Loader
yaml.add_constructor(u'tag:yaml.org,2002:omap', construct_omap)

def main():
    # Charger le fichier YAML avec le Loader personnalisé
    with open(YAML_FILE, 'r', encoding='utf-8') as f:
        yaml_data = yaml.load(f, Loader=yaml.Loader)

    # Valider chaque fichier JSON
    all_valid = True
    for key, json_file in JSON_FILES.items():
        if not os.path.exists(json_file):
            print(f"Le fichier JSON {json_file} n'existe pas.")
            all_valid = False
            continue

        with open(json_file, 'r', encoding='utf-8') as f:
            json_data = json.load(f)

        # Obtenir la section correspondante du YAML
        yaml_section = get_yaml_section(yaml_data, key)

        # Normaliser les données pour la comparaison
        yaml_normalized = normalize_data(yaml_section)
        json_normalized = normalize_data(json_data)

        # Comparer les données normalisées
        if not compare_data(yaml_normalized, json_normalized, key):
            print(f"Divergence trouvée dans {key}.")
            all_valid = False

    # Valider 'tkey'
    key = 'tkey'
    json_file = 'data/tkey.json'  # Le fichier généré par make_dungeon.py
    if not os.path.exists(json_file):
        print(f"Le fichier JSON {json_file} n'existe pas.")
        all_valid = False
    elif not os.path.exists(C_TKEY_FILE):
        print(f"Le fichier des données C {C_TKEY_FILE} n'existe pas.")
        all_valid = False
    else:
        with open(json_file, 'r', encoding='utf-8') as f:
            json_data = json.load(f)

        with open(C_TKEY_FILE, 'r', encoding='utf-8') as f:
            c_tkey_data = json.load(f)

        # Normaliser les données pour la comparaison
        json_normalized = normalize_data(json_data)
        c_tkey_normalized = normalize_data(c_tkey_data)

        # Comparer les données normalisées
        if not compare_data(json_normalized, c_tkey_normalized, key):
            print(f"Divergence trouvée dans {key}.")
            all_valid = False


    # Valider 'travel'
    key = 'travel'
    json_file = 'data/travel.json'  # Le fichier généré par make_dungeon.py
    if not os.path.exists(json_file):
        print(f"Le fichier JSON {json_file} n'existe pas.")
        all_valid = False
    elif not os.path.exists(C_TRAVEL_FILE):
        print(f"Le fichier des données C {C_TRAVEL_FILE} n'existe pas.")
        all_valid = False
    else:
        with open(json_file, 'r', encoding='utf-8') as f:
            json_data = json.load(f)

        with open(C_TRAVEL_FILE, 'r', encoding='utf-8') as f:
            c_travel_data = json.load(f)

        # Normaliser les données pour la comparaison
        json_normalized = normalize_data(json_data)
        c_travel_normalized = normalize_data(c_travel_data)

        # Comparer les données normalisées
        if not compare_data(json_normalized, c_travel_normalized, key):
            print(f"Divergence trouvée dans {key}.")
            all_valid = False

    if all_valid:
        print("Tous les fichiers JSON sont valides et correspondent aux données YAML.")
    else:
        print("Validation terminée avec des divergences.")

def get_yaml_section(yaml_data, key):
    # Mappez la clé à la section correspondante dans les données YAML
    if key == 'arbitrary_messages':
        return yaml_data.get('arbitrary_messages', [])
    if key == 'classes':
        return yaml_data.get('classes', [])
    elif key == 'turn_thresholds':
        return yaml_data.get('turn_thresholds', [])
    elif key == 'locations':
        return yaml_data.get('locations', [])
    elif key == 'objects':
        return yaml_data.get('objects', OrderedDict())
    elif key == 'obituaries':
        return yaml_data.get('obituaries', [])
    elif key == 'hints':
        return yaml_data.get('hints', [])
    elif key == 'motions':
        return yaml_data.get('motions', OrderedDict())
    elif key == 'actions':
        return yaml_data.get('actions', [])
    elif key == 'ignore':
        return compute_ignore(yaml_data)
    else:
        # Gérer les cas spéciaux si nécessaire
        return None

def normalize_data(data):
    """
    Normalise les données pour la comparaison.
    Convertit les tuples en listes et les OrderedDict en listes de listes.
    """
    if isinstance(data, OrderedDict):
        return [[k, normalize_data(v)] for k, v in data.items()]
    elif isinstance(data, dict):
        return {k: normalize_data(v) for k, v in data.items()}
    elif isinstance(data, (list, tuple)):
        return [normalize_data(v) for v in data]
    else:
        return data

def compare_data(yaml_data, json_data, key):
    """
    Compare les données normalisées du YAML et du JSON.
    Retourne True si elles sont égales, False sinon.
    """
    from deepdiff import DeepDiff
    diff = DeepDiff(yaml_data, json_data, ignore_order=True)
    if diff:
        print(f"Differences dans {key}:")
        print(diff)
        return False
    else:
        return True

if __name__ == '__main__':
    try:
        from deepdiff import DeepDiff
    except ImportError:
        print("Le module 'deepdiff' est requis pour exécuter ce script.")
        print("Installez-le en exécutant 'pip install deepdiff'")
        sys.exit(1)

    main()
