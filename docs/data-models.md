# Data Models — open_adventure

> Aucune base de données. L'intégralité des données du jeu vit sous forme de JSON immuables dans `assets/data/`, dérivés de la source de vérité YAML `open-adventure-master/adventure.yaml` via les scripts Python du dépôt. La couche Data les mappe vers des entités Domain immuables.

## 1. Pipeline & origines

```
open-adventure-master/adventure.yaml   (source de vérité — YAML upstream)
        │
        ├─► scripts/make_dungeon.py            ─► assets/data/travel.json, tkey.json
        ├─► open-adventure-master/make_dungeon.py ─► dungeon.c, dungeon.h
        │       │
        │       └─► scripts/extract_c.py        ─► travel_c.json, tkey_c.json (validation)
        │
        └─► scripts/validate_json.py            ─► exit 0 si YAML↔JSON cohérent, 1 sinon

Les autres JSON (locations, objects, motions, actions, conditions, classes, hints, obituaries,
arbitrary_messages, turn_thresholds, metadata) sont copiés/dérivés depuis la même source YAML
selon les conventions du projet upstream.
```

## 2. Assets embarqués (`assets/data/`)

Tous déclarés dans `pubspec.yaml` (sauf `ignore.json` et `map_layout.json` à venir).

| Fichier                     | Taille  | Rôle                                                                     | Modèle Data                                |
|----------------------------|---------|--------------------------------------------------------------------------|--------------------------------------------|
| `locations.json`           | 274 KB  | Liste `[name, { description:{short,long,maptag}, conditions, sound, loud }]` → graphe des lieux | `LocationModel.fromJson` |
| `travel.json`              | 266 KB  | Règles de voyage aplaties (`from_index`, `motion`, `destval`, `condtype/arg1/arg2`, `desttype`, `stop`, `nodwarves`) | `TravelRuleModel.fromJson` |
| `tkey.json`                | 2 KB    | Index `travel` par `locationId` (lookup rapide)                          | lecture directe par `AdventureRepositoryImpl` |
| `objects.json`             | 36 KB   | Liste `[name, { words, inventory, locations(string\|list), states, descriptions, sounds, changes, immovable, is_treasure }]` | `GameObjectModel.fromJson` |
| `motions.json`             | 9 KB    | Vocabulaire de déplacement (`canonical` + `words`)                       | `MotionNormalizerImpl.load`                |
| `actions.json`             | 16 KB   | Catalogue verbes/actions (parser legacy + métadonnées UI optionnelles)   | `ActionModel`                              |
| `conditions.json`          | 23 KB   | Métadonnées de conditions (legacy)                                       | `ConditionModel`                           |
| `arbitrary_messages.json`  | 25 KB   | Messages canoniques par clé (`DWARF_RAN`, `KNIFE_THROWN`, `LAMP_DIM`, `LAMP_OUT`, `MISSES_YOU`, `DWARF_PACK`, …) avec format `%s`/`%d` | accédé via `AdventureRepository.arbitraryMessage(key, count?)` |
| `classes.json`             | 1 KB    | Seuils de classement final (novice…master)                               | lecture brute (S4)                         |
| `hints.json`               | 3 KB    | Indices contextuels                                                      | lecture brute (S4)                         |
| `obituaries.json`          | 988 B   | Messages de mort                                                         | lecture brute (S4)                         |
| `turn_thresholds.json`     | 732 B   | Seuils de pénalité par nombre de tours                                   | lecture brute (S4)                         |
| `metadata.json`            | 52 B    | `{ schema_version: 1, start_location_id: 1 }`                            | `AdventureRepositoryImpl.initialGame()`    |
| `ignore.json`              | 7 B     | Exclusions de validation utilisées par les scripts                        | scripts uniquement, non chargé en runtime  |

Volume total runtime ≈ **658 KB** — bien sous le seuil d'isolate parsing (1 MiB).

## 3. Entités Domain (immuables)

Toutes les entités sont sous `lib/domain/entities/`. Elles n'ont **aucune** dépendance Flutter ni JSON.

### `Game` — état du monde

