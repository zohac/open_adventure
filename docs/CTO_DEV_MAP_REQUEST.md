# Demande MapPage Semaine 3 — À adresser CTO & Dev

## Contexte
- Persona: Maya Greenwood (Game Design) acte la MapPage comme atlas multi-strates révélant uniquement les lieux et chemins déjà explorés.
- Source de vérité: `GameController.mapGraph` (Domain/Application) expose nœuds/arêtes visités. Aucun spoil, aucune mutation côté UI.
- Référence historique: stratification confirmée par Tristan Maher-Kent (historien Colossal Cave) : Surface & Well House → Upper Cave → Hall of Mists → Labyrinthes & Rivière → Sanctuaire & Endgame.

## Attentes côté CTO
1. **Valider l’architecture de données**
   - Confirmer que `GameController` délivre un `MapGraph` sérialisable (autosave) contenant `nodes`, `edges`, `currentLocationId`, `visitedLayers`.
   - Garantir la persistance offline: autosave + slots manuels doivent inclure l’état de découverte de la carte.
   - Ajouter au backlog tech la génération du fichier statique `assets/data/map_layout.json` (mapping `locationId → {layer, x, y, mapTag}`) versionné et testé.
2. **Sécuriser les budgets et guidelines**
   - Bloquer le budget art: 5 couches max, couleurs différenciées (Surface tons chauds, Profondeurs bleus/mauves) sans dépasser 200 KB/image.
   - Valider les tests automatiques: un golden test MapPage par couche + test de sérialisation `MapGraph`.
3. **Communication**
   - Diffuser la règle DDR-001 Option A (incantations invisibles tant qu’indécouvertes) aux équipes QA/UX.
   - Programmer la revue croisée Game Design/UX après implémentation pour vérifier la lisibilité tactile (3–7 choix, pointillés pour sauts magiques).

## Attentes côté Développeur Flutter (S3)
1. **Implémentation MapPage v1**
   - Charger `map_layout.json` (layer + coordonnées) et fusionner avec `GameController.mapGraph` pour n’afficher que les nœuds `visited=true`.
   - Dessiner via `CustomPainter` (PixelCanvas style 16-bit) :
     - nœuds = pastilles par couche, label = `mapTag` historique si disponible sinon nom court;
     - arêtes explorées = trait plein;
     - transitions verticales/magiques (Hall of Mists, XYZZY/PLUGH/PLOVER, puits) = pointillés colorés après première traversée réussie.
   - Badge « Vous êtes ici » = pastille animée (pulse discret) sur `currentLocationId`.
2. **Interaction & UX**
   - Aucune action tactile sur la carte (lecture seule). Respecter zoom/drag léger (×0,75–×1,5) sans mutation du `MapGraph`.
   - Intégrer un sélecteur de couche (chips Material 3) en haut de page, sélection par défaut = couche du lieu courant.
   - Veiller à l’accessibilité: cibles 48dp, contraste AA, semantics labels sur nœuds.
3. **Tests & Observabilité**
   - Golden tests par couche avec fixture `map_layout.json` et `MapGraph` d’exemple.
   - Widget test vérifiant l’apparition du connecteur pointillé après `GameController` signale une arête magique découverte.
   - Ajouter métriques de logs (debug) pour nombre de nœuds/arêtes rendus par couche afin d’aider QA.

## Livrables attendus en fin de S3
- PR Flutter incluant `MapPage`, tests widget/golden, fichier `map_layout.json`, hook autosave `MapGraph`.
- Compte rendu court (1 paragraphe) confirmant validation par CTO (archi + tests) et revue Game Design.

