# Architecture — open_adventure

> **🚧 EN TRANSITION — 2026-05-22.** L'architecture cible (Riverpod 2 + `lib/features/`) est en cours de migration via l'Epic 5 "Foundation Refresh".
> Jusqu'à la livraison des stories 5-1 à 5-15, ce document décrit l'architecture **en place** (ValueNotifier + `lib/presentation/`).
> Source de vérité de l'architecture cible : [`docs/design.md`](./design.md) §3–§5.
> Ce document sera réécrit dans la story 5-15.

> Document descriptif de l'architecture livrée à l'état actuel (S1 + S2 ✅, S3 ~70 %). Doit être lu en complément de la spec normative `docs/CONVERSION_SPEC.md` (§4 et §7) qui prime en cas de divergence.

## 1. Executive Summary

L'application est un portage Flutter mono-binaire du moteur C *Open Adventure 2.5*. Elle suit une **Clean Architecture** stricte (Presentation → Application → Domain ← Data) avec injection par constructeur via DI manuelle dans `lib/main.dart`. Le runtime est **100 % offline** : les données embarquées sont des JSON dérivés du `adventure.yaml` upstream (généré par les scripts Python du dépôt). La logique métier (boucle de tour, conditions, scoring, nains, lampe, mots magiques) vit intégralement dans `lib/domain/`. La UI ne fait que consommer des `ValueNotifier<*ViewState>` immuables exposés par les contrôleurs d'application.

## 2. Technology Stack

| Couche          | Technologie                                                       | Rôle                                                                  |
|-----------------|-------------------------------------------------------------------|-----------------------------------------------------------------------|
| Runtime         | Flutter stable 3.35.x, Dart `>=3.0.0 <4.0.0`                      | Cible Android (iOS planifié)                                          |
| State           | `ValueNotifier` (Flutter foundation) + classes `*ViewState` immuables | Pas de Bloc, pas de Provider — DI manuelle                        |
| Données runtime | `flutter/services.rootBundle` → `BundleAssetDataSource` → mappers | Lecture lazy + cache mémoire ; isolate opt-in via `Settings.parseUseIsolate` |
| Persistance     | `path_provider` (FS) pour autosave, `shared_preferences` pour audio settings | Aucune base SQL                                                |
| Audio           | `just_audio` + `audio_session`                                    | BGM (crossfade), SFX (throttle), focus/ducking                        |
| i18n            | `flutter_localizations` + `intl` (ARB)                            | `app_en.arb` source, `app_fr.arb` cible, génération `flutter gen-l10n` |
| Lint            | `flutter_lints` 6.x (`analysis_options.yaml`)                     | Exclusions : `lib_legacy/`, `test/features/`, `build/`, `coverage/`   |
| Tests           | `flutter_test`, `test`, `coverage`, `mocktail`                    | Couverture cibles : Domain ≥ 90 %, Data ≥ 80 %, Presentation ≥ 60 %   |

## 3. Architecture Pattern

**Clean Architecture / Ports & Adapters** avec une boucle de tour orientée *use-case routing*.

- **Domain** (pur Dart, zéro `flutter:` import) : entités, value objects, ports (`AdventureRepository`, `SaveRepository`, `AudioSettingsRepository`), use cases, services (`DwarfSystem`, `MotionCanonicalizer` interface).
- **Data** (passive) : implémentations IO + mappers JSON → entités. Aucune logique métier. Encapsule `rootBundle`, `path_provider`, `shared_preferences`.
- **Application** : orchestrateurs (`GameController`, `HomeController`, `AudioSettingsController`) + service `AudioController` ; bridge UI ↔ Domain ; convertit `Game` → `GameSnapshot` pour la persistance ; expose des `*ViewState` immuables.
- **Presentation** : widgets Flutter purs (Material 3 + thème 16-bit custom). Aucune logique de règles — chaque page écoute son contrôleur et appelle `perform()` sur tap.

### Flow de dépendances

```
Presentation ──► Application ──► Domain ◀── Data
                                  ▲             │
                                  └─────────────┘ (impl via injection dans main.dart)
```

La règle d'inversion : Domain **ne connaît** ni Flutter ni JSON ; Data **connaît** Domain ; Application **connaît** Domain et orchestre Data via les ports.

## 4. Composition Root

`lib/main.dart` instancie et câble toutes les dépendances avant `runApp`. Pas de framework de DI, pas de service locator. Extrait (état réel, ~100 lignes) :

