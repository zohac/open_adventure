# Asset Inventory — open_adventure

> Inventaire des assets embarqués (réels) et planifiés. Le pipeline de tracking d'art/audio détaillé est généré séparément par `scripts/generate_asset_tracker.py` dans `docs/ASSET_TRACKER.md`.

## 1. Assets data (réels, embarqués)

Tous déclarés dans `pubspec.yaml` section `flutter.assets`. Total ≈ **658 KB** (sous le seuil isolate parsing de 1 MiB).

| Asset                                          | Taille | Forme                                              | Source                                                 |
|-----------------------------------------------|--------|----------------------------------------------------|--------------------------------------------------------|
| `assets/data/locations.json`                  | 274 KB | List `[name, { description, conditions, sound, loud }]` | `scripts/make_dungeon.py` (depuis `adventure.yaml`) |
| `assets/data/travel.json`                     | 266 KB | List `[ { from_index, motion, destval, condtype, …} ]` | `scripts/make_dungeon.py`                              |
| `assets/data/objects.json`                    | 36 KB  | List `[name, { words, locations, states, …}]`     | `scripts/make_dungeon.py`                              |
| `assets/data/arbitrary_messages.json`         | 25 KB  | Map `key → message` (avec placeholders `%s`/`%d`) | YAML upstream                                          |
| `assets/data/conditions.json`                 | 23 KB  | Métadonnées conditions                             | YAML upstream                                          |
| `assets/data/actions.json`                    | 16 KB  | Catalogue verbes + métadonnées UI                  | YAML upstream                                          |
| `assets/data/motions.json`                    | 9 KB   | `[canonical, { words }]`                           | YAML upstream                                          |
| `assets/data/hints.json`                      | 3 KB   | Indices contextuels (système S4)                   | YAML upstream                                          |
| `assets/data/tkey.json`                       | 2 KB   | Index travel par locationId                        | `scripts/make_dungeon.py`                              |
| `assets/data/classes.json`                    | 1 KB   | Seuils classement final                            | YAML upstream                                          |
| `assets/data/obituaries.json`                 | 988 B  | Messages de mort                                   | YAML upstream                                          |
| `assets/data/turn_thresholds.json`            | 732 B  | Seuils de pénalité (turns)                         | YAML upstream                                          |
| `assets/data/metadata.json`                   | 52 B   | `{ schema_version: 1, start_location_id: 1 }`      | maintenu à la main                                     |
| `assets/data/ignore.json`                     | 7 B    | Exclusions de validation                           | maintenu à la main (utilisé par scripts uniquement)    |

Note : `assets/data/map_layout.json` est planifié (cf. `docs/EXEC_S3.md` DoR Map et `scripts/generate_map_layout.py`) mais pas encore embarqué.

## 2. Assets images (planifiés, non livrés)

Spécification : pixel-art 16-bit, 16:9, WebP lossless, ≤ 200 KB/image, total ≤ 10 Mo, naming `assets/images/locations/<key>.webp` avec `<key>` calculé par `locationImageKey(Location)`.

- **Convention de clé** : `mapTag` du lieu si présent, sinon `snake_case(name)`, sinon `id.toString()`.
- **Widget consommateur** : `LocationImage` (Presentation) avec `FadeInImage` + fallback silencieux quand absent.
- **Rendu** : tous via `PixelCanvas` (scale entier, `FilterQuality.none`).
- **Précharge** : prévu post-`ApplyTurn` pour le prochain lieu (S4).
- **Statut actuel** : **0 image livrée**. `pubspec.yaml` n'inclut aucune entrée `assets/images/locations/*.webp`. À déclarer fichier par fichier au fur et à mesure de la livraison (cf. `docs/EXEC_S3.md` ADVT‑S3‑20).
- **Backlog DA** : 15-20 scènes prioritaires en S3 (cf. `docs/ART_ASSET_BIBLE.md`), complétion en S4.

## 3. Assets audio (planifiés, non livrés)

### BGM (Musiques de fond)

- Format : OGG/Opus 48 kHz, stéréo
- Naming : `assets/audio/music/<trackKey>.ogg` (mapping via `defaultBgmAssetResolver` → lowercase de la clé)
- Loops gapless ; crossfade 250–500 ms sur changement de zone (350 ms par défaut dans `AudioController`)
- Budget : 6–8 Mo total (~10-12 loops × ≤ 600 KB)
- Volume par défaut : 60 %
- **Statut actuel** : aucun fichier livré.

### SFX (Effets sonores)

