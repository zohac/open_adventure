#!/usr/bin/env python3
"""
Script pour convertir adventure.yaml en plusieurs fichiers JSON, en gérant les 'omap' pour préserver l'ordre des objets.
"""

import sys
import yaml
import json
from collections import OrderedDict

YAML_NAME = "adventure.yaml"

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
yaml.Loader.add_constructor(u'tag:yaml.org,2002:omap', construct_omap)

def main():
    with open(YAML_NAME, "r", encoding="utf-8") as f:
        db = yaml.load(f, Loader=yaml.Loader)

    # Extraire les noms pour référence
    locnames = list(db["locations"].keys())

    # Construire msgmap pour les messages arbitraires
    msgmap = {}
    for idx, msgname in enumerate(db["arbitrary_messages"].keys()):
        msgmap[msgname] = idx

    objnames = list(db["objects"].keys())
    motionnames = [k.upper() for k in db["motions"].keys()]

    # Construire le tableau travel et tkey
    travel, tkey = buildtravel(db, locnames, msgmap, objnames, motionnames)

    # Calculer ignore
    ignore = compute_ignore(db['motions'], db['actions'])

    # Préparer les données à exporter
    data = {
        'arbitrary_messages': list(db["arbitrary_messages"].items()),
        'classes': db["classes"],
        'turn_thresholds': db["turn_thresholds"],
        'locations': list(db["locations"].items()),
        'objects': list(db["objects"].items()),
        'obituaries': db["obituaries"],
        'hints': db["hints"],
        'motions': list(db["motions"].items()),
        'actions': list(db["actions"].items()),
        'tkey': tkey,
        'travel': travel,
        'ignore': ignore,
    }

    # Exporter chaque section dans un fichier JSON séparé
    for key, value in data.items():
        filename = f"data/{key}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(value, f, ensure_ascii=False, indent=4)
        print(f"Fichier {filename} généré.")

