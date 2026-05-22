# Story 5.3: Port `tokens.css` → Dart (remplace 2-19)

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2 ; supersède la story `2-19-theme-tokens-baseline`
Refs : [epic-5](../planning-artifacts/epic-5.md#story-53-port-tokenscss--dart-remplace-2-19), [design.md §4 ADR-003/004](../design.md), [tokens.css](../../design_handoff_open_adventure/tokens.css)

## Story

**En tant que** développeur,
**je veux** porter les design tokens du handoff (`design_handoff_open_adventure/tokens.css`) en classes Dart typées exposées via des `ThemeExtension`,
**afin que** chaque page refondue (5-7/5-8/5-9) et chaque atome (5-4) consomme la palette/typo/spacing canoniques (encre profonde × halo ambre × papier vieilli, fonts Pixelify/Silkscreen/DM Sans) **sans** chaîne hex/dp/font codée en dur.

## Acceptance Criteria

1. **AC1 — `OAColors` `ThemeExtension`** : `lib/core/theme/oa_colors.dart` expose **toutes** les couleurs du handoff regroupées par famille : `ink` (void/deep/mid/raised/line/hairline), `teal` (mist/deep/glow), `paper` (bright/warm/faded/ink), `amber` (glow/base/deep/shadow/halo) et semantic (treasure/danger/success/magic). Tous les champs `final`, `==`/`hashCode` structurels, `copyWith` + `lerp` implémentés (signature `ThemeExtension`).
2. **AC2 — `OATypography` `ThemeExtension`** : `lib/core/theme/oa_typography.dart` expose les styles `display.xl/l/m/s`, `caps.m/s`, `body.l/m/s`, `action`, `mono` — basés sur les variables CSS (`--t-*`). Fonts résolues : `displayFamily = 'Pixelify Sans'`, `capsFamily = 'Silkscreen'`, `bodyFamily = 'DM Sans'`, `monoFamily = 'JetBrains Mono'` (déclarés en const, sans chaîne magique éparpillée).
3. **AC3 — `OASpacing` `ThemeExtension`** : `lib/core/theme/oa_spacing.dart` expose la grille `s0..s10` (4dp grid, mappée 1:1 sur `--s-*`), `radii` (`r0/r1/r2/r3`), `borderWidths` (`b1/b2/b3`), `hitTargets` (`min: 44, comfy: 48, large: 56`).
4. **AC4 — `OAMotionTokens` partiel** : durées (`durFast: 120ms`, `durBase: 200ms`, `durSlow: 320ms`) exposées sous `lib/core/theme/oa_motion_tokens.dart`. Les **courbes** (`Curves.stepN`) restent de la responsabilité de 5-5 ; cette story expose uniquement les durées, pour permettre à 5-5 de les consommer.
5. **AC5 — Fonts embarquées** : `Pixelify Sans` (Regular 400, Bold 700), `Silkscreen` (Regular 400) embarquées sous `assets/fonts/` et déclarées dans `pubspec.yaml` section `fonts:`. `DM Sans` (Regular 400, Medium 500) embarquée également (pas de `google_fonts` runtime — offline-only impose embed). Licences (`OFL.txt` Google Fonts) committées dans `assets/fonts/<family>/`.
6. **AC6 — Wiring `ThemeData`** : `lib/core/theme/oa_theme.dart` construit un `ThemeData(brightness: Brightness.dark, extensions: [OAColors.dark, OATypography.standard, OASpacing.standard, OAMotionTokens.standard])`. Pas de `lightTheme` — ADR-003 dark-only. Le `MaterialApp` est mis à jour pour utiliser `OAThemeData.dark()` à la place de l'ancien `AppTheme` (`app_theme.dart` supprimé ou réduit à `export 'oa_theme.dart' show OAThemeData`).
7. **AC7 — Helper d'accès** : extension `BuildContextX` sur `BuildContext` exposant `context.oaColors`, `context.oaTypography`, `context.oaSpacing`, `context.oaMotion` — résout via `Theme.of(context).extension<OAColors>()!` etc.
8. **AC8 — Smoke widget test** : `test/core/theme/oa_theme_smoke_test.dart` instancie un `MaterialApp(theme: OAThemeData.dark())` et vérifie : (a) `extension<OAColors>()` non-null, (b) `oaColors.amber.base.value == 0xFFF0A040`, (c) `oaTypography.body.m.fontSize == 15`, (d) `oaSpacing.s4 == 16.0`, (e) `oaMotion.durBase == const Duration(milliseconds: 200)`.
9. **AC9 — Story `2-19-theme-tokens-baseline` marquée superseded** : commentaire inline en tête du fichier story `2-19-theme-tokens-baseline.md` : `> ⚠️ Supersedée par 5-3 (Epic 5 Foundation Refresh, 2026-05-22).` Statut `done` préservé (le travail antérieur reste historisé).
10. **AC10 — Qualité** : `flutter analyze` 0 warning ; tests verts ; couverture Presentation ≥ 60 % préservée (les ports tokens entrent côté `lib/core/theme/` — comptabilisés en Presentation).

## Tasks / Subtasks

- [ ] **Task 1 — Embarquer les fonts** (AC: #5)
  - [ ] Télécharger Pixelify Sans / Silkscreen / DM Sans depuis Google Fonts (OFL).
  - [ ] Déposer sous `assets/fonts/<family>/<family>-<weight>.ttf` + `OFL.txt`.
  - [ ] Section `fonts:` dans `pubspec.yaml`.
- [ ] **Task 2 — `OAColors` ThemeExtension** (AC: #1)
- [ ] **Task 3 — `OATypography` ThemeExtension** (AC: #2)
- [ ] **Task 4 — `OASpacing` ThemeExtension** (AC: #3)
- [ ] **Task 5 — `OAMotionTokens` (durées)** (AC: #4)
- [ ] **Task 6 — `OAThemeData.dark()`** (AC: #6)
- [ ] **Task 7 — Extension `BuildContextX`** (AC: #7)
  - [ ] Fichier `lib/core/theme/build_context_x.dart` (≤ 40 lignes).
- [ ] **Task 8 — Wiring `MaterialApp`** (AC: #6)
  - [ ] `lib/main.dart` consomme `OAThemeData.dark()`.
  - [ ] L'ancien `AppTheme` (`app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart`) reste en place tant que les pages refondues (5-7/5-8/5-9) ne sont pas livrées — Dev Note explicite. **Cette story n'efface pas l'ancien thème**, elle ajoute le nouveau.
- [ ] **Task 9 — Smoke test** (AC: #8)
- [ ] **Task 10 — Superseder `2-19`** (AC: #9)
- [ ] **Task 11 — Vérifications finales** (AC: #10)

## Dev Notes

### Architecture cible

- 4 `ThemeExtension` indépendantes : `OAColors`, `OATypography`, `OASpacing`, `OAMotionTokens`.
- `OAThemeData.dark()` construit le `ThemeData` final ; aucune valeur Material par défaut n'est utilisée pour les couleurs/typo (les composants Material standards qui restent en place — `Scaffold`, `MaterialButton` — héritent du `colorScheme` dérivé).
- Cohabitation transitoire avec `AppTheme` actuel : pendant Epic 5, deux thèmes sont disponibles. Les pages refondues (5-7/5-8/5-9) utilisent `OAThemeData`. Les pages non refondues continuent à fonctionner avec l'ancien `AppTheme` jusqu'à leur reskin. **Le main app utilise `OAThemeData`** dès cette story — les pages non encore refondues doivent rester fonctionnelles visuellement (acceptable de voir un mix transitoire).

### Mapping `tokens.css` → Dart

```dart
// design_handoff_open_adventure/tokens.css     → lib/core/theme/oa_colors.dart
// --c-ink-void: #06101a                        → ink.void = Color(0xFF06101A)
// --c-amber:    #f0a040                        → amber.base = Color(0xFFF0A040)
// --c-amber-halo: rgba(240,160,64,0.22)        → amber.halo = Color.fromRGBO(240,160,64,0.22)
// --t-display-xl: 40px                         → typography.display.xl.fontSize = 40
// --s-4: 16px                                  → spacing.s4 = 16.0
// --hit-min: 44px                              → spacing.hitTargets.min = 44.0
```

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `assets/fonts/PixelifySans/*.ttf` + `OFL.txt` | NEW |
| `assets/fonts/Silkscreen/*.ttf` + `OFL.txt` | NEW |
| `assets/fonts/DMSans/*.ttf` + `OFL.txt` | NEW |
| `pubspec.yaml` (section `fonts:`) | UPDATE |
| `lib/core/theme/oa_colors.dart` | NEW |
| `lib/core/theme/oa_typography.dart` | NEW |
| `lib/core/theme/oa_spacing.dart` | NEW |
| `lib/core/theme/oa_motion_tokens.dart` | NEW |
| `lib/core/theme/oa_theme.dart` | NEW |
| `lib/core/theme/build_context_x.dart` | NEW |
| `lib/main.dart` | UPDATE (theme: OAThemeData.dark()) |
| `test/core/theme/oa_theme_smoke_test.dart` | NEW |
| `docs/implementation-artifacts/2-19-theme-tokens-baseline.md` | UPDATE (bandeau supersedé) |

### Project Context Rules

- **Aucune chaîne hex/dp/font codée en dur** ailleurs que dans `lib/core/theme/`. Tout consommateur passe par `context.oaColors`/`context.oaTypography`/`context.oaSpacing`.
- **Pas de `google_fonts` runtime** (offline-only). Embed local obligatoire.
- **Dark only** (ADR-003) : pas de `lightTheme`. Si quelqu'un tente d'ajouter un light mode, refuser et pointer vers ADR-003.
- **Immutabilité** : tous les champs des `ThemeExtension` sont `final`, constructeurs `const`.

### References

- `design_handoff_open_adventure/tokens.css` (source de vérité numérique)
- `docs/design.md` §4 ADR-003 (dark only), ADR-004 (fonts)
- `docs/planning-artifacts/epic-5.md` §Story 5.3
- Story superseded : `docs/implementation-artifacts/2-19-theme-tokens-baseline.md`
- Flutter API : `ThemeExtension<T>` (docs Flutter stable 3.35.x)

### Previous Story Intelligence

- Story `2-19-theme-tokens-baseline` (done) a livré une première baseline `AppTheme` indigo. Cette baseline ne reflète **pas** la DA finale. Le travail est conservé historiquement mais la story 5-3 redéfinit la palette/typo/spacing depuis zéro, en s'appuyant sur `tokens.css`.
- Pas de mocktail nécessaire ici (pas de service, pure data).

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
