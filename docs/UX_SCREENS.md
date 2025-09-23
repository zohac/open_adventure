# Spécification UX — Écrans et Composants (normatif)

Statut: Normatif. Cette annexe complète `docs/CONVERSION_SPEC.md` (§17–§19) et l’exécution S2–S4. Tout écart doit être amendé ici avant implémentation.

Règle d’or (non négociable): sur les écrans d’action, afficher 3–7 choix réellement utiles, accessibles au pouce, sans saisie texte.

## Principes transverses

- Catégories d’actions: `travel`, `interaction`, `meta` (Inventaire/Observer/Carte/Menu toujours disponibles).
- Priorité d’affichage: sécurité/urgence → travel → interaction → méta; bris d’égalité: label asc (localisé), puis id dest, puis nom objet.
- Overflow: S2 = 6 + bouton `Plus…`; S3+ = scroll/pagination; cibles tactiles ≥ 48×48 dp.
- Descriptions: première visite = `long`, revisit = `short`; `Observer` rejoue la `long` si elle existe.
- Journal: append-only, 200 derniers messages, zéro echo des commandes.
- Images: 16:9 via `PixelCanvas` (scale entier, FilterQuality.none), clé `locationImageKey`.
- Audio: BGM par zone (crossfade 250–500 ms), SFX throttle ≥ 150 ms.
- Incantations: DDR-001 Option A (voir `docs/Dossier_de_Référence.md`) → aucun mot affiché avant découverte; après apprentissage, seul un bouton contextuel dans les salles concernées est autorisé.
- Style visuel: couleurs, typo, composants et motion conformes à `docs/VISUAL_STYLE_GUIDE.md`.

Notation & conventions

- Wireframes: grille 320×180 (base art), composés verticalement. Les zones sont indicatives, l’UI finale est responsive.
- Contrats d’événements: format `UI → Application → Domain → Data` listant l’input, la commande `Command(verb,target?)`, la mutation attendue, puis persistance éventuelle.
- i18n: toutes les chaînes UI passent par ARB (`app.*`, `menu.*`, `actions.*`, `labels.*`). Aucune chaîne dure.

---

## HomePage

- But: accueillir, relancer, créer, configurer.
- Entrées: cold start; retour depuis EndGame/Settings.
- Contenu: logo, boutons `Nouvelle partie`, `Continuer` (autosave), `Charger`, `Options`, `Crédits`.
- Actions: `Nouvelle` → `initialGame`; `Continuer` → `SaveRepository.latest`; `Charger` → `SavesPage`; `Options` → `SettingsPage`; `Crédits` → `CreditsPage`.
- États vides: `Continuer` désactivé si autosave absente.
- A11y: semantics boutons, ordre de focus stable, texte lisible.
- DoD: navigation correcte vers chaque écran; autosave absente ne provoque pas d’erreur.
- Style visuel: conforme à `VISUAL_STYLE_GUIDE.md` §10 (Style A — Héros 16:9 + cartes AccentCard avec barre d’accent 3–4 dp, icônes 24 dp, états enabled/pressed/disabled/focused, mapping d’accents par entrée Home).

Wireframe (320×180, schématique)

```txt
[ LOGO ]

[ Nouvelle partie ]
[ Continuer (slot: date) ]
[ Charger ]
[ Options ] [ Crédits ]
```

Contrats d’événements

- Nouvelle partie → Application: `controller.initNew()` → Domain: `AdventureRepository.initialGame()` → Autosave immédiate (optionnel S2) → Route `Adventure`.
- Continuer → Application: `saveRepo.latest()` → si null: désactivation (aucune action); sinon Domain: `load snapshot` → Route `Adventure`.
- Charger/Options/Crédits → Navigation vers pages dédiées.

i18n clés minimales

- `home.title`, `home.newGame`, `home.continue`, `home.load`, `home.options`, `home.credits`.

## AdventurePage (v0→v2)

- But: écran principal de jeu.
- Entrées: Home (Nouvelle/Continuer/Charger), retour onglets.
- Contenu commun: image 16:9 (optionnelle), titre (lieu), description (long/short), liste d’actions (3–7 visibles), journal minimal.
- Bouton « Revenir »: affiché uniquement si le moteur expose le mouvement BACK/RETURN (historique valide, lieu non `COND_NOBACK`), positionné en tête de la section travel.
- Incantations: aucun bouton ni champ permanent avant découverte; après apprentissage, un seul bouton contextuel apparaît dans les salles actives (zéro liste globale) ; toute autre solution exige un DDR.
- V0 (S2): `travel only`, overflow `Plus…`, Observer rejoue la description, autosave après tour.
- V1 (S3): regroupement par catégories, pagination/scroll, intégration onglets, images intégrées, BGM par zone.
- V2 (S4): StatusBar (score/tours/lampe), i18n, accessibilité finale.
- A11y: cibles ≥ 48dp, ordre de focus image→titre→desc→actions→bottom bar.
- DoD: 1re visite `long`; revisit `short`; interaction < 16 ms; fallback image silencieux.

