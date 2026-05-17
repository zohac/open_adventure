# Story 4.17: Audio — Settings avancés (toggles + sliders + reset + persistance)

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑17 (`docs/EXEC_S4.md`)
Refs : [project-context](../project-context.md), [UX_SCREENS](../UX_SCREENS.md)

## Story

**En tant que** joueur, **je veux** des réglages audio avancés (toggles ON/OFF musique/SFX, sliders volume, bouton reset valeurs par défaut), tous persistés, **afin de** personnaliser finement et restaurer rapidement les défauts si besoin.

## Acceptance Criteria

1. **AC1 — Toggles ON/OFF** Musique/SFX (en plus des sliders existants).
2. **AC2 — Bouton "Réinitialiser"** restaure les valeurs par défaut (BGM 60 %, SFX 100 %, toggles ON).
3. **AC3 — Persistance** via `AudioSettingsRepository` (existant).
4. **AC4 — UI réactive** : changement instantané (pas de "Appliquer").
5. **AC5 — Option "Audio rétro" (EQ léger)** : facultative ; si non implémentée, masquer le toggle.
6. **AC6 — Tests** : traversée ON/OFF sans erreur ; reset effectif ; persistance prouvée.

## Tasks / Subtasks

- [ ] **Task 1 — Étendre `AudioSettings` VO** (toggles + EQ optionnel).
- [ ] **Task 2 — UI SettingsPage** (AC: #1, #2, #4, #5).
- [ ] **Task 3 — Tests** (AC: #6).

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `lib/domain/entities/audio_settings.dart` | UPDATE (toggles) |
| `lib/application/controllers/audio_settings_controller.dart` | UPDATE |
| `lib/presentation/pages/settings_page.dart` | UPDATE |
| `lib/data/repositories/audio_settings_repository_impl.dart` | UPDATE (clés supplémentaires) |
| `test/application/controllers/audio_settings_controller_test.dart` | UPDATE |

### Project Context Rules
- ValueNotifier pattern.
- mocktail only.
- i18n obligatoire.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑17

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
