# Cahier des charges — Conversion « Open Adventure » (C) vers Flutter (Dart)

Statut: approuvé par l’architecture (exécutable). Ce document tient lieu de source de vérité technique. Il intègre l’audit du dépôt actuel et tranche sur « reboot vs. salvage » pour éliminer toute ambiguïté d’exécution.

Source de vérité & gestion des changements

- Cette documentation prime sur tout code existant. En cas de contradiction, aligner le code sur la doc.
- Toute modification de périmètre ou de décision technique doit être intégrée à ce document avant implémentation.
- Les scripts d’outillage (scripts/*.py) ne sont pas embarqués dans l’app; ils servent uniquement à générer/valider les assets.

Références normatives rattachées

- Annexe UX/Audio/Pixel‑Art: `docs/DESIGN_ADDENDUM.md` (règles §17–§19)
- Bible d’assets (art): `docs/ART_ASSET_BIBLE.md` (scènes prioritaires, VFX/SFX discrets, palettes)
- Écrans UX détaillés: `docs/UX_SCREENS.md` (wireframes + DoD par écran)

Résumé exécutif — décision non négociable:

- Reboot Flutter complet. On conserve uniquement: `assets/data/*.json` et la référence C dans `open-adventure-master/`. Les scripts de génération/validation vivent sous `scripts/` (`scripts/make_dungeon.py`, `scripts/extract_c.py`, `scripts/validate_json.py`).
- On jette (ou isole) le code Flutter existant (`lib/`), à l’exception de fragments de modèles JSON éventuellement réutilisables après revue. Aucune dépendance au fichier inexistant `assets/data/game.json` n’est tolérée.

Audit du dépôt — constats bloquants:

- UI inexistante: `lib/features/adventure/presentation/pages/adventure_page.dart:8` lance un `UnimplementedError`.
- Data source invalide: `GameLocalDataSource` lit `assets/data/game.json` qui n’existe pas; non déclaré dans `pubspec.yaml` → crash garanti au démarrage.
- Couverture fonctionnelle quasi nulle: absence de moteur de jeu (pas de `ApplyTurn`, pas de routeur de commandes), pas de gestion de sauvegardes, pas d’UX mobile.
- Tests limités aux assets (présence/forme) sans exécution de gameplay.
- Le C d’origine est complet et testé (`open-adventure-master/` + `adventure.yaml`). Les JSON dérivés sont valides et doivent devenir notre unique base de données embarquée.

Action immédiate:

- Écarter le code Flutter actuel (répertoire `lib/`) en attendant ré-architecture. On repart propre selon la structure ci-dessous.

## 1. Objectifs et périmètre

- Objectif: proposer une version mobile Flutter 100% offline du jeu textuel « Colossal Cave Adventure », jouable intégralement sans réseau, avec une qualité de code industrielle (Clean Architecture, tests, lint) et une UX adaptée au tactile.
- Plateformes: Android, iOS (builds `apk/ipa`).
- Langage: Dart (null-safety), Framework: Flutter stable.
- Données: embarquées comme assets; persistance locale (préférences/fichier). Aucune télémétrie.
- Performances: UI fluide (60 fps), chargement < 1s après cold start (>1ère exécution: assets warmup), parsing non bloquant (Isolates si nécessaire).

Toolchain & dépendances minimales

- Toolchain: Dart ≥ 3.0.0 < 4.0.0, Flutter stable 3.x.
- Dépendances de base: `equatable`, `collection`, `yaml` (S1), `path_provider`, `shared_preferences` (S2), `just_audio`, `audio_session` (S2). Tests: `flutter_test`, `test`, `coverage`, `flutter_lints`, `mocktail`.

Hors périmètre:

- Fonctionnalités réseau (cloud save, analytics, A/B testing), extensions natives non indispensables.

## 2. Exigences fonctionnelles

1) Boucle de jeu SANS saisie texte (UI par boutons)
   - Entrée: les actions possibles sont proposées sous forme de boutons contextuels (navigation, interaction, objets).
   - Sortie: en-tête (nom du lieu), image illustrative (optionnelle), description textuelle, score, nombre de tours.
   - Journal: fil consultable des évènements (sorties système), sans affichage des commandes tapées (puisqu’il n’y en a pas).
   - Commandes: navigation (N, S, E, O…), interactions (PRENDRE, LÂCHER, OUVRIR, FERMER, ALLUMER, ÉTEINDRE…), déduites des règles « travel » et « actions ».
   - Accessibilité: taille de police ajustable, focus/semantics sur les boutons.

2) Écran d’accueil et menu
   - Accueil: logo/visuel, boutons « Nouvelle partie », « Continuer », « Charger », « Options », « Crédits ».
   - Les sauvegardes récentes sont listées (titre, progression, date).
   - Option « Tutoriel » (facultatif V1.1).

3) État de jeu et progression
   - Gestion d’un état de monde (lieu courant, objets, flags, conditions, nains, lampe, score, fin de partie).
   - Système d’indices (hints) conforme aux règles d’origine.
   - RNG déterministe et « seedable » pour tests.

4) Sauvegarde/Chargement
   - Sauvegardes locales (autosave après chaque tour + slots manuels). Format JSON versionné.
   - Compatibilité ascendante du format au sein de la même major.

5) Accessibilité & UX mobile
   - UI lisible, thème clair/sombre, taille de police ajustable.
   - Aucun clavier virtuel (pas de saisie). L’UX est guidée par les boutons.

## 3. Contraintes qualitatives

- Couverture de tests élevée: Domain ≥ 90%, Data ≥ 80%, Presentation (widget) ≥ 60%.
- Analyse statique stricte (`flutter analyze`) + lints recommandées (code lisible, immutabilité, DI explicite).
- SOLID, KISS, DRY; code non-bloquant sur l’UI.

## 4. Architecture (Clean Architecture)

Séparation stricte des dépendances (UI → Application → Domain ← Data/Infrastructure):

- Domain (pur Dart, indépendant):
  - Entities: `Game`, `Location`, `Object`, `Action`, `Condition`, `TravelRule`, `Hint`, `Dwarf`, etc.
  - Value Objects: `Command`, `LocationId`, `ObjectId`, `Score`, `TurnCount`…
  - Repositories (interfaces): `AdventureRepository`, `SaveRepository`, `RngProvider`.
  - Use cases: `ParseCommand`, `ApplyTurn`, `GetCurrentDescription`, `SaveGame`, `LoadGame`, `ComputeScore`, `GetHints`…

- Application (orchestration):
  - GameController (ou Bloc/Cubit) orchestrant les use cases et exposant un `GameViewState` immuable.
  - CommandRouter (stratégie de résolution verbe+objet → use case/action).

- Data/Infrastructure (implémentations):
  - Data sources locales: `AssetDataSource` (lecture JSON des assets), `LocalSaveDataSource` (fichiers / shared_prefs).
  - Repositories implémentant les interfaces du Domain, sans fuite de détails (mapping Models ↔ Entities).
  - Décodage JSON en Isolates si taille > 1 Mo cumulé.

- Presentation (Flutter):
  - Pages: `AdventurePage`, `SettingsPage`, `SavesPage`.
  - Widgets: `ConsoleView` (journal), `CommandInput`, `StatusBar` (score, tours, lieu).
  - State management: BLoC/Cubit ou ValueNotifier + immutable state. Injection par constructeur uniquement.

Couplage: la dépendance pointe toujours vers Domain. Les assets et IO sont encapsulés en Data.

Décisions d’architecture explicites:

- Pas de « mega-model » `game.json`. Le state runtime est construit à partir des JSON atomiques (`locations.json`, `objects.json`, `travel.json`, `actions.json`, …) et persisté séparément via `SaveRepository` (snapshot JSON versionné).
- Toute logique de règles (travel/actions/conditions/score) vit dans Domain, pas dans les Models/Data. Aucune logique dans les widgets.
- Parsing lourd (≥ 1 Mo cumulé) déporté en Isolates à l’initialisation; UI non bloquante.
- Source unique pour les déplacements: utiliser exclusivement `assets/data/travel.json` (généré par `scripts/make_dungeon.py`). Ne pas mélanger avec des règles `travel` embarquées dans `locations.json`.

## 5. Modèle de données & assets

Assets embarqués (pubspec):

```bash
assets/
  data/
    actions.json
    conditions.json
    travel.json
    locations.json
    objects.json
    hints.json
    obituaries.json
    motions.json
    classes.json
    arbitrary_messages.json
    tkey.json
    turn_thresholds.json
  images/
    locations/
      <key>.webp  # 16:9, ≤200KB, offline only
  audio/
    music/
      <track_key>.ogg   # chiptune/16-bit loop, ≤ 600 KB/loop
    sfx/
      <sfx_key>.ogg     # bips/clicks/FX courts, ≤ 60 KB/SFX
```

Principes:

- Schémas JSON documentés; validations à l’initialisation (invariants et clés obligatoires).
- Mapping explicite Models ↔ Entities, sans logique métier dans les Models.
- Chargement lazy + cache mémoire; invalidation sur hot restart uniquement.
- Stratégie d’évolution: version de schéma dans un fichier `assets/data/metadata.json` (V1, V2…).
- Images: mapping `mapTag | name | id` → `assets/images/locations/<key>.webp`. Fallback textuel si manquant. Budget total art ≤ 10 Mo.
- Audio: offline only; formats OGG/Opus (48 kHz), mono pour SFX, stéréo pour BGM; budgets: musique ≤ 6–8 Mo (10–12 loops × ≤ 600 KB), SFX ≤ 1 Mo.
  - Boucles musicales « gapless » (points de loop testés), crossfade 250–500 ms lors des changements de zone; volume par défaut 60% BGM / 100% SFX.
- Images: mapping `mapTag | name | id` → `assets/images/locations/<key>.webp`. Fallback textuel si manquant. Budget total art ≤ 10 Mo.
- Style: pixel art 16‑bit (Megadrive/SNES‑like), voir section « Direction Artistique ».

Schémas JSON (extraits normatifs):

- `locations.json`: liste de `[name, { description:{short?,long?,maptag?}, sound?:string, loud?:bool, conditions?:{string:bool}, travel?: [ TravelRule ] }]`.
- `travel.json`: structure aplatie issue de `make_dungeon.py`; on l’expose via un mapper Data → `TravelRule` regroupé par `locationId`.
- `objects.json`: liste de `[name, { words:[string], inventory?:string, locations:string|[string], states?:[string], descriptions?:[string|[state,string]], sounds?:[string], changes?:[string], immovable?:bool, is_treasure?:bool }]`.
- `actions.json`: liste canonique des verbes + métadonnées d’UI (icône/label) si besoin d’enrichissement.

## 6. Découverte d’actions (sans saisie texte)

- Génération des options: un use case `ListAvailableActions` calcule, pour l’état courant, une liste d’options d’action présentables à l’utilisateur.
- Sources:
  - Règles `travel` filtrées par `locationId` → actions de navigation (ex: Aller Nord, Sud… avec labels directionnels).
  - Règles `actions` filtrées par contexte/conditions/objets → actions d’interaction (ex: Prendre la clé, Ouvrir porte).
- Modèle d’option:
  - `ActionOption { id, category (travel|interaction|meta), label, icon, commandVerb, commandObjectId? }`.
  - Les labels sont générés côté Application/Presentation, sans logique métier.
- Classement & regroupement:
  - Priorité 1: sécurité/urgence (lampes, danger), 2: navigation immédiate, 3: interactions d’objets, 4: méta (inventaire, observer, carte).
  - Pagination/scroll si > 8 options visibles.
- Exécution:
  - Le clic d’un bouton déclenche `ApplyTurn(Command(verb, objectId))`; le domaine reste inchangé (même moteur), seule la source des commandes diffère.

Résolution des options (normatif):

- `ListAvailableActions(Game)` agrège:
  - Déplacements: pour `current.locationId`, filtrer `TravelRule` dont `condition` est satisfaite → options `category=travel`, `verb=motion`, `value=dest` (ou `special/speak`).
  - Interactions: dérivées de `actions.json` + état objets en vue ou en inventaire + `conditions.json`.
- Les « specials » mappent vers des use cases dédiés (`SpecialAction_XYZ`) pour garder la lisibilité.

## 7. Moteur de jeu (Domain)

- Automate de tour: `ParseCommand` → `ApplyTurn` (évalue règles `travel`/`actions`, met à jour `Game`) → `ComputeOutput` (texte, score, fin de partie) → `Autosave`.
- RNG: interface `RngProvider` injectable, seedable pour tests.
- Gestion des nains et états spéciaux conformément aux règles classiques (déplacement pseudo-aléatoire, interactions).

Mapping C → Dart (obligatoire):

- `main.c` (boucle I/O) → `GameController` (Application) + `ApplyTurn` (Domain).
- `init.c` → `AdventureRepository.initialGame()` + mappers Data → Entities; initialisation de `Game` (états, timers, positions).
- `actions.c` → use cases par catégories: `DoInventory`, `Take/Drop/Open/Close/Light/Extinguish`, `Attack/Throw`, `Feed/Brief/Score`, etc.; parser des conditions et effets.
- `saveresume.c` → `SaveRepository` JSON (slots + autosave); compat ascendante intra-major.
- `score.c` → `ComputeScore` (tally, bonus, time/turn penalties) + `ScoreBreakdown` pour UI.
- `misc.c`, `cheat.c` → utilitaires internes (optionnel V1 pour cheat); à isoler derrière des flags debug.

Contrats use cases (signature indicative):

- `ApplyTurn(Command, Game) → Future<TurnResult>`
- `ListAvailableActions(Game) → Future<List<ActionOption>>`
- `SaveGame(slot, GameSnapshot) → Future<void>` / `LoadGame(slot) → Future<GameSnapshot>`
- `ComputeScore(Game) → ScoreBreakdown`

## 8. Sauvegarde locale

- `SaveRepository`: API `save(slot, GameSnapshot)`, `load(slot)`, `latest()`, `list()`, `delete(slot)`.
- Format JSON compact, compressible (optionnel), avec `schema_version` et `game_version`.
- Résilience: lecture tolérante (ignorer champs inconnus), corruption → message + fallback dernier autosave sain.

Détails d’implémentation:

- Emplacement iOS: `NSApplicationSupportDirectory/open_adventure/saves/`. Android: `filesDir/open_adventure/saves/`.
- Nom de fichier: `save_v{schemaVersion}_{slot}.json` + `autosave.json`.
- `GameSnapshot`: sous-ensemble strictement nécessaire (location courante, inventaire, flags, timers, score intermédiaire, seed RNG).

## 9. UI/UX – Détails

- Accueil (`HomePage`): menu principal (nouvelle partie, continuer, charger, options, crédits), affichage des sauvegardes.
- Jeu (`AdventurePage`):
  - En-tête: image du lieu (si disponible), titre (nom du lieu), description textuelle.
  - Boutons d’action: liste verticale des `ActionOption` calculées; largeur responsive, états `enabled/disabled` explicites.
  - Barre inférieure (BottomAppBar): `Carte`, `Inventaire`, `Journal`, `Menu`.
  - `Carte`: vue 2D offline du graphe des lieux (noeuds=lieux, arêtes=déplacements connus), position courante mise en évidence.
  - `Inventaire`: liste des objets portés avec actions contextuelles (utiliser, déposer…).
- `Journal`: fil des événements récents (textes système), scrollable.
- Accessibilité: semantics labels, tailles adaptatives, navigation au switch/lecteur d’écran.

Annexes et normes d’écran: voir `docs/UX_SCREENS.md` (normatif) décrivant le mandat, les entrées/sorties, DoD et tests par écran.

Localisation:

- V1 FR/EN embarquées via ARB; textes dynamiques (descriptions) restent issus des assets.

Art & VFX:

- Voir `docs/ART_ASSET_BIBLE.md` (normatif) pour listes prioritaires de scènes, briefs créatures/objets, VFX/SFX et palettes.
- Suivi de production: `docs/ASSET_TRACKER.md` (tableaux générés). Le générateur doit préserver le préambule normatif et ne remplacer que la section encadrée par `<!-- GENERATED_START/END -->`.

## 10. Tests

- Domain: tests unitaires exhaustifs des use cases (chemins heureux/erreurs), propriété d’invariants, RNG seedé.
- Data: tests de mapping Models↔Entities, parsers JSON (valid/invalid), data sources (fichiers manquants, corruption).
- Application: tests du `GameController` (command → transition d’état → sortie rendue).
- Presentation: widget tests pour `AdventurePage` (saisie, affichage, scrolling), golden tests basiques.
- Mocks: `mockito` pour repositories/data sources.

Harness de non‑régression par oracles C (option build local):

- Compiler `open-adventure-master/` en binaire local; rejouer un set de scénarios déterministes (seed fixée) → capturer sorties canoniques.
- Rejouer les mêmes scénarios via `GameController` → comparer descriptions/états clés (tolérance whitespace).
- Ces tests ne bloquent pas CI mobile (optionnels), mais ils verrouillent la fidélité du moteur.

## 11. Qualité, lint, CI

- Lint: `analysis_options.yaml` strict (pedantic-like + règles de null-safety, immutabilité, ordre des imports, etc.).
- CI minimal: `flutter analyze`, `flutter test --coverage`, artefacts de couverture.

Pipelines:

- Lint stricte (fail on warning), tests unitaires + widgets, rapport de couverture (minimas: Domain ≥ 90%, Data ≥ 80%, Presentation ≥ 60%).
- Job optionnel « data-validate »: exécuter `scripts/validate_json.py` pour vérifier la cohérence YAML → JSON.

## 12. Sécurité & confidentialité

- Aucune collecte de données. Données de jeu et sauvegardes locales uniquement.
- Permissions minimales (aucune permission sensible requise).

## 13. Arborescence cible

```bash
lib/
  domain/
    entities/
    value_objects/
    repositories/
    usecases/
  application/
    controllers/
    routing/
  data/
    datasources/
    models/
    repositories/
  presentation/
    pages/
      home_page.dart
      adventure_page.dart
      map_page.dart
      inventory_page.dart
      saves_page.dart
      settings_page.dart
    widgets/
      action_button_list.dart
      status_bar.dart
      journal_view.dart
  core/
    utils/
    di/
assets/
  data/ (JSON du jeu)
test/
  domain/... application/... data/... presentation/...
```

## 14. Plan de migration depuis C

- Lecture des règles: transposer `actions.c`, `score.c`, `saveresume.c` en Use Cases Dart; exploiter `make_dungeon.py` pour la logique `travel` et `tkey`.
- Données: utiliser les JSON présents comme source (pas de re-génération en runtime). Évolution des schémas via `metadata.json`.
- Validation croisée: scénarios canoniques « état → options → action → nouvel état → sorties »; oracle C optionnel.

Phasage exécutable (Semaine 1 à 4):

- S1: Scaffolding + Data mappers + `AdventureRepository` (lecture assets) + `initialGame()` + smoke tests.
- S2: Moteur minimal: `ListAvailableActions` (travel only) + `ApplyTurn` (navigate) + UI AdventurePage v0 (navigation via boutons) + autosave.
- S3: Interactions d’objets + inventaire + nains + lampe + scoring partiel; widget tests; map/inventaire/journal.
- S4: Scoring complet + fins de jeu + sauvegardes multiples + polissage UX + hardening (résilience, perfs) + CI verte.

## Timeline UI

- S1: aucun écran produit. Fondations uniquement (assets, mappers, `AdventureRepository`, `initialGame`).
- S2: `AdventurePage` v0 — description du lieu, boutons d’actions (travel only), journal minimal; `GameController` branché; autosave.
- S3: `AdventurePage` v1 + onglets; `InventoryPage`, `MapPage`, `JournalView`; actions d’interactions contextuelles; lampe/nains visibles via journal; images de scène (intégration de base, lazy, fallback).
- S4: `AdventurePage` v2 avec `StatusBar` (score/tours/lampe); `SavesPage`, `SettingsPage`, `EndGamePage/Dialog`; i18n et accessibilité finalisées; images polish (precache, cache, toggle Settings).

## Direction Sonore — 16‑bit (SNES/Megadrive‑like)

- Esthétique: chiptune/FM style 90s, patterns mélodiques courts, percussion simple, enveloppes marquées. Pas d’orchestrations réalistes.
- Organisation:
  - BGM par « zone/ambiance » (surface, grotte, rivière, sanctuaire, danger…). 30–60 s en loop.
  - SFX courts pour interactions (bouton, prendre/poser, lampe on/off, découverte, danger nain, succès/échec).
- Technique:
  - Formats: OGG/Opus 48 kHz; normaliser à −14 LUFS intégrée; pic ≤ −1 dBFS; éviter clipping.
  - Boucles: définir `loopStart`/`loopEnd` via édition/descripteur externe (doc de prod) + tests d’écoute; viser « gapless ».
  - Mixage: BGM −8 dB vs SFX 0 dB; ducking soft (−4 dB sur 200 ms) sur SFX importants (alerte/danger).
  - Impl Flutter: `just_audio` + `audio_session` (focus, ducking), service `AudioController` (Application), mapping clé→asset, preload léger.

## Direction Artistique — Pixel Art 16‑bit (SNES/Megadrive‑like)

- Résolution de base et scaling
  - Canvas logique: 320×180 (16:9) ou 384×216 selon confort de placement; scaling par facteur entier uniquement (x2, x3, x4…).
  - Affichage: letterboxing si nécessaire; jamais de mise à l’échelle non entière.
  - Rendu: `FilterQuality.none` sur toutes les `Image` pixel art; pas de lissage; alignement sur un « pixel grid ».

- Formats & pipeline d’assets
  - Source: PNG (palette) ou WebP lossless; sortie embarquée: WebP lossless si plus léger, sinon PNG.
  - Cible par image: ≤ 200 KB; total pack images ≤ 10 Mo.
  - Nommage: `assets/images/locations/<key>.webp` avec `<key>` = `mapTag` ou `snake_case(name)` ou `id`.
  - Palettes: limiter la palette par scène pour cohérence (≤ 32–64 couleurs); autoriser dithering léger.

- UI & typographie
  - Police bitmap (pixel font) embarquée pour titres/menus; texte de description en police lisible non pixellisée si nécessaire (accessibilité), avec option « police pixel » dans les paramètres.
  - Icônes: sprites 16×16/24×24 en pixel art; éviter les vecteurs lissés.

- Accessibilité & dark mode
  - Contrastes élevés AA; ne pas encoder de texte dans les images; `semanticsLabel` descriptif.
  - Mode sombre: ajustement de palette (teinte/saturation) ou overlay discret, sans flouter les pixels.

- Implémentation (guidelines Flutter)
  - Wrapper `PixelCanvas` calculant l’échelle entière `scale = floor(min(w/baseW, h/baseH))` et ajoutant letterboxing.
  - `Image(filterQuality: FilterQuality.none)` et `Transform.scale(scale, filterQuality: FilterQuality.none)` pour préserver les arêtes.
  - Préchargement: `precacheImage` sur l’image du prochain lieu après `ApplyTurn`.

## 15. Critères d’acceptation

- Le jeu se lance offline et reste jouable jusqu’aux fins prévues, avec sauvegarde/reprise.
- `flutter analyze` sans warnings bloquants; tests verts avec couvertures cibles atteintes.
- Scénarios de commande → transition d’état validés (tests d’intégration Domain/Application).

Budgets & perfs:

- Démarrage à froid < 1,0 s sur milieu de gamme (A53/2019), interaction 60 fps, utilisation mémoire < 150 Mo en régime nominal.
- Bundle Android < 30 Mo (sans assets images additionnelles V1).

## 16. Risques et mitigations

- Complexité des règles historiques → documenter et encapsuler les invariants; tests de non-régression systématiques.
- Volume d’assets → parsing en Isolates + cache; monitoring simple de temps de chargement en dev.
- Ambiguïtés de parsing utilisateur → table de synonymes et messages d’erreur actionnables.

---

Annexe B — Exécution & Gouvernance

Découpage des tâches (exécutif):

- Data: mappers JSON↔Entities (locations, objects, travel, actions, hints, motions).
- Domain: `ApplyTurn`, `ListAvailableActions`, `ComputeScore`, `Save/Load` + entités immuables, RNG injecté.
- Application: `GameController`, routeur de commandes, autosave.
- Presentation: `AdventurePage`, `action_button_list`, `journal_view`, `status_bar`, `inventory_page`, `map_page`.
- Outils: validateur JSON, scripts de comparaison avec C, seed fixtures.

Définition de Done (DoD):

- Tests verts, lint zéro warning, couverture respectée, perfs conformes, UX accessible, sauvegardes robustes, scénarios canoniques passants.

---

Annexe A — Interfaces (extrait indicatif)

```dart
/// Représente une commande utilisateur normalisée (verbe, objet, etc.).
class Command {
  final String verb;
  final String? object;
  const Command({required this.verb, this.object});
}

/// Dépendance principale du domaine pour accéder aux données du monde.
abstract class AdventureRepository {
  Future<Game> initialGame();
  Future<Location> locationById(String id);
  Future<List<TravelRule>> travelRulesFor(String locationId);
  Future<List<ActionRule>> actionRulesFor(Command command, String locationId);
}

/// Orchestrateur d’un tour de jeu.
abstract class ApplyTurn {
  Future<TurnResult> call(Command command, Game current);
}

/// Calcule les actions disponibles pour l’état courant (UI par boutons).
abstract class ListAvailableActions {
  Future<List<ActionOption>> call(Game current);
}

/// Option d’action présentable à l’utilisateur (sans logique métier dans la classe).
class ActionOption {
  final String id;
  final String category; // e.g. 'travel', 'interaction', 'meta'
  final String label;    // UI label localisé
  final String? icon;    // nom d’icône Material si besoin
  final String verb;     // mappé vers Command.verb
  final String? objectId; // mappé vers Command.object
  const ActionOption({
    required this.id,
    required this.category,
    required this.label,
    this.icon,
    required this.verb,
    this.objectId,
  });
}
```

## 17. UX Mobile — Normes d’Interaction (normatif)

- Règle d’or: à tout instant, proposer 3–7 choix réellement utiles, accessibles au pouce, sans saisie texte.
- Absence de clavier virtuel: aucune saisie libre; toutes les commandes sont déduites et proposées sous forme de boutons.

17.1 Génération des options (source unique)

- Use case: `ListAvailableActions(Game)` (voir §6) agrège et normalise, Data ne contient aucune logique d’UI.
- Catégories: `travel`, `interaction`, `meta` (toujours visibles: `Inventaire`, `Observer`, `Carte`, `Menu`).
- Dédoublonnage: options identiques (même `verb`+`objectId`) sont fusionnées; conserver la première occurrence déterministe.
- Canonicalisation: verbes motion normalisés via `motions.json` (alias→canonique). L’UI ne présente que le canonique.
- Conditions: en S2 ne retenir que les règles triviales (sans condition). En S3+, appliquer `EvaluateCondition`.

17.2 Priorisation et tri (déterministe)

- Priorité 1: sécurité/urgence (lampe faible, danger nain) → actions `Light/Extinguish/Retreat` si applicables.
- Priorité 2: navigation immédiate (`travel/goto`).
- Priorité 3: interactions d’objets (`Take/Drop/Open/Close/Examine/Use`).
- Priorité 4: méta (`Inventaire`, `Observer`, `Carte`, `Menu`).
- Tiebreakers: (a) label asc (localisé), (b) destination id croissant pour travel, (c) object name asc.

17.3 Surface et overflow

- Visible simultané: max 7 boutons d’action (hors bottom bar). Si >7, rendre les 6 premiers + un bouton `Plus…` ouvrant la liste complète (S3: pagination/scroll au lieu de `Plus…`).
- Taille des cibles tactiles: ≥ 48×48 dp, espacement vertical 8–12 dp, focus order linéaire descendant.
- Fallback « cul‑de‑sac »: si aucune option `travel`/`interaction` n’est disponible, l’UI présente au minimum `Observer`, `Carte`, `Inventaire`.

17.4 Libellés & icônes (génération UI)

- Travel: `Aller ${directionLabel}` (N, S, E, O, NE, NO, SE, SO, HAUT, BAS, ENTRER, SORTIR). Icônes Material: `{N:arrow_upward, S:arrow_downward, E:arrow_forward, O:arrow_back, NE:north_east, NO:north_west, SE:south_east, SO:south_west, HAUT:arrow_upward, BAS:arrow_downward, ENTRER:login, SORTIR:logout}`.
- Interaction objet: `${verbeUI} ${objetDisplayName}` (ex: `Prendre la clé`, `Ouvrir la porte`).
- Méta: `Inventaire`, `Observer`, `Carte`, `Menu` (localisés via ARB; pas de logique dans Domain/Data).
- Cas longs: troncature label à ~32–40 caractères avec ellipsis, `Semantics.label` complet conservé.

17.5 Descriptions (long/short) et « Observer »

- Première visite d’un lieu: utiliser `longDescription` si disponible, sinon `shortDescription`.
- Revisites: utiliser `shortDescription` par défaut.
- Action `Observer` (méta): ré‑affiche la `longDescription` du lieu courant quand elle existe, sinon `shortDescription`.
- Le journal enregistre le texte effectivement affiché (pas la commande).

17.6 Journal (rendu et rétention)

- Fil chronologique des messages système produits par `ComputeOutput`/use cases; aucune écho de commandes.
- Rétention: conserver les 200 derniers messages; suppression FIFO au‑delà, sans jank.
- Accessibilité: `Semantics` activés, annonces par lot (dernier message), support lecteur d’écran.

17.7 Accessibilité (AA)

- Police ajustable (3 crans min.), contrastes conformes (thèmes clair/sombre), focus visible.
- Ordre de focus: image → titre → description → liste d’actions (haut→bas) → bottom bar.
- Labels semantics exhaustifs pour tous boutons; `tooltip` facultatif, pas de dépendance au survol.

17.8 Images de lieu (offline, optionnelles)

- Slot visuel 16:9 au‑dessus du titre; rendu via `PixelCanvas` (scale entier, `FilterQuality.none`, letterboxing noir).
- Clé d’image: `locationImageKey(Location)` = `mapTag` si présent sinon `name` en snake_case ASCII sinon `id`.
- Chemin: `assets/images/locations/<key>.webp`. Poids ≤ 200 KB/image, total art ≤ 10 Mo.
- Fallback: si asset manquant ou feature désactivée → placeholder statique; zéro exception, zéro jank.
- Preload: `precacheImage` de l’image du prochain lieu immédiatement après un `ApplyTurn` réussi.

17.9 Audio (offline only)

- BGM par zone (surface/grotte/river/sanctuary/danger). Formats OGG/Opus 48 kHz, −14 LUFS intégrée, pic ≤ −1 dBFS.
- Volumes par défaut: 60% BGM / 100% SFX. Crossfade 250–500 ms lors d’un changement de zone; boucles gapless.
- SFX: taps, prendre/poser, lampe on/off, alerte nain, découverte. Anti‑spam (throttle ≥ 150 ms pour répétitions).

17.10 Performances & budgets

- Interaction tap→render < 16 ms; démarrage à froid < 1,0 s; mémoire nominale < 150 Mo.
- Parsing assets non bloquant (Isolate au‑delà de 1 Mo cumulés; flag S1/S4).

17.11 Tests normatifs (extraits)

- `ListAvailableActions`: ≥1 action sur lieu avec travel trivial; max 7 visibles; ordre conforme aux priorités.
- `ApplyTurn(goto)`: met à jour `loc`, `turns++`, renvoie description attendue (long→short selon visite).
- Widget: `AdventurePage` rend titre/description + boutons; tap → mise à jour; fallback image silencieux.

## 18. Direction Artistique 16‑bit — Normes de Production (normatif)

- Style: pixel‑art Megadrive/SNES‑like, contours nets, pas d’anti‑aliasing; éviter les dégradés continus.
- Résolution de base: 320×180 (16:9). Composer sur cette grille; l’app applique un scaling entier (×2, ×3, …).
- Palette: limiter à ~32–64 couleurs par scène, contrastes contrôlés, éviter banding via dithering léger si nécessaire.
- Composition: focus clair, profondeur par silhouettes/valeurs, lisibilité du premier plan > arrière‑plan.
- Nommage fichiers: `assets/images/locations/<key>.webp` (lower_snake_case); exporter en WebP lossless ou qualité visuelle équivalente; ≤ 200 KB.
- QA artistique: vérifier lisibilité en taille réduite, contrastes en sombre/clair, absence d’artefacts de ré‑échantillonnage.
- Audio: BGM 30–60 s loopable, ≤ 600 KB/loop; SFX courts, cue précis, enveloppes marquées (style chiptune/FM).

Livrables Game Artist (S3→S4)

- Feuille de route d’images par `mapTag` priorisée (top 20 lieux S3), reste en backlog S4.
- Table `zoneKey → trackKey` (BGM) + 6–10 SFX essentiels, nommage stable (`sfx_pickup`, `sfx_drop`, `sfx_lamp_on`, etc.).
- Validation croisée avec l’équipe dev: intégration sur device, contrôle de jank, itération micro‑contrastes.

## 19. Rôles & Gouvernance (normatif)

- CTO: cette spec prime et verrouille les invariants UX/techniques; tout écart doit être amendé ici avant merge.
- Dev: aucune logique métier en UI; labels/icos générés côté Presentation; Data reste passive; Domain garde l’algorithme.
- Game Artist: respecte les budgets et la grille 320×180; livrables nommés selon la clé d’image; review croisée avant ajout à `pubspec.yaml`.