```dart
class Game {
  final int loc, oldLoc, oldLc2, newLoc;     // position courante / précédente / pré-précédente / cible
  final int turns;                            // nombre de tours
  final int rngSeed;                          // seed RNG déterministe (défaut 42)
  final DwarfState dwarfState;                // sous-système nains
  final Set<int> visitedLocations;            // pour first-visit vs revisit
  final bool magicWordsUnlocked;              // DDR-001 — débloque incantations
  final Map<int, GameObjectState> objectStates;// état runtime des objets indexé par id
  final Set<String> flags;                    // flags globaux (closing, closed, novice, bonus, …)
  final int limit, clock1, clock2;            // timers lampe / événements
  final bool lampWarningIssued;               // anti-spam du message LAMP_DIM
  // copyWith, ==, hashCode structurels (SetEquality + MapEquality)
}
```

### `Location`

```dart
class Location {
  final int id;                  // index dans locations.json
  final String name;             // clé canonique (ex: "LOC_BUILDING")
  final String? shortDescription, longDescription, mapTag;
  final bool loud;
  final Map<String, bool> conditions; // ex: {NOBACK: true, FORCED: false, DEEP: true}
}
```

### `GameObject`

```dart
class GameObject {
  final int id;                          // index dans objects.json
  final String name;                     // ex: "LAMP", "BOTTLE", "AXE"
  final List<String> words;              // alias parser (référence)
  final List<String> locations;          // positions initiales (noms de lieux)
  final bool immovable;
  final bool isTreasure;
  final String? inventoryDescription;
  final List<String>? states;            // ex: ["LAMP_DARK", "LAMP_BRIGHT"]
  final List<String>? stateDescriptions; // descriptions parallèles
}
```

### `GameObjectState`

```dart
class GameObjectState {
  final int id;
  final int? location;       // lieu courant si non porté
  final int? fixedLocation;  // pour objets immobiles
  final bool isCarried;
  final String? state;       // ex: "LAMP_BRIGHT"
  final Object? prop;        // valeur libre (entier ou string)
  // isAt(loc) : convenience helper
}
```

### `TravelRule`

```dart
class TravelRule {
  final int fromId;
  final String motion;        // forme brute (ex: "NORTH", "MOT_12") — normalisée via MotionCanonicalizer
  final String destName;
  final int? destId;
  final String? condType;     // 'cond_goto' | '0' | autres (filtrés en S2)
  final int? condArg1, condArg2;
  final bool noDwarves;
  final bool stop;            // filtré en S2 tant que l'évaluateur de conditions n'est pas complet
  // + destType conservé dans TravelRuleModel
}
```

### `DwarfState`

```dart
class DwarfState {
  final bool activated;
  final bool introShown;
  final List<int> dwarfLocations; // 3 slots, -1 = absent
}
```

### `AudioSettings`

```dart
class AudioSettings {
  final double bgmVolume;  // 0..1
  final double sfxVolume;  // 0..1
}
```

## 4. Value Objects

Sous `lib/domain/value_objects/`. Égalité et hashCode structurels.

| VO                     | Forme                                                                 | Usage                                                |
|-----------------------|-----------------------------------------------------------------------|------------------------------------------------------|
| `Command`             | `{ String verb, String? target }`                                     | Construit dans Application et passé à `ApplyTurnGoto` |
| `TurnResult`          | `{ Game newGame, List<String> messages }`                             | Sortie des use cases interactifs                     |
| `ActionOption`        | `{ String id, category, label, icon?, verb, objectId? }`              | Option UI présentée par `ListAvailableActions`       |
| `Condition`           | union typée (`carry`, `withObject`, `not`, `at`, `state`, `prop`, `have`) | Évaluée par `EvaluateCondition`                  |
| `ScoreBreakdown`      | `{ treasures, exploration, penalties, total }` (total dérivé)         | Sortie de `ComputeScore`                             |
| `DwarfTickResult`     | `{ Game game, List<String> messages }`                                | Sortie de `DwarfSystem.tick`                         |
| `GameSnapshot`        | `{ schema_version=1, int loc, int turns, int rngSeed }`               | Format de persistance autosave                       |
| `MagicWords`          | `static const Set<String>` + `isIncantation(verb)`                    | Filtrage incantations (DDR-001)                      |

