---
project_name: 'open_adventure'
user_name: 'Simon'
date: '2026-05-17'
status: 'complete'
sections_completed:
  - technology_stack
  - framework_rules
  - performance_rules
  - code_organization_rules
  - testing_rules
  - platform_build_rules
  - critical_dont_miss_rules
existing_patterns_found: 20
rule_count: 86
optimized_for_llm: true
---

# Project Context for AI Agents — open_adventure

> **🚧 EN TRANSITION — 2026-05-22.** L'architecture cible (Riverpod 2 + `lib/features/`) est en cours de migration via l'Epic 5 "Foundation Refresh".
> Jusqu'à la livraison des stories 5-1 à 5-15, les sections **State Management / Composition root / DI manuelle** décrivent l'état **en place** (ValueNotifier + `lib/features/` post-5-2 ; migration Riverpod en 5-6 → 5-10).
> Source de vérité de l'architecture cible : [`docs/design.md`](./design.md) §3–§5.
> Toutes les autres règles (Clean Architecture frontières, immutabilité, i18n, boucle de tour, RNG déterministe, PixelCanvas, perfs, tests, plateformes, anti-patterns Domain/Data) restent **valides**.

> Règles critiques que tout agent BMad doit suivre pour produire du code conforme. Centré sur les détails non évidents : un LLM générique connaît Flutter, il ne connaît pas les choix opinionés de ce projet.
>
> Source de vérité fonctionnelle : `docs/CONVERSION_SPEC.md` (prime sur le code en cas de contradiction). Pour navigation détaillée : `docs/index.md`.

---

## Technology Stack & Versions

- **Framework** : Flutter stable **3.41.x** (cf. README §Getting Started)
- **Langage** : Dart `>=3.11.0 <4.0.0` (null-safety stricte)
- **Cible plateforme** : Android (`android/` natif présent), iOS planifié (dossier `ios/` à créer via `flutter create --platforms=ios .`)
- **Lint** : `flutter_lints` ^6.0.0 (`analysis_options.yaml`, fail-on-warning visé). Exclusions : `lib_legacy/`, `test/features/`, `build/`, `coverage/`.

### Dépendances production (pubspec)

| Package              | Version  | Usage                                                  |
|---------------------|----------|--------------------------------------------------------|
| `equatable`         | ^2.0.7   | `Failure`/`DataFailure` (Equatable mixin)              |
| `collection`        | ^1.19.1  | `SetEquality`, `MapEquality`, `ListEquality` pour `==` |
| `yaml`              | ^3.1.3   | (Présent mais non utilisé en runtime — scripts only)   |
| `path_provider`     | ^2.1.5   | `applicationSupportDirectory` pour autosave            |
| `shared_preferences`| ^2.5.3   | Volumes audio persistés                                |
| `just_audio`        | ^0.10.5  | BGM + SFX players                                      |
| `audio_session`     | ^0.2.2   | Focus / ducking iOS+Android                            |
| `intl`              | ^0.20.2  | Format de messages (placeholders ARB)                  |
| `cupertino_icons`   | ^1.0.8   | Icônes iOS-style (peu utilisé — UI Material)           |
| `flutter_localizations` | sdk  | Génération ARB via `flutter gen-l10n`                  |

### Dépendances test

| Package         | Version  | Usage                                              |
|----------------|----------|----------------------------------------------------|
| `flutter_test` | sdk      | Widget tests, pump/pumpAndSettle                   |
| `test`         | ^1.26.2  | Tests Dart purs (Domain)                           |
| `coverage`     | ^1.15.0  | LCOV via `flutter test --coverage`                 |
| `mocktail`     | ^1.0.4   | Mocks pour ports Domain — **pas `mockito`** (pas de codegen) |
| `flutter_lints`| ^6.0.0   | Règles lint Flutter recommandées                   |

### Contraintes de versioning

- **Verrouiller `mocktail`, pas `mockito`** : aucune génération de mocks (`build_runner`) n'est utilisée dans le projet. Ne jamais introduire `mockito` ni `build_runner`.
- **Pas de runtime YAML** : `yaml` est listé en dep production par héritage, mais aucun fichier YAML n'est chargé par l'app. Toute lecture YAML doit rester dans `scripts/*.py`.
- **Pas de bibliothèque d'état tierce** : pas de `provider`, `riverpod`, `bloc`, `get_it`. State management = `ValueNotifier` ; DI = manuelle dans `lib/main.dart`. Toute proposition d'introduction doit être refusée sans DDR explicite.

