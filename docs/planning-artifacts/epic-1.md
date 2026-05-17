# Sprint 1 — Scaffolding, Data layer, AdventureRepository, initialGame

> **Source canonique des DoD détaillés** : [`docs/EXEC_S1.md`](../EXEC_S1.md) (Suivi & tickets ADVT‑S1‑00 → ADVT‑S1‑23).
> Cet epic est une **vue BMad** dérivée de l'EXEC ; en cas de divergence, EXEC_S1 prime.

## Epic 1: Sprint 1 — Scaffolding & Data layer

**Status:** done
**Goal:** Mettre à plat l'arborescence Clean Architecture, brancher tous les assets JSON, écrire les mappers robustes, exposer `AdventureRepository` et livrer `initialGame()` avec smoke tests verts.
**Acceptance:** `flutter analyze` zéro warning, tests Data/Repo/initialGame verts, couverture Data ≥ 70 %, aucune référence à `assets/data/game.json`.

### Story 1.1: Mettre à niveau l'environnement Dart/Flutter
**Status:** done
**Source ticket:** ADVT‑S1‑00
**Goal:** Dart SDK ≥ 3.x, Flutter stable ≥ 3.x ; deps/lockfile à jour ; `flutter pub get` & `flutter analyze` verts.

### Story 1.2: Isoler le legacy hors de lib/
**Status:** done
**Source ticket:** ADVT‑S1‑01
**Goal:** Aucun import de `lib_legacy/` ni `lib/features/...` ; aucune occurrence de `game.json` ou `GameLocalDataSource` dans le code actif ; conserver `pixel_canvas.dart` et `location_image.dart`.

### Story 1.3: Déclarer assets/data/*.json dans pubspec.yaml
**Status:** done
**Source ticket:** ADVT‑S1‑02
**Goal:** Tous les chemins assets/data présents et chargés par `flutter pub get` sans erreur ; test d'existence vert.

### Story 1.4: Scaffolding arborescence Clean Architecture
**Status:** done
**Source ticket:** ADVT‑S1‑03
**Goal:** Dossiers `lib/domain|application|data|presentation|core` créés ; squelettes présents ; imports compilent ; `flutter analyze` propre.

### Story 1.5: Implémenter AssetDataSource (loadList/loadMap + validation)
**Status:** done
**Source ticket:** ADVT‑S1‑04
**Goal:** API `loadList`/`loadMap` opérationnelle ; docstrings ; exceptions claires en cas d'échec format.

### Story 1.6: LocationModel.fromJson + AssetDataSource.getLocations()
**Status:** done
**Source ticket:** ADVT‑S1‑05
**Goal:** `LocationModel.fromJson(Map, int)` accepte un Map ; `getLocations()` retourne une List mappable ; tests sur 3 échantillons.

### Story 1.7: GameObjectModel.fromJson avec normalisation locations
**Status:** done
**Source ticket:** ADVT‑S1‑06
**Goal:** Locations string|list normalisée en List<String> ; champs optionnels null si vides ; round-trip `toEntity`/`toJson` testé.

### Story 1.8: ActionModel / ConditionModel / TravelRuleModel
**Status:** done
**Source ticket:** ADVT‑S1‑07
**Goal:** Parsing structures supportant présence/absence de conditions ; tests sur échantillons réels.

### Story 1.9: AdventureRepository (interfaces Domain)
**Status:** done
**Source ticket:** ADVT‑S1‑08
**Goal:** Interface `initialGame()`, `getLocations()`, `getGameObjects()`, `locationById()`, `travelRulesFor()` ; utilisée par ≥ 1 use case ; pas de dépendance inversée.

### Story 1.10: AdventureRepositoryImpl avec caches et index name↔id
**Status:** done
**Source ticket:** ADVT‑S1‑09
**Goal:** Cache mémoire ; lookup O(1) par id/name ; Failure typé en cas d'asset manquant/corrompu ; perf < 5 ms/lookup en dev.

