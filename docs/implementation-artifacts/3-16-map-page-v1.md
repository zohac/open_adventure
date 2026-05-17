# Story 3.16: MapPage v1 — Atlas topologique multi-couches

Status: ready-for-dev
Epic: 3 (Interactions, Inventaire, Nains, Lampe, Scoring, Map, Journal, Images, Audio)
Source ticket: ADVT‑S3‑16 (`docs/EXEC_S3.md`)
Specs sources : [`docs/Cahier_des_charges_Map.md`](../Cahier_des_charges_Map.md) (normatif), [`docs/CTO_DEV_MAP_REQUEST.md`](../CTO_DEV_MAP_REQUEST.md)

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

**En tant que** joueur d'open_adventure sur mobile,
**je veux** consulter une **carte topologique multi-couches** affichant uniquement les lieux et chemins que j'ai déjà visités, avec un repère « vous êtes ici » et une vue distincte par strate (Surface, Upper Cave, Hall of Mists, Labyrinthes & Rivière, Sanctuaire & Endgame),
**afin de** me repérer dans la caverne sans spoiler les énigmes, et avec une lisibilité tactile 16-bit fidèle à l'œuvre.

## Acceptance Criteria

> Format BDD ; chaque AC est numéroté et référencé par les Tasks ci-dessous.

1. **AC1 — Chargement du layout statique**
   *Given* l'app démarre,
   *When* `MapLayoutRepository.load()` est appelé,
   *Then* `assets/data/map_layout.json` est chargé une seule fois, parsé en `Map<LocationId, MapLayoutNode>` (avec `layer`, `position?`, `mapTag`, `clusterId?`, `isAmbiguous`, `anchorTag?`, `jitterSeed?`), avec cache mémoire et erreurs typées `DataFailure` en cas d'asset manquant/corrompu.

2. **AC2 — MapGraph sérialisable dans le Domain**
   *Given* l'état de jeu actuel,
   *When* `GameController.perform(...)` se termine avec changement de lieu,
   *Then* le `MapGraph` exposé par `GameViewState` :
   - marque `nodes[newLoc].visited = true` ;
   - ajoute l'arête `(currentLoc → newLoc)` avec `discovered = true` et `kind ∈ {normal, magic, vertical}` (`magic` si la motion appartient à `MagicWords`, `vertical` si la motion canonique ∈ `{UP, DOWN}`, sinon `normal`) ;
   - met à jour `currentLocationId = newLoc` ;
   - rajoute `newLoc` à `recentTrail` (buffer circulaire 5–7 derniers, par défaut 6) ;
   - ajoute `layer(newLoc)` à `visitedLayers` si absent ;
   - conserve `schemaVersion = 1`.

3. **AC3 — Persistance MapGraph (autosave + slots)**
   *Given* un tour est terminé avec mutation,
   *When* `SaveRepository.autosave(snapshot)` est appelé,
   *Then* `MapGraph` est inclus dans le `GameSnapshot` JSON ; à la relance, `latest()` reconstruit le `MapGraph` à l'identique (round-trip strict, tolérance aux champs inconnus, fallback sain si schema_version inconnue).

4. **AC4 — Rendu lecture seule via CustomPainter dans PixelCanvas**
   *Given* l'utilisateur ouvre la MapPage,
   *When* la page est buildée,
   *Then* le rendu se fait dans un `PixelCanvas` (canvas logique 320×180, scale entier, `FilterQuality.none`) via un `MapPainter` personnalisé ; **aucune mutation** du `MapGraph` n'est déclenchée par la page (lecture seule absolue).

5. **AC5 — Sélecteur de couche (chips Material 3)**
   *Given* l'utilisateur est sur la MapPage,
   *When* la page s'ouvre,
   *Then* un `Chip` row (M3) en haut de page liste les 5 couches dans l'ordre `surface → upper_cave → hall_of_mists → labyrinths_river → sanctuary_endgame`, avec la couche du lieu courant pré-sélectionnée et labels via clés ARB `map.layer.<key>`. Les couches non encore visitées (`visitedLayers` ne les contient pas) sont visibles mais grisées et désactivées au tap.

6. **AC6 — Badge « Vous êtes ici » avec pulse 800 ms**
   *Given* le `MapGraph.currentLocationId` est dans la couche affichée,
   *When* la page rend,
   *Then* une pastille « vous êtes ici » apparaît à la position du lieu, avec un pulse discret de **800 ms** (alpha ou scale, sans changer le pixel art). Dans un cluster (FOREST/MAZE_*), la position est décalée de `±8 px` selon `jitterSeed(locationId)` — déterministe : même salle → même décalage.

7. **AC7 — Blob FOREST + ancres révélées + breadcrumb**
   *Given* la couche `surface` est affichée et le joueur a visité ≥ 1 nœud `FOREST`,
   *When* la page rend,
   *Then* un blob unique (image WebP ≤ 200 KB, tons verts/ocres) est dessiné pour le cluster FOREST ; **aucun nœud interne** n'est rendu individuellement ; les ancres visibles autour du blob (`VALLEY`, `HILL`, `ROADEND`, `GRATE`, `SLIT`, `CLIFF`, `BUILDING`, `START`) ne sont peintes **que si `nodes[anchorId].visited == true`** ; un **breadcrumb** des 5–7 derniers positions de `recentTrail` est tracé dans le blob avec alpha 60 % → 15 %.

