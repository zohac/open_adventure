# Exécution S2 — Moteur minimal (travel), UI v0, Autosave

Statut: exécutable immédiatement. Durée cible: 1 semaine (5 j/h).

Definition of Ready (DoR)

- `initialGame()` disponible et stable depuis S1; `assets/data/travel.json` validé (scripts/validate_json.py).
- `pubspec.yaml` déclare `assets/data/*` nécessaires et dépendances S2 (voir ci‑dessous).
- Choix de la lib de mocks acté: `mocktail` recommandé.
- Règles: aucune permission réseau; pas d’accès HTTP; seules permissions locales (FS via path_provider) sont autorisées.

Objectif S2

- Livrer un noyau jouable par boutons: calcul des actions de déplacement (`ListAvailableActions` — travel only), application d’un tour pour la navigation (`ApplyTurn` — goto uniquement), UI `AdventurePage` v0 affichant description et boutons d’actions, et autosave après chaque tour.

Dépendances S1 (doivent être vertes)

- Mappers Data ↔ Entities stables pour `locations.json`, `objects.json` (OK même si interactions non utilisées), `travel` embarqué, `motions.json` (pour labels).
- `AdventureRepository.initialGame()` opérationnel. Lecture d’assets déclarée dans `pubspec.yaml`.

Livrables

- Domain
  - `ListAvailableActions` (travel only).
  - `ApplyTurn` (navigation: `goto` → changement de lieu, `speak/special` ignorés en S2).
  - `Command` (VO), `TurnResult` (VO: `newGame`, `messages`).
- Application
  - `GameController` (ValueNotifier/BLoC sans dépendance UI) exposant `GameViewState` immuable.
  - Autosave orchestrée après tour réussi (`SaveRepository.autosave`).
- Presentation
  - `AdventurePage` v0: titre/description du lieu courant + liste de boutons d’actions (travel) + journal minimal.
- Data
  - `SaveRepository` (impl locale fichiers) avec `autosave` + `latest()`.

UI – livrables & DoD

- [ ] HomePage v0 (accueil)
  - DoD:
    - [ ] Affiche les boutons: Nouvelle partie, Continuer, Charger, Options, Crédits;
    - [ ] Bouton Continuer désactivé si autosave absente (`SaveRepository.latest()` retourne null);
    - [ ] Navigation vers chacun des écrans cible fonctionne; aucun crash si aucun slot.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.
- [ ] AdventurePage v0 (description + boutons travel + journal minimal)
  - DoD:
    - [ ] Affiche le titre et la description du lieu courant;
    - [ ] Rend une liste de boutons d’actions `category=travel` cohérente avec `ListAvailableActions`;
    - [ ] Tap sur un bouton met à jour titre/description du nouveau lieu; pas de jank observable;
    - [ ] Journal affiche le dernier message retourné par `TurnResult`;
    - [ ] Respect de §17 (UX Mobile): 3–7 actions visibles max; si >7, rendre 6 + bouton `Plus…`; labels/icônes motion normalisés; première visite = `longDescription`, revisites = `shortDescription`.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.
- [ ] Intégration GameController (injection par constructeur, état immuable)
  - DoD:
    - [ ] `init()` remplit l’état initial et `perform()` déclenche navigation + autosave;
    - [ ] Widget tests valident le cycle init→tap→render.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.
- [ ] Préparation images de scène (placeholder + mapping)
  - DoD:
    - [ ] Slot visuel réservé au-dessus du heading avec `AspectRatio(16/9)` et placeholder statique léger;
    - [ ] Utilitaire `locationImageKey(Location)` dans `lib/core/utils/location_image.dart` (prépare la clé: `mapTag` sinon `name` snake_case sinon `id`);
    - [ ] Si l’image est absente ou la feature désactivée, fallback textuel immédiat (zéro crash, zéro jank);
    - [ ] Tests: absence d’asset ne provoque pas d’exception et le layout reste stable.
    - [ ] Pixel‑perfect prêt: wrapper `PixelCanvas` (base 320×180) créé et utilisé par la zone visuelle; `FilterQuality.none` appliqué.
    - [ ] Revue Game Designer (UX): labels/directions conformes, 3–7 actions visibles + overflow « Plus… », long/short corrects, accessibilité de base.

Audio – livrables & DoD (bootstrap)

