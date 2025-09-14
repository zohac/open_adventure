# Exécution S1 — Scaffolding, Data mappers, AdventureRepository, initialGame, smoke tests

Statut: exécutable immédiatement. Durée cible: 1 semaine (5 j/h).

Definition of Ready (DoR)

- Environnement prêt: Dart ≥ 3.x, Flutter stable 3.x installés; `flutter doctor` OK.
- Données présentes: `assets/data/*.json` existants; `open-adventure-master/adventure.yaml` accessible.
- Outils prêts: scripts `scripts/make_dungeon.py`, `scripts/extract_c.py`, `scripts/validate_json.py` exécutables localement.
- Legacy isolable: accord d’archiver `lib/features/**` et de conserver `lib/(domain|application|data|presentation|core)`.

Objectif S1

- Mettre à plat l’arborescence Clean Architecture, brancher tous les assets JSON, écrire les mappers robustes, exposer `AdventureRepository` et livrer `initialGame()` avec des smoke tests verts. Aucune logique de tour/commande en S1.

Livrables

- Arborescence `lib/` conforme à la spec (domain/application/data/presentation/core) avec fichiers squelettes minimaux.
- Mappers Data ↔ Entities pour: `locations.json`, `objects.json`, `travel.json` (si utilisé), `actions.json`, `motions.json`, `hints.json`, `conditions.json`, `turn_thresholds.json`, `classes.json`, `arbitrary_messages.json`, `obituaries.json`.
- `AdventureRepository` (Domain, interfaces) + implémentation Data « lecture assets ». Pas de dépendance à `game.json`.
- `initialGame()` qui construit un état minimal cohérent (lieu de départ, inventaire vide, flags init). Seed RNG figé pour les tests.
- `pubspec.yaml` mis à jour avec TOUTES les entrées d’assets.
- Tests « smoke » Data/Repository (chargement, mapping, invariants). CI/analyze verts.

Pré‑requis & outillage

- Flutter stable ≥ 3.x, Dart ≥ 3.x, lint stricte (voir `analysis_options.yaml`).
- Données: `assets/data/*.json` (présents), `open-adventure-master/adventure.yaml` comme référence de cohérence.

Dépendances S1 (pubspec)

- Production: `equatable`, `collection`, `yaml`.
- Dev/test: `flutter_test`, `test`, `coverage`, `flutter_lints`.

Arborescence cible (rappel)

```bash
lib/
  domain/{entities,value_objects,repositories,usecases}
  application/{controllers,routing}
  data/{datasources,models,repositories}
  presentation/{pages,widgets}
  core/{utils,di}
```

Modifs de configuration (pubspec.yaml)

```bash
flutter:
  uses-material-design: true
  assets:
    - assets/data/locations.json
    - assets/data/objects.json
    - assets/data/travel.json
    - assets/data/tkey.json
    - assets/data/motions.json
    - assets/data/actions.json
    - assets/data/conditions.json
    - assets/data/hints.json
    - assets/data/obituaries.json
    - assets/data/classes.json
    - assets/data/arbitrary_messages.json
    - assets/data/turn_thresholds.json
```

Contrats Domain (S1)

```bash
abstract class AdventureRepository {
  Future<Game> initialGame();
  Future<List<Location>> getLocations();
  Future<List<GameObject>> getGameObjects();
  // Optionnel S1: hints, motions, actions (lecture brute)
}
```

Règles de mapping (normatif)

- `locations.json`: entrée = `[String name, Map data]`. Le mapper reconstruit:
  - `Location { id:int(auto), name, mapTag?, shortDescription?, longDescription?, sound, loud, conditions:Map<String,bool>, travel:List<TravelRule> }`.
  - Cas edge: champs absents → valeurs par défaut sûres (ex: `sound=Sound.silent`, `conditions={}`).
- `objects.json`: entrée = `[String name, Map data]` → `GameObject` avec
  - `locations` peut être `String` ou `List<String>` → normaliser en `List<String>`.
  - `states|descriptions|sounds|changes`: facultatifs → null si vides.
