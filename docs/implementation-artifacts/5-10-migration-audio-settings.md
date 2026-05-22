# Story 5.10: Migration `AudioController` + `SettingsController` vers providers

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2
Refs : [epic-5](../planning-artifacts/epic-5.md#story-510-migration-audiocontroller--settingscontroller-vers-providers), [design.md §3.1](../design.md), [features/settings.md](../features/settings.md)

## Story

**En tant que** développeur,
**je veux** migrer `AudioController` (`AudioController` service + `AudioSettingsController` `ValueNotifier`) sur Riverpod 2,
**afin que** les pages settings (4-6) et adventure (5-7) puissent consommer `audioControllerProvider` / `audioSettingsProvider` sans recevoir les contrôleurs par constructeur — **sans** changer une seule règle audio : `just_audio` + `audio_session` préservés (édition A1 du Sprint Change Proposal), throttle SFX 150 ms préservé, volumes persistés sur `shared_preferences`.

## Acceptance Criteria

1. **AC1 — `audioControllerProvider`** : `Provider<AudioController>` dans `lib/application/providers/audio_provider.dart`. Instanciation unique côté provider (`AudioController()`), `ref.onDispose(() => controller.dispose())` câblé.
2. **AC2 — `audioSettingsProvider`** : `StateNotifierProvider<AudioSettingsNotifier, AudioSettingsState>`. `AudioSettingsNotifier extends StateNotifier<AudioSettingsState>` (refonte de `AudioSettingsController` `ValueNotifier` actuel). Dépend de `loadAudioSettingsProvider` + `saveAudioSettingsProvider` + `audioControllerProvider`. `AudioSettingsState` (immutable, `final`, `==`/`hashCode`, `copyWith`) reflète `{ bgmVolume: double, sfxVolume: double, muted: bool, isLoading: bool }`.
3. **AC3 — Initialisation** : le notifier expose `init()` qui appelle `loadAudioSettings()` puis pousse les volumes au `AudioController` via `setVolume(bgm, sfx)`. Cet appel doit rester **exactement 1 fois** au démarrage (cf. `project-context.md` §Testing Rules → Tests Application). L'app appelle `init()` au démarrage via `ref.read(audioSettingsProvider.notifier).init()` (probablement déclenché par `OpenAdventureApp` ou un widget bootstrap).
4. **AC4 — Persistance préservée** : `setBgmVolume(v)` et `setSfxVolume(v)` poussent au `AudioController` **et** persistent via `SaveAudioSettings` (use case existant). Throttle ou debounce de la persistance : si le user manipule rapidement le slider, persister uniquement la valeur finale (max 1 write toutes les 300 ms — réutiliser pattern existant si déjà présent). `shared_preferences` reste le backend.
5. **AC5 — `just_audio` + `audio_session` préservés** : aucune dépendance audio changée. Pas de `audioplayers` (banni par édition A1 du Sprint Change Proposal). Ducking iOS+Android intact. Cf. édition A1 : `design.md` §3.1 a été patché pour confirmer `just_audio + audio_session`.
6. **AC6 — Throttle SFX 150 ms** : si `AudioController.playSfx(...)` implémente déjà un throttle 150 ms (cf. `project-context.md` §Performance Rules), il reste tel quel. Aucune modification de la logique audio dans cette story — **seulement le wrapper Riverpod**.
7. **AC7 — Tests préservés** : tests existants `test/application/controllers/audio_settings_controller_test.dart` migrés vers `ProviderContainer(overrides: [...])`. Vérifications :
   - `loadAudioSettings` appelé exactement 1 fois lors de `init()`.
   - `saveAudioSettings` appelé après chaque `setBgmVolume`/`setSfxVolume` (avec throttle).
   - `AudioController.setVolume(...)` appelé avec les bonnes valeurs.
   - Volumes persistés et rechargés correctement (test E2E via mock `shared_preferences`).
8. **AC8 — `main.dart` allégé** : suppression des lignes `AudioController audioController = AudioController(); ... AudioSettingsController audioSettingsController = AudioSettingsController(...); await audioSettingsController.init();`. Le bootstrap audio passe par les providers. Conserver `WidgetsFlutterBinding.ensureInitialized()` ; conserver l'appel à `init()` (mais via `ProviderContainer` ou `ref.read` à un point bien défini — documenter le choix).
9. **AC9 — Qualité** : `flutter analyze` 0 warning ; couverture Application ≥ 80 % préservée.

## Tasks / Subtasks

- [ ] **Task 1 — `audioControllerProvider`** (AC: #1)
- [ ] **Task 2 — `AudioSettingsNotifier`** (AC: #2)
  - [ ] Refactor `AudioSettingsController` → `AudioSettingsNotifier` (StateNotifier).
  - [ ] `AudioSettingsState` immuable.
- [ ] **Task 3 — `audioSettingsProvider`** (AC: #2)
- [ ] **Task 4 — Use case providers** (AC: #2)
  - [ ] `loadAudioSettingsProvider`, `saveAudioSettingsProvider`, `audioSettingsRepositoryProvider`.
- [ ] **Task 5 — Throttle persistance** (AC: #4)
- [ ] **Task 6 — Init bootstrap** (AC: #3, #8)
- [ ] **Task 7 — `main.dart` allégé** (AC: #8)
- [ ] **Task 8 — Tests migrés** (AC: #7)
- [ ] **Task 9 — Lint + couverture** (AC: #9)

## Dev Notes

### Architecture cible

```
audioSettingsRepositoryProvider     (Provider<AudioSettingsRepository>)
loadAudioSettingsProvider           (Provider<LoadAudioSettings>)
saveAudioSettingsProvider           (Provider<SaveAudioSettings>)
audioControllerProvider             (Provider<AudioController>)
audioSettingsProvider               (StateNotifierProvider<AudioSettingsNotifier, AudioSettingsState>)
```

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/application/controllers/audio_settings_controller.dart` | UPDATE (`ValueNotifier`→`StateNotifier`) |
| `lib/application/providers/audio_provider.dart` | NEW |
| `lib/application/providers/audio_settings_provider.dart` | NEW |
| `lib/application/services/audio_controller.dart` | UNCHANGED (logique audio préservée) |
| `lib/main.dart` | UPDATE (suppression instanciations audio) |
| `test/application/controllers/audio_settings_controller_test.dart` | UPDATE (ProviderContainer) |

### Project Context Rules

- **`just_audio` + `audio_session`** : non négociables (cf. édition A1).
- **Throttle SFX 150 ms** : préservé.
- **Volumes persistés** : `shared_preferences` reste le backend (cf. `project-context.md` §Dépendances production).
- **mocktail uniquement** ; pas de `mockito`.
- **Pas de `Random()` non-seedé** : non applicable ici.

### References

- `docs/design.md` §3.1 (patché édition A1 — `just_audio` + `audio_session`)
- `docs/features/settings.md`
- `docs/planning-artifacts/epic-5.md` §Story 5.10
- Code actuel : `lib/application/controllers/audio_settings_controller.dart`, `lib/application/services/audio_controller.dart`

### Previous Story Intelligence

- **2-17-audio-controller-bootstrap** + **2-18-settings-volumes-persistes** (done) : ont livré le système audio mature. Cette story ne change que la couche d'exposition.
- **5-1** doit être livré avant.

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