- Format : OGG/Opus 48 kHz, mono
- Naming : `assets/audio/sfx/<sfxKey>.ogg`
- Throttle anti-spam : 150 ms (configurable via `AudioController.sfxThrottle`)
- Budget : 1 Mo total (~60 KB/SFX max)
- Volume par défaut : 100 %
- Événements câblés à prévoir (S3) : prendre, poser, lampe on/off, alerte nain, attaque, danger, succès/échec
- **Statut actuel** : aucun fichier livré.

## 4. Diagrammes & ressources documentaires

Sous `diagram/` (drawio + sortie Graphviz). Non embarqués dans l'app.

| Fichier                              | Source                                  |
|-------------------------------------|------------------------------------------|
| `diagram/travel.dot` + `.png`       | `scripts/generate_travel_graph.py`       |
| `diagram/Clean_Architecture.drawio` | Manuel                                   |
| `diagram/uml.drawio`                | Manuel                                   |
| `diagram/location.drawio` + `.xml`  | Manuel                                   |
| `diagram/map_layers.drawio.xml`     | `scripts/export_drawio_map.py`           |
| `diagram/mindmap.drawio`            | Manuel                                   |
| `diagram/test.drawio`               | Manuel                                   |

Et sous `docs/` :

| Fichier                                | Source / usage                                       |
|---------------------------------------|------------------------------------------------------|
| `docs/map_layers/*.json` (5 strates)  | `scripts/export_layer_graphs.py`                     |
| `docs/map_layout_plan.yaml`           | Plan de couches éditorial                            |
| `docs/ux_screens_images/*.png`        | Screenshots wireframes HomePage (DA validation)      |
| `docs/ASSET_TRACKER.md`               | Généré par `scripts/generate_asset_tracker.py`       |
| `docs/ASSET_MANIFEST.json`            | Généré par `scripts/generate_asset_manifest.py` — source d'entrée IA pour génération d'art/audio |

## 5. Localisation des sauvegardes runtime

Les sauvegardes ne sont pas des assets embarqués mais des données utilisateur écrites sur le device.

- **iOS** : `NSApplicationSupportDirectory/open_adventure/saves/` (et `autosave.json` au même niveau actuellement)
- **Android** : `<applicationSupportDir>/open_adventure/`
- **Fichier S2** : `autosave.json`
- **Fichiers S4 prévus** : `save_v{schemaVersion}_{slot}.json` (+ `autosave.json`)

## 6. Pipeline de génération (rappel)

```
adventure.yaml  ─► scripts/update_assets.py
                        ├─► scripts/make_dungeon.py            ─► travel.json, tkey.json
                        ├─► open-adventure-master/make_dungeon.py ─► dungeon.c/h
                        ├─► scripts/extract_c.py               ─► travel_c.json, tkey_c.json (validation)
                        └─► scripts/validate_json.py            ─► exit 0/1

Reporting :
  python3 scripts/generate_asset_tracker.py    → docs/ASSET_TRACKER.md (sections regénérées entre marqueurs)
  python3 scripts/generate_asset_manifest.py   → docs/ASSET_MANIFEST.json (idempotent, n'écrit jamais sous assets/)
  python3 scripts/generate_map_layout.py       → assets/data/map_layout.json (à venir)
  python3 scripts/generate_travel_graph.py --output diagram/travel.dot  → puis `dot -Tpng` pour PNG
```

Dépendances Python : `PyYAML>=6.0` (cf. `requirements-dev.txt`). Compatible macOS/Linux, aucune dépendance réseau.

## 7. Budgets et gates

| Catégorie       | Budget        | Mécanisme de contrôle                                            |
|-----------------|---------------|------------------------------------------------------------------|
| Images totales  | ≤ 10 Mo       | `docs/ASSET_TRACKER.md` (généré) — manuel pour le moment         |
| Image unitaire  | ≤ 200 KB      | Revue art ; non vérifié automatiquement                          |
| BGM total       | 6–8 Mo        | `docs/ASSET_TRACKER.md`                                          |
| BGM unitaire    | ≤ 600 KB      | Revue audio                                                      |
| SFX total       | ≤ 1 Mo        | `docs/ASSET_TRACKER.md`                                          |
| SFX unitaire    | ≤ 60 KB       | Revue audio                                                      |
| Mémoire audio   | < 20 Mo       | `AudioController` (preload/déchargement) — vérification S4       |
| Cache image     | 64–96 Mo      | `ImageCache.maximumSizeBytes` à régler en S4                     |
| Bundle Android  | < 30 Mo       | DoD S4 (à valider par `flutter build apk --release --analyze-size`) |