- [ ] AudioController (service Application) — bootstrap
  - DoD:
    - [ ] Mise en place `AudioController` (lecture BGM/SFX via `just_audio`) sans réseau, assets embarqués;
    - [ ] Gestion du cycle de vie (pause/resume sur `AppLifecycleState`), focus audio via `audio_session`;
    - [ ] API: `playBgm(trackKey, {crossfadeMs})`, `stopBgm()`, `playSfx(sfxKey)`, `setVolumes(bgm,sfx)`; logs dev propres.
- [ ] Settings audio (basique)
  - DoD:
    - [ ] Deux sliders en Settings: Volume Musique, Volume SFX; persistance simple (SharedPreferences);
    - [ ] Valeurs appliquées à l’`AudioController` au démarrage et en temps réel.

Contrats Domain (normatif)

```dart
class Command {
  final String verb;      // ex: "NORTH", "SOUTH" (motion normalisée)
  final String? target;   // ex: destination (name ou id) pour travel
  const Command({required this.verb, this.target});
}

class TurnResult {
  final Game newGame;
  final List<String> messages; // descriptions/journal à afficher
  const TurnResult(this.newGame, this.messages);
}

abstract class ListAvailableActions {
  Future<List<ActionOption>> call(Game current);
}

abstract class ApplyTurn {
  Future<TurnResult> call(Command command, Game current);
}
```

Algorithme — ListAvailableActions (travel only)

1) Récupérer le lieu courant: `loc = await repo.locationById(current.loc)`.
2) Lister les règles de voyage: `rules = loc.travel` (ou `repo.travelRulesFor(loc.id)`).
3) Filtrer les règles par condition satisfaite (S2: condition absente ou triviale — pas d’évaluation complexe; voir « Limitations S2 »).
4) Pour chaque règle eligible:
   - Si `action.type != 'goto'`, ignorer en S2.
   - Déterminer la destination: `destName = action.value` (string) → `destId = lookupIdByName(destName)`.
   - Pour chaque verbe de la règle `rule.verbs` (ex: ["NORTH", "N"]):
     - Normaliser via `motions.json` (synonymes → motion canonique), ajouter une `ActionOption`
       `{ id: "travel:$locId->$destId:$verb", category: 'travel', label: labelFor(verb, destName), icon: iconFor(verb), verb: verb, objectId: "$destId" }`.
5) Dédupliquer par destination (garder le verbe canonique), trier par heuristique: cardinales (N,E,S,O) puis vert/haut/bas, puis autres.

Algorithme — ApplyTurn (navigation)
Entrée: `Command(verb, target)`.

1) Récupérer lieu courant + règles: `rules = loc.travel`.
2) Identifier les règles où `verb ∈ rule.verbs` ET `action.type == 'goto'` ET condition triviale satisfaite.
3) Si multiple: appliquer la première selon l’ordre de définition.
4) Appliquer: `newLoc = destId`, `turns += 1`, mettre à jour `oldloc/newloc`, etc. (champs de `Game`).
5) Sorties: `messages = [Location.longDescription ?? shortDescription]`.
6) Retourner `TurnResult` puis déclencher autosave (Application layer).

Limitations S2 (assumées)

- Conditions complexes sur travel (lampe, portes, flooding…) non évaluées; on n’expose que les routes sans condition ou triviales. Les règles `special`/`speak` ne sont pas proposées.
- Pas d’inventaire, pas d’interactions d’objets, pas de nains.

Save/Autosave — portée S2

- Domain: définir `SaveRepository` minimal:

```dart
abstract class SaveRepository {
  Future<void> autosave(GameSnapshot snapshot);
  Future<GameSnapshot?> latest();
}

class GameSnapshot { // minimal S2
  final int loc;
  final int turns;
  final int rngSeed;
  const GameSnapshot({required this.loc, required this.turns, required this.rngSeed});
}
```

- Impl locale fichier (`applicationSupportDirectory/open_adventure/autosave.json`).
- `GameController` convertit `Game` → `GameSnapshot` après chaque tour.

GameController — responsabilités (S2)

- Exposer `state: GameViewState` avec `locationTitle`, `locationDescription`, `actions: List<ActionOption>`, `journal`.
- Méthodes: `init()`, `perform(ActionOption)`, `refreshActions()`.
- Orchestration:
  - `init()` → `repo.initialGame()` → `refreshActions()`.
  - `perform(option)` → construire `Command(verb=option.verb, target=option.objectId)` → `ApplyTurn` → maj `state` → autosave → `refreshActions()`.

AdventurePage v0 — exigences

