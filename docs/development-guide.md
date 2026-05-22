# Development Guide — open_adventure

> Setup, build, tests, scripts. Complète `README.md` (quickstart) avec le niveau de détail dont les agents BMad ont besoin pour produire des PRs propres.

## 1. Prérequis

- **Flutter** stable 3.35.x (Dart `>=3.0.0 <4.0.0`). Vérifier : `flutter --version` puis `flutter doctor`.
- **Python 3** (pour les scripts d'assets uniquement). Voir `requirements-dev.txt` → `PyYAML>=6.0`.
- **Graphviz** (optionnel) pour rendre les diagrammes `.dot` en PNG (`dot -Tpng …`).
- **Android Studio + SDK** (cible Android présente) ou Xcode (planifié, dossier `ios/` à créer).

## 2. Installation

```bash
flutter pub get                       # dépendances Flutter
flutter pub run build_runner --help   # (non utilisé actuellement — pas de codegen runtime)
flutter gen-l10n                      # régénère lib/l10n/app_localizations.dart depuis les ARB
```

Environnement Python (optionnel, pour les scripts) :

```bash
# Option recommandée — venv
python3 -m venv .venv
source .venv/bin/activate            # macOS/Linux
pip install -r requirements-dev.txt

# Option rapide
python3 -m pip install --user PyYAML
```

Vérification :

```bash
python3 -c "import yaml; print(yaml.__version__)"
```

## 3. Lancer l'application

```bash
flutter run                           # device/emu par défaut
flutter run -d emulator-5554          # cible spécifique
flutter run --profile                 # mode profile (mesures perf)
flutter run --release                 # cf. limitations release sans signing release
```

Cible release Android : le `signingConfig` par défaut utilise les clés de debug (`android/app/build.gradle.kts`, TODO de signing release).

## 4. Tests

```bash
flutter analyze                                # lint strict — DoD : zéro warning
flutter test                                   # tous les tests
flutter test test/domain                       # ciblage par couche
flutter test test/data test/domain test/core   # combo recommandé en S1
flutter test --coverage                        # produit coverage/lcov.info
```

### Cibles de couverture (DoD S4)

| Couche       | Seuil |
|--------------|-------|
| Domain       | ≥ 90 % |
| Data         | ≥ 80 % |
| Application  | ≥ 80 % |
| Presentation | ≥ 60 % |

### Organisation

Les tests miroirent `lib/` (un fichier par module). Voir `test/domain/`, `test/data/`, `test/application/`, `test/features/`, `test/core/`, `test/l10n/`.

### Outils

- `flutter_test` (widget tests, pump/pumpAndSettle).
- `mocktail` pour les ports Domain et collaborators d'Application.
- Pas de `mockito` (codegen).

## 5. Build

```bash
flutter build apk                              # APK debug-ish (signed avec keystore debug)
flutter build apk --release --analyze-size     # APK release (TODO release signing)
flutter build appbundle --release              # AAB (Play Store)
flutter build ipa                              # iOS (subordonné à l'ajout du dossier ios/)
```

Bundle target Android < 30 Mo (DoD S4 — actuellement non vérifié).

## 6. Mise à jour des assets depuis l'amont

Les `assets/data/*.json` sont générés depuis `open-adventure-master/adventure.yaml`. Procédure recommandée :

```bash
python3 scripts/update_assets.py --out assets/data
```

Cet orchestrateur enchaîne :

1. `scripts/make_dungeon.py` → `travel.json` + `tkey.json` (canonique).
2. `open-adventure-master/make_dungeon.py` → `dungeon.c/.h` (best effort, depuis le dossier amont).
3. `scripts/extract_c.py` → `travel_c.json` + `tkey_c.json` (validation).
4. `scripts/validate_json.py` → exit 0 si YAML↔JSON cohérent, sinon 1.

Options :

```bash
python3 scripts/update_assets.py --canonical   # écrase travel/tkey depuis le C (à utiliser avec soin)
python3 scripts/update_assets.py --strict      # exit 1 si validation diverge
```

Avancé (manuel) :

```bash
python3 scripts/make_dungeon.py --out assets/data
cd open-adventure-master && python3 make_dungeon.py && cd ..
python3 scripts/extract_c.py --out assets/data \
  --in-travel open-adventure-master/dungeon.c \
  --in-tkey   open-adventure-master/dungeon.c
python3 scripts/validate_json.py
```

## 7. Outils de reporting

```bash
python3 scripts/generate_asset_tracker.py     # → docs/ASSET_TRACKER.md (3 tableaux + budgets)
python3 scripts/generate_asset_manifest.py    # → docs/ASSET_MANIFEST.json (source IA, idempotent)
python3 scripts/generate_map_layout.py        # → assets/data/map_layout.json (S3, à venir)
python3 scripts/generate_travel_graph.py --output diagram/travel.dot
dot -Tpng diagram/travel.dot -o diagram/travel.png
python3 scripts/export_layer_graphs.py        # → docs/map_layers/*.json (5 strates)
```

## 8. Workflow de développement (recommandation)

1. **Avant tout PR** : `flutter analyze` puis `flutter test` doivent passer en local. Reproduire les tests ciblés de la zone modifiée (`flutter test test/<couche>/<fichier>.dart`).
2. **Si les JSON changent** : `python3 scripts/validate_json.py` (depuis le `.venv`). Si divergence → corriger côté YAML/script et regénérer.
3. **Si l'on touche au DI dans `main.dart`** : compiler en `flutter run` pour vérifier le wiring (DI manuelle, pas de container).
4. **Si l'on ajoute une chaîne UI** : créer la clé dans `lib/l10n/app_en.arb`, propager dans `app_fr.arb`, regénérer `app_localizations.dart` via `flutter gen-l10n`. Ne **jamais** coder en dur de chaîne FR/EN dans Presentation.
5. **Si l'on ajoute un asset image** : déclarer le fichier (un par un) dans `pubspec.yaml` section `flutter.assets`, vérifier le respect du budget (≤ 200 KB), valider le rendu via `PixelCanvas` (`FilterQuality.none`).
6. **Si l'on touche au scoring/score.c** : maintenir parité avec `open-adventure-master/score.c`. Documenter toute divergence justifiée.

## 9. Conventions de code

- Linting : `flutter_lints` 6.x (cf. `analysis_options.yaml`). Exclusions : `lib_legacy/`, `test/features/`, `build/`, `coverage/`. Pas de surcharge active.
- Null-safety stricte ; immutabilité par défaut ; `final`/`const` quand possible.
- Domain pur (zéro import `package:flutter/*`).
- Presentation sans logique métier (juste écoute `ValueNotifier` + appel `controller.perform(option)`).
- Models passifs (jamais de calcul métier).
- Tests : `mocktail` pour les ports, pas de fakes ad-hoc inutiles.

## 10. Debug & profiling

- DevTools Flutter : `flutter pub global activate devtools` puis `flutter pub global run devtools`.
- Profiling perf interaction : `flutter run --profile` puis Timeline DevTools. Cible : tap bouton → render < 16 ms.
- Logs audio dev : `AudioController` expose des messages debug (à filtrer par tag custom si nécessaire).

## 11. Pièges fréquents

- **`flutter pub get` qui échoue après pull** : supprimer `pubspec.lock` puis relancer.
- **`AssetDataFormatException`** au démarrage : assets JSON manquants ou mal formés ; relancer `scripts/validate_json.py`.
- **Tests qui touchent au FS** : utiliser un `supportDirProvider` mock pour `SaveRepositoryImpl` (cf. test existant).
- **`make_dungeon.py` qui crashe** : s'assurer d'être bien **dans** `open-adventure-master/` pour la version upstream (cherche `adventure.yaml` en CWD).
- **Isolate parsing** : désactivé par défaut. Si test forcé : `BundleAssetDataSource(forceIsolateParsing: true)`.

## 12. Références internes

- Spec normative : [`docs/CONVERSION_SPEC.md`](./CONVERSION_SPEC.md)
- Plans de sprint : [`docs/EXEC_S1.md`](./EXEC_S1.md), [`docs/EXEC_S2.md`](./EXEC_S2.md), [`docs/EXEC_S3.md`](./EXEC_S3.md), [`docs/EXEC_S4.md`](./EXEC_S4.md)
- Référence historien + DDR : [`docs/Dossier_de_Référence.md`](./Dossier_de_Référence.md)
- Wireframes UX : [`docs/UX_SCREENS.md`](./UX_SCREENS.md)
- Direction artistique : [`docs/VISUAL_STYLE_GUIDE.md`](./VISUAL_STYLE_GUIDE.md), [`docs/ART_ASSET_BIBLE.md`](./ART_ASSET_BIBLE.md)
- Architecture détaillée : [`docs/architecture.md`](./architecture.md)
- Modèle de données : [`docs/data-models.md`](./data-models.md)
- Inventaire composants : [`docs/component-inventory.md`](./component-inventory.md)
- Inventaire assets : [`docs/asset-inventory.md`](./asset-inventory.md)
