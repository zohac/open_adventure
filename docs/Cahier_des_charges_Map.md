1. Vision de Game Design

   La **MapPage** est une **carte topologique** qui montre ce que le joueur **a réellement vécu** : ancres, traversées, trace récente et position, **sans jamais feindre une géométrie physique** dans les zones non-euclidiennes (forêt & labyrinthes). On reste lisible au pouce, fidèle à l’œuvre, et dans les budgets 16-bit.

2. Décision de Conception — Cahier des charges Map (FOREST)

### A. Périmètre & invariants

* **Couches (5 niveaux)** : Surface & Well House, Upper Cave, Hall of Mists, Labyrinthes & Rivière, Sanctuaire & Endgame. Sélecteur d’étage (chips) en haut; sélection par défaut = couche du lieu courant.
* **Source de vérité** : `GameController.mapGraph` (Domain/Application) expose **uniquement** ce qui a été découvert. La Map est **lecture-seule** et **ne mute rien**. L’état de découverte est inclus dans l’**autosave** + **slots**.  
* **Direction artistique** : pixel art 16-bit, **canvas logique 320×180**, scaling **entier** (×2, ×3…), `FilterQuality.none`, images ≤ **200 KB** chacune, pack images ≤ **10 MB**.  

### B. Modèle de données

1. **`MapGraph` (sérialisable)**

```ts
type MapGraph = {
  nodes: Record<LocationId, { visited: boolean; layer: LayerKey; clusterId?: "FOREST" | "MAZE_A" | "MAZE_B"; anchorTag?: string }>;
  edges: Array<{ from: LocationId; to: LocationId; kind: "normal" | "magic" | "vertical"; discovered: boolean }>;
  currentLocationId: LocationId;
  visitedLayers: LayerKey[];
  recentTrail: LocationId[]; // buffer circulaire, 5–7 derniers lieux
  schemaVersion: number;     // pour compat intra-major
};
```

* **Autosave** : `MapGraph` est sérialisé dans le snapshot de partie (autosave/slots), format JSON **versionné**.

2. **`assets/data/map_layout.json` (statique)**

   Entrées par `locationId` :

```json
{
  "locationId": "LOC_FOREST7",
  "layer": "SURFACE",
  "x": null, "y": null,               // null dans un cluster non-euclidien
  "mapTag": "Forest.",
  "clusterId": "FOREST",               // FOREST | MAZE_A | MAZE_B | null
  "isAmbiguous": true,                 // non-euclidien → rendu en blob
  "anchorTag": null,                   // ex: "GRATE", "VALLEY" pour ancres
  "jitterSeed": "LOC_FOREST7"          // dispersion stable dans le blob
}
```

* Le layout **ne spoile pas** : seules les métadonnées de placement et de cluster sont statiques; l’affichage dépend de `MapGraph.visited`.

### C. Rendu & interactions (FOREST)

* **Blob FOREST** : une **seule image** 16-bit (≤200 KB), tons verts/ocres; **aucun** nœud interne rendu. Autour du blob, affichage des **ancres** (VALLEY, HILL, ROADEND, GRATE, SLIT, CLIFF) **uniquement si visitées**.  
* **Position du joueur** : pastille “vous êtes ici” avec **pulse discret** (800 ms). Dans la forêt, sa position **bouge légèrement** (±8 px) selon `jitterSeed(locationId)` ; **même salle → même position**.
* **Trace (breadcrumb)** : rendre les **5–7 dernières** positions dans le blob (alpha 60%→15%).
* **Chemins** :

  * **Parcourus** → trait plein.
  * **Magiques / verticaux** (puits, XYZZY/PLUGH/PLOVER) → **pointillés colorés** **après** première traversée réussie. Règle DDR-001 **Option A** : rien n’apparaît avant découverte. 
* **Brouillard de guerre** : **aucun** à l’intérieur du blob (l’opacité du cluster **est** l’anti-spoil). Hors forêt : la Map **n’affiche jamais** d’éléments non découverts (pas de fog directionnel). 
* **Zoom/Pan** : lecture-seule, pan léger et zoom **×0,75–×1,5**.
* **Accessibilité** : ancres = cibles ≥ **48 dp**, labels `Semantics` (“Grille — explorée”, “Vallée — sortie connue”), contrastes **AA**, thèmes clair/sombre.  

### D. Implémentation Flutter

* **`MapPage` (Presentation)** : `CustomPainter` dans un **PixelCanvas** 320×180; toutes les `Image` avec `FilterQuality.none`; **letterboxing** si nécessaire.
* **Projection FOREST** :

  * Si `clusterId=="FOREST"` ⇒ dessiner le **blob**, puis :

    * calcul `offset = hash(jitterSeed) → (dx,dy) ∈ [-8,+8]`, easing 150 ms à chaque changement de salle;
    * **breadcrumb** depuis `recentTrail`;
    * ancres (icônes/labels) uniquement si `nodes[anchorId].visited == true`;
    * traits/arêtes : ne peindre que `edges.discovered==true`.
* **Sélecteur d’étage** : chips en haut, couche courante pré-sélectionnée.
* **Performance** : frame **< 16 ms**; pas de lissage; rebuild minimal. 
* **Audio** : inchangé (BGM par zone; crossfade 250–500 ms). 
* **i18n** : clés ARB `map.layer.surface`, `map.anchor.grate`, etc. (voir matrice `UX_SCREENS.md`). 

### E. Tests & validation

* **Golden tests** (MapPage) :

  1. **FOREST** avec `recentTrail` et une ancre découverte (GRATE) → blob + breadcrumb + trait plein vers GRATE.
  2. **Apparition d’un pointillé magique** **après** découverte (edge.kind="magic" → discovered true).
  3. **Sérialisation** round-trip `MapGraph` (incluant `recentTrail` et `visitedLayers`). 
* **Widget tests** :

  * Sélecteur de couches (chips) : sélection correcte + accessibilité.
  * “Vous êtes ici” rendu/pulse; jitter stable par `locationId`.
* **CI / Couvertures** : Domain ≥ 90%, Application ≥ 80%, Presentation ≥ 60% (S4), goldens stables. 

### F. Livrables S3 (PR attendu)

* `lib/presentation/pages/map_page.dart` + painter.
* `assets/data/map_layout.json` (v2 avec `clusterId/isAmbiguous/jitterSeed/anchorTag`).
* Hook d’**autosave** pour `MapGraph` dans `GameController`.
* **Tests** : widget + goldens + sérialisation.
* **Note de synthèse** (1 paragraphe) de validation croisée CTO/Game Design. 

3. Risques & Coût de l’Inaction

* **Tenter une carte “physique” de la forêt** : contradiction visuelle majeure (graphe non planaire), UI illisible, perte de confiance, et surcharge d’assets hors budget 16-bit.  
* **Ne pas adopter le mode topologique** : absence de repères utiles (trace/ancres), errance frustrante, churn mobile.
* **Ignorer DDR-001 (incantations invisibles avant découverte)** : spoil des énigmes, dissonance avec le scoring/hints, régressions QA.

**Clause finale (gouvernance)** — Cette spécification **prime** sur toute implémentation antérieure. Tout écart doit être amendé ici **avant merge**. Respect des budgets, de la grille 320×180 et des tests goldens obligatoire.