- Affiche: AppBar (titre lieu), corps = description + liste de boutons d’actions (vertical) + zone « journal » (les derniers messages).
- Appui sur un bouton: désactivé pendant exécution; spinner léger si besoin; remonte `perform`.
- Accessibilité: `semanticsLabel` sur boutons, taille police réglable via paramètres système.

Fichiers à créer/mettre à jour

- `lib/domain/usecases/list_available_actions.dart`
- `lib/domain/usecases/apply_turn.dart`
- `lib/domain/value_objects/command.dart`, `lib/domain/value_objects/turn_result.dart`
- `lib/application/controllers/game_controller.dart`
- `lib/data/repositories/save_repository_impl.dart`, `lib/domain/repositories/save_repository.dart`
- `lib/presentation/pages/adventure_page.dart` (impl v0)
- `lib/core/utils/location_image.dart` (mapping de clé d’image, sans IO)
- `lib/presentation/widgets/pixel_canvas.dart` (scale entier + letterboxing; aucun lissage)
- `lib/application/controllers/audio_controller.dart` (service Application; sans UI)

Dépendances S2 (pubspec)

- Production: `path_provider` (saves sur FS), `shared_preferences` (volumes audio), `just_audio`, `audio_session`.
- Test: `mocktail`.

Sprint DoD (S2)

- `AdventurePage` v0 jouable: navigation par boutons (travel only), journal mis à jour, autosave après chaque tour.
- `GameController` testé (init/perform/autosave); `ListAvailableActions`/`ApplyTurn(goto)` couverts.
- Slot image prêt (placeholder + PixelCanvas), sans jank ni crash si image absente.
- Audio bootstrap opérationnel (api AudioController + sliders Settings) sans glitch; pas de dépendance réseau.

Tests & validations (S2)

- Domain
  - `ListAvailableActions` retourne ≥1 action sur un lieu avec travel non conditionné; labels et verbes cohérents avec `motions.json`.
  - `ApplyTurn` avec `goto` met à jour `loc` et incrémente `turns`; renvoie la description attendue.
- Application
  - `GameController.init()` produit un `state` avec actions non vides si travel simple disponible.
  - `perform()` applique la navigation et déclenche `SaveRepository.autosave` (mocké) exactement 1 fois.
- Presentation (widget tests)
  - `AdventurePage` affiche description + N boutons; tap sur un bouton met à jour le titre/description (pump + settle).
  - `AdventurePage` limite l’affichage à ≤7 boutons d’action et affiche `Plus…` si overflow; première visite rend « long », seconde rend « short ».
- Non‑régression perfs: interaction < 16 ms; aucun jank sur le parcours tap→render.

Definition of Done (S2)

- `flutter analyze` sans warnings; tests S2 verts; couverture Domain (S2) ≥ 80%.
- Navigation jouable via boutons à partir de l’écran d’accueil vers au moins 10 lieux connectés sans conditions.
- Autosave disponible: relance de l’app → reprise au dernier lieu.

Risques & mitigations (S2)

- Règles travel dépendant de conditions non gérées: filtrer côté `ListAvailableActions` pour n’exposer que les règles triviales; tracer les omissions pour S3 (backlog).
- Ambiguïté des verbes (synonymes): normaliser via `motions.json` et définir une table `canonicalMotion[alias]`.
- Régressions UI: widget tests sur `AdventurePage` + goldens basiques pour le layout.

Suivi & tickets

