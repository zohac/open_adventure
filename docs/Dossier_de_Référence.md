# Dossier de Référence — Colossal Cave Adventure & Open Adventure

*(par Tristan Maher-Kent, historien du jeu vidéo)*

---

## 1. Histoire et Évolutions

### 1.1 Origines

- **1976** — Will Crowther développe la première version d’*Adventure* sur PDP-10 en FORTRAN.
  - Inspiré par ses explorations de Mammoth Cave (Kentucky).
  - Version rudimentaire : exploration de grotte, peu d’objets, sans scoring formalisé.

### 1.2 Extension Don Woods (1977)

- Ajout de la dimension fantastique (dragon, trésors, magie).
- Mise en place d’un système de **scoring** (objectif : 350 points).
- Diffusion large via ARPANET.

### 1.3 La version 430 points (1978 → 1995)

- Évolution dite **Adventure 2.x**.
- Ajout de zones, objets, puzzles supplémentaires.
- **1995** : consolidation dans la version **Adventure 2.5** (430 points).

### 1.4 Ports et variantes

- Multiples forks non “mainline” : 550, 660 points (extensions communautaires).
- Diffusions sur Unix (BSD Games), PC (1981), DOS, etc.
- Important : **ne pas confondre** ces variantes avec la ligne principale Crowther/Woods.

### 1.5 Open Adventure (2017 → )

- Projet mené par **Eric S. Raymond** avec l’accord de Crowther & Woods.
- Traduction C moderne de *Adventure 2.5*.
- Données en **YAML** compilées en C structs.
- Licence libre BSD 2-clauses.

---

## 2. Mécaniques de Jeu

### 2.1 Exploration

- Déplacements textuels : N, S, E, O, UP, DOWN, IN, OUT.
- Commande historique **BACK/RETURN** : revient au lieu précédent (sauf `COND_NOBACK`), gère les transitions forcées (`oldlc2`).
- Cartographie souterraine (Hall of Mists, Maze of Twisty Passages…).

### 2.2 Objets et inventaire

- Objets portables : lampe, clés, cage, trésors…
- Objets fixes : fissure, porte rouillée…
- Gestion des états (lampe allumée/éteinte, plante arrosée, dragon vivant/mort…).

### 2.3 Personnages et aléas

- **Nains** : hostiles, apparaissent aléatoirement, peuvent lancer une hache.
- **Pirate** : vole les trésors, les dépose dans sa caverne.
- **Créatures diverses** : serpent, dragon, ours, troll.

### 2.4 Conditions spéciales

- **Lampe** : durée limitée, recharge via batterie.
- **Eau/Huile** : nécessaires pour certains puzzles.
- **Phrases magiques** : déclenchent des téléportations ou solutions de puzzles.

---

## 📚 Addendum — Vue d’ensemble historienne & prête à l’emploi (Open Adventure 430)

*(Sources primaires : `adventure.yaml`, `score.c`, `actions.c` ; documentation : `history.adoc`, `notes.adoc`.)*

### A. Comment le jeu « pense » — Boucle de tour (vision macro)

1) **Entrée** : intention (verbe+objet / mouvement).  
2) **Résolution** : d’abord **travel** (déplacement), sinon **actions** (interaction), sinon **incompréhension**.  
3) **Événements** : PNJ (nains/pirate), timers (lampe), états de fin (`closng/closed`).  
4) **Mise à jour** : lieu, objets, flags, score partiel.  
5) **Sortie** : description + messages → tour suivant.

**Invariants** : règles de **travel** contextuelles ; **actions** conditionnelles (objet présent/porté, état valide) ; nains/pirate **uniquement souterrain**.

**Flags majeurs** : `dflag` (profondeur/nains), `closng/closed`, `bonus`, `numdie`, `trnluz`, `novice`.

### B. Taxonomie des commandes → UI sans clavier (boutons)

- **Travel** : N, S, E, O, NE, NO, SE, SO, UP, DOWN, IN, OUT.  
  - Inclure **BACK/RETURN** (bouton « Revenir ») si un chemin inverse existe et que la salle n’est pas `COND_NOBACK`.  
- **Interaction** : TAKE/DROP, OPEN/CLOSE, LIGHT/EXTINGUISH, FEED, THROW, ATTACK, READ, WAVE, FILL/POUR, UNLOCK/LOCK…  
- **Meta** : LOOK/EXAMINE, INVENTORY, SCORE, HELP, SAVE/LOAD.

**Règle mobile** : afficher **3–7** choix utiles par tour. Priorité : **sécurité** (lampe/danger) → **navigation** (incl. `BACK/RETURN`) → **objets** → **méta**.  
**Nota** : les **mots magiques** ne sont **pas** listés par défaut (préservation de la découverte ; voir § 7.1) et ne peuvent être injectés que lorsque le joueur a appris l’incantation.

