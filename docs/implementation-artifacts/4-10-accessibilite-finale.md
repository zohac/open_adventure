# Story 4.10: Accessibilité finale — voice-over + contrastes + clavier

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑10 (`docs/EXEC_S4.md`)
Refs : [project-context](../project-context.md), [VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md)

## Story

**En tant que** utilisateur dépendant de TalkBack/VoiceOver ou de la navigation clavier, **je veux** un audit final complet et des correctifs sur toutes les pages livrées (Home, Adventure v2, Inventory, Saves, Settings, Map, EndGame, Credits), **afin de** garantir une expérience AA sans trou.

## Acceptance Criteria

1. **AC1 — Audit checklist interne** : couvrir TalkBack (Android), VoiceOver (iOS, manuel ou simulateur), navigation clavier émulée (Flutter desktop ou web).
2. **AC2 — Contrastes vérifiés** : ratios ≥ AA documentés pour clair et sombre (mesure via Accessibility Insights ou outil équivalent).
3. **AC3 — Tap targets ≥ 48 dp** sur toutes pages.
4. **AC4 — Tests semantics finaux** : étendre `test/presentation/accessibility_test.dart` (Story 3-18) avec MapPage, EndGamePage, SavesPage v2, SettingsPage v2.
5. **AC5 — Correctifs critiques** : tout problème bloquant (labels manquants, ordre focus erratique, contraste < AA) corrigé.
6. **AC6 — Note de synthèse** dans `Completion Notes` : checklist passée, problèmes résiduels, recommandations.

## Tasks / Subtasks

- [ ] **Task 1 — Audit manuel** (AC: #1, #2).
- [ ] **Task 2 — Étendre tests semantics** (AC: #4).
- [ ] **Task 3 — Correctifs** (AC: #5).
- [ ] **Task 4 — Note synthèse** (AC: #6).

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| Pages presentation (toutes) | Ajustements semantics/focus |
| `lib/presentation/theme/app_colors.dart` | Ajustements contrastes |
| `test/presentation/accessibility_test.dart` | Étendre |

### Project Context Rules
- i18n obligatoire pour labels semantics.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑10
- Story 3-18 (a11y de base S3)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