8. **AC8 — Arêtes parcourues vs magiques/verticales**
   *Given* le `MapGraph` contient des arêtes découvertes,
   *When* la couche est affichée,
   *Then* :
   - les arêtes `kind=normal` et `discovered=true` sont tracées en **trait plein** (couleur cohérente avec le thème) ;
   - les arêtes `kind=magic` ou `kind=vertical` et `discovered=true` sont tracées en **pointillés colorés** (couleurs distinctes pour magic vs vertical) ;
   - aucune arête `discovered=false` n'est tracée (DDR-001 Option A : zéro spoil).

9. **AC9 — Zoom & pan légers, lecture seule**
   *Given* l'utilisateur interagit avec la MapPage,
   *When* il pince/drag,
   *Then* zoom limité ∈ **[×0,75 ; ×1,5]** et pan léger autorisés sans muter le `MapGraph` (aucun appel à `controller.perform` ni écriture).

10. **AC10 — Accessibilité AA**
    *Given* un lecteur d'écran est actif,
    *When* la MapPage est focus,
    *Then* :
    - chaque ancre visible expose un `Semantics(label: ...)` localisé (`map.anchor.<TAG>` + état "explorée"/"sortie connue") ;
    - les chips de couche ont labels semantics et taille cible ≥ **48 dp** ;
    - contrastes texte/fond ≥ AA dans les deux thèmes (clair/sombre) ;
    - aucun élément interactif < 48 dp.

11. **AC11 — Frame budget < 16 ms**
    *Given* la MapPage est ouverte,
    *When* l'utilisateur change de couche ou zoome,
    *Then* aucun rebuild ne dépasse **16 ms** sur les golden devices (Samsung Tab A8 2019, POCO F4), mesuré via DevTools Timeline.

12. **AC12 — Observabilité dev**
    *Given* l'app tourne en mode debug,
    *When* la MapPage rend,
    *Then* `debugPrint` (ou logger équivalent silencé en release) émet `MapPage: layer=<key> nodes=<n> edges=<n> (visible)` à chaque build couche.

13. **AC13 — Golden tests + sérialisation**
    *Given* les tests `flutter test --update-goldens` sont exécutés,
    *When* on lance la suite,
    *Then* :
    - 5 goldens (1 par couche) sont stables avec une fixture `map_layout.json` + un `MapGraph` ex. fixé.
    - 1 widget test FOREST avec `recentTrail` non vide + GRATE découverte → blob + breadcrumb + trait plein vers GRATE.
    - 1 widget test : apparition d'un pointillé `kind=magic` **après** que `MapGraph` enregistre l'arête comme `discovered=true`.
    - 1 test sérialisation round-trip `MapGraph` (incluant `recentTrail` et `visitedLayers`).
    - 1 test chips sélecteur : sélection correcte + désactivation des couches non visitées + accessibilité.

14. **AC14 — Navigation depuis HomePage et AdventurePage**
    *Given* l'utilisateur est sur la HomePage (ou AdventurePage avec onglet Carte futur),
    *When* il sélectionne « Carte »,
    *Then* la MapPage s'ouvre via `Navigator.push` en `MaterialPageRoute`, avec le `GameController` injecté par constructeur. Une action `meta:map` existait déjà côté `ListAvailableActions` ; l'UI doit maintenant la router vers `MapPage` au lieu de la traiter comme no-op (cf. `GameController.perform` cas `verb == 'MAP'` qui ne fait rien actuellement — déléguer au widget appelant).