### C. PNJ historiques — Nains & Pirate (lecture gameplay)

**Nains (pression dynamique)**  
- **Où/quand** : **souterrain** après les premières galeries.  
- **Comportement** : errance ; s’ils partagent votre salle → **jet de couteau** (souvent loupé, parfois mortel).  
- **Contre-jeu** : **lancer la hache** ; **nourrir** un nain **aggrave** son agressivité.  
- **Endgame** : en **closed**, leur nuisance **s’atténue**.

*UI* : journal “Un nain apparaît…”, bouton **Lancer la hache** visible **seulement** si nain présent + hache.

**Pirate (friction économique)**  
- **Où/quand** : jamais surface/Well House ; privilégie profondeur/maze.  
- **Comportement** : **vole les trésors**, laisse un **billet**, **cache** tout dans sa **planque** (impasse du Maze).  
- **Conséquence** : **aucune perte définitive** ; il **retarde** la validation des points (dépôt Well House).

*UI* : journal “Un pirate vous détrousse…”, puis “Vous retrouvez la planque…”. Icône “trésor sécurisé” quand déposé.

### D. Scoring historique — tableau d’audit

| Catégorie | Principe canonique | Points (430) | Note d’usage |
|---|---|---:|---|
| **Découverte trésor** | Chaque trésor trouvé | +2 | Une fois par trésor |
| **Dépôt trésor** | Dépôt à la **Well House** | +10 / +12 / +14 | Avant coffre / coffre / après coffre |
| **Progrès** | Entrée “réelle” en grotte | +25 | Déclenche “vie souterraine” |
| **Closing** | Fin enclenchée (`closng`) | +25 | Jalons de fin |
| **Closed → issue** | Sortie en grotte fermée | +10/25/30/45 | none / splatter / defeat / victory |
| **Survie** | (3 − morts) × 10 | ≤ +30 | Cap historique = 30 |
| **Witt’s End** | Magazine à Witt’s End | +1 | Clin d’œil |
| **Arrondi** | Ajustement final | +2 | Tradition |

**Malus** : indices (barème), **novice** −5, indice de closing −10, **temps** `trnluz`, **sauvegardes** `saved`.

### E. Carte conceptuelle (zones & passages clés)

Surface ↔ **Debris Room** (XYZZY) ↔ **Hall of Mists** → **Maze** (planque pirate) / **Pont de cristal** (bâton noir) / **Dragon** / **Serpent** / **Rivière** → **Sanctuaire** → **Closing/Closed**.  
Invariants : le **maze** exige **cartographie** ; certains barrages exigent **objet** ou **mot**.

### F. Mots magiques — politique d’expérience (rappel historien)

Piliers : **XYZZY**, **PLUGH**, **PLOVER**, **FEE/FIE/FOE/FOO**. L’UI n’en **affiche pas** les libellés par défaut ; le journal ne montre que **l’effet**.  
👉 La **présentation UX** des incantations relève du **Game Designer** (voir § 7.1 “DDR-001”).

### G. Sauvegardes — contrat minimal

- **Autosave** après **chaque tour** + **slots** manuels.  
- Snapshot recommandé :  
  `loc`, `visited`, `turn`, `scorePartial`, `inventory[]`, `objectsState{}`, `flags{dflag,closng,closed,bonus,novice}`, `hintsUsed[]`, `rngSeed`.  
- **Compat ascendante** (même major).

### H. Déterminisme & tests (héritage “seed”)

- **Seed** fixe ⇒ rencontres nains / vol pirate **reproductibles**.  
- **Oracles** (voir § 7.4) : 3 scripts de non-régression (navette mots magiques ; nain présent/absent ; vol→récup→dépôt).

### I. Pièges & bonnes pratiques (joueur)

- **Nains** : ne pas **nourrir** ; garder la **hache** ; lancer **uniquement** si nain présent.  
- **Pirate** : **banquer** tôt ; s’il vole, **planque** → reprise → dépôt.  
- **Lampe** : anticiper les **batteries** (430).  
- **Maze** : la carte n’expose que le **déjà visité** (option par défaut).

### J. Références (primaires & secondaires)

Primaires : *Open Adventure* (`adventure.yaml`, `actions.c`, `score.c`, `saveresume.c`), `history.adoc`, `notes.adoc`.  
Secondaires : Jimmy Maher (*The Digital Antiquarian*), Tristan Donovan (*Replay*), Steven L. Kent (*The Ultimate History of Video Games*), IFWiki/IFArchive.

---

## 2.5 Nains & Pirate — mécanique de jeu (version « ligne principale » 350/430, Open Adventure fidèle)

> ⚠️ Léger spoiler de gameplay (comportements des PNJ, pas de solutions d’énigmes complètes).

