# Asset Bible — Scenes, Characters, VFX/SFX (normatif)

Statut: Normatif. Cette bible guide la production artistique (images 16‑bit), les VFX minimalistes et les SFX. Elle complète `docs/CONVERSION_SPEC.md` (§17–§19), `docs/DESIGN_ADDENDUM.md` et s’aligne sur les lectures historiques du `docs/Dossier_de_Référence.md` (PNJ, ambiance 1977).

Règle d’or: images nettes (PixelCanvas, scale entier), ≤ 200 KB par scène, budget total art ≤ 10 Mo. Aucune animation lourde: overlays discrets seulement.

Suivi & reporting (obligatoire)

- Le suivi de production art/audio est généré automatiquement par script et publié dans `docs/ASSET_TRACKER.md`.
- Le script (spécifié ci‑dessous) ne modifie pas le runtime; il lit `assets/data/*.json` et liste les éléments attendus.

Asset Tracker — spécification de génération

- Entrées: `assets/data/{locations,objects,motions,actions,hints,classes,arbitrary_messages,obituaries,turn_thresholds,tkey,travel}.json`.
- Sorties: `docs/ASSET_TRACKER.md` contenant 3 tableaux Markdown:
  1) Locations (scènes):
     - Colonnes: `key` (mapTag|name_snake|id), `name`, `zone`, `image` (present ✓/✗, size KB, budget ≤ 200), `vfx` (overlay prévu ✓/✗), `bgm` (trackKey), `priority` (S3/S4), `owner`, `status`, `notes`.
     - Détection `image`: fichier `assets/images/locations/<key>.webp`; calcul taille; warning si > 200 KB.
  2) Objects (repères visuels/SFX):
     - Colonnes: `id/name`, `isTreasure`, `locations` (count), `sfx` (pickup/drop ✓/✗), `vfx` (sparkle/glow ✓/✗), `owner`, `status`.
  3) Audio (BGM/SFX):
     - Colonnes: `type` (bgm/sfx), `key`, `file` (present ✓/✗), `size KB`, `loop` (bgm), `throttle` (sfx), `owner`, `status`.
- Règles:
  - Aucune écriture d’assets; seulement lecture et génération Markdown.
  - Budgets: images ≤ 200 KB chacune (warning), pack images ≤ 10 Mo (résumé haut de page); audio BGM pack ≤ 8 Mo, SFX ≤ 1 Mo.
  - Les colonnes `owner`, `status`, `notes` sont laissées vides et remplies manuellement par l’équipe.
- Commande attendue: `python3 scripts/generate_asset_tracker.py`.

## 1) Scènes prioritaires (S3 Must‑Have)

Clé d’image: `locationImageKey(Location)` = `mapTag` > `name_snake_case` > `id`. Chemin: `assets/images/locations/<key>.webp`.

- LOC_START — Route et maison de puits (surface)
  - Mood: clair, forêt, ruisseau.
  - Composition: maison à droite, cours d’eau en avant‑plan.
  - Palette: verts/ocres naturels, ciel bleu.
  - VFX: eau (shimmer discret, optionnel), lamp glow si lampe allumée.
  - SFX: ruisseau (BGM zone surface + SFX eau léger).
- LOC_BUILDING — Intérieur du puits (well house)
  - Mood: intérieur cosy, briques.
  - Composition: table simple, sources d’objets (lampe, clés, bouteille).
  - Palette: bruns/ocres, contraste doux.
  - VFX: étincelle trésor (si présent).
  - SFX: intérieur calme (BGM surface faible).
- LOC_VALLEY — Vallée et ruisseau
  - Mood: forêt, pierre humide.
  - Composition: lit rocheux, perspective diagonale.
  - Palette: verts froids, gris pierre.
  - VFX: eau légère.
- LOC_HILL — Sommet boisé
  - Mood: ouvert, route en pente.
  - VFX: aucun.
- LOC_ROADEND — Fin de route
  - Mood: lisière, arbres denses.
- LOC_GRATE — Grille d’accès
  - Mood: curiosité, grille saillante.
  - VFX: highlight de grille (subtil), trésor si déposé.
- LOC_CLIFF — Falaise
  - Mood: vertige, chasm au loin.
  - VFX: aucun.
- LOC_COBBLE — Salle pavée (sous terre)
  - Mood: pierre froide, torches absentes (lumière lampe).
  - Palette: gris/bleus, haut contraste lampe.
  - VFX: lamp glow (halo discret, overlay codé).
- LOC_DEBRIS — Salle des débris
  - Mood: encombrée, poussiéreuse.
  - VFX: poussière statique légère (overlay).
- LOC_PITTOP — Haut du petit puits
  - Mood: danger latent.
- LOC_MISTHALL — Hall des brumes
  - Mood: mystérieux, brume au sol.
  - Palette: gris froids, bleus; touches cyan.
  - VFX: brume (overlay semi‑opaque très léger, immobile ou parallax minimal).
- LOC_KINGHALL — Salle du roi
  - Mood: majesté, échos.
  - Palette: ambre/or sur pierre sombre.
  - VFX: scintillement trésor (si trésors présents).
- LOC_BIRDCHAMBER — Chambre de l’oiseau
  - Mood: alcôve paisible.
  - VFX: aucun (son > image).
- LOC_SOFTROOM — Salle douce (textures souples)
  - Mood: chaleureux, matières velours.
- LOC_ORIENTAL — Salle orientale
  - Mood: motifs géométriques, contraste coloré.
  - Palette: rouges profonds, cyan/teal accents.
- LOC_SWCHASM & LOC_NECHASM — Les deux rives du gouffre
  - Mood: brume verticale, pont rickety.
  - VFX: brume verticale (overlay discret), highlight pont.
