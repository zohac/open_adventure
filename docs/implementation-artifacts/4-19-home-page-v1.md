# Story 4.19: HomePage v1 — style 16-bit final + i18n/a11y

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑19 (`docs/EXEC_S4.md`)
Refs : [VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md), [UX_SCREENS](../UX_SCREENS.md), [project-context](../project-context.md)

## Story

**En tant que** joueur lançant l'app, **je veux** une HomePage finalisée 16-bit (typographies, spacing, états raffinés), avec i18n FR/EN complètes et a11y AA, **afin de** poser une première impression conforme à la DA finale.

## Acceptance Criteria

1. **AC1 — Application VISUAL_STYLE_GUIDE** : polices, palette, espacement, états (hover/pressed/disabled/focus) raffinés ; pixel-perfect via `PixelCanvas` quand applicable.
2. **AC2 — Continuer disabled si absence d'autosave** : déjà couvert ADVT‑S2‑20 ; vérifier maintien après refactor.
3. **AC3 — i18n FR/EN complètes** : toutes clés du menu accueil + crédits + tooltips.
4. **AC4 — a11y AA** : focus/labels/contraste OK ; cibles ≥ 48 dp.
5. **AC5 — Tests** : widget tests rendu + interactions + a11y guidelines.

## Tasks / Subtasks

- [ ] **Task 1 — Refactor HomePage** (AC: #1, #2).
- [ ] **Task 2 — i18n complète** (AC: #3).
- [ ] **Task 3 — A11y final** (AC: #4).
- [ ] **Task 4 — Tests** (AC: #5).

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `lib/presentation/pages/home_page.dart` | Refactor DA finale |
| `lib/presentation/pages/home/widgets/*` | Refactor |
| `lib/presentation/theme/*` | Possible ajustements tokens |
| `lib/l10n/app_en.arb`, `app_fr.arb`, `app_localizations.dart` | UPDATE |
| `test/presentation/pages/home_page_test.dart` | UPDATE |

### Project Context Rules
- Pixel-perfect.
- i18n obligatoire.
- mocktail only.
- ValueNotifier pattern.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑19
- `docs/VISUAL_STYLE_GUIDE.md`
- `docs/UX_SCREENS.md` (Home)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