```dart
final motionNormalizer = await MotionNormalizerImpl.load();
final adventureRepository = AdventureRepositoryImpl();
final listAvailableActionsTravel = ListAvailableActionsTravel(adventureRepository, motionNormalizer);
const evaluateCondition = EvaluateConditionImpl();
final listAvailableActions = ListAvailableActions(
  adventureRepository: adventureRepository,
  travel: listAvailableActionsTravel,
  evaluateCondition: evaluateCondition,
);
// + Examine, Take/Drop, Open/Close, Light/Extinguish, DrinkLiquid, ApplyTurnGoto
final applyTurn = ApplyTurn(travel: applyTurnGoto, examine: examine, /* …7 autres… */);
final saveRepository = SaveRepositoryImpl();
final dwarfSystem = DwarfSystem(adventureRepository);
final audioController = AudioController();
final audioSettingsController = AudioSettingsController(/* … */);
await audioSettingsController.init();
final controller = GameController(
  adventureRepository: adventureRepository,
  listAvailableActions: listAvailableActions,
  applyTurn: applyTurn,
  saveRepository: saveRepository,
  dwarfSystem: dwarfSystem,
);
final homeController = HomeController(saveRepository: saveRepository);
runApp(OpenAdventureApp(/* … */));
```

## 5. Boucle de tour (tick)

```
UI tap (ActionOption)
   │
   ▼
GameController.perform(option)
   ├─ early return si meta verb (INVENTORY/OBSERVER/MAP) traité côté UI
   ├─ blocage si verb ∈ magicWords && !magicWordsUnlocked
   │
   ├─► ApplyTurn(option, game)             ← Domain
   │     ├─ category 'travel'   → ApplyTurnGoto (BACK, FORCED, COND_NOBACK)
   │     └─ category 'interaction' → Take/Drop/Open/Close/Light/Extinguish/Examine/Drink
   │
   ├─► DwarfSystem.tick(game)              ← seulement si state changed
   ├─► _applyLampTimers(game)              ← décrément `limit`, message LAMP_DIM/LAMP_OUT
   │
   ├─► ListAvailableActions(game)          ← recalcul des boutons (travel + interaction + meta)
   ├─► Location lookup (titre, mapTag, description first-visit/revisit)
   ├─► _appendJournal (trim 200 derniers messages)
   │
   └─► SaveRepository.autosave(GameSnapshot(loc, turns, rngSeed))
```

### Garanties