Wireframe (v0 S2)

```txt
[ Image 16:9 (PixelCanvas) ]

Lieu courant (titre)
Description (long/short)

[ Action 1 ]
[ Action 2 ]
[ Action 3 ]
[ Action 4 ]
[ Action 5 ]
[ Action 6 ]
[ Plus… ]  # visible si >6

{ Journal (dernier message) }
```

Contrats d’événements

- Tap ActionOption → Application: `controller.perform(option)` → Domain: `ApplyTurn(Command(verb=option.verb, target=option.objectId))` → retourne `TurnResult` → Autosave → `controller.refreshActions()`.
- Observer (meta) → ne crée pas de mutation Domain; affiche description long/short selon règle; journal append.
- Onglets (v1) → Navigation interne; aucun reset d’état.

i18n clés minimales

- `actions.travel.north/east/south/west/up/down/in/out` (icône mappée, voir §17.4).
- `actions.meta.inventory`, `actions.meta.observe`, `actions.meta.map`, `actions.meta.menu`.
- `journal.title`, `journal.empty`, `adventure.title`.

## InventoryPage

- But: agir sur les objets portés.
- Contenu: liste d’items portés, actions contextuelles (Utiliser/Ouvrir/Fermer/Allumer/Éteindre/Poser).
- Actions: déclenchent `ApplyTurn` (routing interactions) + journal + refresh actions.
- États vides: message « Inventaire vide ».
- A11y: roles list + actions par item.
- DoD: invariants (pas de doublons, états cohérents) testés.

Wireframe

```txt
Inventaire

- [Nom objet A]  [Utiliser] [Poser]
- [Nom objet B]  [Allumer] [Éteindre]

(État vide: « Inventaire vide »)
```

Contrats d’événements

- Tap Utiliser/Ouvrir/Fermer/Allumer/Éteindre/Poser → Application: `controller.perform(option)` → Domain: use case dédié → journal + refresh actions.

i18n

- `inventory.title`, `inventory.empty`, `actions.use/open/close/light/extinguish/drop`.

## MapPage

- But: visualiser les lieux découverts et la position courante.
- Contenu: graphe noeuds/arêtes (découverts), surlignage du lieu courant; pan/zoom léger (optionnel).
- Actions: non mutantes (pas de téléportation).
- DoD: golden test stable; mise à jour après déplacement; zéro jank.

Wireframe

```txt
[  o----o    o ]
   |   /\   /
   o  o  o-o   * Vous êtes ici (badge)
```

Contrats

- Aucune mutation; `controller.mapGraph` dérivé des déplacements réalisés.

i18n

- `map.title`, `map.legend.youAreHere`.

## JournalView

- But: consulter l’historique (200 derniers messages).
- Contenu: liste chronologique, ancre bas.
- DoD: append/trim/scroll stables; accessibilité OK.

Wireframe

```txt
Journal
---------------------------------
[Dernier message]
[Message N-1]
[...]
```

Contrats

- Append géré côté `controller` après `TurnResult`. Trim à 200 messages (FIFO), scroll-to-bottom.

i18n

- `journal.title`, `journal.empty`.

## SavesPage

- But: gérer slots (charger/supprimer) et reprise.
- Contenu: liste triée par `updated_at` avec `title/progression/date`.
- Actions: `Charger`, `Supprimer` (confirmations), écraser lors de la sauvegarde manuelle.
- DoD: lecture tolérante (champs inconnus), suppression sûre.

Wireframe

```txt
Sauvegardes

[Slot 3] Titre — 57% — 2025-09-14   [Charger] [Supprimer]
[Slot 2] Titre — 12% — 2025-09-10   [Charger] [Supprimer]
(État vide: « Aucune sauvegarde »)
```

Contrats

- Charger → Application: `saveRepo.load(slot)` → Domain: `GameSnapshot` → Route `Adventure`.
- Supprimer → ConfirmationDialog → `saveRepo.delete(slot)` → refresh liste.

i18n

- `saves.title`, `saves.empty`, `saves.load`, `saves.delete`, `saves.confirmDelete`.

## SettingsPage

- But: préférences d’expérience.
- Contenu: thème clair/sombre, taille police, langue FR/EN, volumes BGM/SFX, toggle images de scène.
- Actions: sliders (appli immédiate), persistance SharedPreferences.
- DoD: préférences restaurées au relaunch; i18n complète (S4).

