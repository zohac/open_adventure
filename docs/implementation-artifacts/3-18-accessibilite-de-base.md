# Story 3.18: Accessibilité de base — semantics + a11y AA pass S3

Status: ready-for-dev
Epic: 3
Source ticket: ADVT‑S3‑18 (`docs/EXEC_S3.md`)
Refs : [project-context](../project-context.md), [UX_SCREENS](../UX_SCREENS.md), [VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md)

## Story

**En tant que** utilisateur dépendant d'un lecteur d'écran ou d'une grande police, **je veux** que toutes les actions et listes de l'app (S3 livré) soient annoncées et navigables, **afin de** jouer dans des conditions équivalentes aux utilisateurs voyants.

## Acceptance Criteria

1. **AC1 — Boutons d'action étiquetés** : chaque `ActionOption` rendue dans `AdventurePage` est encapsulée dans `Semantics(label: <label localisé + état>, button: true)`. État inclut "désactivé" quand applicable.
2. **AC2 — Listes annotées** : `InventoryPage`, `JournalView`, `MapPage` listent leurs items avec `Semantics` ; `liveRegion: true` pour le journal et les flashes.
3. **AC3 — Cibles tactiles ≥ 48 dp** : tous boutons interactifs (chips Map, items inventaire, boutons d'action) respectent `MaterialTapTargetSize.padded`. Vérifier via tests.
4. **AC4 — Contrastes AA** : palette `AppColors` validée en clair ET sombre (ratio ≥ 4.5:1 pour texte normal, ≥ 3:1 pour large/UI). Documenter les ratios dans `docs/VISUAL_STYLE_GUIDE.md`.
5. **AC5 — Ordre de focus déterministe** : sur AdventurePage, l'ordre est `image → titre → description → liste actions → barre journal`. Tests via `FocusTraversalGroup`.
6. **AC6 — Police adaptative** : `Theme.of(context).textTheme` réagit au `MediaQuery.textScaler` (≥ ×2.0 sans cassure de layout).
7. **AC7 — Tests semantics** : `test/presentation/.../accessibility_test.dart` couvre les pages clés (Adventure, Inventory, Home, Settings, JournalView, MapPage si livré) — passe `expect(tester, meetsGuideline(...))` (`androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`).
8. **AC8 — Revue manuelle TalkBack/VoiceOver** : sur device, parcours nominal Home → Adventure → Tap action → Inventory → Map → Settings annoncé sans trou. Note de synthèse dans `Completion Notes`.

## Tasks / Subtasks

- [ ] **Task 1 — Audit pages existantes** (AC: #1, #2, #5)
  - [ ] Auditer `home_page.dart`, `adventure_page.dart`, `inventory_page.dart`, `settings_page.dart`, `saves_page.dart`, `credits_page.dart`.
  - [ ] Lister les manques (boutons sans labels, listes sans `Semantics`, ordre focus implicite).
- [ ] **Task 2 — Ajouter Semantics** (AC: #1, #2)
  - [ ] Compléter labels via `AppLocalizations` ; pas de chaîne brute.
- [ ] **Task 3 — Vérifier tap targets + contrastes** (AC: #3, #4)
  - [ ] Mesurer via `tester.getSize` ; ajuster `AppColors` si ratio < AA.
  - [ ] Documenter ratios mesurés dans `docs/VISUAL_STYLE_GUIDE.md`.
- [ ] **Task 4 — Focus order** (AC: #5)
  - [ ] Wrapper chaque page principale avec `FocusTraversalGroup(policy: OrderedTraversalPolicy())`.
- [ ] **Task 5 — Police adaptative** (AC: #6)
  - [ ] Tester layouts à textScaler ×1.0, ×1.5, ×2.0 ; corriger débordements.
- [ ] **Task 6 — Tests automatisés** (AC: #7)
  - [ ] `test/presentation/accessibility_test.dart` (≥ 5 pages × 4 guidelines).
- [ ] **Task 7 — Revue manuelle + note synthèse** (AC: #8)

## Dev Notes

### Source tree components to touch

| Path | NEW / UPDATE |
|---|---|
| Pages presentation (home, adventure, inventory, settings, saves, credits) | UPDATE |
| `lib/l10n/app_en.arb`, `app_fr.arb`, `app_localizations.dart` | UPDATE (labels semantics) |
| `lib/presentation/theme/app_colors.dart` | UPDATE possible (ajustements contrastes) |
| `docs/VISUAL_STYLE_GUIDE.md` | UPDATE (ratios mesurés) |
| `test/presentation/accessibility_test.dart` | NEW |

### Project Context Rules
- **i18n** : tous labels semantics via `AppLocalizations`.
- **mocktail only** côté tests.
- **Domain pur** : aucun changement Domain — uniquement Presentation + theme.

### References
- `docs/EXEC_S3.md` ADVT‑S3‑18
- Flutter guidelines : `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `textContrastGuideline`, `labeledTapTargetGuideline`
- `docs/VISUAL_STYLE_GUIDE.md`

### Previous Story Intelligence
- DoR fixé en S2 (ADVT‑S2‑19 Theme tokens) ; les contrastes de base existent mais n'ont pas été audités formellement.

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