## 5. Mappers (`lib/data/models/`)

### Règles invariantes

- **Aplatissement** : `AssetDataSource.getLocations()` transforme `[name, {...}]` en `{ name, ...}` avant mapping. Idem `GameObjectModel.fromEntry` pour `objects.json`.
- **`locations` polymorphe** : `GameObjectModel._normalizeLocations` accepte `String` ou `List<String>` → toujours `List<String>` en sortie ; absence → liste vide.
- **Champs optionnels** : `null` si vides (`states/descriptions/sounds/changes`).
- **`is_treasure` / `treasure`** : double clé tolérée (rétro-compat YAML).
- **ID séquentiel** : index dans le tableau source ; généré par la repository, jamais par le mapper.
- **Aucune logique métier** dans les modèles. Le mapper transforme, point.

### `LocationModel.fromJson(map, id)`

Lit `description.{short,long,maptag}`, `conditions: Map<String,bool>`, `loud: bool` (défaut false). Retourne un `LocationModel extends Location`.

### `GameObjectModel.fromJson(map, id)`

Lit `words`, `locations`, `immovable`, `is_treasure` (avec fallback `treasure`), `inventory` (trim → null si vide), `states`, `descriptions` (dynamic — string ou tuple), `sounds`, `changes`. Expose aussi `toEntity()` (projection Domain pure) et `toJson()` (round-trip).

### `TravelRuleModel.fromJson(map)`

Lit `from_index`, `motion`, `destval` (peut être int → `destId`, sinon `destName`), `condtype`, `condarg1/2`, `desttype`, `nodwarves`, `stop`. Le filtrage par `ListAvailableActionsTravel` ne garde que les règles `condtype ∈ {cond_goto, "0"}` et `stop=false` tant que l'évaluateur de conditions complet n'est pas branché (à étendre en S3/S4).

### `ActionModel`, `ConditionModel`

Lecture brute. Pas de logique. Servent à exposer le catalogue verbes/conditions au reste du Domain (utilisé par `EvaluateCondition` côté condtions, par les use cases côté actions).

## 6. Persistance — schéma S2

### `GameSnapshot` JSON

```json
{
  "schema_version": 1,
  "loc": 1,
  "turns": 0,
  "rng_seed": 42
}
```

Écrit à `${applicationSupportDirectory}/open_adventure/autosave.json` après chaque tour réussi. Lecture tolérante : champs inconnus ignorés, `GameSnapshot.fromJson` n'utilise que `loc/turns/rng_seed`.

### Évolution prévue S4 (cf. `docs/EXEC_S4.md` + `docs/Dossier_de_Référence.md` §7.3)

Le snapshot devra porter :

```json
{
  "schema_version": 2,
  "rng_seed": 123456789,
  "turn": 42,
  "score_partial": 87,
  "location": "HALL_OF_MISTS",
  "visited": ["BUILDING","DEBRIS","HALL_OF_MISTS"],
  "inventory": ["LAMP","AXE","CAGE"],
  "objects_state": { "BIRD": "caged", "DRAGON": "alive", "VASE": "intact" },
  "flags": { "dflag": 2, "closng": false, "closed": false, "bonus": "none", "novice": false },
  "hints_used": [3],
  "obituaries": 0
}
```

Multi-slots S4 : fichiers `save_v{schemaVersion}_{slot}.json` dans le même répertoire, métadonnées `{ updated_at, turns, score, locationName }` pour `SavesPage`.

## 7. Conventions d'évolution

- **Incrément `schema_version`** dans `metadata.json` (assets) ET dans `GameSnapshot` (persistance) à chaque rupture de schéma.
- **Compat ascendante intra-major** obligatoire pour les sauvegardes.
- **Diff cross-source** : `scripts/validate_json.py` doit rester exit 0 entre YAML, JSON canoniques et (si présents) extraits C. Job CI `data-validate` prévu S4 (non bloquant).
- **Pas de logique métier** dans les modèles ni dans les JSON. Toute règle vit dans `lib/domain/usecases/` ou `lib/domain/services/`.