15. **AC15 — Génération assets pipeline**
    *Given* le script `scripts/generate_map_layout.py` existe (déjà livré, lit `docs/map_layout_plan.yaml` et `assets/data/locations.json`),
    *When* on lance `python3 scripts/generate_map_layout.py`,
    *Then* `assets/data/map_layout.json` est produit, déterministe, et déclaré dans `pubspec.yaml`. Le script est intégré à `scripts/update_assets.py` (ajout d'une étape optionnelle ou documentation explicite dans README).

16. **AC16 — i18n complète**
    *Given* la MapPage est rendue,
    *When* on alterne FR/EN,
    *Then* tous les labels (titre, chips, ancres, semantics) viennent de clés ARB (`map.title`, `map.layer.<key>`, `map.anchor.<TAG>`, `map.legend.*`). **Aucune** chaîne brute dans la presentation.

## Tasks / Subtasks

- [ ] **Task 1 — Générer `assets/data/map_layout.json` + déclaration pubspec** (AC: #1, #15)
  - [ ] Exécuter `python3 scripts/generate_map_layout.py` ; vérifier déterminisme.
  - [ ] Ajouter la ligne `- assets/data/map_layout.json` dans `pubspec.yaml` (section `flutter.assets`).
  - [ ] Mettre à jour `scripts/update_assets.py` pour appeler `generate_map_layout.py` après `validate_json.py` (étape facultative ; documenter dans README).
  - [ ] Vérifier que tous les 175+ `LOC_*` de `locations.json` sont couverts par le plan YAML (le script échoue sinon).

- [ ] **Task 2 — Domain : entité `MapGraph` + VO `MapLayoutNode`** (AC: #2, #3, #13)
  - [ ] Créer `lib/domain/entities/map_graph.dart` :
    - `class MapGraph { final Map<int, MapNodeState> nodes; final List<MapEdge> edges; final int currentLocationId; final Set<String> visitedLayers; final List<int> recentTrail; final int schemaVersion; }`
    - `class MapNodeState { final bool visited; final String layer; final String? clusterId; final String? anchorTag; }`
    - `class MapEdge { final int from; final int to; final MapEdgeKind kind; final bool discovered; }`
    - `enum MapEdgeKind { normal, magic, vertical }`
    - Égalité valeur via `SetEquality`/`MapEquality`/`ListEquality` (`package:collection`).
    - `copyWith` + `factory MapGraph.empty(int startLocationId, String startLayer)`.
    - `Map<String, dynamic> toJson()` / `factory MapGraph.fromJson(Map<String, dynamic>)`.
  - [ ] Créer `lib/domain/value_objects/map_layout_node.dart` :
    - `class MapLayoutNode { final int locationId; final String layer; final (double, double)? position; final String mapTag; final String? clusterId; final bool isAmbiguous; final String? anchorTag; final String? jitterSeed; }`
    - Tests de construction + égalité dans `test/domain/entities/map_graph_test.dart` (≥ 8 cas dont round-trip JSON, empty, copyWith partiel, edge kind detection).

- [ ] **Task 3 — Domain : ports `MapLayoutRepository`** (AC: #1)
  - [ ] Créer `lib/domain/repositories/map_layout_repository.dart` :
    - `abstract class MapLayoutRepository { Future<Map<int, MapLayoutNode>> load(); String layerOf(int locationId); }` (layerOf peut être un helper sur le cache).
  - [ ] Tests dans `test/domain/repositories/` non requis (interface).

- [ ] **Task 4 — Data : `MapLayoutRepositoryImpl` + model** (AC: #1, #13)
  - [ ] Créer `lib/data/models/map_layout_node_model.dart` (factory `fromJson(Map<String, dynamic>, int id)`).
  - [ ] Créer `lib/data/repositories/map_layout_repository_impl.dart` :
    - Lit `AssetPaths.mapLayoutJson` (constante à ajouter dans `lib/core/constant/asset_paths.dart`).
    - Cache mémoire `_cache` (lazy, premier appel chauffe).
    - Index `_locNameToId` via `AdventureRepository.getLocations()` pour résoudre `LOC_*` → id séquentiel.
    - Lance `DataFailure('Map layout missing or corrupt', cause: ...)` typé en cas d'erreur.
  - [ ] Tests `test/data/repositories/map_layout_repository_impl_test.dart` :
    - Chargement réussi sur asset réel ;
    - DataFailure si JSON mal formé (fixture invalide) ;
    - Lookup id↔name cohérent avec `AdventureRepository`.

- [ ] **Task 5 — Domain service : `MapGraphUpdater`** (AC: #2)
  - [ ] Créer `lib/domain/services/map_graph_updater.dart` :
    - `class MapGraphUpdater { Future<MapGraph> applyMove({required MapGraph current, required int newLoc, required String motion, required MapLayoutRepository layout}); }`
    - Logique :
      1. `kind = MagicWords.isIncantation(motion) ? magic : (motion ∈ {UP, DOWN} ? vertical : normal)`.
      2. Marquer `nodes[newLoc].visited = true` (créer l'entrée depuis `layout.load()` si absente).
      3. Ajouter/update `edges` : si arête `(currentLoc → newLoc)` existante avec même `kind`, marquer `discovered=true` ; sinon append.
      4. `currentLocationId = newLoc` ; ajouter `layer(newLoc)` à `visitedLayers` ; push `newLoc` dans `recentTrail` (cap 6, FIFO).
    - **Cas BACK** : `motion == 'BACK'` doit toujours marquer l'arête `discovered=true` (toujours `kind=normal`, jamais magic/vertical via BACK).
  - [ ] Tests `test/domain/services/map_graph_updater_test.dart` :
    - Normal forward (cardinal) ;
    - UP/DOWN → vertical ;
    - Incantation → magic ;
    - BACK → réutilise arête existante en discovered ;
    - recentTrail circulaire (cap 6, drop le plus ancien) ;
    - visitedLayers ne duplique pas une couche.

- [ ] **Task 6 — Étendre `Game` ou contexte controller pour porter `MapGraph`** (AC: #2)
  - [ ] **Décision recommandée** : exposer `MapGraph` dans `GameViewState` (Application) plutôt que dans `Game` (Domain). Raison : MapGraph est un projet **dérivé** de l'état + des assets de layout (pas une donnée canonique du jeu C). Garder `Game` minimal préserve la fidélité au `score.c`/`saveresume.c` upstream.
  - [ ] Si **finalement** placé dans `Game` : alors `Game` doit accueillir un `MapGraph mapGraph` avec valeur par défaut `MapGraph.empty(loc, layer)` ; mettre à jour `copyWith` + `==` + `hashCode`. Cette option duplique l'info `loc/currentLocationId` (à arbitrer).
  - [ ] Mettre à jour `GameViewState` : ajouter `final MapGraph mapGraph;` + initialiser dans `initial()` ; propager via `copyWith` ; égalité via `MapEquality`/`ListEquality`/`SetEquality`.
  - [ ] Mettre à jour `GameController.init()` : initialiser `mapGraph` via `MapGraphUpdater.bootstrap(layoutRepo, initialGame.loc)`.
  - [ ] Mettre à jour `GameController.perform(option)` : après autosave, appeler `MapGraphUpdater.applyMove(...)` si lieu a changé (else inchangé) ; injecter via constructeur (DI manuelle dans `main.dart`).

- [ ] **Task 7 — Persistance `MapGraph` dans `GameSnapshot`** (AC: #3, #13)
  - [ ] Étendre `lib/domain/value_objects/game_snapshot.dart` :
    - Ajouter `final MapGraph? mapGraph;` (nullable pour rétro-compat S2).
    - Bump `schema_version` à **2** (le `fromJson` lit V1 sans mapGraph → mapGraph=null, V2 avec).
    - `toJson()` sérialise `mapGraph` sous clé `map_graph` quand non null.
    - `fromJson(json)` tolère absence (V1) et parse via `MapGraph.fromJson` si présent.
  - [ ] Mettre à jour `SaveRepositoryImpl` : aucun changement (le snapshot porte déjà tout). Vérifier que `autosave` écrit V2 et que `latest()` lit V1 et V2.
  - [ ] Mettre à jour `GameController._toSnapshot(game)` → `_toSnapshot(game, mapGraph)`.
  - [ ] Tests `test/data/repositories/save_repository_impl_test.dart` (étendre) :
    - Round-trip V2 avec MapGraph ;
    - Lecture V1 (champ `map_graph` absent) → mapGraph=null sans crash ;
    - Round-trip avec `recentTrail` plein (6 éléments) et plusieurs `visitedLayers`.

- [ ] **Task 8 — Presentation : `MapPage` + `MapPainter`** (AC: #4, #5, #6, #7, #8, #9, #12, #14)
  - [ ] Créer `lib/presentation/pages/map_page.dart` :
    - `StatefulWidget` ; constructeur prend `GameController` ; écoute `ValueListenableBuilder<GameViewState>`.
    - Layout : `Scaffold` avec `AppBar(title: l10n.mapTitle)` ; corps = `Column(children: [MapLayerSelector, Expanded(PixelCanvas(child: CustomPaint(painter: MapPainter(...))))])`.
    - Gesture : `InteractiveViewer(minScale: 0.75, maxScale: 1.5, panEnabled: true, scaleEnabled: true)` autour du `CustomPaint`.
    - `debugPrint('MapPage: layer=$selectedLayer nodes=${visibleNodes.length} edges=${visibleEdges.length}')` à chaque build (silenced en release via `kDebugMode`).
  - [ ] Créer `lib/presentation/widgets/map_layer_selector.dart` :
    - `Wrap` ou `Row` de `FilterChip` (Material 3) pour les 5 couches ; pré-sélectionner `layerOf(currentLocationId)` ; griser+disabled si layer ∉ `visitedLayers`.
    - Labels via `l10n.mapLayerSurface`, `l10n.mapLayerUpperCave`, etc.
    - Semantics labels explicites ; taille tap ≥ 48 dp.
  - [ ] Créer `lib/presentation/widgets/map_painter.dart` :
    - `class MapPainter extends CustomPainter` ; reçoit `mapGraph`, `layoutNodes`, `selectedLayer`, `themeColors` (palette via `AppColors`).
    - Pipeline `paint(Canvas, Size)` :
      1. Récupérer la liste des `nodes` dont `layer == selectedLayer` ET `visited == true`.
      2. Si la couche contient un cluster FOREST : dessiner l'image blob (chargée via `assets/images/map/forest_blob.webp` quand livrée ; en S3, **fallback** dessin procédural d'un blob vert/ocre via `Path` + `Paint`) ; puis breadcrumb à partir de `recentTrail` filtré par cluster.
      3. Dessiner les arêtes `discovered==true` dont les deux extrémités sont visibles dans la couche : trait plein si `kind=normal`, pointillés colorés si `kind=magic|vertical`.
      4. Dessiner les ancres (icône pixel + label clipped) uniquement si `anchorTag != null && visited == true`.
      5. Dessiner la pastille « vous êtes ici » à `position(currentLocationId)` (ou centre cluster + jitter si `clusterId != null`), avec pulse 800 ms via `AnimationController` injecté.
    - `shouldRepaint(oldDelegate) => oldDelegate.mapGraph != mapGraph || oldDelegate.selectedLayer != selectedLayer || oldDelegate.pulseValue != pulseValue`.
  - [ ] Brancher la navigation depuis `HomePage` (méthode `_openMap()` analogue à `_openSaves()`) et **router** l'action `meta:map` côté `AdventurePage` (cf. `GameController.perform` qui no-op actuellement) :
    - Dans `AdventurePage`, intercepter les options `category=meta && verb=='MAP'` avant `controller.perform` pour ouvrir `MapPage` via `Navigator.push`. Garder `controller.perform` no-op côté Domain inchangé.

- [ ] **Task 9 — i18n FR/EN** (AC: #5, #10, #16)
  - [ ] Ajouter dans `lib/l10n/app_en.arb` (source) :
    - `mapTitle` : `"Map"`
    - `mapLayerSurface` : `"Surface & Well House"`
    - `mapLayerUpperCave` : `"Upper Cave"`
    - `mapLayerHallOfMists` : `"Hall of Mists"`
    - `mapLayerLabyrinthsRiver` : `"Labyrinths & River"`
    - `mapLayerSanctuaryEndgame` : `"Sanctuary & Endgame"`
    - `mapAnchorBuilding` : `"Building"`, `mapAnchorValley`, `mapAnchorHill`, `mapAnchorRoadend`, `mapAnchorGrate`, `mapAnchorSlit`, `mapAnchorCliff`, `mapAnchorStart`.
    - `mapAnchorVisited` : `"explored"` ; `mapAnchorKnown` : `"known exit"`.
    - `mapLegendVisited` : `"Visited path"`, `mapLegendMagic` : `"Magic shortcut"`, `mapLegendVertical` : `"Vertical passage"`.
    - `mapHereLabel` : `"You are here"`.
    - `mapLayerLocked` : `"Layer not yet discovered"`.
  - [ ] Dupliquer toutes les clés dans `lib/l10n/app_fr.arb` avec les traductions (`"Carte"`, `"Surface & Maison du Puits"`, `"Caverne Supérieure"`, `"Hall des Brumes"`, `"Labyrinthes & Rivière"`, `"Sanctuaire & Final"`, `"Bâtiment"`, `"Vallée"`, `"Colline"`, etc.).
  - [ ] Documenter les placeholders via `@key` au besoin (aucun placeholder dynamique nécessaire ici, pour l'instant).
  - [ ] Régénérer `lib/l10n/app_localizations.dart` via `flutter gen-l10n`.

- [ ] **Task 10 — Constantes & DI** (AC: #1, #14)
  - [ ] Ajouter `AssetPaths.mapLayoutJson = 'assets/data/map_layout.json';` dans `lib/core/constant/asset_paths.dart`.
  - [ ] Câbler dans `lib/main.dart` :
    - `final mapLayoutRepository = MapLayoutRepositoryImpl(assets: ..., adventureRepository: adventureRepository);`
    - `final mapGraphUpdater = MapGraphUpdater(mapLayoutRepository);`
    - Passer `mapGraphUpdater` au `GameController(... mapGraphUpdater: ...)`.

- [ ] **Task 11 — Tests widget + goldens** (AC: #4, #5, #6, #7, #8, #10, #13)
  - [ ] `test/presentation/pages/map_page_test.dart` :
    - Build avec controller + `MapGraph` fixture, golden par couche (5 fichiers `.png` sous `test/presentation/pages/goldens/map_<layer>.png`) ;
    - Tap chip → couche change ; chip layer non visité disabled ;
    - Aucune mutation de `controller.value.game` après tap/pan/zoom ;
    - Semantics : label `mapHereLabel` présent ; chips ≥ 48 dp (vérifier via `tester.getSize`).
  - [ ] `test/presentation/widgets/map_painter_test.dart` :
    - Test golden FOREST : `recentTrail = [LOC_FOREST3, LOC_FOREST7, ...]` + GRATE visitée → blob + breadcrumb + trait plein vers GRATE.
    - Test golden : apparition pointillé magique après MapGraph contient `MapEdge(from=BUILDING, to=Y2, kind=magic, discovered=true)`.
  - [ ] `test/domain/entities/map_graph_test.dart` (déjà task 2) : round-trip JSON, empty, copyWith.
  - [ ] `test/domain/services/map_graph_updater_test.dart` (déjà task 5) : 6 cas listés.
  - [ ] `test/data/repositories/save_repository_impl_test.dart` (étendre) : compat V1↔V2.
  - [ ] `test/data/repositories/map_layout_repository_impl_test.dart` (déjà task 4) : load OK + DataFailure.

- [ ] **Task 12 — Perf, lint, doc** (AC: #11, #12)
  - [ ] Lancer `flutter analyze` ; **zéro warning**.
  - [ ] Bench manuel : ouvrir MapPage sur device (`flutter run --profile`), changer de couche 5 fois ; vérifier DevTools Timeline : aucune frame > 16 ms.
  - [ ] Mettre à jour `docs/component-inventory.md` : ajouter `MapPage`, `MapLayerSelector`, `MapPainter`, `MapGraph`, `MapLayoutNode`, `MapLayoutRepository(Impl)`, `MapGraphUpdater`.
  - [ ] Mettre à jour `docs/architecture.md` §10 (UI) avec les nouveaux composants Map.
  - [ ] Mettre à jour `docs/data-models.md` : ajouter section MapGraph (entity + persistance + schema_version=2).
  - [ ] Mettre à jour `docs/index.md` : `MapPage` listé en `Generated Documentation` → composants UI.

- [ ] **Task 13 — Note de synthèse de validation cross-rôles** (livrable Cahier §F)
  - [ ] Rédiger un paragraphe de synthèse (≤ 200 mots) dans `Completion Notes List` (section `Dev Agent Record` ci-dessous) couvrant :
    - Validation CTO : architecture (Domain/Application/Data/Presentation) respectée, snapshot V2 rétro-compatible, tests aux seuils, perfs mesurées < 16 ms.
    - Validation Game Design : lisibilité tactile (3–7 ancres simultanées, cibles ≥ 48 dp), DDR-001 Option A respectée (pointillés magic après découverte uniquement), DA 16-bit conforme (PixelCanvas, FilterQuality.none, palette).
    - Risques résiduels et décisions différées (MAZE_A/MAZE_B en backlog, blob FOREST procédural si asset WebP pas encore livré, mapping zone→BGM à câbler dans ADVT‑S3‑21).
  - [ ] Lister dans `File List` (section `Dev Agent Record`) **tous** les fichiers créés/modifiés (~25) pour servir de checklist PR.
  - [ ] Cette note + le File List remplacent un éventuel ticket récap : ils servent de base à la code-review (`gds-code-review`).

## Dev Notes

### Architecture cible (résumé)

```
┌─ Presentation ──────────────────────────────────────────────┐
│ MapPage (StatefulWidget)                                    │
│  └─ ValueListenableBuilder<GameViewState>                   │
│       └─ Column                                              │
│            ├─ MapLayerSelector (FilterChip M3)              │
│            └─ PixelCanvas → InteractiveViewer → CustomPaint │
│                                       └─ MapPainter         │
└─────────────────────────────────────────────────────────────┘
            │ lit GameViewState.mapGraph
┌─ Application ───────────────────────────────────────────────┐
│ GameController (étendu)                                     │
│  ├─ init() bootstrap MapGraph (layoutRepo + initialGame)    │
│  ├─ perform() → MapGraphUpdater.applyMove(...) si loc change│
│  └─ _toSnapshot(game, mapGraph) → GameSnapshot V2           │
└─────────────────────────────────────────────────────────────┘
            │ injecte
┌─ Domain ────────────────────────────────────────────────────┐
│ MapGraphUpdater (service)                                   │
│  └─ applyMove(current, newLoc, motion, layoutRepo)           │
│        → MapGraph (immutable, copyWith)                     │
│ MapGraph entity + MapNodeState + MapEdge(enum kind)         │
│ MapLayoutNode VO                                            │
│ MapLayoutRepository (interface)                             │
└─────────────────────────────────────────────────────────────┘
            │ implémenté par
┌─ Data ──────────────────────────────────────────────────────┐
│ MapLayoutRepositoryImpl                                     │
│  ├─ AssetDataSource.loadMap('assets/data/map_layout.json') │
│  ├─ Cache mémoire + index id↔name                            │
│  └─ DataFailure typé si manquant/corrompu                   │
│ MapLayoutNodeModel.fromJson                                 │
└─────────────────────────────────────────────────────────────┘
```

### Source tree components to touch

| Path | NEW or UPDATE | Reason |
|------|---------------|--------|
| `assets/data/map_layout.json` | **NEW** (généré) | Source statique pour MapLayoutRepository (AC1, AC15) |
| `pubspec.yaml` | **UPDATE** | Déclarer `- assets/data/map_layout.json` |
| `lib/core/constant/asset_paths.dart` | **UPDATE** | Ajouter `static const String mapLayoutJson` |
| `lib/domain/entities/map_graph.dart` | **NEW** | Entité immuable + JSON round-trip |
| `lib/domain/value_objects/map_layout_node.dart` | **NEW** | VO statique de layout |
| `lib/domain/repositories/map_layout_repository.dart` | **NEW** | Port |
| `lib/domain/services/map_graph_updater.dart` | **NEW** | Mise à jour MapGraph par tour |
| `lib/data/models/map_layout_node_model.dart` | **NEW** | Mapper JSON → MapLayoutNode |
| `lib/data/repositories/map_layout_repository_impl.dart` | **NEW** | Implémentation |
| `lib/domain/value_objects/game_snapshot.dart` | **UPDATE** | Ajout `mapGraph?`, bump `schema_version=2`, fromJson tolérant V1 |
| `lib/application/controllers/game_controller.dart` | **UPDATE** | Injecter `MapGraphUpdater`, exposer `mapGraph` dans `GameViewState`, mettre à jour à chaque tour, étendre `_toSnapshot` |
| `lib/data/repositories/save_repository_impl.dart` | (lecture) | Aucun changement requis si snapshot est self-contained. Vérifier que round-trip V1/V2 fonctionne via JSON. |
| `lib/main.dart` | **UPDATE** | Câbler `MapLayoutRepositoryImpl` + `MapGraphUpdater`, passer au GameController |
| `lib/presentation/pages/map_page.dart` | **NEW** | Page principale |
| `lib/presentation/widgets/map_layer_selector.dart` | **NEW** | Chips M3 |
| `lib/presentation/widgets/map_painter.dart` | **NEW** | CustomPainter |
| `lib/presentation/pages/home_page.dart` | **UPDATE** | Bouton "Carte" → ouvrir MapPage (Navigator.push) |
| `lib/presentation/pages/adventure_page.dart` | **UPDATE** | Intercepter `meta:map` action → ouvrir MapPage avant `controller.perform` |
| `lib/l10n/app_en.arb` | **UPDATE** | Clés `map.*` (voir Task 9) |
| `lib/l10n/app_fr.arb` | **UPDATE** | Traductions FR |
| `lib/l10n/app_localizations.dart` | régénéré | `flutter gen-l10n` |
| `test/...` | **NEW** (5 fichiers + extensions) | Voir Task 11 |
| `scripts/update_assets.py` | **UPDATE (optionnel)** | Inclure `generate_map_layout.py` dans la séquence |
| `docs/component-inventory.md`, `docs/architecture.md`, `docs/data-models.md`, `docs/index.md` | **UPDATE** | Refléter les nouveaux composants |

### Project Structure Notes

- **Conforme** à `docs/source-tree-analysis.md` § "Layout obligatoire" : tous les nouveaux fichiers respectent la structure `lib/{domain,application,data,presentation,core}/...`.
- **Aucun nouveau dossier** créé ; on peuple les dossiers existants `lib/domain/entities/`, `lib/domain/repositories/`, `lib/domain/services/`, `lib/data/repositories/`, `lib/data/models/`, `lib/presentation/pages/`, `lib/presentation/widgets/`.
- **Pas de divergence** vs `docs/CONVERSION_SPEC.md` §13 (arborescence cible).

### Testing standards summary

- **Test miroir obligatoire** : pour chaque fichier `lib/<chemin>.dart` ajouté, créer `test/<chemin>_test.dart`.
- **Domain tests = `package:test` pur Dart** ; pas de `flutter_test`, pas de `MaterialApp`.
- **Widget tests** : `flutter_test`, `mocktail` pour mocks, `pump()` + `pumpAndSettle()`. Pas de `mockito`, pas de `build_runner`.
- **Goldens** : `flutter test --update-goldens` lors de l'ajout, puis stabilité requise. Stockage sous `test/presentation/<chemin>/goldens/`.
- **Cible couverture** (alignée S4) : Domain ≥ 90 %, Data ≥ 80 %, Presentation ≥ 60 %. Cette story doit pousser les nouveaux modules MapGraph/Updater à ≥ 90 % Domain et MapLayoutRepositoryImpl à ≥ 80 % Data.
- **Frame budget perf** : mesuré via DevTools Timeline, à consigner dans Completion Notes (cf. modèle ADVT‑S2‑15).

### Project Context Rules

Extraits directs de [`docs/project-context.md`](../project-context.md) **applicables à cette story** :

- **Domain pur** : `MapGraph`, `MapEdge`, `MapNodeState`, `MapLayoutNode`, `MapGraphUpdater` n'importent **jamais** `package:flutter/*`. Aucun `BuildContext`, aucun `ValueNotifier`, aucun `Material`.
- **Data passive** : `MapLayoutNodeModel` et `MapLayoutRepositoryImpl` ne contiennent aucune logique métier (juste parsing + cache + lookup).
- **Presentation sans logique** : `MapPage`/`MapPainter`/`MapLayerSelector` consomment `mapGraph` immuable ; aucune mutation domaine côté UI. Le pan/zoom est purement visuel.
- **Composition root unique** : nouveau wiring exclusivement dans `lib/main.dart` (`MapLayoutRepositoryImpl`, `MapGraphUpdater`, passage au `GameController`).
- **Immutabilité** : `MapGraph` + `MapEdge` + `MapNodeState` final + const partout possible ; `copyWith` ; `==`/`hashCode` structurels via `package:collection` (`MapEquality`, `ListEquality`, `SetEquality`).
- **i18n** : aucune chaîne en dur dans `MapPage`/`MapLayerSelector`/`MapPainter`. Toujours `AppLocalizations.of(context).mapXxx`. Régénération `flutter gen-l10n` après MAJ ARB.
- **IDs vs noms** : tous les `LOC_*` sont résolus en index séquentiel via `LookupService` ou caches de `AdventureRepository`. Ne jamais hardcoder un id.
- **Asset paths via constantes** : `AssetPaths.mapLayoutJson` jamais inliné comme string littéral.
- **Snapshot versionné** : bump `schema_version` à 2 pour le passage MapGraph, **lecture tolérante** pour V1 (mapGraph=null si absent), **toJson** émet toujours V2 désormais.
- **Pas de réseau, pas de télémétrie** : la MapPage est 100 % offline ; aucun appel HTTP, aucune image distante. Le blob FOREST est un asset embarqué ou un dessin procédural local (S3 fallback acceptable).
- **Pixel-perfect** : `MapPainter` peint dans le canvas logique 320×180 du `PixelCanvas` parent, `FilterQuality.none` partout. Si une image WebP est utilisée, vérifier `paintImage` avec `filterQuality: FilterQuality.none`.
- **Pas de Provider/Riverpod/Bloc** : injection par constructeur ; écoute via `ValueListenableBuilder`.
- **mocktail only** dans les tests (jamais `mockito`).
- **DDR-001 Option A** : aucune arête `kind=magic` ne doit jamais être tracée tant que `discovered=false`. Aucune ancre non visitée. Aucun cluster MAZE_* en S3 (MAZE_A/MAZE_B sont en backlog ; on se concentre sur FOREST en S3).

### References

- Spec normative MapPage : [docs/Cahier_des_charges_Map.md#A. Périmètre & invariants](../Cahier_des_charges_Map.md)
- Spec MapPage §D Implémentation Flutter : [docs/Cahier_des_charges_Map.md#D. Implémentation Flutter](../Cahier_des_charges_Map.md)
- Spec MapPage §E Tests & validation : [docs/Cahier_des_charges_Map.md#E. Tests & validation](../Cahier_des_charges_Map.md)
- Demande CTO/Dev S3 : [docs/CTO_DEV_MAP_REQUEST.md](../CTO_DEV_MAP_REQUEST.md)
- Architecture Clean : [docs/architecture.md#3. Architecture Pattern](../architecture.md)
- Conventions code : [docs/project-context.md#Framework-Specific Rules](../project-context.md)
- Modèle de données : [docs/data-models.md#3. Entités Domain](../data-models.md)
- Composants existants : [docs/component-inventory.md](../component-inventory.md)
- DDR-001 Option A (incantations) : [docs/Dossier_de_Référence.md#7.1 DDR-001](../Dossier_de_Référence.md)
- Sprint S3 EXEC : [docs/EXEC_S3.md#suivi--tickets](../EXEC_S3.md) (ADVT‑S3‑16)
- Wireframe HomePage (pour le bouton Carte) : [docs/UX_SCREENS.md](../UX_SCREENS.md)
- Direction Artistique : [docs/VISUAL_STYLE_GUIDE.md](../VISUAL_STYLE_GUIDE.md), [docs/ART_ASSET_BIBLE.md](../ART_ASSET_BIBLE.md)
- Pipeline assets : [docs/asset-inventory.md#6. Pipeline de génération](../asset-inventory.md), `scripts/generate_map_layout.py`, `docs/map_layout_plan.yaml`
- Exports par strate (référence) : `docs/map_layers/{surface,upper_cave,hall_of_mists,labyrinths_river,sanctuary_endgame}.json`

### Previous Story Intelligence

Story précédente complétée : **3.15 — InventoryPage** (`docs/implementation-artifacts/3-15-inventory-page.md` n'existe pas encore au format BMad, mais la page est livrée). Patterns à reproduire :

- **Structure `Scaffold + AppBar + FlashMessageListener + ValueListenableBuilder<GameViewState>`** : copier le squelette de `lib/presentation/pages/inventory_page.dart`. C'est le standard du projet.
- **Constructeur** : `const MapPage({super.key, required this.controller})` ; pas de service locator.
- **Loading state** : `if (state.isLoading || game == null) return const Center(child: CircularProgressIndicator());` → reproduire à l'identique.
- **Labels via `AppLocalizations.of(context)`** : jamais en dur.
- **Tests widget** : reprendre le pattern de `test/presentation/pages/inventory_page_test.dart` (pump avec controller stub, tap, vérifier callbacks).

### Git Intelligence Summary

Derniers commits significatifs (sur `develop`) :

- `711f618` add local Claude Code permissions allowlist
- `d084007` add per-layer map export scripts and generated layer graphs ← **directement lié** : a livré `scripts/export_layer_graphs.py`, `docs/map_layers/*.json`, et probablement `scripts/generate_map_layout.py`.
- `5ca07bf` Move Pit Brink to labyrinth layer ← affinement du `map_layout_plan.yaml`.
- `1dc0fc5` Assign map layers to locations ← création/maintenance du plan YAML.

**Implication** : le pipeline de génération est déjà en place. Cette story consomme ce travail amont. Si `assets/data/map_layout.json` est absent au début, le générer immédiatement (`python3 scripts/generate_map_layout.py`).

### Latest tech information

- **Flutter 3.35.x** (verrouillé par projet) :
  - `CustomPainter.shouldRepaint` : retourner `false` si rien d'observable n'a changé (perf critique).
  - `InteractiveViewer` : préférer `panEnabled: true, scaleEnabled: true, minScale: 0.75, maxScale: 1.5, boundaryMargin: EdgeInsets.all(20)`. NE PAS imbriquer `InteractiveViewer` dans un `SingleChildScrollView` (conflit de gestes).
  - `paintImage` : passer explicitement `filterQuality: FilterQuality.none` pour préserver le pixel art.
  - `Path.dashed` : Flutter ne fournit pas de helper natif ; implémenter un util `drawDashedLine(canvas, p1, p2, paint, {required double dashLength, required double gapLength})` dans `map_painter.dart` (ou utiliser `PathMetric.extractPath` segment par segment).
- **Material 3 `FilterChip`** : `selected`/`onSelected` ; pour disabled, passer `onSelected: null` et `selected: false`. Pour la grisure, ajuster `backgroundColor`/`selectedColor` via `Theme.of(context).colorScheme`. Tap target : par défaut 48 dp via `MaterialTapTargetSize.padded` (vérifier `themeData.materialTapTargetSize`).
- **`AnimationController` pulse** : créer dans `initState` avec `vsync: this` (mixer `SingleTickerProviderStateMixin`), `Duration(milliseconds: 800)`, `repeat(reverse: true)`. Disposer dans `dispose()`. **Ne pas** créer dans `build()`.
- **`ValueListenableBuilder` performance** : ne reconstruit que le child dépendant ; encapsuler la zone Map dans le builder, garder l'AppBar/Selector hors du builder si possible (rebuild ciblé).

## Dev Agent Record

### Agent Model Used

_(à renseigner par dev-story)_

### Debug Log References

_(à renseigner par dev-story — captures DevTools, logs MapPage, mesures perf)_

### Completion Notes List

_(à renseigner par dev-story — décisions prises, divergences vs plan, notes pour retro)_

### File List

_(à renseigner par dev-story — liste exhaustive des fichiers créés/modifiés)_