Wireframe

```txt
Paramètres

Thème       [ Clair | Sombre ]
Taille texte [---O-----]
Langue      [ FR | EN ]
Musique     [---O-----]
SFX         [---O-----]
Images scènes [ ON ]
```

Contrats

- Sliders/Toggle → Application: `settingsController.set*` → persistance `SharedPreferences` → application immédiate (volumes, thème, images on/off).

i18n

- `settings.title`, `settings.theme`, `settings.textScale`, `settings.language`, `settings.musicVolume`, `settings.sfxVolume`, `settings.sceneImages`.

## EndGamePage/Dialog

- But: conclure la partie, proposer rejouer/charger/crédits.
- Contenu: `ScoreBreakdown` (trésors, exploration, pénalités, indices, morts, bonus), classe, options.
- DoD: score conforme `ComputeScore`; gel des actions de jeu.

Wireframe

```txt
Fin de partie

Score: 243
Trésors: 130 | Exploration: 80 | Pénalités: -12 | Hints: -5 | Morts: -0 | Bonus: 50
Classe: « Adventurer »

[ Rejouer ]  [ Charger ]  [ Crédits ]
```

Contrats

- `ComputeScore` → `EndGame {reason, breakdown}` → affichage → boutons navigation.

i18n

- `end.title`, `end.score`, `end.class`, `end.playAgain`, `end.load`, `end.credits`.

## CreditsPage

- But: attribution/légal.
- Contenu: blocs concis, images légères.
- DoD: offline, performance stable.

## HintSheet (S4)

- But: indices contextuels (payants en score).
- Contenu: liste d’indices déblocables selon contexte, coût visible.
- DoD: malus appliqué une fois; idempotence.

## MenuSheet (in‑game)

- But: accès rapide aux utilitaires (Inventaire/Carte/Journal/Saves/Settings/Quitter).
- DoD: non intrusif, focus géré.

## ConfirmationDialog (global)

- But: confirmer actions destructives.
- DoD: clair, localisé, navigation accessible.

## ErrorRecoveryDialog/Page

- But: gérer corruption de sauvegarde et lecture d’asset échouée.
- Contenu: message, options (restaurer autosave saine / nouvelle partie).
- DoD: aucune crash path; reprise fiable.

## OnboardingOverlay (opt V1.1)

- But: didacticiel minimal (3 bulles) sur l’UX par boutons.
- DoD: non bloquant; resettable en Settings.

## DevDebugPanel (dev only)

- But: seed RNG, téléport test, lampe faible, logs audio.
- DoD: derrière flag; absent en release.

---

## Dependencies par sprint

- S2: HomePage, Adventure v0, Saves minimal (autosave/latest), Settings (volumes), Audio bootstrap.
- S3: Inventory, Map, Journal, Adventure v1 (regroupements), images lieux, BGM zones.
- S4: EndGame, Saves complets, Settings complets (thème/langue/police/images), HintSheet, polish UX.

## Tests normatifs par écran (extraits)

- Adventure: ≤7 actions visibles; overflow; `long/short`; tap→render < 16 ms.
- Inventory/Map/Journal: tap→perform; goldens Map; append/trim.
- Saves/Settings: round‑trip prefs/saves; confirmations destructives.
- EndGame: breakdown exact et navigation.
- Home: « Continuer » désactivé sans autosave; routage correct.

## Accessibilité — Checklist par écran

- Focus visible et ordre cohérent (image→titre→desc→actions→barre; listes: haut→bas; dialogues: bouton primaire en premier).
- Labels semantics sur tous les boutons (incluant actions dynamiques et « Plus… »).
- Taille de police: support d’au moins 3 crans (S4), pas de clipping ni d’overlap.
- Contrastes AA dans les deux thèmes; icônes accompagnées de libellés (pas d’icône seule informative).

## Budgets & performances par écran

- Adventure: tap→render < 16 ms; scroll fluide; image précachée; pas de jank lors des crossfades BGM.
- Inventory/Map/Journal: rebuild minimal (listes const/stables), aucun jank sur interactions courantes.
- Saves/Settings/EndGame: navigation instantanée (< 100 ms), IO asynchrone non bloquant.

## Matrice i18n — Préfixes

- Écran: `home.*`, `adventure.*`, `inventory.*`, `map.*`, `journal.*`, `saves.*`, `settings.*`, `end.*`, `credits.*`.
- Actions: `actions.travel.*`, `actions.meta.*`, `actions.interact.*`.
- Labels génériques: `labels.ok`, `labels.cancel`, `labels.delete`, `labels.load`, `labels.confirmation`.
