# Exécution S3 — Interactions, Inventaire, Nains, Lampe, Scoring partiel

Statut: exécutable immédiatement. Durée cible: 1 semaine (5 j/h).

Definition of Ready (DoR)

- Mapping zones → BGM validé (surface/grotte/danger…); liste SFX prioritaire définie.
- Nommage des images `<key>.webp` validé (mapTag → snake_case) et budget art confirmé (≤ 10 Mo).
- Direction artistique 16‑bit (palette, typographie) approuvée.
- `pubspec.yaml` préparé pour lister explicitement toutes les images `assets/images/locations/*.webp` et les audio `assets/audio/{music,sfx}/*.ogg`.
- DDR pertinentes confirmées dans `docs/Dossier_de_Référence.md` (incantations Option A, comportement PNJ, oracles O1–O3 prêts pour QA).
- Architecture de la carte validée: `GameController.mapGraph` sérialisable (`nodes`, `edges`, `currentLocationId`, `visitedLayers`) et persistance autosave/saves couvrant l’état de découverte.
- Fichier statique `assets/data/map_layout.json` planifié (mapping `locationId → {layer, x, y, mapTag}`) avec propriétaire identifié.

Objectif S3

- Étendre le noyau jouable avec les interactions d’objets (prendre/poser/ouvrir/fermer/allumer/éteindre/examiner), l’inventaire, une première itération des nains (déplacements/rencontres), la gestion de la lampe, le scoring partiel, et livrer les vues Map/Inventaire/Journal avec tests widgets.

Dépendances S2 (doivent être vertes)

- `ListAvailableActions` (travel) et `ApplyTurn` (goto) en place. `GameController` + autosave opérationnels. `AdventurePage` v0 fonctionnelle. Les incantations sont déjà filtrées par ADVT‑S2‑23/24 et ne doivent être débloquées qu’ici (actions `special`).
- Mouvement `BACK/RETURN` implémenté côté Domain/Application/UI (ADVT‑S2‑21/22) pour garantir l’option « Revenir » dans les cul-de-sac.
- Mappers JSON stables (S1) et accès Repository aux entités requises.

Livrables

- Domain
  - Évaluation de conditions: `EvaluateCondition` (support des types de base: `carry`, `with`, `not`, `at`, `state`, `prop`, `have` — périmètre minimal S3).
  - Use cases d’interaction:
    - `TakeObject`, `DropObject`, `OpenObject`, `CloseObject`, `LightLamp`, `ExtinguishLamp`, `Examine`, `InventoryUseCase` (retourne vue texte de l’inventaire).
  - Extension `ListAvailableActions`: ajouter `category='interaction'` et `category='meta'` (Inventaire/Observer/Carte) en plus de `travel`.
  - Extension `ApplyTurn`: appliquer effets des interactions (mutation de `Game`), messages utilisateur, et décrémenter timers (lampe).
  - Dwarves (S3 minimal): `DwarfSystem.tick(Game)` — apparition/déplacement stochastique (RNG seedée), message d’alerte/attaque (sans combat complet — S4), blocage éventuel de chemins ignoré en S3.
  - Scoring partiel: `ComputeScore` (partiel) — points pour trésors pris, lieux clés visités, pénalités de base par tour (sans bonus/fins S4).
- Application
  - `GameController`: orchestration interactions + journal; regroupement d’options; autosave après chaque tour; exposition `inventory`, `mapGraph`, `journal`.
- Data
  - Mappers pour `conditions.json` → `Condition` et pour `actions.json` (synonymes/labels icônes). Pas de logique métier dans Data.
- Presentation
  - `InventoryPage`: liste des objets portés avec actions contextuelles (poser/utiliser/éteindre/allumer).
- `MapPage`: graphe 2D multi‑couches des lieux découverts (noeuds/arêtes) alimenté par `map_layout.json` + `GameController.mapGraph`; position courante surlignée. Voir `docs/CTO_DEV_MAP_REQUEST.md` pour le détail des livrables CTO/dev (strates, connecteurs magiques, tests).
  - `JournalView`: fil chronologique des messages avec ancre sur le dernier événement.
  - `AdventurePage` v1: intégration des onglets/bottom bar (Carte, Inventaire, Journal, Menu) et des catégories d’actions.
  - Images de scène: intégration visuelle par lieu au-dessus du heading (si disponible), offline only.
  - Audio: BGM par zone (loop gapless) + SFX d’interaction (prendre/poser, lampe on/off, alerte nain).
  - Art Bible: livrer 15–20 scènes prioritaires conformes à `docs/ART_ASSET_BIBLE.md` (noms, palettes, budgets, VFX discrets).