- `travel.json`/`tkey.json`: si utilisé en S1, faire un mapper Data → `List<TravelRule>` groupées par `LocationId`; S1 peut s’appuyer uniquement sur `travel` embarqué dans `locations.json` si présent.
- `actions.json`, `motions.json`, `conditions.json`: lecture brute (types de base), sans logique métier.

initialGame() (règles S1)

- Source de vérité: assets JSON. Interdiction d’accéder à un `game.json`.
- Stratégie de démarrage:
  - Choix du lieu de départ: si `assets/data/metadata.json` existe avec `start_location` (name) ou `start_location_id` (int), l’utiliser. Sinon, fallback: première entrée de `locations.json`.
  - `Game` initial: position = start, inventaire vide, timers au défaut (voir entité `Game`), RNG seedé `seed=42`.
  - Pas d’entités dynamiques (nains, pirate) initialisées au-delà des valeurs par défaut.

Implémentations S1 (fichiers impactés)

- Isoler le legacy: déplacer/mettre en quarantaine le code existant de `lib/` vers `lib_legacy/` (ou le laisser en place mais supprimer toute importation). Aucun fichier sous `lib/features/...` n’est modifié ni importé.
- Créer de zéro la data layer sous les nouveaux chemins:
  - `lib/data/datasources/asset_data_source.dart` (loadList/loadMap + validation légère).
  - `lib/data/models/location_model.dart`, `lib/data/models/game_object_model.dart`, `lib/data/models/travel_rule_model.dart`, `lib/data/models/action_model.dart`, `lib/data/models/condition_model.dart`.
  - `lib/data/repositories/adventure_repository_impl.dart` (lecture assets + caches + index name↔id).
- Créer les interfaces Domain neuves sous:
  - `lib/domain/repositories/adventure_repository.dart`.
  - `lib/domain/entities/*` nécessaires au chargement initial (`Location`, `GameObject`, etc.).
- Mettre à jour `pubspec.yaml` pour déclarer tous les assets et s’assurer qu’aucun code n’importe `lib_legacy/`.

Important — politique d’archivage du legacy

- On archive uniquement le code PRÉ‑EXISTANT avant S1 (principalement `lib/features/**`).
- On ne déplace PAS les nouveaux fichiers et l’arborescence créée en S1:
  - `lib/domain/**`, `lib/application/**`, `lib/data/**`, `lib/presentation/**`, `lib/core/**`.
  - En particulier, conserver: `lib/presentation/widgets/pixel_canvas.dart`, `lib/presentation/widgets/location_image.dart`, `lib/core/utils/location_image.dart`.
- Appliquer une allowlist lors du déplacement: tout ce qui n’est pas dans `lib/(domain|application|data|presentation|core)/**` est candidat à l’archive en `lib_legacy/`.

Exemples de signatures (Data)

```dart
abstract class AssetDataSource {
  Future<List<dynamic>> loadList(String assetPath);
  Future<Map<String, dynamic>> loadMap(String assetPath);
}

class AdventureLocalDataSourceImpl implements AssetDataSource {
  final AssetBundle bundle;
  AdventureLocalDataSourceImpl({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;
  @override Future<List> loadList(String p) async => json.decode(await bundle.loadString(p));
  @override Future<Map<String,dynamic>> loadMap(String p) async => json.decode(await bundle.loadString(p));
}
```

Correction — LocationModel (extrait)

```dart
class LocationModel extends Location {
  factory LocationModel.fromJson(Map<String, dynamic> json, int id) {
    final desc = (json['description'] as Map<String, dynamic>?) ?? const {};
    final sound = SoundModel.fromString(json['sound']);
    final travel = ((json['travel'] as List?) ?? [])
      .map((e) => TravelRuleModel.fromJson(Map<String, dynamic>.from(e))).toList();
    return LocationModel(
      id: id,
      name: json['name'] ?? 'Unknown',
      mapTag: desc['maptag'],
      shortDescription: desc['short'],
      longDescription: desc['long'],
      sound: sound,
      loud: json['loud'] ?? false,
      conditions: Map<String, bool>.from(json['conditions'] ?? {}),
      travel: travel,
    );
  }
}
```

