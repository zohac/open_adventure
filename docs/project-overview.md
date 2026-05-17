# Project Overview — open_adventure

> Portage mobile Flutter du jeu textuel **Colossal Cave Adventure** (lignée Crowther/Woods → Eric S. Raymond *Open Adventure 2.5* — 430 points), 100 % offline, sans saisie clavier (UI par boutons contextuels), rendu pixel-art 16-bit, FR/EN.

## Identité

- **Projet** : open_adventure
- **Type** : application mobile (Flutter, mono-part)
- **Version** : `1.0.0+1` (pubspec)
- **Plateformes cibles** : Android (`android/` natif présent), iOS (planifié — pas de dossier `ios/` à ce jour)
- **Licence amont** : référence C `open-adventure-master/` publiée par E.S. Raymond sous BSD 2-clauses, avec accord de Crowther & Woods
- **Domaine** : adventure game (interactive fiction), historiquement fidèle à *Adventure 2.5*

## Pitch en une phrase

Rejouer *Colossal Cave Adventure* sur smartphone, sans clavier ni connexion, dans une esthétique 16-bit Megadrive/SNES, en gardant la fidélité gameplay du C upstream comme oracle.

## Décisions normatives fortes

1. **Reboot Flutter complet** par rapport au code legacy (cf. `docs/CONVERSION_SPEC.md` §résumé exécutif). Seuls les `assets/data/*.json` et la référence `open-adventure-master/` survivent.
2. **Source de vérité = `docs/CONVERSION_SPEC.md`**. En cas de contradiction, le code s'aligne sur la doc.
3. **Aucune saisie texte** : la boucle de jeu propose 3–7 boutons contextuels (sécurité → travel → interaction → méta). Voir `docs/Dossier_de_Référence.md` §B.
4. **Incantations Option A (DDR-001)** : XYZZY/PLUGH/PLOVER/FEE-FIE-FOE-FOO ne sont jamais listées proactivement. Un bouton contextuel apparaît seulement dans les lieux où l'incantation agit, et après découverte diégétique (flag `Game.magicWordsUnlocked`).
5. **Mouvement BACK/RETURN** géré natif Domain via `oldLoc`/`oldLc2`, sans passer par `travel.json` ; respect de `COND_NOBACK` et des transitions forcées (`FORCED`).
6. **Pas de `game.json`** monolithique. L'état runtime se construit à partir des JSON atomiques + snapshot autosave séparé (`assets/data/metadata.json` porte uniquement `schema_version` et `start_location_id`).
7. **100 % offline** : aucune permission réseau, aucune télémétrie, données et sauvegardes locales uniquement.

## Stack — vue synthétique

| Catégorie         | Choix                                                       | Notes                                                          |
|-------------------|-------------------------------------------------------------|----------------------------------------------------------------|
| Langage           | Dart `>=3.0.0 <4.0.0`                                       | Null-safety stricte                                            |
| Framework         | Flutter stable 3.35.x                                       | `flutter doctor` OK requis pour bootstrap                      |
| Architecture      | Clean Architecture (Domain/Application/Data/Presentation/Core) | DI manuelle dans `main.dart`                                 |
| State management  | `ValueNotifier<GameViewState>` (GameController/HomeController/AudioSettingsController) | Pas de Bloc, pas de Provider package |
| Persistance       | Fichiers JSON via `path_provider` (autosave) + `shared_preferences` (audio settings) | Pas de SQLite                              |
| Audio             | `just_audio` + `audio_session`                              | BGM par zone (crossfade) + SFX throttle ; mémoire < 20 Mo cible |
| Images de scène   | WebP pixel-art via `PixelCanvas` (scale entier, FilterQuality.none) | 16:9, ≤ 200 KB/image, total ≤ 10 Mo                    |
| i18n              | `flutter_localizations` + ARB (`app_en.arb` source, `app_fr.arb`) | ~80 clés, code généré dans `lib/l10n/app_localizations.dart` (554 lignes) |
| Tests             | `flutter_test`, `test`, `coverage`, `mocktail`              | 56 fichiers de tests, miroir de `lib/`                         |
| Lint              | `flutter_lints` 6.x via `analysis_options.yaml`             | Exclusions : `lib_legacy/`, `test/features/`, `build/`, `coverage/` |
| Diagrammes        | drawio (assets) + Graphviz (`dot`) pour graphe travel       | `diagram/travel.dot` → `diagram/travel.png`                    |

## Avancement par sprint (lecture de `docs/EXEC_S*.md`)

