# Source Tree Analysis — open_adventure

Généré par `gds-document-project` le 2026-05-17. Mode : `initial_scan` / Deep Scan.

## Vue d'ensemble

Monorepo applicatif Flutter mono-part (`mobile`). Référence amont C (Open Adventure 2.5/430 pts d'Eric S. Raymond) embarquée en lecture seule sous `open-adventure-master/`, consommée **uniquement** par les scripts Python de génération d'assets ; jamais compilée ni embarquée dans le binaire mobile.

## Arborescence annotée

```text
open_adventure/                       # racine du projet Flutter
├── lib/                              # code applicatif Dart (Clean Architecture)
│   ├── main.dart                     # composition root : DI manuelle + runApp
│   │
│   ├── domain/                       # ⬛ cœur métier — pur Dart, zéro dépendance Flutter
│   │   ├── entities/                 # objets métier immuables
│   │   │   ├── game.dart             # état du monde (loc, oldLoc, turns, lampe, dwarfState, objectStates, flags…)
│   │   │   ├── location.dart         # lieu (id, name, mapTag, descriptions, conditions)
│   │   │   ├── game_object.dart      # objet du jeu (id, name, words, locations, immovable, isTreasure, states…)
│   │   │   ├── game_object_state.dart# état runtime d'un GameObject (location/fixed/carry/prop/state)
│   │   │   ├── dwarf_state.dart      # état du sous-système nains (activated, slots, …)
│   │   │   ├── travel_rule.dart      # règle de voyage (fromId, motion, destName/destId, conditions)
│   │   │   └── audio_settings.dart   # préférences audio persistées
│   │   ├── value_objects/            # VOs immuables
│   │   │   ├── command.dart          # Command(verb, target)
│   │   │   ├── turn_result.dart      # (newGame, messages)
│   │   │   ├── action_option.dart    # option UI (id, category, label, icon, verb, objectId?)
│   │   │   ├── condition.dart        # AST de conditions (carry/with/not/at/state/prop/have)
│   │   │   ├── score_breakdown.dart  # (treasures, exploration, penalties, total)
│   │   │   ├── dwarf_tick_result.dart# sortie du DwarfSystem
│   │   │   ├── game_snapshot.dart    # snapshot persistance autosave (loc, turns, rngSeed, schema_version)
│   │   │   ├── magic_words.dart      # incantations canoniques (XYZZY, PLUGH, PLOVER, FEE/FIE/FOE/FOO)
│   │   │   └── _placeholder.dart     # marqueur structurel
│   │   ├── repositories/             # ports (interfaces)
│   │   │   ├── adventure_repository.dart       # initialGame, getLocations/Objects, locationById, travelRulesFor, arbitraryMessage
│   │   │   ├── save_repository.dart            # autosave/latest (multi-slots en S4)
│   │   │   └── audio_settings_repository.dart  # load/save AudioSettings
│   │   ├── services/                 # services Domain
│   │   │   ├── dwarf_system.dart     # tick() : activation/déplacement/menace, RNG seedée
│   │   │   └── motion_canonicalizer.dart # interface de canonicalisation des verbes de déplacement
│   │   ├── usecases/                 # use cases (one-shot ou orchestrateurs)
│   │   │   ├── list_available_actions.dart     # ListAvailableActions + ListAvailableActionsTravel
│   │   │   ├── apply_turn.dart                 # routeur travel/interaction
│   │   │   ├── apply_turn_goto.dart            # navigation (gère BACK/RETURN, FORCED, COND_NOBACK)
│   │   │   ├── evaluate_condition.dart         # évaluation Condition → bool
│   │   │   ├── examine.dart                    # description contextuelle (porté ou en vue)
│   │   │   ├── take_object.dart                # +inventaire (immovable interdit)
│   │   │   ├── drop_object.dart                # −inventaire (objet visible au lieu)
│   │   │   ├── open_object.dart                # transition state OPEN (clé requise via interaction_requirements)
│   │   │   ├── close_object.dart               # transition state CLOSE
│   │   │   ├── light_lamp.dart                 # allumage si limit>0
│   │   │   ├── extinguish_lamp.dart            # extinction
│   │   │   ├── drink_liquid.dart               # consommation BOTTLE state WATER
│   │   │   ├── inventory.dart                  # rendu texte de l'inventaire
│   │   │   ├── compute_score.dart              # scoring partiel (trésors+exploration−pénalités)
│   │   │   ├── get_locations.dart              # read-through repo
│   │   │   ├── get_game_objects.dart           # read-through repo
│   │   │   ├── load_audio_settings.dart        # AudioSettingsRepository.load
│   │   │   ├── save_audio_settings.dart        # AudioSettingsRepository.save
│   │   │   └── _placeholder.dart
│   │   └── constants/
│   │       └── interaction_requirements.dart   # mapping objet→clé requise pour OPEN
│   │
│   ├── application/                  # ⬜ orchestration UI ↔ Domain (sans Flutter widgets)
│   │   ├── controllers/
│   │   │   ├── game_controller.dart            # ValueNotifier<GameViewState> + init/perform/refreshActions + autosave + lampe + dwarves
│   │   │   ├── home_controller.dart            # HomeViewState (autosave latest)
│   │   │   └── audio_settings_controller.dart  # binding sliders ↔ AudioController + persistance
│   │   ├── services/
│   │   │   └── audio_controller.dart           # just_audio + audio_session : playBgm/stopBgm/playSfx, crossfade, focus/ducking
│   │   └── routing/
│   │       └── app_router.dart                 # squelette routes (peu utilisé — navigation impérative S2)
│   │
│   ├── data/                         # ⬛ implémentations IO/JSON (passives, sans logique métier)
│   │   ├── datasources/
│   │   │   └── asset_data_source.dart          # AssetDataSource + BundleAssetDataSource (loadList/loadMap/getLocations, isolate opt-in)
│   │   ├── models/                             # mappers Models ↔ Entities (JSON → Domain)
│   │   │   ├── location_model.dart             # LocationModel.fromJson (flattened {name, description, conditions, loud})
│   │   │   ├── game_object_model.dart          # GameObjectModel.fromJson (normalise locations string|list)
│   │   │   ├── travel_rule_model.dart          # TravelRuleModel.fromJson (motion, destval, condtype, destType, stop, nodwarves)
│   │   │   ├── action_model.dart               # lecture brute actions.json
│   │   │   └── condition_model.dart            # lecture brute conditions.json
│   │   ├── repositories/                       # impls des ports Domain
│   │   │   ├── adventure_repository_impl.dart  # caches + index name↔id pour Location et GameObject
│   │   │   ├── save_repository_impl.dart       # autosave.json sous applicationSupportDirectory/open_adventure/
│   │   │   └── audio_settings_repository_impl.dart # shared_preferences
│   │   └── services/
│   │       └── motion_normalizer_impl.dart     # MotionCanonicalizer chargé depuis motions.json + table _renames
│   │
│   ├── presentation/                 # ⬜ UI Flutter (widget-only, zéro logique métier)
│   │   ├── pages/
│   │   │   ├── home_page.dart                  # menu accueil (Nouvelle/Continuer/Charger/Options/Crédits)
│   │   │   ├── adventure_page.dart             # description + boutons actions + journal + flash messages
│   │   │   ├── inventory_page.dart             # liste objets portés + actions contextuelles
│   │   │   ├── saves_page.dart                 # liste slots (placeholder S2 → enrichi S4)
│   │   │   ├── settings_page.dart              # sliders volumes + thème + langue
│   │   │   ├── credits_page.dart               # crédits
│   │   │   └── home/widgets/
│   │   │       ├── home_hero_banner.dart       # bannière 16-bit de l'accueil
│   │   │       └── home_menu_button.dart       # bouton menu pixel-art
│   │   ├── widgets/
│   │   │   ├── pixel_canvas.dart               # scaling entier (320×180), FilterQuality.none
│   │   │   ├── location_image.dart             # FadeInImage + fallback silencieux si .webp absent
│   │   │   ├── icon_helper.dart                # mapping nom → IconData (Material)
│   │   │   └── flash_message_listener.dart     # consomme GameViewState.flashMessage → SnackBar
│   │   └── theme/
│   │       ├── app_theme.dart                  # ThemeData.light()/.dark()
│   │       ├── app_colors.dart                 # palette 16-bit
│   │       ├── app_typography.dart             # polices pixel
│   │       └── app_spacing.dart                # échelle 8/16/24
│   │
│   ├── core/                         # utilitaires partagés (zéro Flutter dans les modules réutilisables)
│   │   ├── constant/
│   │   │   └── asset_paths.dart                # constantes AssetPaths.* (tous chemins assets/data/*.json)
│   │   ├── error/
│   │   │   ├── exceptions.dart                 # AssetDataFormatException, LookupNotFoundException
│   │   │   └── failures.dart                   # Failure / DataFailure (Equatable)
│   │   ├── usecases/usecase.dart               # contrat générique (legacy)
│   │   ├── utils/
│   │   │   ├── json_validator.dart             # requireList/requireMap typés
│   │   │   ├── isolate_executor.dart           # FlutterIsolateExecutor.compute() (opt-in via Settings)
│   │   │   ├── location_image.dart             # locationImageKey(Location) : mapTag → snake_case(name) → id
│   │   │   └── lookup_service.dart             # idFromName / nameFromId pour Location et GameObject
│   │   ├── settings.dart                       # Settings.parseUseIsolate, parseIsolateThresholdBytes
│   │   └── di/_placeholder.dart                # marqueur structurel (DI manuelle dans main.dart)
│   │
│   └── l10n/                         # internationalisation
│       ├── app_en.arb                          # source EN (~80 clés au 2026-05-17)
│       ├── app_fr.arb                          # cible FR
│       └── app_localizations.dart              # code généré par flutter gen-l10n (554 lignes)
│
├── assets/                           # données de jeu embarquées (offline)
│   └── data/                         # JSON dérivés du YAML upstream (généré par scripts/)
│       ├── locations.json            # 274 KB — graphe des lieux (descriptions short/long, mapTag, conditions)
│       ├── travel.json               # 266 KB — règles de déplacement aplaties (from_index, motion, destval, condtype…)
│       ├── tkey.json                 # 2 KB   — index travel par locationId
│       ├── objects.json              # 36 KB  — objets (words, locations, states, descriptions, treasure flag)
│       ├── motions.json              # 9 KB   — vocabulaire de déplacement (canonical + synonymes)
│       ├── actions.json              # 16 KB  — verbes/actions catalogue
│       ├── conditions.json           # 23 KB  — métadonnées de conditions
│       ├── arbitrary_messages.json   # 25 KB  — messages canoniques (DWARF_*, LAMP_DIM, KNIFE_THROWN…)
│       ├── classes.json              # 1 KB   — classes de score (novice…master)
│       ├── hints.json                # 3 KB   — indices contextuels (système activé S4)
│       ├── obituaries.json           # 988 B  — messages de mort
│       ├── turn_thresholds.json      # 732 B  — seuils de pénalité par tours
│       ├── metadata.json             # 52 B   — { schema_version: 1, start_location_id: 1 }
│       └── ignore.json               # 7 B    — exclusions de validation
│
├── test/                             # 56 fichiers Dart de tests (miroir de lib/)
│   ├── domain/                       # entités, VOs, use cases, services (couverture haute S1-S3)
│   ├── data/                         # mappers, AssetDataSource (isolate inclus), repositories, perf
│   ├── application/                  # GameController, HomeController, AudioController/Settings
│   ├── presentation/                 # widget tests pages clés + theme
│   ├── core/                         # AssetPaths, LookupService, LocationImage
│   └── l10n/                         # AppLocalizations
│
├── scripts/                          # outillage Python (jamais embarqué)
│   ├── make_dungeon.py               # YAML → JSON canonique (travel.json + tkey.json)
│   ├── extract_c.py                  # parse dungeon.c (référence C) → travel_c.json/tkey_c.json (validation)
│   ├── validate_json.py              # diff YAML↔JSON (et optionnellement C), exit 0/1
│   ├── update_assets.py              # orchestrateur (make_dungeon → extract_c → validate)
│   ├── generate_asset_tracker.py     # produit docs/ASSET_TRACKER.md
│   ├── generate_asset_manifest.py    # produit docs/ASSET_MANIFEST.json (source IA art/audio)
│   ├── generate_map_layout.py        # produit assets/data/map_layout.json (couches MapPage)
│   ├── generate_travel_graph.py      # produit diagram/travel.dot (rendu PNG via Graphviz)
│   ├── export_layer_graphs.py        # produit docs/map_layers/*.json (un par strate)
│   └── export_drawio_map.py          # export drawio depuis map_layers
│
├── android/                          # cible native Android (Gradle Kotlin DSL, namespace com.example.open_adventure)
│   ├── build.gradle.kts              # plugins root
│   ├── app/build.gradle.kts          # config app (compileSdk via Flutter, debug signing TODO release)
│   ├── gradle/, gradle.properties, settings.gradle.kts
│   └── app/                          # sources Android (AndroidManifest, MainActivity Kotlin)
│
├── docs/                             # documentation projet (source de vérité fonctionnelle)
│   ├── CONVERSION_SPEC.md            # ★ normatif — spec de portage C→Flutter complète
│   ├── Dossier_de_Référence.md       # historien / DDR (incantations, PNJ, oracles seedés)
│   ├── EXEC_S1.md … EXEC_S4.md       # plans d'exécution de sprint (S1-S2 ✅, S3 partiel, S4 ⏳)
│   ├── UX_SCREENS.md                 # wireframes/DoD par écran
│   ├── VISUAL_STYLE_GUIDE.md         # palette/typographie/composants UI 16-bit
│   ├── ART_ASSET_BIBLE.md            # briefs scènes/objets/créatures, palettes, VFX/SFX
│   ├── DESIGN_ADDENDUM.md            # checklists Dev/Artist/CTO
│   ├── Cahier_des_charges_Map.md     # spec MapPage v1/v2 (multi-couches)
│   ├── CTO_DEV_MAP_REQUEST.md        # détails livrables CTO/dev pour la carte
│   ├── ASSET_TRACKER.md              # tableau généré (images/audio/sizes vs budgets)
│   ├── ASSET_MANIFEST.json           # source IA pour génération d'assets
│   ├── map_layout_plan.yaml          # plan de couches Map
│   ├── map_layers/                   # exports JSON par strate
│   ├── ux_screens_images/            # screenshots wireframes HomePage
│   ├── planning-artifacts/           # (vide) — réservé sortie BMad PRD/UX/Architecture
│   └── implementation-artifacts/     # (vide) — réservé sortie BMad sprint/story
│
├── open-adventure-master/            # ⚠ référence amont C (Raymond) — non compilée
│   ├── adventure.yaml                # ★ source de vérité du jeu (gameplay/lore/données)
│   ├── make_dungeon.py               # générateur upstream → dungeon.c/h (utilisé par scripts/update_assets.py)
│   ├── actions.c, score.c, saveresume.c, misc.c, init.c, main.c, advent.h, cheat.c …  # sources C
│   ├── history.adoc, hints.adoc, notes.adoc, README.adoc, INSTALL.adoc                 # documentation upstream
│   └── tests/                                                                          # oracles .chk (mazealldiff, tall, plover, dwarf, lampdim2…)
│
├── diagram/                          # diagrammes drawio + sortie Graphviz (travel.png/.dot)
├── coverage/                         # rapports LCOV (généré par `flutter test --coverage`)
├── pubspec.yaml                      # ★ dépendances + déclaration des assets/data/*.json
├── pubspec.lock
├── analysis_options.yaml             # flutter_lints + exclusions (lib_legacy/, test/features/, build/, coverage/)
├── devtools_options.yaml
├── requirements-dev.txt              # PyYAML pour scripts/
└── README.md                         # ★ quickstart dev (toolchain, commandes, scripts)
```

## Critical directories (par ordre de priorité de lecture)

| Dossier                          | Pourquoi c'est critique                                                                          |
|---------------------------------|--------------------------------------------------------------------------------------------------|
| `lib/domain/`                   | Cœur métier — toute la logique de jeu. Aucune dépendance Flutter. À comprendre en premier.       |
| `lib/application/controllers/`  | Orchestration UI ↔ Domain (GameController surtout). Source de vérité du cycle init/perform.     |
| `assets/data/*.json`            | Données embarquées. `locations.json` (274 KB) et `travel.json` (266 KB) sont la base du monde.   |
| `docs/CONVERSION_SPEC.md`       | Source de vérité fonctionnelle. Prime sur tout code en cas de contradiction (cf. en-tête doc).   |
| `lib/data/repositories/`        | Implémentations IO + caches + index. Frontière unique vers les assets/JSON.                      |
| `scripts/`                      | Régénération/validation des assets depuis YAML upstream. Indispensable si `adventure.yaml` bouge.|
| `lib/presentation/widgets/pixel_canvas.dart` | Convention pixel-perfect (FilterQuality.none + scale entier). À respecter pour toute image. |
| `open-adventure-master/`        | Référence canonique 430 pts (gameplay/score/save). Oracle de fidélité pour tests cross-langage.  |

## Points d'entrée

- **App** : `lib/main.dart` (composition root, DI manuelle).
- **Tests** : `flutter test` (root `test/`) ; sous-arborescences miroir de `lib/`.
- **Build assets** : `python3 scripts/update_assets.py --out assets/data` (orchestrateur).
- **Diagrammes** : `python3 scripts/generate_travel_graph.py --output diagram/travel.dot` puis `dot -Tpng diagram/travel.dot -o diagram/travel.png`.

## Conventions structurelles

- **Clean Architecture stricte** : Presentation → Application → Domain ← Data. La dépendance pointe toujours vers Domain.
- **DI manuelle** dans `main.dart` (pas de container). Injection par constructeur partout ailleurs.
- **Immutabilité** des entités/VOs (`copyWith` + `==`/`hashCode` structurels via `package:collection`).
- **Logique métier interdite** dans `data/models/` et `presentation/`. Les modèles font le mapping ; les widgets affichent.
- **JSON aplati** côté Data : `LocationModel.fromJson({name, ...data}, id)` au lieu du tuple natif `[name, {...}]`.
- **Tests miroirs** de `lib/` (chaque module Domain/Data/Application/Presentation a son répertoire correspondant dans `test/`).