Plan de travail S1 (ordonnancement)

1) Config: mise à jour `pubspec.yaml` (assets) + `flutter pub get`.
2) Data layer: `AssetDataSource`, mappers `LocationModel`, `GameObjectModel` (vérifier nullabilité), loaders utilitaires.
3) Repositories: `AdventureRepository` (Domain) + impl Data (lecture assets).
4) `initialGame()`: builder d’état minimal + RNG seedé.
5) Tests smoke Data/Repo + `flutter analyze` sans warnings.

Tests & validations (S1)

- Data
  - Charger `assets/data/locations.json` → type `List`, taille > 0, chaque entrée mappée en `Location` avec `id` croissant.
  - Charger `assets/data/objects.json` → `List<GameObject>`; vérifier normalisation `locations: List<String>`.
- Repository
  - `AdventureRepository.getLocations()` retourne N = taille JSON.
  - `AdventureRepository.getGameObjects()` retourne M = taille JSON.
- initialGame
  - `initialGame()` positionne un `loc` valide (existe dans la liste), inventaire vide, timers au défaut.
- Perf
  - Parsing total des assets < 300ms sur machine de dev (mesure approximative), non bloquant sur l’UI (Isolate si > 1 Mo cumulé).

Definition of Done (S1)

- `flutter analyze` sans warnings bloquants.
- Tests S1 verts (Data/Repo/initialGame smoke). Couverture Data ≥ 70% mini.
- Aucune référence résiduelle à `assets/data/game.json`.
- Documentation courte intégrée dans `docs/` (ce fichier) + commentaires docstrings dans mappers.

Risques & mitigations (S1)

- Divergences de schémas JSON: ajouter un validateur léger (clé obligatoire, types) et échouer bruyamment en dev.
- Coût de parsing: basculer la lecture/parse lourde en Isolate; lazy load pour jeux de données non critiques S1.
- Incohérence d’ID: générer `id` séquentiels à partir de l’index, et fournir un utilitaire de lookup par `name`.

- Suivi & tickets

- [ ] ADVT‑S1‑00: Mettre à niveau l’environnement — Dart SDK ≥ 3.x, Flutter stable ≥ 3.x; mise à jour deps/lockfile.
  - DoD:
    - [ ] `environment:` dans `pubspec.yaml` défini à `'>=3.0.0 <4.0.0'` ou supérieur compatible.
    - [ ] `flutter --version` documenté; `flutter pub get` et `flutter analyze` passent.
    - [ ] CI locale exécute tests avec la nouvelle toolchain.
- [ ] ADVT‑S1‑01: Isoler le legacy — mettre tout le code existant de `lib/` hors du chemin (ex: `lib_legacy/`) et purger toutes dépendances (incl. `GameLocalDataSource`, `assets/data/game.json`).
  - DoD:
    - [ ] Aucun import de `lib_legacy/` ni de `lib/features/...` dans le nouveau code.
    - [ ] Aucune occurrence de `game.json` ni de `GameLocalDataSource.*` dans le projet actif.
    - [ ] `flutter analyze` passe; l’app démarre sans référencer d’assets inexistants.
    - [ ] Les répertoires allowlist `lib/domain|application|data|presentation|core` et fichiers `pixel_canvas.dart`, `location_image.dart` (widget) et `location_image.dart` (utils) RESTENT sous `lib/`.
- [ ] ADVT‑S1‑02: Mettre à jour `pubspec.yaml` avec l’intégralité des assets `assets/data/*.json` + vérification via test existant.
  - DoD:
    - [ ] Tous les chemins listés dans `assets/` présents et chargés par `flutter pub get` sans erreur.
    - [ ] Test d’existence des assets vert (test/core/constants/asset_paths_test.dart).