| Sprint | Objectif                                                                 | État        |
|--------|--------------------------------------------------------------------------|-------------|
| **S1** | Scaffolding Clean Architecture, mappers Data ↔ Entities, `AdventureRepository`, `initialGame()`, smoke tests | ✅ Terminé  |
| **S2** | Moteur travel (`ListAvailableActions`/`ApplyTurn(goto)`), UI v0 (HomePage, AdventurePage), autosave, audio bootstrap, BACK/RETURN, filtre incantations | ✅ Terminé  |
| **S3** | Interactions (Take/Drop/Open/Close/Light/Extinguish/Examine/Drink), `EvaluateCondition`, `DwarfSystem.tick`, `ComputeScore` partiel, InventoryPage | 🟡 ~70 %   |
| **S3 — restant** | MapPage v1 (multi-couches), JournalView, intégration `LocationImage` + déclaration assets/images, audio mapping zones + SFX, Art Bible (15-20 scènes), a11y, lint final | ⏳ TODO     |
| **S4** | Scoring complet (parité `score.c`), fins de jeu, multi-saves, polish UX/AdventurePage v2/StatusBar, i18n finale, perfs/hardening, CI verte | ⏳ Non commencé |

## Architecture en une image (textuelle)

```
┌────────────────────────────────────────────────────────────────────┐
│                         Presentation                               │
│   HomePage  AdventurePage  InventoryPage  SavesPage  SettingsPage  │
│            PixelCanvas  LocationImage  FlashMessageListener        │
└────────┬───────────────────────────────────────────────────────────┘
         │ écoute ValueNotifier<*ViewState>
┌────────▼───────────────────────────────────────────────────────────┐
│                         Application                                │
│   GameController   HomeController   AudioSettingsController        │
│                       AudioController (just_audio)                 │
└────────┬───────────────────────────────────────────────────────────┘
         │ injecte
┌────────▼─────────────────────────┐    ┌─────────────────────────────┐
│           Domain                 │◀───│           Data              │
│   Entities  ValueObjects         │    │   Models (fromJson)         │
│   Repositories (interfaces)      │    │   AdventureRepositoryImpl   │
│   UseCases (ApplyTurn/...)       │    │   SaveRepositoryImpl        │
│   Services (DwarfSystem,         │    │   AudioSettingsRepoImpl     │
│             MotionCanonicalizer) │    │   MotionNormalizerImpl      │
└──────────────────────────────────┘    │   BundleAssetDataSource     │
                                        └─────────────┬───────────────┘
                                                      │ lit
                                        ┌─────────────▼───────────────┐
                                        │   assets/data/*.json        │
                                        │   (~658 KB total)           │
                                        └─────────────────────────────┘

         Pipeline de génération assets (hors runtime app)
   open-adventure-master/adventure.yaml ──► scripts/make_dungeon.py
        └► dungeon.c/.h (upstream) ──────► scripts/extract_c.py
        └► validation ─────────────────── scripts/validate_json.py
```

## Métriques rapides

- **Code Dart applicatif** : 84 fichiers, ~7 970 lignes (`lib/`)
- **Code Dart tests** : 56 fichiers (`test/`, ~368 KB)
- **Assets data** : 14 fichiers JSON, ~658 KB total
- **i18n** : 2 locales (EN source + FR), ~80 clés ARB
- **Use cases Domain** : 18 (hors orchestrateurs)
- **Pages UI** : 6 (Home, Adventure, Inventory, Saves, Settings, Credits)

## Liens vers les documents détaillés

- [Architecture détaillée](./architecture.md)
- [Source tree annoté](./source-tree-analysis.md)
- [Inventaire des composants UI/Domain](./component-inventory.md)
- [Modèle de données](./data-models.md)
- [Inventaire des assets](./asset-inventory.md)
- [Development guide](./development-guide.md)
- [Deployment guide](./deployment-guide.md)
- Spec normative : [`docs/CONVERSION_SPEC.md`](./CONVERSION_SPEC.md)
- Référence historien/DDR : [`docs/Dossier_de_Référence.md`](./Dossier_de_Référence.md)
- Plans de sprint : [`docs/EXEC_S1.md`](./EXEC_S1.md), [`docs/EXEC_S2.md`](./EXEC_S2.md), [`docs/EXEC_S3.md`](./EXEC_S3.md), [`docs/EXEC_S4.md`](./EXEC_S4.md)
- Direction artistique : [`docs/VISUAL_STYLE_GUIDE.md`](./VISUAL_STYLE_GUIDE.md), [`docs/ART_ASSET_BIBLE.md`](./ART_ASSET_BIBLE.md)
- Écrans : [`docs/UX_SCREENS.md`](./UX_SCREENS.md)