- [x] ADVT‑S2‑01: Créer VOs `Command` et `TurnResult` (Domain) + tests basiques d’immutabilité.
  - DoD:
    - [x] Classes final/const, sans setters; égalité basée sur valeur; tests de construction/égalité passent.
    - [x] `Game` (et les structures qu’il embarque) exposent une égalité/hashCode structurés afin que `TurnResult` compare réellement les valeurs.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue Game Designer validée (UX/labels, si applicable).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑02: Implémenter `ListAvailableActions` (travel only) — normalisation via `motions.json`, déduplication, tri heuristique.
  - DoD:
    - [x] Retourne uniquement des actions `category=travel`; verbes normalisés; pas de doublons; ordre déterministe testé.
    - [x] Canonicalisation alimentée par `motions.json` (chargée/calculée, pas de table hardcodée) et production de labels/icônes ARB.
    - [x] Filtre toute règle `condtype` ≠ `cond_goto`/`0` et toutes les règles `stop=true` tant que l’évaluateur de conditions n’est pas en place.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue Game Designer validée (UX/labels/icônes, si applicable).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑03: Tests `ListAvailableActions` — cas: plusieurs verbes même destination, absence de condition, vérif labels/icônes.
  - DoD:
    - [x] ≥ 5 cas couverts; labels lisibles; icônes mappées pour N/E/S/O et UP/DOWN (si présents sur le lieu).
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue Game Designer validée (UX/labels/icônes, si applicable).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑04: Implémenter `ApplyTurn` (goto) — mutation `Game` (loc, oldloc/newloc, turns++), production messages description.
  - DoD:
    - [x] Mise à jour cohérente des champs; message contient `longDescription` si disponible sinon `short`.
    - [x] Met à jour `visitedLocations` pour respecter la règle « première visite = long, revisite = short », et `initialGame()` marque déjà le lieu de départ comme visité.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑05: Tests `ApplyTurn` — transition de lieu, intégrité `turns`, messages non vides.
  - DoD:
    - [x] Trois cas: normal, verb sans règle (échec attendu), multi‑règles → prend la première; tous verts.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑06: Implémenter `SaveRepository` minimal (autosave/latest) — fichiers JSON, répertoires platform‑aware.
  - DoD:
    - [x] Autosave écrit un fichier `autosave.json` valide; latest lit et reconstruit `GameSnapshot`.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑07: Tests `SaveRepository` minimal — round‑trip autosave/latest, gestion absence d’autosave.
  - DoD:
    - [x] Latest retourne `null` si fichier absent; round‑trip préserve valeurs; tests isolés du FS réel.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑08: Implémenter `GameController` — `init/perform/refreshActions`, binding autosave, état immuable.
  - DoD:
    - [x] `init()` renseigne état; `perform()` notifie changements; dépendances injectées par constructeur; tests unitaires verts.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑09: Tests `GameController` — `init()` produit actions, `perform()` appelle autosave exactement 1 fois (mock), met à jour l’état.
  - DoD:
    - [x] Vérification avec mockito: une seule invocation d’autosave par tour; journal mis à jour.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑10: Implémenter `AdventurePage` v0 — description + boutons d’actions (travel) + journal minimal.
  - DoD:
    - [x] Rendu stable; aucun `UnimplementedError`; état contrôlé par injection du contrôleur.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue Game Designer validée (UX/flow, si applicable).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑11: Widget tests `AdventurePage` — rendu initial, tap bouton → mise à jour description/titre.
  - DoD:
    - [x] Deux tests passent sur simulateur de widget; pumpAndSettle sans jank apparent.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue Game Designer validée (UX/labels, si applicable).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑12: Normaliser motions — table `canonicalMotion[alias]`, mapping icônes/labels (UI utils) + tests utilitaires.
  - DoD:
    - [x] Aliases courants couverts (N,S,E,W,NE,NW,SE,SW,UP,DOWN,IN,OUT); tests de mapping verts.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue Game Designer validée (icônes/labels, si applicable).
    - [ ] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑13: Gestion d’absence d’actions (lieu cul‑de‑sac non conditionné) — afficher message et action « Observer ».
  - DoD:
    - [x] UI affiche un fallback; pas de crash; test dédié.
    - [x] Revue CTO validée (architecture/code/tests).
    - [x] Revue Game Designer validée (UX/visuel, si applicable).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑14: Lint/Analyze — zéro warning; vérifier tailles de listes, null‑safety.
  - DoD:
    - [x] `flutter analyze` zéro warning; CI locale verte.
    - [x] Revue CTO validée (lint/qualité).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑15: Mesure perf manuelle — interaction bouton→render < 16 ms; consigner dans note d’implémentation.
  - DoD:
    - [x] Mesure notée (screenshot devtools ou log); pas de frame au‑delà de 16 ms sur action simple.
      - Samsung Tab A8 (profil) — interaction « Aller Nord » : Build 1.5 ms / Layout 3.4 ms / Raster 12.4 ms (aucun jank).
      - POCO F4 (120 Hz) — interaction « Aller Nord » : Build 1.4 ms / Layout 6.6 ms / Raster 4.5 ms (jank signalé car budget 8.3 ms @120 Hz, conforme <16 ms).
    - [x] Revue CTO validée (perfs mesurées).
    - [x] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [x] ADVT‑S2‑16: Préparer l’intégration des images — slot UI + utilitaire `locationImageKey` + tests de fallback.
  - DoD:
    - [x] Fichier utilitaire créé et testé; AdventurePage v0 affiche un placeholder stable; absence d’asset ne loggue pas d’erreur.
    - [ ] Revue CTO validée (architecture/code/tests).
    - [ ] Revue Game Designer validée (cadrage visuel, si applicable).
    - [ ] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [ ] ADVT‑S2‑17: Audio — bootstrap `AudioController` + cycle de vie + focus.
  - DoD:
    - [ ] `AudioController` instanciable en test; `playBgm/stopBgm/playSfx` n’échouent pas (mocks);
    - [ ] Pause/resume appelé sur changement de lifecycle; pas d’accès réseau; pas de crash.
    - [ ] Revue CTO validée (architecture/audio/focus/tests).
    - [ ] Revue Game Designer validée (volumes défaut, si applicable).
    - [ ] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [ ] ADVT‑S2‑18: Audio — Settings volumes Musique/SFX persistés et appliqués.
  - DoD:
    - [ ] Modifs de sliders reflétées instantanément; persistance testée; restaurées au démarrage.
    - [ ] Revue CTO validée (architecture/persistance/tests).
    - [ ] Revue Game Designer validée (UX audio, si applicable).