### 2.5.1 Les Nains (Dwarves)

**Résumé** — Ennemis souterrains ; **jets de couteaux** lors des rencontres ; **seule riposte fiable** : **lancer la hache**. Les **nourrir** les **énerve**. En **closed**, leur pression diminue.  
**Procédure** — (1) Première incursion : un nain rate son coup ; la **hache** apparaît tôt. (2) Rencontres ultérieures : attaque s’ils partagent la salle. (3) Lancer la hache **uniquement** s’ils sont là (sinon elle tombe).  
**Table** — Zones actives : **souterrain** ; score : **aucun** pour les tuer (enjeu = **survie** et **tours**).

### 2.5.2 Le Pirate

**Résumé** — Cible **uniquement** les **trésors** ; laisse un **billet** ; cache tout dans une **planque** du **Maze** ; **aucune perte définitive**.  
**Procédure** — Vol → billet → planque → reprise du lot → dépôt Well House. **Récidive possible** tant que vous portez des trésors.  
**Table** — Lieux sûrs : **surface** & **Well House** ; score : retard d’encaissement, pas de malus permanent.

---

## 3. Scoring et Mots Magiques

### 3.1 Scoring (règles canoniques 430 points — Open Adventure)

> Source primaire : open-adventure / `score.c`. (Titres internes : `dflag`, `closng`, `closed`, `bonus`, etc.)

**Barème positifs** — Découverte de trésor **+2** ; dépôt **+10/12/14** ; Progrès **+25** ; Closing **+25** ; Issue en closed **+10/25/30/45** ; Survie **≤ +30** ; Witt’s End **+1** ; Arrondi **+2**.  
**Malus** — Indices (barème), **novice −5**, indice closing **−10**, **tours** `trnluz`, **sauvegardes** `saved`.  
**Implémentation** — Itère `is_treasure`; dépôt si `place==LOC_BUILDING` & `found`; ordre : positifs → déductions ; **classe finale** via `classes[]`.

### 3.2 Scoring (version 350 points — repères)

Logique similaire mais **pondérations** et **plafond** différents (350), bonus d’“endgame” moins développés (spécifiques 430).

### 3.3 Mots magiques (liste)

> ⚠️ Spoiler léger.

| Mot | Effet | Conditions | 350/430 | Origine | Note |
|---|---|---|:--:|---|---|
| **XYZZY** | Building ↔ Debris | Uniquement dans ces pièces | ✔︎ | Crowther | Conservé |
| **PLUGH** | Building ↔ Y2 | “Hollow voice” à Y2 | ✔︎ | Woods | Conservé |
| **PLOVER** | Plover ↔ Y2 | Bypass Dark Room | ✔︎ | Woods | Conservé |
| **FEE/FIE/FOE/FOO** | Rappelle les œufs | Séquence en Giant’s Room | ✔︎ | Woods | Conservé |

---

## 4. Open Adventure — Différences Modernes

- **Fidélité stricte** au gameplay 2.5 (430).  
- Changements **réversibles** via `-o` (oldstyle).  
- Données `adventure.yaml` → C idiomatique ; options : `seed`, `version`, prompt `>`, alias (`l`,`x`,`z`,`i`,`g`).  
- **Sauvegardes robustes**, **seed** pour rejouabilité/QA.

---

## 5. Annexes (sources)

Primaires : `open-adventure-master/` (`score.c`, `actions.c`, `saveresume.c`, `adventure.yaml`), `history.adoc`, `notes.adoc`.  
Secondaires : Maher, Donovan, Kent ; IFWiki, IFArchive.

---

## 6. Puzzles difficiles ou controversés (repères)

Gouffre & bâton noir (pont de cristal), Dragon (attaque verbale), Œufs d’or & pirate (planque), Troll (péage), Vase Ming (coussin), Serpent (oiseau), Labyrinthes (cartographie), Witt’s End (cul-de-sac), Géant (séquence), Coffre (portage).

---

## 7. Adaptation Mobile — Décisions à figer (CTO & Game Designer)

> Objectif : supprimer les ambiguïtés d’exécution tout en respectant l’ADN historique.

### 7.1 DDR-001 — **Incantations (mots magiques) : politique UX**

- **Option A — Fidélité pure (recommandation historienne par défaut du dossier)**  
  Les mots restent **secrets** tant que le joueur ne les a pas découverts in-universe (oiseaux, billets, stèles, indices). Une fois révélés, l’UI ajoute uniquement dans les **lieux concernés** un bouton contextuel « Utiliser l’incantation » libellé avec le mot appris — jamais de liste globale. Aucun coût additionnel n’est imposé : seule l’utilisation d’un **indice** conserve la pénalité historique déjà codifiée.
