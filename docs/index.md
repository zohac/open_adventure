# open_adventure — Documentation Index

> **Point d'entrée principal pour les agents BMad et le développement assisté par IA.**
> Généré par `gds-document-project` le 2026-05-17 (mode `initial_scan` / Deep Scan).
>
> Source de vérité fonctionnelle : [`CONVERSION_SPEC.md`](./CONVERSION_SPEC.md) (prime sur le code en cas de contradiction).

## Project Overview

- **Type** : monolith / mobile (Flutter)
- **Langage principal** : Dart `>=3.0.0 <4.0.0` (Flutter stable 3.35.x)
- **Architecture** : Clean Architecture (Presentation → Application → Domain ← Data)
- **Domaine** : portage mobile de *Colossal Cave Adventure* (Open Adventure 2.5 / 430 pts, lignée Crowther/Woods/Raymond)
- **Plateformes** : Android (natif présent), iOS (planifié — `ios/` à créer)
- **Mode** : 100 % offline (aucune permission réseau, aucune télémétrie)

## Quick Reference

- **Tech stack** : Flutter + Dart + ValueNotifier + just_audio + path_provider + shared_preferences + ARB (FR/EN)
- **Entry point** : [`lib/main.dart`](../lib/main.dart) (composition root, DI manuelle)
- **Architecture pattern** : Clean Architecture / Ports & Adapters
- **Source de vérité données** : `open-adventure-master/adventure.yaml` (YAML upstream, non compilé) → `assets/data/*.json` (généré par `scripts/`)
- **State management** : `ValueNotifier<*ViewState>` (GameController, HomeController, AudioSettingsController)
- **Persistance** : `path_provider` (autosave JSON) + `shared_preferences` (audio)
- **Tests** : 56 fichiers Dart, miroir de `lib/`. Cibles couverture (S4) : Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 %
- **CI** : aucune actuellement — plan dans [EXEC_S4.md](./EXEC_S4.md)

## Avancement projet

| Sprint | État        | Objectif synthétique                                                |
|--------|-------------|----------------------------------------------------------------------|
| S1     | ✅ Terminé  | Scaffolding Clean Architecture + Data layer + `initialGame()`        |
| S2     | ✅ Terminé  | Moteur travel + UI v0 + autosave + audio bootstrap + BACK + filtre incantations |
| S3     | 🟡 ~70 %   | Interactions, lampe, nains, ComputeScore partiel, InventoryPage     |
| S3 — reste | ⏳       | MapPage v1, JournalView, LocationImage, audio mapping/SFX, Art Bible, a11y |
| S4     | ⏳ Non commencé | Scoring complet, fins de jeu, multi-saves, polish, hardening, CI verte |

## Documentation générée (par cette passe)

- [Project Overview](./project-overview.md) — pitch + stack + métriques + diagramme synthétique
- [Architecture](./architecture.md) — Clean Architecture, boucle de tour, persistance, state, audio, i18n, tests, CI, risques
- [Source Tree Analysis](./source-tree-analysis.md) — arborescence annotée + critical directories + conventions
- [Component Inventory](./component-inventory.md) — entités/VOs/use cases/controllers/services/pages/widgets + backlog manquant
- [Data Models](./data-models.md) — pipeline d'assets, entités Domain, schémas JSON, snapshot persistance
- [Asset Inventory](./asset-inventory.md) — JSON embarqués, images/audio planifiés, pipeline de génération, budgets
- [Development Guide](./development-guide.md) — setup, build, tests, scripts, workflow PR, conventions
- [Deployment Guide](./deployment-guide.md) — Android (actuel), iOS (planifié), CI/CD, signing, distribution
- API Contracts — **Non applicable** (aucune API HTTP — application 100 % offline sans communication réseau)

## Documentation existante (source du projet)

### Normative — source de vérité

- [`CONVERSION_SPEC.md`](./CONVERSION_SPEC.md) — Cahier des charges complet C → Flutter (§17–§19 UX mobile, heuristiques actions, DA)
- [`Dossier_de_Référence.md`](./Dossier_de_Référence.md) — Vue historien + DDR (incantations Option A, PNJ, oracles seedés, exemple snapshot JSON)
- [`UX_SCREENS.md`](./UX_SCREENS.md) — Wireframes + DoD par écran (Home, Adventure, Inventory, Map, Journal, Saves, Settings, EndGame…)
- [`VISUAL_STYLE_GUIDE.md`](./VISUAL_STYLE_GUIDE.md) — Palette, typographie, composants UI, motion, règles 16-bit
- [`ART_ASSET_BIBLE.md`](./ART_ASSET_BIBLE.md) — Briefs scènes/objets/créatures, palettes prioritaires, VFX/SFX
- [`DESIGN_ADDENDUM.md`](./DESIGN_ADDENDUM.md) — Checklists Dev/Artist/CTO
- [`Cahier_des_charges_Map.md`](./Cahier_des_charges_Map.md) — Spec MapPage v1/v2 (multi-couches)
- [`CTO_DEV_MAP_REQUEST.md`](./CTO_DEV_MAP_REQUEST.md) — Détails livrables CTO/dev pour la carte

