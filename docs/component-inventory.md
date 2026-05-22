# Component Inventory — open_adventure

> Inventaire des composants livrés par couche (Domain / Application / Data / Presentation / Core). État au 2026-05-17 (S1+S2 ✅, S3 ~70 %).

## Domain — entités

| Nom                  | Fichier                                            | Rôle |
|---------------------|----------------------------------------------------|------|
| `Game`              | `lib/domain/entities/game.dart`                    | État du monde immuable (loc, oldLoc/oldLc2, turns, rngSeed, dwarfState, visitedLocations, magicWordsUnlocked, objectStates, flags, lamp timers) |
| `Location`          | `lib/domain/entities/location.dart`                | Lieu (id, name, mapTag, descriptions short/long, conditions, loud) |
| `GameObject`        | `lib/domain/entities/game_object.dart`             | Objet du jeu (words, locations, immovable, isTreasure, states, descriptions, inventoryDescription) |
| `GameObjectState`   | `lib/domain/entities/game_object_state.dart`       | État runtime (location/fixedLocation/isCarried/state/prop + `isAt(loc)`) |
| `DwarfState`        | `lib/domain/entities/dwarf_state.dart`             | Sous-système nains (activated, introShown, 3 slots) |
| `TravelRule`        | `lib/domain/entities/travel_rule.dart`             | Règle de déplacement issue de `travel.json` |
| `AudioSettings`     | `lib/domain/entities/audio_settings.dart`          | Préférences audio (bgmVolume, sfxVolume) |

## Domain — value objects

| Nom                  | Fichier                                              | Rôle |
|---------------------|------------------------------------------------------|------|
| `Command`           | `lib/domain/value_objects/command.dart`              | `{verb, target?}` |
| `TurnResult`        | `lib/domain/value_objects/turn_result.dart`          | `{newGame, messages}` |
| `ActionOption`      | `lib/domain/value_objects/action_option.dart`        | Option UI (id, category, label, icon, verb, objectId) |
| `Condition`         | `lib/domain/value_objects/condition.dart`            | AST conditions (carry / withObject / not / at / state / prop / have) |
| `ScoreBreakdown`    | `lib/domain/value_objects/score_breakdown.dart`      | `{treasures, exploration, penalties, total}` |
| `DwarfTickResult`   | `lib/domain/value_objects/dwarf_tick_result.dart`    | Sortie `DwarfSystem.tick` |
| `GameSnapshot`      | `lib/domain/value_objects/game_snapshot.dart`        | Persistance autosave (loc, turns, rngSeed, schema_version) |
| `MagicWords`        | `lib/domain/value_objects/magic_words.dart`          | Set incantations + `isIncantation(verb)` |

## Domain — ports

| Interface                    | Fichier                                                  | Implémentation                          |
|------------------------------|----------------------------------------------------------|------------------------------------------|
| `AdventureRepository`        | `lib/domain/repositories/adventure_repository.dart`      | `data/repositories/adventure_repository_impl.dart` |
| `SaveRepository`             | `lib/domain/repositories/save_repository.dart`           | `data/repositories/save_repository_impl.dart`      |
| `AudioSettingsRepository`    | `lib/domain/repositories/audio_settings_repository.dart` | `data/repositories/audio_settings_repository_impl.dart` |
| `MotionCanonicalizer`        | `lib/domain/services/motion_canonicalizer.dart`          | `data/services/motion_normalizer_impl.dart`        |

## Domain — services

| Service               | Fichier                                          | Rôle |
|-----------------------|--------------------------------------------------|------|
| `DwarfSystem`         | `lib/domain/services/dwarf_system.dart`          | `tick(game)` — activation `DEEP`, déplacement 3 slots, menaces, attaque rare ; LCG seedée |
| `MotionCanonicalizer` | `lib/domain/services/motion_canonicalizer.dart`  | Interface : `toCanonical`, `uiKey`, `iconName`, `priority` |

## Domain — use cases