UI – livrables & DoD

- [ ] AdventurePage v1 (onglets + catégories d’actions)
  - DoD:
    - [ ] Bottom bar/onglets opérationnels (Carte, Inventaire, Journal, Menu);
    - [ ] Sections d’actions regroupées (travel/interaction/meta) avec titres;
    - [ ] Navigation entre onglets sans perte d’état;
    - [ ] Respect de §17: priorisation (sécurité > travel > interaction > méta), 3–7 actions visibles (overflow paginé/scrollé), labels/icônes normalisés; `Observer` rejoue la description longue si disponible.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.
- [ ] InventoryPage
  - DoD:
    - [ ] Liste des objets portés avec actions contextuelles par item (poser/utiliser/éteindre/allumer);
    - [ ] Tap déclenche `perform` et met à jour l’inventaire/journal.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.
- [ ] MapPage v1
  - DoD:
    - [ ] Chargement de `assets/data/map_layout.json` + fusion avec `GameController.mapGraph` pour n’afficher que les nœuds/arêtes visités (incantations en pointillés révélés après découverte, badge « vous êtes ici » animé);
    - [ ] CustomPainter (PixelCanvas) respectant le budget art (≤200 KB/couche, max 5 couches) et sélecteur de couches (chips M3) positionné en haut;
    - [ ] Zoom/drag léger (×0,75–×1,5) en lecture seule, semantics labels sur nœuds, logs debug (#nœuds/#arêtes) activés;
    - [ ] Golden tests par couche + test widget connecteur pointillé + test de sérialisation `MapGraph`;
    - [ ] Revue Game Designer/UX: lisibilité tactile confirmée (3–7 choix sur l’onglet, pointillés pour transitions magiques, contraste AA) et diffusion DDR‑001 Option A.
- [ ] JournalView
  - DoD:
    - [ ] Append des messages, trim au seuil (ex: 200), scroll to bottom sur nouvel ajout;
    - [ ] Widget test valide l’append + scroll.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.
- [ ] Image de scène par lieu (intégration S3)
  - DoD:
    - [ ] `pubspec.yaml` déclare les fichiers présents sous `assets/images/locations/` (listing explicite des .webp);
    - [ ] `AdventurePage` charge `assets/images/locations/<key>.webp` via `locationImageKey` (S2) avec `FadeInImage` + placeholder, rendu via `PixelCanvas` (scale entier);
    - [ ] Contraintes: `AspectRatio 16/9`, poids ≤ 200 KB/image, total art ≤ 10 MB; `FilterQuality.none`; fallback silencieux si manquant; préchargement de l’image du prochain lieu après `ApplyTurn`;
    - [ ] Accessibilité: `semanticsLabel` = nom du lieu; tests widget vérifient fallback et affichage de l’image quand présente.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.
- [ ] Art Bible (S3) — scènes prioritaires
  - DoD:
    - [ ] 15–20 lieux livrés selon `ART_ASSET_BIBLE.md` (clés `<key>` valides, palettes/contrastes conformes, VFX discrets seulement);
    - [ ] Revue croisée dev/art: rendu net via `PixelCanvas` (aucun flou), contrôles sur device (×2/×3);
    - [ ] Budget total art ≤ 10 Mo maintenu.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.

Audio – livrables & DoD

- [ ] BGM par zone (loop + crossfade)
  - DoD:
    - [ ] Table de mapping `zoneKey → trackKey` (ex: surface/grotte/danger);
    - [ ] `AudioController.playBgm` appelé sur changement de zone avec crossfade 250–500 ms;
    - [ ] Boucles gapless (écoute contrôlée), latence de démarrage < 50 ms.
- [ ] SFX d’interaction (prendre/poser/ouvrir/fermer/lampe on/off/alerte nain)
  - DoD:
    - [ ] Mapping `eventKey → sfxKey`; déclenché dans `GameController`/use cases;
    - [ ] Pas de spam (throttle 100–200 ms si répétitions); volume SFX gouverné par Settings.

Contrats Domain (extraits normatifs)

```dart
abstract class EvaluateCondition {
  bool call(Condition cond, Game game);
}

abstract class TakeObject { Future<TurnResult> call(String objectId, Game game); }
abstract class DropObject { Future<TurnResult> call(String objectId, Game game); }
abstract class OpenObject { Future<TurnResult> call(String objectId, Game game); }
abstract class CloseObject { Future<TurnResult> call(String objectId, Game game); }
abstract class LightLamp { Future<TurnResult> call(Game game); }
abstract class ExtinguishLamp { Future<TurnResult> call(Game game); }
abstract class Examine { Future<TurnResult> call(String? targetId, Game game); }

abstract class ComputeScore { ScoreBreakdown call(Game game); }

class ScoreBreakdown {
  final int treasures; final int exploration; final int penalties; final int total;
  const ScoreBreakdown({required this.treasures,required this.exploration,required this.penalties})
    : total = treasures + exploration - penalties;
}
```

Règles — Disponibilité des actions (S3)

- Contexte « en vue »: objets présents à `locationId` courant ou portés (inventaire).
- `Take`: visible, non immobile, pas déjà porté.
- `Drop`: porté.
- `Open/Close`: si l’objet supporte ces états via `states`/`descriptions` et conditions satisfaites (clé, etc. — limité S3 aux cas explicites simples).
- `Light/Extinguish`: lampe uniquement; allumer requiert carburant/timer > 0; éteindre toujours possible si allumée.
- `Examine`: toujours disponible, renvoie description courte/longue selon contexte.
- Les règles `actions.json`/`conditions.json` guident les disponibilités; en cas de doute, on n’expose pas l’action (principe de sûreté S3).

Lampe — gestion S3

- Champs `limit/clock1/clock2` du `Game` pilotent la durée restante (basé sur l’état d’origine C). À chaque tour avec lampe allumée: décrémenter; avertir via `lmwarn` quand seuil franchi.
- `LightLamp` échoue si batterie vide → message dédié.

Dwarves — S3 minimal

- À chaque `ApplyTurn`, `DwarfSystem.tick(game, rng)` peut déclencher: apparition (proba faible), déplacement vers le joueur (heuristique simple: random walk biaisé), message « Un nain vous observe/attaque ». Pas de résolution de combat en S3.
- Pas de side‑effects sur les objets/chemins en S3; uniquement journal + éventuel impact mineur de score (optionnel).

Scoring partiel (S3)

- Trésors: +X si porté ou déposés à un « lieu de scoring » (déterminé via `classes.json`/tags simples).
- Exploration: +1 par lieu unique visité (set), plafonné.
- Pénalités: +k toutes les N actions (turns), valeur modérée.
- Le bonus de fin, classes complètes et cas spéciaux restent en S4.

Algorithmes — Mises à jour

- `ListAvailableActions`
  - Étendre le calcul: pour chaque objet visible/porté, proposer actions contextuelles en appliquant `EvaluateCondition`.
  - Injecter options méta: `Inventaire`, `Observer` (rejoue la description), `Carte`.
- `ApplyTurn`
  - Router: si `category=interaction`, déléguer au use case dédié; sinon `travel` (déjà S2).
  - Après mutation: `DwarfSystem.tick`, `ComputeScore(partiel)`, timer lampe, puis autosave.

MapPage — exigences

- Graphe construit à partir des arêtes découvertes (travel réalisés) et des destinations « triviales » depuis le lieu courant.
- Layout simple (force‑directed ou grille), aucune dépendance native externe; snapshot minimal pour goldens.

InventoryPage — exigences

- Liste des objets portés; actions contextuelles visibles par ligne; compatibilité accessibilité (semantics).

JournalView — exigences

- Append‑only, taille bornée (ex: 200 derniers messages), scroll to bottom sur nouveau message.

Fichiers à créer/mettre à jour

- `lib/domain/usecases/*` (interactions listées, EvaluateCondition, ComputeScore(partiel), DwarfSystem).
- `lib/application/controllers/game_controller.dart` (orchestration interactions/score/dwarves/journal).
- `lib/presentation/pages/inventory_page.dart`, `map_page.dart`, `widgets/journal_view.dart`, `widgets/action_button_list.dart` (groupes).
- `lib/presentation/widgets/location_image.dart` (widget d’image de scène + placeholder, s’appuie sur `locationImageKey`)
- `lib/application/controllers/audio_controller.dart` (étendu: crossfade, mapping zones)
- `assets/audio/music/*.ogg`, `assets/audio/sfx/*.ogg` (déclarés dans `pubspec.yaml`)

Tests & validations (S3)

- Domain
  - `Take/Drop`: invariants inventaire (pas de doublons), présence/absence aux bons lieux.
  - `Light/Extinguish`: transitions lampe + décrément compteur par tour + `lmwarn`.
  - `Open/Close`: états cohérents selon `states/descriptions` (cas simples).
  - `EvaluateCondition`: vérités de base sur `carry/with/not/at/state`.
  - `DwarfSystem.tick`: déterministe avec seed donnée (contrôle des messages attendus).
  - `ComputeScore(partiel)`: trésors/lieux/pénalités conformes.
- Application
  - `GameController.perform()` applique interaction + autosave; journal enrichi.
- Presentation (widget tests)
  - `InventoryPage` rend la liste et déclenche `perform` sur action.
  - `MapPage` affiche au moins les nœuds découverts et le lieu courant.
  - `JournalView` append et scroll correctement.

Definition of Done (S3)

- `flutter analyze` sans warnings; tests S3 verts; couverture Domain (S3) ≥ 85%.
- Jouabilité enrichie: prendre/poser/allumer/éteindre, examine; journal lisible; inventaire et carte consultables.
- Lampe fonctionnelle (compteur, avertissements) et premières rencontres de nains (messages) sans crash.

Risques & mitigations (S3)

- Explosion combinatoire des conditions: scope contrôlé, ne supporter que les conditions de base en S3; backloguer le reste S4.
- Nains trop intrusifs: calibrer probabilités; basculer via flag config dev.
- Régressions de performance UI: profiler les listes (inventaire/actions), limiter le rebuild via state immuable et `const` widgets.

Suivi & tickets

- [x] ADVT‑S3‑01: Implémenter `EvaluateCondition` (types: carry, with, not, at, state, prop, have) + tests de vérité.
  - DoD:
    - [x] Chaque type retourne vrai/faux correct sur scénarios contrôlés; cas de combinaison `not` couvert; couverture ≥ 90% sur ce module.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑02: Étendre `ListAvailableActions` — catégories `interaction` et `meta` (Inventaire/Observer/Carte) + tests.
  - DoD:
    - [x] Options contextuelles visibles uniquement quand applicables; pas de doublons; tri par priorité (sécurité > travel > interaction > méta);
    - [x] Tests: présence de `Inventaire/Observer/Carte` et d’au moins 2 interactions valides.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑03: Use case `TakeObject` — maj inventaire/lieu, interdits (immovable), messages + tests.
  - DoD:
    - [x] Objet passe de lieu → inventaire; immovable interdit avec message spécifique; tests succès/échec.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑04: Use case `DropObject` — maj inventaire/lieu, messages + tests.
  - DoD:
    - [x] Objet retiré de l’inventaire et visible au lieu courant; message ajouté au journal; tests verts.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑05: Use case `OpenObject` — gestion états simples via `states/descriptions`, contraintes triviales + tests.
  - DoD:
    - [x] État bascule open; description cohérente; échec si condition non satisfaite (clé manquante) — S3: cas trivials seulement.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑06: Use case `CloseObject` — états inverses + tests.
  - DoD:
    - [x] État bascule closed; messages corrects; tests couverts.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑07: Use case `LightLamp` — prérequis batterie, flags, messages + tests (incl. échec).
  - DoD:
    - [x] Lampe passe à allumée; compteur non négatif; message d’avertissement quand seuil; test d’échec batterie vide.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑08: Use case `ExtinguishLamp` — transitions + tests.
  - DoD:
    - [x] Lampe éteinte; pas de décrément au tour suivant; tests verts.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑09: Use case `Examine` — description contextuelle (courte/longue) + tests.
  - DoD:
    - [x] Retourne description adaptée au contexte (porté/en vue); message non vide; tests.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [x] ADVT‑S3‑10: `InventoryUseCase` — rendu texte de l’inventaire pour journal/UI + tests.
  - DoD:
    - [x] Liste formatée stable; test d’objets multiples, ordre défini.
    - [x] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [ ] ADVT‑S3‑11: `DwarfSystem.tick` (minimal) — apparition/déplacement, messages, déterminisme par seed + tests.
  - DoD:
    - [ ] Avec seed fixe, séquence de messages stable; aucune modification d’objets/chemins en S3; tests 100%.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [ ] ADVT‑S3‑12: `ComputeScore(partiel)` — trésors/exploration/pénalités + tests.
  - DoD:
    - [ ] Calcule total = trésors + exploration − pénalités; valeurs attendues sur scénarios unitaires; tests verts.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [ ] ADVT‑S3‑13: Intégrer interactions dans `ApplyTurn` (routing) + autosave après mutation + tests d’intégration.
  - DoD:
    - [ ] `ApplyTurn` route par `category`; autosave appelée une fois par tour; tests d’intégration couvrent 2 interactions.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [ ] ADVT‑S3‑14: Mettre à jour `GameController` — journal append, timers lampe par tour, hook nains + tests.
  - DoD:
    - [ ] Journal conserve les 200 derniers messages; timers décrémentés si lampe allumée; nains hook exécuté; tests.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [ ] ADVT‑S3‑15: `InventoryPage` — liste + actions contextuelles + widget tests.
  - DoD:
    - [ ] Affiche objets portés; actions par item fonctionnelles; widget tests tap→perform OK.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (UX/labels/interactions).
- [ ] ADVT‑S3‑16: `MapPage` v1 — graphe des lieux découverts + goldens.
  - DoD:
    - [ ] Noeuds/arêtes rendus pour lieux visités; lieu courant mis en évidence; golden test stable.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (lisibilité, conventions UX).
- [ ] ADVT‑S3‑17: `JournalView` — append/trim/scroll bottom + tests.
  - DoD:
    - [ ] Ajoute en bas; tronque au‑delà du seuil; scroll automatique testé.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (UX/lecture/ordre de focus).
- [ ] ADVT‑S3‑18: Accessibilité de base — labels semantics sur actions et listes + vérifs.
  - DoD:
    - [ ] Tous boutons dotés de labels; tests semantics passent (where applicable);
    - [ ] Revue manuelle sur lecteur d’écran.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (a11y de base confirmée).
- [ ] ADVT‑S3‑19: Lint/Analyze — zéro warning; couverture Domain ≥ 85%.
  - DoD:
    - [ ] `flutter analyze` ok; rapport de couverture ≥ 85% sur Domain; build de test vert.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
- [ ] ADVT‑S3‑20: Déclarer et intégrer les images de scène — `pubspec.yaml` + widget `LocationImage`.
  - DoD:
    - [ ] `pubspec.yaml` liste les .webp présents; `LocationImage` affiche l’image quand disponible sinon placeholder;
    - [ ] Widget tests: image présente → rendue; image absente → placeholder, zéro exception.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (DA 16‑bit/palette/netteté/budgets).
- [ ] ADVT‑S3‑21: Audio — mapping zones→BGM + crossfade sur changement de zone.
  - DoD:
    - [ ] Crossfade audible propre; loop gapless validé; latence < 50 ms à l’oreille;
    - [ ] Tests unitaires: sélection de track par zone; intégration: appels AudioController au bon moment.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (mixage/DA audio).
- [ ] ADVT‑S3‑22: Audio — SFX d’interaction (prendre/poser/lampe/danger nain) + throttle.
  - DoD:
    - [ ] SFX déclenchés aux bons événements; pas de spam; volumes appliqués.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (DA audio/rendu UX).
- [ ] ADVT‑S3‑23: Art — livrer top 15–20 scènes (Asset Bible) + revue croisée.
  - DoD:
    - [ ] Scènes livrées, nommage `<key>` correct, contraintes et budgets respectés; validation croisée effectuée.
    - [ ] Revue de code CTO: séparation stricte (Domain vs UI), interactions/conditions encapsulées en use cases, tests Domain ≥ 85%.
    - [ ] Revue Game Designer validée (DA 16‑bit/netteté/conformité Asset Bible).

Références C (source canonique)

- open-adventure-master/actions.c
- open-adventure-master/misc.c
- open-adventure-master/advent.h
- open-adventure-master/hints.adoc
- open-adventure-master/notes.adoc
- open-adventure-master/tests/dwarf.chk
- open-adventure-master/tests/weirddwarf.chk
- open-adventure-master/tests/wakedwarves.chk
- open-adventure-master/tests/lampdim2.chk
- open-adventure-master/tests/lampdim3.chk