def buildtravel(db, locnames, msgmap, objnames, motionnames):
    locs = db['locations']
    objs = db['objects']

    # Build verbmap
    verbmap = {}
    for motion_name, motion_data in db["motions"].items():
        motion_name_upper = motion_name.upper()
        try:
            words = motion_data.get("words", [])
            for word in words:
                # sys.stderr.write(f"{word}, ")
                verbmap[word.upper()] = motion_name_upper
        except TypeError:
            pass

    # Helper functions
    def dencode(action, name):
        if action[0] == "goto":
            try:
                return locnames.index(action[1])
            except ValueError:
                sys.stderr.write(
                    f"dungeon: unknown location {action[1]} in goto clause of {name}\n"
                )
                raise
        elif action[0] == "special":
            return 300 + action[1]
        elif action[0] == "speak":
            try:
                return 500 + msgmap[action[1]]
            except KeyError:
                sys.stderr.write(
                    f"dungeon: unknown message {action[1]} in speak clause of {name}\n"
                )
                raise
        else:
            print(f"Unknown action type: {action}")
            raise ValueError

    def cencode(cond, name):
        if cond is None:
            return 0
        elif cond == ["nodwarves"]:
            return 100
        elif cond[0] == "pct":
            return cond[1]
        elif cond[0] == "carry":
            try:
                return 100 + objnames.index(cond[1])
            except ValueError:
                sys.stderr.write(
                    f"dungeon: unknown object name {cond[1]} in carry clause of {name}\n"
                )
                sys.exit(1)
        elif cond[0] == "with":
            try:
                return 200 + objnames.index(cond[1])
            except ValueError:
                sys.stderr.write(
                    f"dungeon: unknown object name {cond[1]} in with clause of {name}\n"
                )
                sys.exit(1)
        elif cond[0] == "not":
            try:
                obj = objnames.index(cond[1])
                obj_data = objs[cond[1]]
                if isinstance(cond[2], int):
                    state = cond[2]
                elif cond[2] in obj_data.get("states", []):
                    state = obj_data.get("states").index(cond[2])
                else:
                    sys.stderr.write(
                        f"dungeon: unmatched state symbol {cond[2]} in not clause of {name}\n"
                    )
                    sys.exit(1)
                return 300 + obj + 100 * state
            except ValueError:
                sys.stderr.write(
                    f"dungeon: unknown object name {cond[1]} in not clause of {name}\n"
                )
                sys.exit(1)
        else:
            print(f"Unknown condition: {cond}")
            raise ValueError

    # Build ltravel
    ltravel = []
    for i, (name, loc) in enumerate(locs.items()):
        if "travel" in loc:
            for rule in loc["travel"]:
                tt = [i]
                dest = dencode(rule["action"], name) + 1000 * cencode(rule.get("cond"), name)
                tt.append(dest)
                verbs = []
                for e in rule["verbs"]:
                    e_upper = e.upper()
                    if e_upper in verbmap:
                        verbs.append(verbmap[e_upper])  # Use the motion name directly
                    else:
                        sys.stderr.write(f"dungeon: unknown verb {e} in travel rules of {name}\n")
                        sys.exit(1)
                if not verbs:
                    verbs.append(1)  # Magic dummy entry for null rules
                tt.extend(verbs)
                ltravel.append(tt)

    # Process ltravel to build travel and tkey
    travel = [{
        'from_index': 0,
        'from_location': "LOC_NOWHERE",
        'motion': 0,
        'condtype': 0,
        'condarg1': 0,
        'condarg2': 0,
        'desttype': 0,
        'destval': 0,
        'nodwarves': False,
        'stop': False
    }]
    tkey = [0]
    oldloc = 0
    travel_index = 1  # Since we already have one entry in travel

    while ltravel:
        rule = ltravel.pop(0)
        loc = rule.pop(0)
        newloc = rule.pop(0)
        if loc != oldloc:
            tkey.append(len(travel))
            oldloc = loc
        elif travel:
            # Flip the last element's 'stop' between "true" and "false"
            last_flag = travel[-1]['stop']
            travel[-1]['stop'] = False if last_flag == True else True

        while rule:
            cond = newloc // 1000
            nodwarves = True if cond == 100 else False

            # Process conditions
            if cond == 0:
                condtype = "cond_goto"
                condarg1 = 0
                condarg2 = 0
            elif cond < 100:
                condtype = "cond_pct"
                condarg1 = cond
                condarg2 = 0
            elif cond == 100:
                condtype = "cond_goto"
                condarg1 = 100
                condarg2 = 0
            elif cond <= 200:
                condtype = "cond_carry"
                condarg1 = objnames[cond - 100]
                condarg2 = 0
            elif cond <= 300:
                condtype = "cond_with"
                condarg1 = objnames[cond - 200]
                condarg2 = 0
            else:
                condtype = "cond_not"
                condarg1 = cond % 100
                condarg2 = (cond - 300) // 100

            # Process destination
            dest = newloc % 1000
            if dest <= 300:
                desttype = "dest_goto"
                destval = locnames[dest]
            elif dest >= 500:
                desttype = "dest_speak"
                destval = list(msgmap.keys())[dest - 500]
            else:
                desttype = "dest_special"
                destval = locnames[dest - 300]

            motion = rule.pop(0)
            travel_entry = {
                'from_index': len(tkey) - 1,
                'from_location': locnames[len(tkey) - 1],
                'motion': motion,
                'condtype': condtype,
                'condarg1': condarg1,
                'condarg2': condarg2,
                'desttype': desttype,
                'destval': destval,
                'nodwarves': nodwarves,
                'stop': False,
            }
            travel.append(travel_entry)
            travel_index += 1

        # After processing all entries for this location, set 'stop' to True
        travel[-1]['stop'] = True

    return travel, tkey

def compute_ignore(motions, actions):
    ignore = ''
    for motion_name, motion_data in motions.items():
        if not motion_data.get('oldstyle', True):
            words = motion_data.get('words', [])
            for word in words:
                if len(word) == 1:
                    ignore += word.upper()
    for action_name, action_data in actions.items():
        if not action_data.get('oldstyle', True):
            words = action_data.get('words', [])
            for word in words:
                if len(word) == 1:
                    ignore += word.upper()
    return ignore

if __name__ == '__main__':
    main()