- [ ] ADVT‑S1‑03: Scaffolding arborescence Clean Architecture (`lib/domain|application|data|presentation|core`) + fichiers squelettes.
  - DoD:
    - [ ] Dossiers créés; fichiers d’index/squelettes présents; imports compilent.
    - [ ] `flutter analyze` zéro warning structurel (imports, unused files tolérés avec ignore localisé si nécessaire).
- [ ] ADVT‑S1‑04: Implémenter `AssetDataSource` (loadList/loadMap) + helper de validation JSON (clés requises, types).
  - DoD:
    - [ ] Deux méthodes opérationnelles, docstrings présentes, exceptions claires en cas d’échec.
    - [ ] Tests: charge une liste et une map; cas d’erreur format → lève une exception dédiée.
- [ ] ADVT‑S1‑05: Créer `LocationModel.fromJson(Map,int)` (nouveau fichier) + `AssetDataSource.getLocations()` pour fournir un `Map` par entrée.
  - DoD:
    - [ ] `LocationModel.fromJson` accepte un `Map` et renseigne toutes les propriétés attendues.
    - [ ] `AssetDataSource` lit `assets/data/locations.json` et retourne une `List` mappable; tests verts sur 3 échantillons.
- [ ] ADVT‑S1‑06: Créer `GameObjectModel.fromJson` (nouveau fichier) — normaliser `locations`, champs optionnels → null si vides.
  - DoD:
    - [ ] Gestion `locations` string|list validée; `states/descriptions/sounds/changes` null si vides.
    - [ ] Tests de round‑trip `toEntity`/`toJson` sur un objet complexe.