| Use case                              | Fichier                                                          | Catégorie | Notes |
|--------------------------------------|------------------------------------------------------------------|-----------|-------|
| `ListAvailableActions`               | `lib/domain/usecases/list_available_actions.dart`                | meta      | Agrège travel + interactions + 3 meta-actions ; tri priorité (security < travel < interaction < meta) |
| `ListAvailableActionsTravel`         | idem                                                              | travel    | Filtre incantations, dédupe par destination+canonical, expose BACK si autorisé |
| `ApplyTurn`                          | `lib/domain/usecases/apply_turn.dart`                            | router    | Route par `category` vers le use case dédié |
| `ApplyTurnGoto`                      | `lib/domain/usecases/apply_turn_goto.dart`                       | travel    | Gère BACK, FORCED, COND_NOBACK ; met à jour `oldLoc/oldLc2/visitedLocations` |
| `EvaluateCondition`                  | `lib/domain/usecases/evaluate_condition.dart`                    | logique   | 7 types : `carry`, `withObject`, `not`, `at`, `state`, `prop`, `have` |
| `Examine`                            | `lib/domain/usecases/examine.dart`                               | interaction | Description courte/longue selon contexte (porté ou en vue) |
| `TakeObject`                         | `lib/domain/usecases/take_object.dart`                           | interaction | Refus si `immovable` |
| `DropObject`                         | `lib/domain/usecases/drop_object.dart`                           | interaction | Décharge au lieu courant |
| `OpenObject`                         | `lib/domain/usecases/open_object.dart`                           | interaction | Vérifie clé via `interaction_requirements` |
| `CloseObject`                        | `lib/domain/usecases/close_object.dart`                          | interaction | Transition state inverse |
| `LightLamp`                          | `lib/domain/usecases/light_lamp.dart`                            | interaction | Refus si `limit ≤ 0` |
| `ExtinguishLamp`                     | `lib/domain/usecases/extinguish_lamp.dart`                       | interaction | Toujours possible si allumée |
| `DrinkLiquid`                        | `lib/domain/usecases/drink_liquid.dart`                          | interaction | BOTTLE → vide ; messages dédiés |
| `Inventory`                          | `lib/domain/usecases/inventory.dart`                             | meta      | Rendu texte de l'inventaire |
| `ComputeScore`                       | `lib/domain/usecases/compute_score.dart`                         | meta      | Partiel S3 : trésors + exploration (cap 30) − pénalités tours (interval 20 → 2 pts) |
| `GetLocations`                       | `lib/domain/usecases/get_locations.dart`                         | read      | Pass-through repo |
| `GetGameObjects`                     | `lib/domain/usecases/get_game_objects.dart`                      | read      | Pass-through repo |
| `LoadAudioSettings`                  | `lib/domain/usecases/load_audio_settings.dart`                   | settings  | Lit via `AudioSettingsRepository` |
| `SaveAudioSettings`                  | `lib/domain/usecases/save_audio_settings.dart`                   | settings  | Écrit via `AudioSettingsRepository` |

## Application — controllers

| Controller                | Fichier                                                       | ViewState              | Responsabilités |
|---------------------------|----------------------------------------------------------------|------------------------|------------------|
| `GameController`          | `lib/application/controllers/game_controller.dart`            | `GameViewState`        | `init()`, `perform(option)`, `refreshActions()`, journal (200 max), lampe (`_applyLampTimers`, seuil 30), Dwarf tick, autosave, `clearFlashMessage()`, `objectById` |
| `HomeController`          | `lib/application/controllers/home_controller.dart`            | `HomeViewState`        | `refreshAutosave()` — pilote "Continuer" |
| `AudioSettingsController` | `lib/application/controllers/audio_settings_controller.dart`  | (volumes)              | Charge à l'init, propage les changements à `AudioController`, persiste via `SaveAudioSettings` |

## Application — services

| Service           | Fichier                                              | Rôle |
|-------------------|------------------------------------------------------|------|
| `AudioController` | `lib/application/services/audio_controller.dart`     | `playBgm/stopBgm/playSfx/setVolumes` ; crossfade 350 ms ; throttle SFX 150 ms ; `WidgetsBindingObserver` (pause/resume) ; `AudioSession` (focus). Implémente `AudioOutput`. |

## Application — routing

| Élément        | Fichier                                          | Statut |
|----------------|--------------------------------------------------|--------|
| `AppRouter`    | `lib/application/routing/app_router.dart`        | Squelette — navigation actuelle impérative via `Navigator.push` depuis HomePage |

## Data — datasources

| Composant                    | Fichier                                                   | Notes |
|-----------------------------|-----------------------------------------------------------|-------|
| `AssetDataSource` (abstract) | `lib/data/datasources/asset_data_source.dart`            | API : `loadList`, `loadMap`, `getLocations()` (flattened) |
| `BundleAssetDataSource`      | idem                                                      | Implémentation par défaut via `rootBundle`. Isolate opt-in (`Settings.parseUseIsolate` ou flag constructeur `forceIsolateParsing`) |