---

## Critical Implementation Rules

### Framework-Specific Rules (Flutter / Dart)

#### Clean Architecture — frontières non négociables

- **Domain pur** : `lib/domain/**` ne doit **jamais** importer `package:flutter/*`. Aucune classe Material, aucun `ValueNotifier`, aucun `BuildContext`. Si tu en as besoin, c'est que la classe va dans `Application` ou `Presentation`.
- **Data passive** : `lib/data/models/**` fait du mapping JSON ↔ entités, **point**. Aucun calcul métier, aucune décision. Si la logique dépend de l'état du jeu, elle vit dans un use case Domain.
- **Presentation sans logique** : `lib/features/**` (+ atomes `lib/core/widgets/**`) écoute un `ValueNotifier<*ViewState>` et appelle `controller.perform(...)`. Aucune mutation, aucun calcul de score, aucune règle de visibilité d'action.
- **Application = orchestration** : `lib/application/controllers/**` bridge UI ↔ Domain ; ne contient pas de logique métier (ex : règle "incantation cachée tant que non débloquée" → reste dans `MagicWords.isIncantation` côté Domain et est appliquée à l'`ActionOption` côté GameController).
- **Sens du flux** : Presentation → Application → Domain ← Data. La dépendance pointe toujours vers Domain. Une importation Data → Domain est autorisée ; Domain → Data est interdite.

#### Composition root unique

- Toute nouvelle dépendance se câble dans `lib/main.dart` (DI manuelle, injection par constructeur).
- **Pas de service locator**, **pas de singleton statique non testable**. `GameController`, repositories, services audio sont **instanciés** dans `main()` et passés via constructeur.
- Pour tester un use case, instancier ses dépendances avec `mocktail`. Ne jamais lire `rootBundle` directement dans un test ; passer un `AssetDataSource` injecté.

#### Immutabilité

- Toutes les entités Domain et VOs ont : champs `final`, constructeur `const` quand possible, `copyWith`, `==` et `hashCode` structurels. Pour les collections non-primitives, utiliser `SetEquality`/`MapEquality` (`package:collection`).
- `*ViewState` (GameViewState, HomeViewState, …) suivent la même règle : immuables + `copyWith` + égalité valeur.
- Pour les `List`/`Set`/`Map` exposés à l'UI : `List.unmodifiable(...)` / `Map.unmodifiable(...)` avant publication via `ValueNotifier.value`.

#### i18n

- **Aucune chaîne UI codée en dur** dans `lib/features/**` ni `lib/core/widgets/**`. Toujours passer par une clé ARB (`AppLocalizations.of(context).<key>`).
- `ActionOption.label` porte **une clé ARB** (ex : `actions.travel.back`, `actions.interaction.take.LAMP`), pas un texte. La résolution se fait dans le widget qui construit le bouton.
- À chaque ajout de clé : éditer `lib/l10n/app_en.arb` **et** `lib/l10n/app_fr.arb`, déclarer placeholders via `@key`, regénérer `lib/l10n/app_localizations.dart` via `flutter gen-l10n`.
- Convention de naming des clés : `snake_case` + structuration par contexte (`actions.travel.back`, `actions.interaction.take.<OBJECT_NAME>`, `home.menu.continue`).

#### Boucle de tour — ordre obligatoire

Dans `GameController.perform(option)` (cf. `lib/application/controllers/game_controller.dart`), l'ordre est **non négociable** :

```
1. Short-circuit meta verbs (INVENTORY, OBSERVER, MAP) — ne déclenchent pas un tour
2. Short-circuit incantations si !game.magicWordsUnlocked
3. ApplyTurn(option, game)                                  ← Domain (routeur)
4. (si newGame != currentGame) DwarfSystem.tick(newGame)
5. (si newGame != currentGame) _applyLampTimers(newGame)
6. _adventureRepository.locationById(newGame.loc)
7. _listAvailableActions(newGame)  → filtrage MagicWords
8. _selectDescription(location, firstVisit)                 ← long sur première visite, short sur revisite
9. _appendJournal (trim à 200 derniers messages)
10. value = state.copyWith(...)
11. (si newGame != currentGame) saveRepository.autosave(snapshot)
```

- Ne pas inverser DwarfSystem et lampe : la lampe ne décrémente que lorsque l'état change ; le tick nain peut modifier `rngSeed` qui sera propagé.
- `_applyLampTimers` lit `objectStates` pour trouver la lampe (cherche `state == 'LAMP_BRIGHT'`) ; ne pas hardcoder un id.

#### Déterminisme RNG

- La seed vit dans `Game.rngSeed` (défaut 42 en S1). Toute consommation de RNG **doit** repartir d'un LCG local seedé sur ce champ et **propager** le nouvel état via `game.copyWith(rngSeed: rng.state)`. Cf. `DwarfSystem._Lcg`.
- Interdiction d'utiliser `Random()` non-seedé ou `DateTime.now()` dans Domain. Oracles seedés (O1–O3, cf. `docs/Dossier_de_Référence.md` §7.4) doivent rester reproductibles.

#### Pixel-perfect

- Toute image pixel-art passe par `PixelCanvas` (`lib/core/widgets/pixel_canvas.dart`) en canvas logique 320×180 ou 384×216, scale entier uniquement, `FilterQuality.none`.
- Pas de scaling non entier, pas de lissage. Si un nouveau widget affiche du pixel-art sans `PixelCanvas`, c'est une régression à corriger.

---

### Performance Rules

- **Target** : 60 fps sur les golden devices (Samsung Tab A8 2019, iPhone XR/11). Aucune frame > 16 ms sur le parcours nominal (tap → render). Bench déjà documenté : `docs/EXEC_S2.md` ADVT‑S2‑15.
- **Cold start** : cible < 1,0 s, warm start < 500 ms (DoD S4).
- **Mémoire** : empreinte totale < 150 Mo ; audio < 20 Mo ; cache image `ImageCache.maximumSizeBytes` à régler 64–96 Mo (S4) ; bundle Android release < 30 Mo.
- **Parsing JSON** : actuellement synchrone (`Settings.parseUseIsolate = false`). Seuil de bascule isolate = 1 MiB cumulé (`Settings.parseIsolateThresholdBytes`). Si tu ajoutes un asset qui pousse `assets/data/` au-delà du seuil, **active** le flag dans `Settings` (et adapte le test associé). Ne jamais lancer un `compute()` direct ailleurs — toujours passer par `IsolateExecutor`.
- **Caches repository** : `AdventureRepositoryImpl` cache `_locations`, `_objects`, `_locNameToId`, `_objNameToId`. Ne pas recharger les JSON dans un use case. Si tu ajoutes un cache, document-le et fournis un mécanisme d'invalidation testable.
- **Listes UI** : pour `actions/journal/inventory`, utiliser `ListView.builder` (pas de `Column` qui force le layout complet). Limiter les rebuilds via `const` constructors et `ValueListenableBuilder` ciblé.
- **Audio throttle** : `AudioController` throttle les SFX à 150 ms par défaut. Ne pas appeler `playSfx` en boucle sans tenir compte du throttle.
- **Précharge image** : prévoir `precacheImage` du prochain lieu après un `ApplyTurn` réussi (DoD S4).

---

### Code Organization Rules

#### Layout obligatoire

```
lib/
  domain/{entities,value_objects,repositories,usecases,services,constants}
  application/{controllers,services,providers,routing}
  data/{datasources,models,repositories,services}
  features/{home,adventure,inventory,saves,settings,credits}     ← un écran = un dossier (cf. design.md §3.2)
  core/{constant,error,theme,widgets,usecases,utils,settings.dart,di}
  l10n/{app_en.arb,app_fr.arb,app_localizations.dart}
  main.dart
```

- **`features/<screen>/`** : tout le code dédié à un écran (page + widgets internes + state local éventuel). Un widget vit ici **si** il est consommé uniquement par cet écran.
- **`core/widgets/`** : atomes UI transverses partagés entre plusieurs écrans (`pixel_canvas.dart`, `flash_message_listener.dart`, `icon_helper.dart`, `location_image.dart`). Les composants design system (`OAStamp`, `OAPill`, …) arrivent en Story 5-4.
- **`core/theme/`** : tokens et thèmes Material (`app_colors.dart`, `app_spacing.dart`, `app_typography.dart`, `app_theme.dart`). La Story 5-3 renomme/refonde ces fichiers vers `oa_colors.dart` etc.
- **`application/providers/`** : providers Riverpod (cf. [`dev-notes/riverpod-playbook.md`](./dev-notes/riverpod-playbook.md)). Introduit en Story 5-1 ; rempli par 5-6 → 5-10.

- **Tout nouveau use case** va dans `lib/domain/usecases/<verb>_<object>.dart` avec :
  - une `abstract class` contractuelle (`abstract class TakeObject { Future<TurnResult> call(String objectId, Game game); }`),
  - une `class <Name>Impl implements <Name>` implémentation,
  - exporté et injecté dans `main.dart`.
- **Pas de "manager", "helper", "util"** dans Domain. Préférer un nom de domaine (`DwarfSystem`, `MotionCanonicalizer`).
- **Mappers** : un fichier par schéma sous `lib/data/models/`, nommé `<entity>_model.dart`. Constructeur `factory <Model>.fromJson(Map<String, dynamic>, [int id])`. Optionnel : `toJson()`, `toEntity()`.

#### Naming

- **Classes** : `PascalCase` (`GameController`, `ApplyTurnGoto`).
- **Fichiers** : `snake_case` (`apply_turn_goto.dart`, `motion_normalizer_impl.dart`).
- **Tests** : `<fichier>_test.dart` dans `test/<même chemin que lib/>`.
- **Méthodes/variables** : `lowerCamelCase`. Champs privés : préfixe `_`.
- **Constantes** : `lowerCamelCase` (ex : `defaultBgmAssetResolver`) ou `kPrefix` pour les vraies constantes globales (ex : `kOpenObjectRequiredKeys` dans `interaction_requirements.dart`).
- **Use case → fichier `<verb>_<object>.dart`** : `take_object.dart`, `light_lamp.dart`, etc. La classe d'API publique = `Verb` ou `VerbObject` (`TakeObject`), l'impl = `<Name>Impl` (`TakeObjectImpl`).

#### Asset paths

- Toujours via `AssetPaths.*` (`lib/core/constant/asset_paths.dart`). Ne jamais coder en dur `'assets/data/locations.json'` dans un autre fichier.

#### IDs vs noms

- Les **IDs publics** (Location, GameObject) sont des **index** dans le tableau source JSON, générés séquentiellement par la repository. Ne jamais les hardcoder dans le code (sauf cas justifié — ex : `LOC_BUILDING` résolu par nom via cache).
- Pour résoudre `name ↔ id` utiliser le `LookupService` ou les caches `_locNameToId`/`_objNameToId` de la repository.

---

### Testing Rules

- **Test miroir** : chaque module `lib/<couche>/<chemin>.dart` doit avoir un test `test/<couche>/<chemin>_test.dart`. Si tu crées un fichier sans test, c'est incomplet.
- **Couverture cibles (DoD S4, gate CI prévue)** : Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 %.
- **Outils** : `flutter_test` + `mocktail`. Ne pas introduire `mockito` ni `build_runner`. Pour un mock, créer `class MockX extends Mock implements X {}` localement dans le test.
- **Tests Domain** : doivent être 100 % en pur Dart (`package:test`), sans `flutter_test`. Aucun `MaterialApp`, aucun widget.
- **Tests Data** : tests d'`AssetDataSource` doivent couvrir chemin nominal **et** isolate forcé (`BundleAssetDataSource(forceIsolateParsing: true)`) **et** entrée invalide (`AssetDataFormatException`).
- **Tests Application** : tester que `autosave` est appelée **exactement 1 fois** par tour réussi (via `verify(...).called(1)`).
- **Widget tests** : utiliser `pump()` + `pumpAndSettle()`. Vérifier qu'aucun `Exception` n'est levé en l'absence d'asset (image notamment). Tester explicitement le bouton `Plus…` si > 7 actions.
- **Tests d'oracle (S4)** : O1 navette mots magiques, O2 nain présent/absent, O3 pirate vol→récup→dépôt (`docs/Dossier_de_Référence.md` §7.4). Seed fixe ; comparaison messages avec tolérance whitespace.
- **SaveRepository tests** : utiliser un `supportDirProvider` mocké (ne **jamais** toucher le vrai FS dans un test).

---

### Platform & Build Rules

- **Plateformes supportées** : Android (présent), iOS (à scaffolder avant 1re build : `flutter create --platforms=ios .`).
- **Aucune permission sensible** déclarée. Le jeu est 100 % offline : aucune permission réseau, aucun stockage externe, aucun capteur. Ne jamais ajouter une permission Android/iOS sans DDR explicite.
- **`applicationId` Android** : actuellement `com.example.open_adventure` (placeholder, cf. `android/app/build.gradle.kts`). À remplacer avant publication (ex : `io.<org>.openadventure`).
- **Signing release Android** : actuellement keystore debug (`signingConfigs.getByName("debug")`). TODO release signing avant publication.
- **CI** : aucune (`.github/workflows/` absent). Plan dans `docs/EXEC_S4.md` ADVT‑S4‑11/14. Tout PR doit faire tourner `flutter analyze` + `flutter test` en local jusqu'à la mise en place de la CI.
- **Builds locaux** :
  - `flutter build apk` (APK debug-signed)
  - `flutter build apk --release --analyze-size` (release ; vérifier < 30 Mo)
  - `flutter build appbundle --release` (AAB Play Store)
  - `flutter build ipa` (iOS, après création `ios/`)
- **Pas de fastlane**, pas de Bitrise. Si distribution semi-auto requise, en discuter via DDR.

---

### Critical Don't-Miss Rules (anti-patterns & gotchas)

#### Doctrine

1. **La spec prime sur le code** (`docs/CONVERSION_SPEC.md` §source-de-vérité). Si le code diverge, c'est le code qu'on aligne — pas la doc. Toute déviation doit être documentée dans la spec ou via un DDR avant merge.
2. **Aucun `game.json` monolithique**. L'état runtime se compose à partir des JSON atomiques + `GameSnapshot`. Toute tentative de réintroduire un méga-modèle doit être refusée.
3. **Pas de réseau**. Aucun `http`, `dio`, `web_socket_channel`, `firebase_*`. Aucune télémétrie. Aucun crash reporter tiers. Si vraiment besoin, DDR explicite.
4. **Fidélité gameplay 430 pts** : toute divergence vs `open-adventure-master/{actions,score,saveresume,init}.c` doit être justifiée. Pour Score/Save, traiter le C upstream comme oracle.

#### Anti-patterns Flutter à refuser

- ❌ `setState` dans une page qui dispose déjà d'un `ValueNotifier` — toujours `ValueListenableBuilder` ou écoute directe.
- ❌ Logique métier dans un widget (`if (object.isTreasure) score += 2` côté UI). → use case Domain.
- ❌ Lecture directe de `rootBundle.loadString(...)` hors `BundleAssetDataSource`. → injecter `AssetDataSource`.
- ❌ Chaîne FR/EN codée en dur dans Presentation (`Text('Aller Nord')`). → clé ARB.
- ❌ Initialisation d'un repository ailleurs que dans `main.dart`. → DI explicite par constructeur.
- ❌ `Random()` non-seedé dans Domain. → LCG local seedé sur `Game.rngSeed`.
- ❌ Singleton statique mutable (`static Game current; …`). → state immuable + `ValueNotifier`.
- ❌ Mocks `mockito` + `@GenerateMocks` + `build_runner`. → `mocktail` uniquement.
- ❌ `await` dans un constructeur (Dart ne le permet pas) — utiliser `static Future<T> load(...)` (cf. `MotionNormalizerImpl.load`).
- ❌ Import croisé `lib/data/models/` → `lib/domain/usecases/`. La direction autorisée : Data dépend de Domain, jamais l'inverse.

#### Gotchas spécifiques au domaine

- **BACK/RETURN ne passe pas par `travel.json`**. Il consulte `Game.oldLoc`/`Game.oldLc2` et respecte `Location.conditions['NOBACK']` + `FORCED`. Cf. `ApplyTurnGoto._resolveBackTarget` et `ListAvailableActionsTravel._resolveBackTarget`. Ne pas chercher de règle `motion=BACK` dans `travel.json`, elle n'existe pas.
- **Incantations (XYZZY/PLUGH/PLOVER/FEE-FIE-FOE-FOO)** : filtrées par `MagicWords.isIncantation(verb)` tant que `Game.magicWordsUnlocked == false`. Le débridage se fait par événement diégétique (à implémenter S3+). DDR-001 Option A — **ne jamais** les exposer proactivement.
- **`travel.json` filtrage S2** : `ListAvailableActionsTravel` ne garde que les règles dont `condtype ∈ {cond_goto, "0"}` et `stop == false`. Quand `EvaluateCondition` couvrira plus de types (S3+), élargir ce filtre dans `ListAvailableActionsTravel`, pas dans un autre endroit.
- **Lampe** : `clock1/clock2/limit` sont modélisés ; `_applyLampTimers` cherche un objet par `state == 'LAMP_BRIGHT'` (pas par id), décrémente `limit`, émet `LAMP_DIM` au seuil 30 (`_lampWarningThreshold`, à externaliser en S4 dans `turn_thresholds.json`), bascule à `LAMP_DARK` à 0. Ne pas court-circuiter ce flux.
- **Nains** : `DwarfSystem.tick` n'agit que si `Location.conditions['DEEP'] == true`. Hors souterrain, les nains sont retirés (`dwarfLocations = [-1, -1, -1]`). En S3, le tick ne modifie ni objets ni chemins ; uniquement journal + propagation seed.
- **`Game.objectStates`** est indexé par **id** (int), pas par nom. Pour LAMP/BOTTLE, l'id sort de `getGameObjects()` (séquence d'apparition dans `objects.json`). Ne pas hardcoder l'id ; toujours résoudre via l'objet `GameObject`.
- **first-visit vs revisit** : `Game.visitedLocations` est marqué dans `ApplyTurnGoto` (et `initialGame()` y inclut le lieu de départ). `_selectDescription(location, firstVisit: ...)` choisit long → short avec fallback inverse. Inverser ce paramètre = bug subtil de UX.
- **`flashMessage`** : exposé pour la SnackBar via `FlashMessageListener`. Toujours `controller.clearFlashMessage()` après consommation (le widget le fait déjà). Si tu en ajoutes un, n'oublie pas `flashMessage: null` quand le contexte n'en exige plus.
- **Mots magiques + meta verbs** : dans `GameController.perform`, le retour anticipé pour `OBSERVER/MAP/INVENTORY` est **avant** le filtre incantation. L'ordre exact est dans le code ; respecte-le.
- **Scripts Python** : doivent rester sous `scripts/` et **jamais** être appelés depuis le runtime app. Toute logique de génération/validation reste hors du binaire mobile.

