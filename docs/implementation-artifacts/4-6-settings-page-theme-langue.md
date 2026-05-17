# Story 4.6: SettingsPage — thème + taille police + langue (FR/EN) + persistance

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑06 (`docs/EXEC_S4.md`)
Refs : [project-context](../project-context.md), [VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md), [UX_SCREENS](../UX_SCREENS.md)

## Story

**En tant que** joueur, **je veux** régler le thème (clair/sombre/système), la taille de police (3 crans), la langue (FR/EN) depuis SettingsPage avec persistance entre sessions, **afin de** personnaliser le confort de lecture.

## Acceptance Criteria

1. **AC1 — UI controls** : SettingsPage ajoute 3 sélecteurs (thème, taille police, langue) en plus des sliders volumes existants.
2. **AC2 — Persistance** : préférences sauvées via `shared_preferences` (clés `app.theme`, `app.fontScale`, `app.locale`).
3. **AC3 — Application live** : changement de thème → `OpenAdventureApp` rebuild avec le nouveau `themeMode` ; changement de police → `MediaQuery.textScaler` mis à jour ; changement de langue → `MaterialApp.locale` mis à jour, ARB recharge.
4. **AC4 — Tests persistance + locale** : préférences restaurées au démarrage ; changement de langue reflété sans relancer l'app.
5. **AC5 — i18n + a11y** : labels via ARB ; semantics ; cibles ≥ 48 dp.

## Tasks / Subtasks

- [ ] **Task 1 — `AppPreferencesController` (Application)** : expose `AppPreferencesViewState { themeMode, fontScale, locale }`.
- [ ] **Task 2 — `AppPreferencesRepository` (Domain) + impl shared_preferences (Data)**.
- [ ] **Task 3 — Bind `OpenAdventureApp`** à `AppPreferencesController` (write `themeMode`, `locale`, `textScaler`).
- [ ] **Task 4 — UI SettingsPage** : sélecteurs.
- [ ] **Task 5 — Tests** (AC: #4).

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/application/controllers/app_preferences_controller.dart` | NEW |
| `lib/domain/repositories/app_preferences_repository.dart` | NEW |
| `lib/data/repositories/app_preferences_repository_impl.dart` | NEW |
| `lib/main.dart` | UPDATE (DI + binding) |
| `lib/presentation/pages/settings_page.dart` | UPDATE (sélecteurs) |
| `lib/l10n/app_en.arb`, `app_fr.arb`, `app_localizations.dart` | UPDATE |
| `test/application/controllers/app_preferences_controller_test.dart` | NEW |
| `test/data/repositories/app_preferences_repository_impl_test.dart` | NEW |

### Project Context Rules
- ValueNotifier pattern.
- DI manuelle dans main.dart.
- mocktail only.
- i18n obligatoire.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑06
- `docs/UX_SCREENS.md` (Settings)
- `lib/application/controllers/audio_settings_controller.dart` (pattern existant à imiter)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