## Data — models (mappers)

| Modèle              | Fichier                                          | Cible Domain |
|---------------------|--------------------------------------------------|--------------|
| `LocationModel`     | `lib/data/models/location_model.dart`            | `Location`   |
| `GameObjectModel`   | `lib/data/models/game_object_model.dart`         | `GameObject` (avec `toEntity()` et `toJson()`) |
| `TravelRuleModel`   | `lib/data/models/travel_rule_model.dart`         | `TravelRule` |
| `ActionModel`       | `lib/data/models/action_model.dart`              | données brutes actions.json |
| `ConditionModel`    | `lib/data/models/condition_model.dart`           | données brutes conditions.json |

## Data — repositories

| Implementation                       | Fichier                                                              | Notes |
|--------------------------------------|----------------------------------------------------------------------|-------|
| `AdventureRepositoryImpl`            | `lib/data/repositories/adventure_repository_impl.dart`               | Caches + index `name↔id` ; expose `initialGame`, `getLocations`, `getGameObjects`, `locationById`, `travelRulesFor`, `arbitraryMessage(key, count?)` |
| `SaveRepositoryImpl`                 | `lib/data/repositories/save_repository_impl.dart`                    | Autosave fichier JSON sous `applicationSupportDirectory/open_adventure/` |
| `AudioSettingsRepositoryImpl`        | `lib/data/repositories/audio_settings_repository_impl.dart`          | `shared_preferences` (clés `audio.bgmVolume`, `audio.sfxVolume`) |

## Data — services

| Service                  | Fichier                                                | Rôle |
|--------------------------|---------------------------------------------------------|------|
| `MotionNormalizerImpl`   | `lib/data/services/motion_normalizer_impl.dart`        | Charge `motions.json`, table `_renames` (IN→ENTER, U→UP, NORTHEAST→NE…) ; filtre `MOT_*` / `HERE` / `NUL` → `UNKNOWN` |

## Features — pages

> Post Story 5-2 : pages déplacées sous `lib/features/<screen>/` (un écran = un dossier).

| Page                  | Fichier                                                      | Statut | Notes |
|-----------------------|---------------------------------------------------------------|--------|-------|
| `HomePage`            | `lib/features/home/home_page.dart`                            | ✅ S2  | Menu Nouvelle/Continuer/Charger/Options/Crédits ; tap "Continuer" disabled si autosave absente. Refonte UI déléguée à 5-8. |
| `AdventurePage`       | `lib/features/adventure/adventure_page.dart`                  | ✅ S2  | Description + boutons d'actions + journal + flash messages + "Plus…" si > 7 actions. Refonte UI déléguée à 5-7. |
| `InventoryPage`       | `lib/features/inventory/inventory_page.dart`                  | ✅ S3  | Liste objets portés + actions contextuelles. Refonte UI déléguée à 5-9. |
| `SavesPage`           | `lib/features/saves/saves_page.dart`                          | 🟡 stub | Sera enrichi en S4 (multi-slots, métadonnées, suppression) |
| `SettingsPage`        | `lib/features/settings/settings_page.dart`                    | ✅ S2  | Sliders volumes BGM/SFX persistés ; thème/langue ajoutés en S4 |
| `CreditsPage`         | `lib/features/credits/credits_page.dart`                      | ✅ S2  | Crédits historiques |
| `MapPage`             | _non livré_                                                   | ⏳ S3   | Cf. `docs/Cahier_des_charges_Map.md` + `docs/CTO_DEV_MAP_REQUEST.md` |

## Core — widgets transverses

> Post Story 5-2 : atomes UI partagés déplacés sous `lib/core/widgets/`. Story 5-4 ajoutera `OAStamp`, `OAPill`, etc.