- LOC_SECRET4 & LOC_SECRET6 — Antre du dragon
  - Mood: menace, teintes verdâtres.
  - VFX: souffle (halo vert intermittent optionnel), sang (état mort), pas de gore.
- LOC_BARRENROOM — Salle stérile
  - Mood: aride, brun/gris.

Note: la liste exhaustive des lieux est dérivable de `assets/data/locations.json`. Les scènes ci‑dessus couvrent le parcours critique S3 et les rencontres majeures.

## 2) Personnages/Créatures — Briefs visuels & VFX discrets

👉 Référentiel comportemental détaillé dans `docs/Dossier_de_Référence.md` §C ; s’en servir pour caler les poses/clins d’œil narratifs.

Les créatures sont intégrées dans les images de scène correspondantes (pas de sprites séparés). Utiliser silhouettes lisibles 16‑bit, détails par aplats.

- DWARF (apparitions aléatoires)
  - Silhouette: petite, trapue, hache, yeux rougeoyants minimes.
  - VFX: alerte danger (blink rouge discret en overlay optionnel), aucun mouvement lourd.
  - SFX: stinger « danger nain » court.
- PIRATE/GENIE (OBJ_30, furtif)
  - Silhouette: ombre furtive, sac de trésors.
  - VFX: étincelle brève lors de vol/dépôt trésor (sparkle).
  - SFX: tintin léger.
- DRAGON (SECRET4/SECRET6)
  - Silhouette: massif, écailles vertes, gueule ouverte (bars), variante morte (au sol, sang parcimonieux).
  - VFX: halo verdâtre très léger quand en vie.
  - SFX: souffle sourd/hiss.
- TROLL (CHASM)
  - Silhouette: burly, posture bloquante.
  - VFX: aucun; accent sur panneau « Pay troll ».
  - SFX: grognement court.
- BEAR (BARRENROOM)
  - Silhouette: imposant; variantes: féroce, assis, content.
  - VFX: aucun.
  - SFX: grognement; mastication sur feed.
- SNAKE (KINGHALL)
  - Silhouette: long corps, barre le passage; variante chassée.
  - VFX: langue bifide « tick » très discret (facultatif).
  - SFX: sifflement.
- BIRD (BIRDCHAMBER/forêt)
  - Silhouette: petit, vif.
  - VFX: aucun.
  - SFX: chant mélodieux, variations selon état (cage/libre).

## 3) Objets clés — Guidage visuel (intégrés aux scènes)

Objets visibles doivent ressortir par valeur/couleur sans rompre la palette.

- LAMP (LOC_BUILDING) — laiton brillant
  - Accent: reflets métalliques chauds; ON: halo discret autour.
  - SFX: lamp_on/off.
- KEYS (LOC_BUILDING) — trousseau
  - Accent: highlights spéculaires.
- BOTTLE (LOC_BUILDING) — variantes eau/huile
  - Accent: reflets liquides.
- GRATE (GRATE/BELOWGRATE) — grille massive
  - État: ouverte/fermée.
- ROD/ROD2 (DEBRIS/NOWHERE) — baguette noire
  - Accent: pointe marquée.
- DOOR (IMMENSE) — porte rouillée
  - État: rouillée/dérrouillée.
- PILLOW (SOFTROOM) — velours
  - Accent: texture douce.
- CHASM/BRIDGE (SWCHASM/NECHASM) — pont rickety
  - État: intact/détruit (wreckage en fond).

Note: la liste exhaustive des objets vient de `assets/data/objects.json`. Ce sous‑ensemble couvre les objets à forte salience visuelle S3.

## 4) VFX Overlay — Catalogue minimal (réutilisable)

- Sparkle trésor: 2–3 éclats, cycle 800–1200 ms, alpha faible.
- Lamp glow: halo circulaire semi‑opaque (multiplier) 10–20 px au centre de l’item.
- Mist drift: bandeau gras à alpha 0.1–0.2, déplacement subtil (optionnel S4).
- Water shimmer: bande fine ondulée, loop 1.2–1.6 s.

Implémentation: overlays légers (rendus Flutter, pas d’assets animés lourds); désactivables via Settings.

## 5) Audio — Cue Sheet minimale (S3)

👉 Vérifier les ambiances et cues décrits par l’historien (pirate, nains, lampe) afin de rester fidèle à l’imaginaire sonore d’origine.

- UI tap: clic doux 30–60 ms.
- Take/Drop: pick/drop brefs.
- Lamp on/off: switch.
- Dwarf alert: stinger court.
- Treasure discovered: jingle bref.
- Door open/close (rouillée): grincement.
- Bridge creak: bois qui craque.
- Dragon hiss: souffle sourd.

BGM zones (rappel): surface, grotte, rivière, sanctuaire, danger — crossfade 250–500 ms, loop gapless.

## 6) Palettes — Guides par zone

- Surface: verts/ocres, ciel bleu; contraste moyen.
- Grotte générique: gris/bleus froids; fort contraste lampe.
- Hall des brumes: gris neutres + cyan; brume au sol.
- Salle du roi: ambre/or + ombres bleues.
- Salle orientale: rouges profonds + cyan; motifs géométriques.
- Salle douce: pastels chauds; textures feutrées.
- Chasm: bleus/gris froids; profondeur marquée.
- Antre du dragon: verts maladifs + ocres sombres.

## 7) Livraison & QA

- Paquet S3: 20 scènes must‑have listées; .webp ≤ 200 KB chacune; naming strict; miniatures (facultatif) pour revue.
- QA device: vérif neteté (FilterQuality.none), lisibilité en ×2 et ×3, contrastes en thème sombre et clair (overlay noir possible).
- Checklists: respecter docs/CONVERSION_SPEC.md §17–§19 et docs/DESIGN_ADDENDUM.md.