- [ ] ADVT‑S1‑07: Créer `ActionModel`, `ConditionModel`, `TravelRuleModel` (lecture depuis `locations.json` et/ou `travel.json`).
  - DoD:
    - [ ] Parsing des structures JSON supporté, incluant présence/absence de conditions.
    - [ ] Tests de parsing sur échantillons réels (assets/data/*) et cas limites (champs manquants).
- [ ] ADVT‑S1‑08: Créer `AdventureRepository` (Domain) — interfaces: `initialGame()`, `getLocations()`, `getGameObjects()`, `locationById()`, `travelRulesFor(locationId)`.
  - DoD:
    - [ ] Interface publiée et utilisée par au moins un use case; pas de dépendance inversée (Data → Domain seulement).
- [ ] ADVT‑S1‑09: Implémenter `AdventureRepositoryImpl` (Data) avec caches mémoire et index `name↔id` pour lieux/objets.
  - DoD:
    - [ ] Réutilisation des données entre appels; lookup O(1) par id/name; tests de perfs unitaires (< 5 ms/lookup sur dev).
    - [ ] Gestion d’erreurs: renvoie une Failure typed en cas d’asset manquant/corrompu.
- [ ] ADVT‑S1‑10: Utilitaires `LookupService` (résolution id/name, vérifs d’existence) — pur Dart.
  - DoD:
    - [ ] `idFromName`/`nameFromId` pour `Location` et `GameObject`; tests succès/échec (`NotFound`).
- [ ] ADVT‑S1‑11: Implémenter `initialGame()` (builder d’état minimal, RNG seedée 42, start loc depuis `metadata.json` sinon fallback).
  - DoD:
    - [ ] `Game` initial avec `loc` valide, `turns=0`, inventaire vide; seed stockée.
    - [ ] Test: si `metadata.json` absent → utilise première entrée de `locations.json`.
- [ ] ADVT‑S1‑12: Tests Data — `locations.json` (mapping complet, id séquentiels, valeurs par défaut) + `objects.json` (normalisations).
  - DoD:
    - [ ] ≥ 8 tests Data verts; couverture Data ≥ 70%.
- [ ] ADVT‑S1‑13: Tests Repository — `getLocations`, `getGameObjects`, `locationById`, `travelRulesFor` (si disponible), cas d’erreurs lecture.
  - DoD:
    - [ ] Tous les chemins heureux et erreurs couverts; aucun accès disque dans Domain.
- [ ] ADVT‑S1‑14: Test `initialGame()` — loc valide, inventaire vide, timers par défaut, seed déterministe.
  - DoD:
    - [ ] Test dédié vérifiant seed=42; `loc` ∈ set des ids; timers par défaut conformes à l’entité.
- [ ] ADVT‑S1‑15: Lint/Analyze — corriger tous les warnings, activer règles de null‑safety et ordre d’imports.
  - DoD:
    - [ ] `flutter analyze` sans warnings; CI locale verte.
- [ ] ADVT‑S1‑16: Préparer option Isolate pour parsing si taille cumulée > 1 Mo (feature flag, non activée par défaut S1).
  - DoD:
    - [ ] Flag exposé (`Settings`/const); branche utilisant `compute()` couverte par test unitaire qui vérifie l’appel.
- [ ] ADVT‑S1‑17: Documentation — compléter ce doc + README (setup assets, architecture) + docstrings sur mappers.
  - DoD:
    - [ ] `README.md` mis à jour; docstrings présentes sur `AssetDataSource` et modèles; ce fichier reflète l’état livré.
- [ ] ADVT‑S1‑18: Nettoyage `assets/` et scripts — supprimer doublons (YAML/C) et déplacer scripts Python vers `scripts/`.
  - DoD:
    - [ ] Supprimés: `assets/adventure.yaml`, `assets/make_dungeon.py`, `assets/extract_c.py`, `assets/travel_c.c`, `assets/tkey_c.c`;
    - [ ] Créé: `scripts/validate_json.py` (chemins robustes vers `open-adventure-master/adventure.yaml` et `assets/data/`);
    - [ ] Docs mises à jour pour référencer `scripts/validate_json.py` (CONVERSION_SPEC/EXEC_S4);
    - [ ] Lancement local `python3 scripts/validate_json.py` documenté (facultatif) et passe sur jeux de données actuels.
- [ ] ADVT‑S1‑19: Revue technique des scripts de génération (scripts/make_dungeon.py, scripts/extract_c.py, scripts/validate_json.py).
  - DoD:
    - [ ] Lecture du code revue (paths relatifs, messages d’erreur explicites, exit codes 0/1 corrects);
    - [ ] Entrées/sorties documentées en tête de fichier; compatibilité macOS/Linux vérifiée;
    - [ ] Pas de dépendance réseau; dépendances Python listées (PyYAML).
- [ ] ADVT‑S1‑20: Tests d’intégration des scripts — génération/validation des assets.
  - DoD:
    - [ ] `python3 scripts/make_dungeon.py --out assets/data` génère `travel.json` et `tkey.json` sans erreur en < 3 s sur machine dev;
    - [ ] `python3 scripts/extract_c.py --out assets/data` génère `travel_c.json` et `tkey_c.json` sans erreur;
    - [ ] `python3 scripts/validate_json.py` retourne exit code 0 (ou loggue clairement les divergences si attendues) ;
    - [ ] Les fichiers générés existent et sont valides JSON (jq or python json load dans le test).
- [ ] ADVT‑S1‑21: Script d’orchestration « update-assets » (facultatif mais recommandé).
  - DoD:
    - [ ] Une seule commande séquentielle exécute: make_dungeon → extract_c → validate;
    - [ ] Documentation dans README (section « Mise à jour des assets à partir de l’amont »);
    - [ ] Ignorer en CI mobile par défaut (usage dev/mainteneur seulement).

Références C (source canonique)

- open-adventure-master/adventure.yaml
- open-adventure-master/make_dungeon.py
- open-adventure-master/advent.h
- open-adventure-master/init.c
- open-adventure-master/README.adoc
- open-adventure-master/INSTALL.adoc
- open-adventure-master/tests/ (oracles data et cohérence; à consulter pour cas limites)