### Story 1.11: LookupService (idFromName/nameFromId)
**Status:** done
**Source ticket:** ADVT‑S1‑10
**Goal:** Résolution Location et GameObject ; tests succès/échec (`NotFound`).

### Story 1.12: initialGame() builder avec RNG seedée 42
**Status:** done
**Source ticket:** ADVT‑S1‑11
**Goal:** `Game` initial avec `loc` valide depuis `metadata.json` (fallback première entrée) ; `turns=0` ; seed stockée ; tests dédiés.

### Story 1.13: Tests Data — locations.json + objects.json
**Status:** done
**Source ticket:** ADVT‑S1‑12
**Goal:** ≥ 8 tests Data verts ; couverture Data ≥ 70 % ciblée.

### Story 1.14: Tests Repository (chemins heureux + erreurs)
**Status:** done
**Source ticket:** ADVT‑S1‑13
**Goal:** `getLocations`, `getGameObjects`, `locationById`, `travelRulesFor`, cas d'erreurs lecture couverts ; aucun accès disque dans Domain.

### Story 1.15: Tests initialGame() (loc valide, seed=42, timers défaut)
**Status:** done
**Source ticket:** ADVT‑S1‑14
**Goal:** Test dédié vérifiant seed=42 ; `loc ∈ set des ids` ; `turns=0`.

### Story 1.16: Lint/Analyze — null-safety + ordre imports
**Status:** done
**Source ticket:** ADVT‑S1‑15
**Goal:** `flutter analyze` zéro warning ; tests unitaires ciblés verts.

### Story 1.17: Feature flag parsing Isolate (> 1 Mo)
**Status:** done
**Source ticket:** ADVT‑S1‑16
**Goal:** `Settings.parseUseIsolate` + `parseIsolateThresholdBytes` exposés ; branche `compute()` testée via executor espion.

### Story 1.18: Documentation README + docstrings mappers
**Status:** done
**Source ticket:** ADVT‑S1‑17
**Goal:** README mis à jour (setup, archi, flags, commandes) ; docstrings sur `AssetDataSource` et modèles.

### Story 1.19: Nettoyage assets/ et déplacement scripts Python
**Status:** done
**Source ticket:** ADVT‑S1‑18
**Goal:** `scripts/validate_json.py` créé avec chemins robustes ; docs mises à jour pour le référencer.

### Story 1.20: Revue technique scripts make_dungeon/extract_c/validate_json
**Status:** done
**Source ticket:** ADVT‑S1‑19
**Goal:** Paths robustes ; exit codes 0/1 corrects ; entrées/sorties documentées ; compat macOS/Linux ; deps Python listées.

### Story 1.21: Tests d'intégration des scripts (génération/validation)
**Status:** done
**Source ticket:** ADVT‑S1‑20
**Goal:** `make_dungeon.py` génère travel/tkey sans erreur ; `extract_c.py` génère validation files ; `validate_json.py` exit 0/1 selon cohérence.

### Story 1.22: Script d'orchestration update-assets
**Status:** done
**Source ticket:** ADVT‑S1‑21
**Goal:** `scripts/update_assets.py` séquence make_dungeon → extract_c → validate ; documenté dans README ; usage dev/mainteneur.

### Story 1.23: Générateur Asset Tracker (Markdown)
**Status:** done
**Source ticket:** ADVT‑S1‑22
**Goal:** `scripts/generate_asset_tracker.py` lit assets et produit `docs/ASSET_TRACKER.md` ; 3 tableaux + budgets ; exit code 0.

### Story 1.24: Générateur Asset Manifest (source IA)
**Status:** done
**Source ticket:** ADVT‑S1‑23
**Goal:** `scripts/generate_asset_manifest.py` parse assets et produit `docs/ASSET_MANIFEST.json` (idempotent, n'écrit jamais sous assets/) ; consommé par asset_tracker.