| Widget                    | Fichier                                                       | Rôle |
|---------------------------|----------------------------------------------------------------|------|
| `PixelCanvas`             | `lib/core/widgets/pixel_canvas.dart`                          | Conteneur pixel-perfect (320×180 logique, scale entier, FilterQuality.none) |
| `LocationImage`           | `lib/core/widgets/location_image.dart`                        | `FadeInImage` `assets/images/locations/<key>.webp` + fallback silencieux |
| `FlashMessageListener`    | `lib/core/widgets/flash_message_listener.dart`                | Écoute `GameViewState.flashMessage` → SnackBar puis `clearFlashMessage` |
| `IconHelper`              | `lib/core/widgets/icon_helper.dart`                           | Mapping nom Material → `IconData` (utilisé par les `ActionOption.icon`) |
| `home_hero_banner.dart`   | `lib/features/home/widgets/home_hero_banner.dart`             | Bannière pixel-art de la HomePage (interne à la feature `home/`) |
| `home_menu_button.dart`   | `lib/features/home/widgets/home_menu_button.dart`             | Bouton menu 16-bit (interne à la feature `home/`) |

## Core — theme

> Post Story 5-2 : tokens déplacés sous `lib/core/theme/`. Story 5-3 introduira `oa_colors.dart`, `oa_typography.dart`, `oa_spacing.dart` (palette dark-only ambre/encre).

| Token              | Fichier                                              | Rôle |
|--------------------|-------------------------------------------------------|------|
| `AppTheme`         | `lib/core/theme/app_theme.dart`                      | `ThemeData.light()/.dark()` (refonte en 5-3) |
| `AppColors`        | `lib/core/theme/app_colors.dart`                     | Palette 16-bit (refonte en 5-3) |
| `AppTypography`    | `lib/core/theme/app_typography.dart`                 | Polices pixel + tailles (refonte en 5-3) |
| `AppSpacing`       | `lib/core/theme/app_spacing.dart`                    | Échelle 8/16/24 (refonte en 5-3) |

## Core

| Composant                      | Fichier                                              | Rôle |
|--------------------------------|-------------------------------------------------------|------|
| `AssetPaths`                   | `lib/core/constant/asset_paths.dart`                 | Constantes des chemins assets/data/*.json |
| `AssetDataFormatException`     | `lib/core/error/exceptions.dart`                     | Erreur typée parsing assets |
| `LookupNotFoundException`      | idem                                                  | Lookup id/name introuvable |
| `Failure` / `DataFailure`      | `lib/core/error/failures.dart`                       | Erreurs métier (Equatable) |
| `JsonValidator`                | `lib/core/utils/json_validator.dart`                 | `requireList`/`requireMap` typés |
| `IsolateExecutor`              | `lib/core/utils/isolate_executor.dart`               | Wrapper `compute()` (Flutter foundation) |
| `LookupService`                | `lib/core/utils/lookup_service.dart`                 | `idFromName`/`nameFromId` pour Location/GameObject |
| `locationImageKey(Location)`   | `lib/core/utils/location_image.dart`                 | `mapTag` → `snake_case(name)` → `id` |
| `Settings`                     | `lib/core/settings.dart`                             | `parseUseIsolate`, `parseIsolateThresholdBytes` |

## l10n

| Fichier                                 | Rôle |
|----------------------------------------|------|
| `lib/l10n/app_en.arb`                  | Source EN (~80 clés, placeholders `@key`) |
| `lib/l10n/app_fr.arb`                  | Cible FR |
| `lib/l10n/app_localizations.dart`      | Code généré `flutter gen-l10n` (554 lignes) |

## Composants reconnus comme manquants (backlog)

| Sprint cible | Composant                       | Notes |
|--------------|----------------------------------|-------|
| S3           | `MapPage` v1 multi-couches       | Voir spec dédiée + `assets/data/map_layout.json` à générer via `scripts/generate_map_layout.py` |
| S3           | `JournalView` widget dédié       | Actuellement le journal est rendu directement dans `AdventurePage` |
| S3           | Intégration `LocationImage` réelle | Le widget existe ; il manque les `.webp` (Art Bible) et leur déclaration dans `pubspec.yaml` |
| S3           | Mapping `zoneKey → trackKey` BGM | `AudioController` supporte l'API, le mapping n'est pas câblé au `GameController` |
| S4           | `EndGamePage` / dialog            | Affichage breakdown + classe + actions rejouer/charger/crédits |
| S4           | `StatusBar` (AdventurePage v2)   | Score / tours / lampe en temps réel |
| S4           | `SaveRepository` multi-slots     | `save/load/list/delete` + écriture atomique + tolérance corruption |
| S4           | `ComputeScore` complet           | Parité `score.c` (bonus fin, classes, hints malus, deaths) |
| S4           | Système d'indices                | `GetHints` + `UseHint(id)` avec malus idempotent |
| S4           | CI                                | `.github/workflows/` absent — à créer |
