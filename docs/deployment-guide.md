# Deployment Guide — open_adventure

> État au 2026-05-17 : aucune CI configurée (`.github/workflows/` absent), pas de `fastlane/`, pas de `Bitrise.yml`. Seul Android dispose d'un dossier natif. iOS planifié. Ce document décrit l'état actuel et le plan tel qu'écrit dans `docs/EXEC_S4.md`.

## 1. Cibles plateformes

| Plateforme | Dossier natif    | Statut                         | Notes                                                            |
|-----------|------------------|---------------------------------|-----------------------------------------------------------------|
| Android   | `android/`       | ✅ présent (Gradle Kotlin DSL)  | `namespace = "com.example.open_adventure"`, `applicationId` idem (TODO unique vrai bundle) |
| iOS       | `ios/`           | ⏳ absent — à créer             | Avant la 1re build : `flutter create --platforms=ios .`         |
| Web       | n/a              | hors périmètre                  | Architecture compatible mais aucune cible définie               |
| Desktop   | n/a              | hors périmètre                  | —                                                                |

## 2. Build Android

### Commandes

```bash
flutter pub get
flutter analyze                                # gate qualité
flutter test                                   # gate tests
flutter build apk                              # debug-signed (debug keystore)
flutter build apk --release --analyze-size     # release (cf. notes signing)
flutter build appbundle --release              # AAB pour Play Store
```

### Configuration actuelle (`android/app/build.gradle.kts`)

- `compileSdk = flutter.compileSdkVersion` (suit le SDK Flutter)
- `minSdk = flutter.minSdkVersion`
- `targetSdk = flutter.targetSdkVersion`
- `versionCode = flutter.versionCode`, `versionName = flutter.versionName`
- `JavaVersion.VERSION_11` (source/target/JVM)
- **Signing release** : utilise actuellement le keystore debug (`signingConfig = signingConfigs.getByName("debug")`). **TODO** : remplacer par une vraie config release avant publication.
- **applicationId** : `com.example.open_adventure` — placeholder à remplacer avant publication (cf. commentaire `TODO: Specify your own unique Application ID`).

### Bundle size

DoD S4 : APK release < 30 Mo. À mesurer avec `flutter build apk --release --analyze-size`.

## 3. Build iOS (planifié)

Le dossier `ios/` n'existe pas. Avant la première build :

```bash
flutter create --platforms=ios .          # génère ios/ sans toucher au reste
```

Puis vérifier :

- `Info.plist` : permissions minimales (aucune permission sensible nécessaire ; le jeu est 100 % offline).
- Capabilities : aucune.
- `Podfile` généré OK ; `pod install` réussit pour `path_provider`, `just_audio`, `audio_session`, `shared_preferences`.
- `audio_session` configuration iOS (mode `playback`) — vérifier le bon comportement avec le ringer/silent switch.
- Sauvegardes : `NSApplicationSupportDirectory` (déjà géré par `SaveRepositoryImpl` via `path_provider`).
- Signing : Apple Developer Program requis pour distribution (TestFlight / App Store).

## 4. Pipeline CI/CD (planifié S4)

**Aucune CI actuellement.** Plan documenté dans `docs/EXEC_S4.md` :

### Jobs minimaux

```yaml
# .github/workflows/ci.yml (à créer)
jobs:
  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.x'
          channel: stable
      - run: flutter pub get
      - run: flutter analyze --fatal-warnings   # zéro warning
      - run: flutter test --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/lcov.info
      # Enforcer les seuils via lcov_cobertura ou coverage tool
```

### Job optionnel `data-validate`

Non bloquant pour le pipeline mobile.

```bash
python3 scripts/validate_json.py
```

### Build automation

Plan : recourir à `fastlane` (Android + iOS) ou GitHub Actions natif (`gradle`/`xcodebuild`). Aucune décision arrêtée à ce jour.

## 5. Distribution

- **Android** : Play Store (interne → fermée → ouverte). Pré-requis : application unique, vraie signing release, screenshots/fiche store (16-bit pixel-art à fournir), classification PEGI/IARC (jeu d'aventure, sans violence graphique).
- **iOS** : App Store / TestFlight. Pré-requis : compte Apple Developer ($99/an), même fiche produit.
- **Pas de canal de distribution alternative** (pas de F-Droid prévu, pas de side-loading documenté).

## 6. Données utilisateur

- **Sauvegardes locales** : `${applicationSupportDirectory}/open_adventure/autosave.json` (S2) puis multi-slots (S4).
- **Préférences audio** : `shared_preferences` (clés `audio.bgmVolume`, `audio.sfxVolume`).
- **Aucune télémétrie**, aucune analyse, aucun crash reporter intégré. Le crash reporting natif (Play Console / TestFlight) reste disponible automatiquement.
- **Aucune permission sensible** déclarée ; pas de réseau, pas de stockage externe, pas de capteurs.

## 7. Confidentialité (à publier)

Pour la mise en ligne :

- **Politique de confidentialité** : minimaliste — "aucune collecte de données utilisateur, aucune connexion réseau". Doit néanmoins être publiée pour Play Store/App Store.
- **Privacy nutrition labels iOS** : "Data Not Collected".
- **Play Data Safety** : "No data collected, no data shared".

## 8. Stratégie de release

Cf. `docs/EXEC_S4.md`. Synthèse :

1. **DoD S4 verts** (scoring complet, fins de jeu, multi-saves, i18n FR/EN, a11y AA, perfs).
2. **Build Android signé release** + audit bundle size + smoke test sur appareils cibles (cf. `docs/Dossier_de_Référence.md` §7.6 : Samsung Tab A8 et POCO F4 mesurés en S2).
3. **Publication interne** (Internal testing track).
4. **Build iOS** (après création `ios/`) + TestFlight.
5. **Release publique** alignée Android/iOS quand parité atteinte.

## 9. Rollback

- Aucun mécanisme de feature flag runtime à distance (pas de réseau).
- Rollback = nouvelle release Play/App Store avec version corrigée.
- Sauvegardes utilisateur : tolérance aux corruptions (S4 — fallback dernier autosave sain) + compat ascendante de `schema_version`.

## 10. Limitations connues

| Limitation | Statut |
|-----------|--------|
| iOS non scaffoldé        | Ajouter `ios/` via `flutter create --platforms=ios .` |
| Signing release Android  | Configurer un keystore release et remplacer `signingConfigs.getByName("debug")` |
| `applicationId` générique| Choisir un identifiant unique (`io.<org>.openadventure` p.ex.) avant publication |
| Pas de CI                | Créer `.github/workflows/ci.yml` (analyze + test + coverage) |
| Pas de crash reporter    | Optionnel — peut rester via crash native si le store le fournit |
| Pas de fastlane          | Optionnel — utile si publication semi-automatisée |
| Bundle size non mesuré   | À vérifier après livraison Art Bible (10 Mo images possibles) |