### Plans de sprint

- [`EXEC_S1.md`](./EXEC_S1.md) — Scaffolding & Data layer ✅
- [`EXEC_S2.md`](./EXEC_S2.md) — Moteur travel + UI v0 + autosave + audio bootstrap ✅
- [`EXEC_S3.md`](./EXEC_S3.md) — Interactions + inventaire + lampe + nains + scoring partiel + MapPage/JournalView/images/audio 🟡
- [`EXEC_S4.md`](./EXEC_S4.md) — Scoring complet + fins + multi-saves + polish + CI ⏳

### Reporting généré

- [`ASSET_TRACKER.md`](./ASSET_TRACKER.md) — Tableaux Locations/Objects/Audio + budgets (généré par `scripts/generate_asset_tracker.py`)
- [`ASSET_MANIFEST.json`](./ASSET_MANIFEST.json) — Source IA pour génération d'art/audio (généré par `scripts/generate_asset_manifest.py`)
- [`map_layout_plan.yaml`](./map_layout_plan.yaml) + [`map_layers/`](./map_layers/) — Plan et exports des couches MapPage
- [`ux_screens_images/`](./ux_screens_images/) — Screenshots wireframes (HomePage clair/sombre)
- [`project-scan-report.json`](./project-scan-report.json) — État interne de ce workflow

### Référence amont (lecture seule, non compilée)

- `open-adventure-master/adventure.yaml` — source de vérité YAML (gameplay/lore/données)
- `open-adventure-master/{actions,score,saveresume,init,main,misc,cheat}.c` — implémentation C de référence
- `open-adventure-master/{history,hints,notes,README,INSTALL}.adoc` — documentation upstream
- `open-adventure-master/tests/*.chk` — oracles canoniques (mazealldiff, tall, plover, dwarf, lampdim2…)

## Getting Started — guide rapide

### Pour développer

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Voir [development-guide.md](./development-guide.md) §1-3 pour le setup complet.

### Pour comprendre le code

1. Lire [`project-overview.md`](./project-overview.md) (5 min).
2. Lire [`architecture.md`](./architecture.md) §1-5 (cœur + boucle de tour).
3. Parcourir [`source-tree-analysis.md`](./source-tree-analysis.md) pour situer chaque dossier.
4. Lire [`data-models.md`](./data-models.md) pour comprendre les schémas JSON et entités.
5. Consulter [`component-inventory.md`](./component-inventory.md) pour identifier précisément un use case ou un widget.

### Pour créer un PRD brownfield BMad

Pointer le workflow `gds-prd` (ou `bmad-create-prd` côté Software Dev) sur ce fichier (`docs/index.md`). Les agents trouveront ainsi :

- la spec normative (`CONVERSION_SPEC.md`),
- l'état actuel (par sprint, EXEC_S1…S4),
- les contrats Domain (`architecture.md` §5-8 et `component-inventory.md` Domain),
- les DDR en vigueur (`Dossier_de_Référence.md` §7).

### Pour mettre à jour les assets depuis l'amont

```bash
python3 scripts/update_assets.py --out assets/data        # orchestrateur
python3 scripts/validate_json.py                           # vérification
```

Voir [development-guide.md](./development-guide.md) §6 pour les options avancées.

## Verification Recap

- **Tests/extractions exécutés** : aucun test Flutter relancé par cette passe (lecture seule). État pris de la doc EXEC_S* et de l'inspection du code (`lib/main.dart`, `GameController`, `ApplyTurn`, `ListAvailableActions`, mappers Data, `AdventureRepositoryImpl`, `SaveRepositoryImpl`, `DwarfSystem`, `ComputeScore`).
- **Outstanding risks / follow-ups** :
  - `applicationId = com.example.open_adventure` (placeholder) à changer avant release.
  - Signing release Android utilise toujours les clés debug.
  - `ios/` à créer avant la 1re build iOS.
  - Aucune CI configurée — créer `.github/workflows/ci.yml` (analyze + test + coverage).
  - `GameSnapshot` minimal (loc/turns/rngSeed) à étendre en S4 pour reprise complète.
  - `_lampWarningThreshold = 30` codé en dur dans `GameController` — externaliser via `turn_thresholds.json`.
- **Recommended next checks before PR** :
  - `flutter analyze` zéro warning ;
  - `flutter test` vert ;
  - `python3 scripts/validate_json.py` exit 0 si JSON modifiés ;
  - mise à jour de [`component-inventory.md`](./component-inventory.md) si ajout/suppression d'un module structurel.

## Prochaines actions BMad recommandées

1. **Generate Project Context** (`gds-generate-project-context`) — produit un `project-context.md` LLM-optimisé qui s'appuiera sur ce dossier `docs/`.
2. **Sprint Planning** (`gds-sprint-planning`) — formaliser le reste de S3 + S4 dans `docs/implementation-artifacts/sprint-status.yaml`.
3. **Create Story → Dev Story → Code Review** (cycle) sur les tickets restants (MapPage, JournalView, ComputeScore complet, multi-saves, EndGamePage, CI).