- **Déterminisme** : RNG injectée seedée (`Game.rngSeed`, défaut 42 en S1). Le `DwarfSystem` utilise un LCG local seedé sur ce champ et propage le nouvel état dans `game.copyWith(rngSeed: rng.state)`.
- **Première visite** = `longDescription`, revisites = `shortDescription` (fallback inverse si l'un est vide).
- **BACK/RETURN** : `ApplyTurnGoto` consulte `oldLoc` (et `oldLc2` si lieu forcé), refuse si la salle a `COND_NOBACK`, sans toucher à `travel.json`.
- **Incantations** filtrées par `MagicWords.isIncantation(verb)` tant que `game.magicWordsUnlocked == false` (DDR-001 Option A).
- **Lampe** : `clock1/clock2/limit` modélisés. Quand allumée, `_applyLampTimers` décrémente, émet `LAMP_DIM` au seuil 30 et `LAMP_OUT` à 0 (en basculant `LAMP_BRIGHT → LAMP_DARK`).

## 6. Data Architecture

Aucune base relationnelle. Tous les contenus statiques sont des **JSON immuables** embarqués sous `assets/data/` et déclarés explicitement dans `pubspec.yaml`. Voir [data-models.md](./data-models.md) pour le détail.

- **Chargement** : `BundleAssetDataSource` (singleton de facto via instanciation dans `main.dart`) lit/décode via `rootBundle.loadString` + `json.decode`. Décodage en isolate disponible (`Settings.parseUseIsolate`, seuil `parseIsolateThresholdBytes = 1 MiB`) mais désactivé par défaut.
- **Mapping** : un fichier par schéma sous `lib/data/models/` (`LocationModel`, `GameObjectModel`, `TravelRuleModel`, `ActionModel`, `ConditionModel`). Les modèles **étendent** ou **convertissent** vers les entités Domain ; ils n'ajoutent aucune logique métier.
- **Caches** : `AdventureRepositoryImpl` cache `_locations`, `_objects`, `_locNameToId`, `_objNameToId`, `_arbitraryMessages`. Premier `getLocations()` chauffe le cache ; les appels suivants sont O(1).
- **Index** : `name ↔ id` reconstruit séquentiellement à partir de l'ordre dans le JSON. Les IDs publics sont des **index** dans la liste source.

## 7. Persistance & Sauvegarde

Implémentée a minima en S2, à compléter en S4 (multi-slots, écriture atomique).

- **Localisation** :
  - iOS : `NSApplicationSupportDirectory/open_adventure/`
  - Android : `<applicationSupportDir>/open_adventure/`
- **Fichier autosave** : `autosave.json`, écrit après chaque tour réussi.
- **Schéma** : `{ schema_version: 1, loc, turns, rng_seed }`. Réversible via `GameSnapshot.fromJson`. Champ inconnu = ignoré (lecture tolérante).
- **Snapshot** : minimal en S2 (loc/turns/rngSeed). À enrichir en S4 pour rejouabilité complète (inventaire, flags, lampe…).
- **Multi-slots S4** : `save_v{schemaVersion}_{slot}.json`, listing trié par `updated_at`, suppression confirmée côté UI, fallback corruption → dernier autosave sain.

## 8. State Management

Pas de framework. Chaque controller applicatif est un `ValueNotifier<TViewState>` où `TViewState` est une classe immuable avec `copyWith` et égalité valeur.

- **`GameController` → `GameViewState`** : porte `game`, `locationTitle`, `locationMapTag`, `locationId`, `locationDescription`, `actions: List<ActionOption>`, `journal: List<String>`, `isLoading`, `flashMessage?`.
- **`HomeController` → `HomeViewState`** : `isLoading`, `autosave: GameSnapshot?`. Sert à griser "Continuer" si absence.
- **`AudioSettingsController`** : binding volumes Musique/SFX persistés (`shared_preferences`) ↔ `AudioController`. `init()` charge les préférences et applique les volumes au démarrage.

La UI utilise `ValueListenableBuilder` ou écoute directe via `addListener`. Aucun `setState` dans le chemin chaud.

## 9. UI / Theming

- **Thème 16-bit** : `AppTheme.light()/.dark()` (`lib/presentation/theme/`) + tokens `AppColors`, `AppTypography`, `AppSpacing`.
- **Pixel-perfect** : tout asset visuel passe par `PixelCanvas` (scaling entier, `FilterQuality.none`) en canvas logique 320×180.
- **Images de lieu** : `LocationImage` charge `assets/images/locations/<key>.webp` via `locationImageKey(Location)` (priorité `mapTag` → `snake_case(name)` → `id`). Fallback silencieux si absent ; aucun crash.
- **Flash messages** : `FlashMessageListener` écoute `GameViewState.flashMessage` et le surface en SnackBar, puis appelle `controller.clearFlashMessage()`.
- **Bouton « Plus… »** : si > 7 actions à proposer, AdventurePage rend les 6 premières + un overflow modal listant le reste.

## 10. Audio Architecture

- **`AudioController`** (Application/services) implémente l'interface `AudioOutput` : `playBgm(trackKey)`, `stopBgm()`, `playSfx(effectKey)`, `setVolumes({bgm, sfx})`.
- **Mapping clés → fichiers** via resolvers injectables (`defaultBgmAssetResolver` → `assets/audio/music/<key>.ogg`, `defaultSfxAssetResolver` → `assets/audio/sfx/<key>.ogg`).
- **Crossfade** BGM 350 ms par défaut ; **throttle SFX** 150 ms (anti-spam).
- **Lifecycle** : implémente `WidgetsBindingObserver` pour pause/resume sur `AppLifecycleState`.
- **Focus** : `AudioSession` configuré en mode `music` ; ducking soft prévu pour SFX importants (alerte/danger/victoire) en S4.
- **Budget mémoire** : empreinte audio cible < 20 Mo (preload prochaine zone + déchargement).
- **État S3 restant** : mapping `zoneKey → trackKey` et table SFX d'interaction (prendre/poser/lampe/danger nain) à finaliser.

## 11. Internationalisation

- Source : `lib/l10n/app_en.arb` (~80 clés, placeholders documentés via `@key`).
- Cible : `lib/l10n/app_fr.arb`.
- Code généré : `lib/l10n/app_localizations.dart` (`AppLocalizations`).
- Convention : aucune chaîne brute dans le code Presentation. Les `ActionOption.label` portent **des clés ARB** (`actions.travel.back`, `actions.interaction.take.LAMP`, etc.), résolues à l'affichage côté widget.
- DoR S4 : ARB complets, script d'extraction depuis assets, test CI échouant si clé manquante.

## 12. Outillage hors runtime (`scripts/`)

Les scripts Python ne sont jamais embarqués. Ils servent à régénérer ou valider les assets depuis l'amont C/YAML.

```
adventure.yaml ─► scripts/make_dungeon.py ─► travel.json, tkey.json
                                         ▼
   open-adventure-master/make_dungeon.py ─► dungeon.c, dungeon.h
                                         ▼
        scripts/extract_c.py ─► travel_c.json, tkey_c.json (validation)
                                         ▼
        scripts/validate_json.py ─► exit 0 si YAML↔JSON cohérents, 1 sinon

Orchestrateur :  scripts/update_assets.py [--canonical] [--strict]
Reporting    :  scripts/generate_asset_tracker.py → docs/ASSET_TRACKER.md
               scripts/generate_asset_manifest.py → docs/ASSET_MANIFEST.json (source IA)
               scripts/generate_map_layout.py    → assets/data/map_layout.json (MapPage)
               scripts/generate_travel_graph.py  → diagram/travel.dot (+ Graphviz)
```

## 13. Testing Strategy

- **Architecture des tests** : miroir de `lib/` (un fichier de test par module ; sous-dossiers Domain/Data/Application/Presentation/Core/l10n).
- **Outils** : `flutter_test` + `mocktail` pour les ports Domain ; pas de mockito.
- **Catégories couvertes** :
  - Domain : 18 use cases + entités/VOs + `DwarfSystem.tick` (déterministe via seed), `ComputeScore` (composantes isolées).
  - Data : mappers (round-trip JSON), `AssetDataSource` (chemin nominal + isolate forcé + entrée invalide), repositories (chemins heureux + erreurs typées `DataFailure`), perf (< 5 ms/lookup).
  - Application : `GameController` (cycle init → perform → autosave mocké exactement 1 fois), `HomeController` (refreshAutosave), `AudioController` (lifecycle, volumes), `AudioSettingsController` (persistance).
  - Presentation : widget tests sur AdventurePage (rendu, tap → render < 16 ms mesuré), HomePage, InventoryPage, SettingsPage, `FlashMessageListener`, thème.
- **Oracles seedés** : O1 navette mots magiques (Building↔Debris/Y2), O2 nain présent/absent, O3 pirate vol→récup→dépôt (cf. `docs/Dossier_de_Référence.md` §7.4). Implémentation S4.
- **Cibles couverture** (gate CI prévu S4) : Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 %.

## 14. CI / CD

- **CI actuelle** : aucune (pas de `.github/workflows/`, pas de `fastlane/`, pas de `bitrise.yml`). Exécution locale uniquement (`flutter analyze`, `flutter test`).
- **Plan S4 (extrait de `docs/EXEC_S4.md`)** :
  - `flutter analyze` (fail-on-warning)
  - `flutter test --coverage` + artefact LCOV + enforcement des seuils
  - Job optionnel `data-validate` : `python3 scripts/validate_json.py` (non bloquant sur mobile).
- **Build local** : `flutter build apk` / `flutter build ipa` (iOS subordonné à l'ajout du dossier `ios/`).

## 15. Sécurité & confidentialité

- Zéro permission sensible. Aucune permission réseau requise.
- Aucune télémétrie, aucune collecte de données utilisateur.
- Sauvegardes locales uniquement (FS application).
- Pas de stockage de credentials, pas de SecureStorage à l'horizon.

## 16. Points de vigilance

1. **Spec prime sur le code** (cf. `CONVERSION_SPEC.md` §1) : tout PR doit aligner le code sur la doc, pas l'inverse.
2. **DI manuelle** : si on grossit, surveiller la lisibilité de `main.dart` (déjà ~100 lignes de wiring) ; un container léger pourrait être envisagé.
3. **`game.json` interdit** : tout rappel d'un état monolithique unique doit être refusé en review.
4. **iOS** : le dossier `ios/` n'existe pas encore. Avant la première build iOS, prévoir : `flutter create --platforms=ios .`, vérification `Podfile`, support `path_provider` (`NSApplicationSupportDirectory`), test du `audio_session` config iOS.
5. **Multi-saves** : `GameSnapshot` actuel ne porte que `loc/turns/rngSeed`. La reprise complète exige d'étendre le schéma en S4 (inventaire, flags, lampe, objectStates…) en gardant `schema_version` ascendant.
6. **MapPage** : la spec `Cahier_des_charges_Map.md` + `CTO_DEV_MAP_REQUEST.md` impose un graphe multi-couches sérialisable (`GameController.mapGraph`). Non implémenté à ce jour.
7. **Lampe seuil = 30 turns** dans `GameController._lampWarningThreshold` — valeur magique à externaliser en S4 dans `turn_thresholds.json` (déjà présent à 732 B).
8. **`Settings.parseUseIsolate = false`** par défaut. Vu que `travel.json` (266 KB) + `locations.json` (274 KB) restent en dessous du seuil 1 MiB combiné, OK pour l'instant. Surveiller si nouveaux assets s'ajoutent.

## 17. Carte du code (résumé navigable)

- Cœur métier : [`lib/domain/`](../lib/domain/)
- Orchestration : [`lib/application/controllers/game_controller.dart`](../lib/application/controllers/game_controller.dart)
- IO/JSON : [`lib/data/`](../lib/data/)
- UI : [`lib/presentation/`](../lib/presentation/)
- Points d'entrée : [`lib/main.dart`](../lib/main.dart)
- Pipeline assets : [`scripts/update_assets.py`](../scripts/update_assets.py)
