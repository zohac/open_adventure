# Story 4.10: Accessibilité finale — voice-over + contrastes + clavier

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑10 (`docs/EXEC_S4.md`)
Refs : [design.md](../design.md), [project-context](../project-context.md)
~~Refs obsolètes~~ : ~~[VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md)~~ (superseded 2026-05-22)

---
## 📝 Amendement Design Handoff — 2026-05-22

Intégrer durant le dev :
- **ADR-006 — Motion steps** : audit `MediaQuery.disableAnimations` doit couvrir le motion system `OAAnimations` livré en 5-5
- **Contrastes WCAG AA** : à valider sur la palette ambre/encre du handoff (ADR-003) — pas sur l'indigo de `VISUAL_STYLE_GUIDE.md` obsolète
- **Pages couvertes** : Home, Adventure v2, Inventory, Saves, Settings, Map, EndGame, Credits → toutes refondues en Epic 5 / blocked-by-epic-5 → l'audit ne peut être qu'**après** livraison d'Epic 5 et des stories 4-x débloquées
- **Atomes UI** : `OAStamp`, `OAPill`, `OAIcon` doivent porter les Semantics labels (DRY) — vérifier que 5-4 les expose correctement

> ℹ️ Non bloquant techniquement, mais l'audit final doit être planifié **après** clôture d'Epic 5 et des stories UI 4-5/4-6/4-7/4-8/4-19 pour avoir un état stable à auditer.
---

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