- **Option B — Mixte (exception “clavier ciblé”)**  
  UI boutons + champ “incantation” **contextuel** (apparition seulement dans les pièces concernées). Les mots ne sont pas listés.
- **Option C — Gamey (zéro clavier, UX guidée)**  
  Cartouches d’incantation **déverrouillées** par découverte/indice ; bouton “Utiliser l’incantation” proposé **après** déblocage.

> **À trancher par le Game Designer.** Le présent dossier retient **Option A** tant qu’un DDR signé ne dit pas le contraire.  
> Si **Option B** est choisie, elle introduit une **unique exception** à la règle “zéro clavier”.

### 7.2 Appendice d’équilibrage historique (exposition UX/QA)

- **Lampe** : durée en tours, seuil d’alerte texte, cadence de messages de batterie faible.  
- **Nains** : cadence moyenne de rencontre, fréquence de jet raté/réussi, atténuation en `closed`.  
- **Pirate** : déclencheur d’apparition (port de trésors, zones), planque unique dans le Maze, immunité surface/Well House.

> *But* : rendre vérifiable l’équilibre **sans** ouvrir le code C. (Valeurs détaillées à reprendre telles quelles de `adventure.yaml`/`actions.c` dans un tableau interne de production.)

### 7.3 Sauvegarde — **exemple JSON minimal** (schéma V1)

```json
{
  "schema_version": 1,
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

### 7.4 Oracles seedés — tests de fidélité

- O1 — Navette mots magiques : Building ↔ Debris (XYZZY), Building ↔ Y2 (PLUGH) → vérif locales/texte.
- O2 — Nain : état avec/ sans nain présent → “Lancer la hache” visible/absent ; issue du lancer ; journal attendu.
- O3 — Pirate : port de trésors → vol (billet) → planque (récup) → dépôt → score.

> Comparaison : messages (tolérance espaces) + états (loc, inventaire, score, flags).

### 7.5 Accessibilité — Definition of Done (AA)

- Polices : 3 crans min ; contrastes AA (clair/sombre).
- Focus : ordre déterministe (image → titre → description → actions → barre).
- Semantics : labels complets sur tous boutons ; journal annoncé par lot.
- Option texte-seul : désactivation images (faible RAM).

### 7.6 Cibles matérielles & perfs

- Golden devices QA : Android A53 (2019), iPhone XR/11.
- Budgets : cold start <1,0 s, interaction 60 fps, mémoire <150 Mo.
- Cache images/audio : LRU simple, plafond RAM configurable (par défaut ~32–48 Mo art, ~4–8 Mo audio décodé).

### 7.7 Plan des Indices (UX)

- Opt-in via bouton Indices ; jamais intrusif.
- Pénalités conformes au barème historique.
- Texte d’indice contextuel (lieu/état), non spoilant au premier niveau (niveaux 1→2→solution).

### 7.8 DDR — Registre de décisions

- DDR-001 Incantations (A/B/C) — par défaut : A (fidélité pure).
- DDR-002 Carte/minimap — n’affiche que les salles visitées (icônes clés facultatives).
- DDR-003 Messages de sécurité — autoriser un pré-avertissement lampe faible (non présent en 1977) : NON par défaut ; OUI seulement avec drapeau “accessibilité”.

## 8. Open Adventure — Différences Modernes (rappel)

- Fidélité stricte 2.5/430 ; changements techniques réversibles (`-o`).
- Données YAML → C ; options `seed`, `version`, prompt `>`, alias (`l`,`x`,`z`,`i`,`g`).
- Sauvegardes robustes ; rejouabilité par seed.

## 9. Annexes (sources & lectures)

`Primaires` : `open-adventure-master`/ (`score.c`, `actions.c`, `saveresume.c`, `adventure.yaml`), `history.adoc`, `notes.adoc`.
Secondaires : Maher (Digital Antiquarian), Donovan (Replay), Kent (Ultimate History), IFWiki/IFArchive.

## 10. Puzzles difficiles — mémo d’équipe

Gouffre/bâton noir (pont), Dragon (attaque verbale), Œufs/pirate (planque), Troll (péage), Vase Ming (coussin), Serpent (oiseau), Labyrinthes (carto), Witt’s End (cul-de-sac), Géant (séquence), Coffre (portage).

## 🔎 Conclusion

Le présent dossier suffit pour guider CTO & Game Designer vers une adaptation mobile offline fidèle à Open Adventure.

Les points sensibles UX (incantations, carte, messages de sécurité) sont explicitement remis à l’arbitrage GD via DDR, sans altérer la fidélité historique par défaut.

Les oracles seedés, l’exemple de sauvegarde et l’appendice d’équilibrage donnent aux devs & QA des repères actionnables et testables.

```makefile
::contentReference[oaicite:0]{index=0}
```