- [ ] ADVT‑S2‑19: Theme/tokens baseline (VISUAL_STYLE_GUIDE)
  - DoD:
    - [ ] Définir `ThemeData` (ColorScheme, TextTheme, spacing scale) et styles de base (boutons/listes);
    - [ ] Appliquer les règles 16‑bit: `PixelCanvas`/FilterQuality.none intégrés au layout, pas de lissage;
    - [ ] Revue CTO validée (archi/qualité/tests);
    - [ ] Revue Game Designer validée (cohérence visuelle avec VISUAL_STYLE_GUIDE).
- [ ] ADVT‑S2‑20: HomePage v0 (wireframe UX_SCREENS)
  - DoD:
    - [ ] Menu minimal: [Nouvelle partie] [Continuer] [Charger] [Options] [Crédits]; “Continuer” affiche autosave si présent (sinon disabled);
    - [ ] Navigation fonctionnelle vers chaque écran (placeholders acceptés); widget tests tap→route OK;
    - [ ] Revue CTO validée (UI/tests);
    - [ ] Revue Game Designer validée (structure/wording UX_SCREENS).
    - [ ] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [ ] ADVT‑S2‑21: Prise en charge du mouvement `BACK/RETURN` (retour arrière) — Domain/Application/UI.
  - DoD:
    - [ ] `ListAvailableActionsTravel` expose une option `category=travel` « Revenir » lorsque `Game.oldLoc` reste accessible et qu’aucune condition `COND_NOBACK` ne bloque la marche arrière;
    - [ ] `ApplyTurnGoto` gère `motion=BACK` en suivant l’historique (`oldLoc/oldLc2`) sans passer par `travel.json`, en respectant les règles forcées et les lieux sans retour;
    - [ ] `GameController` conserve l’historique requis pour le retour, déclenche `perform()` sur l’action « Revenir », journal mis à jour;
    - [ ] Widget tests AdventurePage: présence du bouton « Revenir » dans un cul-de-sac, tap → retour à la salle précédente → autosave invoquée;
    - [ ] Revue CTO validée (architecture/code/tests);
    - [ ] Revue Game Designer validée (libellés/flow « Revenir »);
    - [ ] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.
- [ ] ADVT‑S2‑22: Tests de non-régression `BACK` — scénarios de retour bloqué/autorisé.
  - DoD:
    - [ ] Tests Domain (ApplyTurn) couvrant: retour simple, retour via lieu forcé, retour impossible (`COND_NOBACK`) → message adéquat;
    - [ ] Tests Application (GameController) vérifiant qu’un retour invalide ne modifie pas l’état et que l’historique est mis à jour sur navigation normale;
    - [ ] Widget test garantissant qu’aucune option « Revenir » n’apparaît sur un lieu initial sans historique;
    - [ ] Revue CTO validée (architecture/code/tests);
    - [ ] Revue de code CTO: architecture respectée (Domain pur, Data passive, UI sans logique), qualité (lint OK, noms/clarté), tests suffisants.

Références C (source canonique)

- open-adventure-master/make_dungeon.py
- open-adventure-master/advent.h
- open-adventure-master/main.c
- open-adventure-master/adventure.yaml
- open-adventure-master/tests/mazealldiff.chk
- open-adventure-master/tests/tall.chk
- open-adventure-master/tests/plover.chk
- open-adventure-master/tests/domefail.chk