#### Workflow PR

- Avant tout merge sur `develop`/`main` : `flutter analyze` zéro warning **et** `flutter test` vert. Si tests Domain modifiés, vérifier que la couverture cible (≥ 90 %) reste tenue.
- Si JSON modifiés : `python3 scripts/validate_json.py` doit retourner exit 0. Si pas le cas, corriger côté YAML/scripts et regénérer via `python3 scripts/update_assets.py`.
- Documenter toute nouvelle entrée critique dans `docs/index.md` + `docs/component-inventory.md` (au minimum) pour que les agents BMad gardent une carte à jour.

---

## Références

- Spec normative : [`docs/CONVERSION_SPEC.md`](./CONVERSION_SPEC.md)
- Référence historien + DDR : [`docs/Dossier_de_Référence.md`](./Dossier_de_Référence.md)
- Plans de sprint : `docs/EXEC_S1.md`…`EXEC_S4.md`
- Architecture détaillée : [`docs/architecture.md`](./architecture.md)
- Inventaire composants : [`docs/component-inventory.md`](./component-inventory.md)
- Modèle de données : [`docs/data-models.md`](./data-models.md)
- Master index : [`docs/index.md`](./index.md)

---

## Usage Guidelines

**Pour les agents IA :**

- Lire ce fichier **avant** toute implémentation. Le charger explicitement en contexte au démarrage de chaque story.
- Suivre toutes les règles à la lettre. En cas de doute, choisir l'option la plus restrictive.
- Si une règle conflicte avec un objectif de story, signaler le conflit et demander un arbitrage **avant** d'implémenter.
- Si une nouvelle convention émerge (ex : nouveau pattern d'use case, nouvelle contrainte de perf), proposer son ajout à ce fichier dans le PR concerné.

**Pour les humains :**

- Garder ce fichier **lean** : il doit servir d'aide-mémoire LLM, pas de documentation exhaustive. Pour le détail, renvoyer vers `docs/architecture.md`, `docs/component-inventory.md`, `docs/data-models.md`.
- Mettre à jour à chaque changement de stack (`pubspec.yaml`), de pattern structurant (DI, state management), ou de DDR (`docs/Dossier_de_Référence.md` §7).
- Revue trimestrielle : retirer les règles devenues évidentes ou obsolètes ; conserver uniquement ce qu'un LLM ne devinerait pas seul.
- Toute modification structurante doit aussi être propagée dans la spec normative (`docs/CONVERSION_SPEC.md`) si elle change le contrat fonctionnel.

Last Updated: 2026-05-17
