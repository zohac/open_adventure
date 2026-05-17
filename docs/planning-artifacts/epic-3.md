# Sprint 3 — Interactions, Inventaire, Nains, Lampe, Scoring partiel, Map/Journal, Images, Audio zones

> **Source canonique des DoD détaillés** : [`docs/EXEC_S3.md`](../EXEC_S3.md) (Suivi & tickets ADVT‑S3‑01 → ADVT‑S3‑23).
> Cet epic est une **vue BMad** dérivée de l'EXEC ; en cas de divergence, EXEC_S3 prime.

## Epic 3: Sprint 3 — Boucle interactive enrichie

**Status:** in-progress
**Goal:** Étendre le noyau jouable avec les interactions d'objets, l'inventaire, première itération des nains, gestion lampe, scoring partiel, vues Map/Inventaire/Journal, images de scène et audio par zones.
**Acceptance:** `flutter analyze` zéro warning, tests S3 verts, couverture Domain S3 ≥ 85 %, jouabilité Take/Drop/Open/Close/Light/Extinguish/Examine, lampe fonctionnelle, premières rencontres nains.

### Story 3.1: EvaluateCondition (carry/with/not/at/state/prop/have)
**Status:** done
**Source ticket:** ADVT‑S3‑01
**Goal:** 7 types évalués correctement ; `not` couvert ; couverture ≥ 90 % sur ce module.

### Story 3.2: ListAvailableActions — catégories interaction + meta
**Status:** done
**Source ticket:** ADVT‑S3‑02
**Goal:** Options Inventaire/Observer/Carte + ≥ 2 interactions valides ; pas de doublons ; tri sécurité > travel > interaction > méta.

### Story 3.3: TakeObject use case
**Status:** done
**Source ticket:** ADVT‑S3‑03
**Goal:** Objet lieu → inventaire ; refus immovable avec message spécifique ; tests succès/échec.

### Story 3.4: DropObject use case
**Status:** done
**Source ticket:** ADVT‑S3‑04
**Goal:** Objet inventaire → lieu courant ; message au journal ; tests verts.

### Story 3.5: OpenObject use case (états + clé requise)
**Status:** done
**Source ticket:** ADVT‑S3‑05
**Goal:** Bascule state OPEN ; description cohérente ; échec si clé manquante (cas triviaux S3).

### Story 3.6: CloseObject use case
**Status:** done
**Source ticket:** ADVT‑S3‑06
**Goal:** Bascule state CLOSED ; messages corrects ; tests couverts.

### Story 3.7: LightLamp use case (batterie + flags)
**Status:** done
**Source ticket:** ADVT‑S3‑07
**Goal:** Bascule allumée ; compteur non négatif ; message d'avertissement au seuil ; échec batterie vide.

### Story 3.8: ExtinguishLamp use case
**Status:** done
**Source ticket:** ADVT‑S3‑08
**Goal:** Bascule éteinte ; pas de décrément au tour suivant ; tests verts.

### Story 3.9: Examine use case (description contextuelle)
**Status:** done
**Source ticket:** ADVT‑S3‑09
**Goal:** Description adaptée porté/en vue ; message non vide ; tests.

### Story 3.10: InventoryUseCase (rendu texte)
**Status:** done
**Source ticket:** ADVT‑S3‑10
**Goal:** Liste formatée stable ; tests objets multiples, ordre défini.

### Story 3.11: DwarfSystem.tick minimal (apparition/déplacement)
**Status:** done
**Source ticket:** ADVT‑S3‑11
**Goal:** Avec seed fixe, séquence de messages stable ; aucune modification objets/chemins ; tests 100 %.

### Story 3.12: ComputeScore partiel (trésors/exploration/pénalités)
**Status:** done
**Source ticket:** ADVT‑S3‑12
**Goal:** Total = trésors + exploration − pénalités ; valeurs attendues sur scénarios unitaires.

### Story 3.13: Intégrer interactions dans ApplyTurn (routing + autosave)
**Status:** done
**Source ticket:** ADVT‑S3‑13
**Goal:** ApplyTurn route par `category` ; autosave appelée 1× par tour ; tests d'intégration sur 2 interactions.

### Story 3.14: GameController — journal + timers lampe + hook nains
**Status:** done
**Source ticket:** ADVT‑S3‑14
**Goal:** Journal trim aux 200 derniers ; timers décrémentés si lampe allumée ; hook nains exécuté ; tests.

### Story 3.15: InventoryPage (liste + actions contextuelles)
**Status:** done
**Source ticket:** ADVT‑S3‑15
**Goal:** Objets portés affichés ; actions par item fonctionnelles ; widget tests tap → perform.

### Story 3.16: MapPage v1 (graphe multi-couches + goldens)
**Status:** backlog
**Source ticket:** ADVT‑S3‑16
**Goal:** Chargement `assets/data/map_layout.json` + `GameController.mapGraph` ; CustomPainter PixelCanvas (≤ 200 KB/couche, max 5) ; chips de couche M3 ; zoom/drag léger ×0,75–×1,5 ; semantics labels ; goldens par couche + test sérialisation MapGraph.
**Refs:** [`docs/Cahier_des_charges_Map.md`](../Cahier_des_charges_Map.md), [`docs/CTO_DEV_MAP_REQUEST.md`](../CTO_DEV_MAP_REQUEST.md).

### Story 3.17: JournalView (append/trim/scroll bottom)
**Status:** backlog
**Source ticket:** ADVT‑S3‑17
**Goal:** Append en bas ; tronque au seuil (~200) ; scroll automatique testé ; widget test valide append + scroll.

### Story 3.18: Accessibilité de base (semantics + a11y)
**Status:** backlog
**Source ticket:** ADVT‑S3‑18
**Goal:** Labels semantics sur tous boutons et listes ; tests semantics passent ; revue manuelle sur lecteur d'écran.

### Story 3.19: Lint/Analyze + couverture Domain ≥ 85 %
**Status:** backlog
**Source ticket:** ADVT‑S3‑19
**Goal:** `flutter analyze` zéro warning ; rapport couverture ≥ 85 % sur Domain ; build de test vert.

### Story 3.20: Déclarer et intégrer images de scène (LocationImage)
**Status:** backlog
**Source ticket:** ADVT‑S3‑20
**Goal:** `pubspec.yaml` liste les `.webp` présents ; `LocationImage` affiche l'image quand disponible sinon placeholder ; widget tests fallback OK.

### Story 3.21: Audio — mapping zones → BGM + crossfade
**Status:** backlog
**Source ticket:** ADVT‑S3‑21
**Goal:** Crossfade audible propre ; loop gapless validé ; latence < 50 ms ; tests unitaires sélection track par zone ; intégration appels AudioController au bon moment.

### Story 3.22: Audio — SFX d'interaction + throttle
**Status:** backlog
**Source ticket:** ADVT‑S3‑22
**Goal:** SFX déclenchés (prendre/poser/lampe/danger nain) ; pas de spam (throttle 100–200 ms) ; volumes appliqués.

### Story 3.23: Art — livrer 15–20 scènes prioritaires (Asset Bible)
**Status:** backlog
**Source ticket:** ADVT‑S3‑23
**Goal:** Scènes livrées, nommage `<key>` correct, contraintes et budgets respectés (≤ 200 KB/image, total ≤ 10 Mo) ; revue croisée dev/art.
**Refs:** [`docs/ART_ASSET_BIBLE.md`](../ART_ASSET_BIBLE.md).
