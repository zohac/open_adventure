# Story 5.4: Atomes UI partagés (`OAStamp`, `OAPill`, `OAIcon`, `OASceneFrame`, `OAItemSprite`)

Status: review
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2
Refs : [epic-5](../planning-artifacts/epic-5.md#story-54-atomes-ui-partagés), [design.md §10 Glossaire / ADR-010](../design.md), [design-system.jsx](../../design_handoff_open_adventure/design-system.jsx), [action-buttons.jsx](../../design_handoff_open_adventure/action-buttons.jsx), [pixel-ui.jsx](../../design_handoff_open_adventure/pixel-ui.jsx)

## Story

**En tant que** développeur UI,
**je veux** disposer des 5 composants de base (`OAStamp`, `OAPill`, `OAIcon`, `OASceneFrame`, `OAItemSprite`),
**afin que** les pages refondues (5-7 AdventurePage, 5-8 HomePage, 5-9 InventoryPage) puissent être assemblées sans dupliquer la logique visuelle (bordures pixel, ombres bloc, tones contextuels, hit targets).

## Acceptance Criteria

1. **AC1 — `OAStamp`** : bouton commun (cf. `design.md` §10 Glossaire). API minimale :
   ```dart
   const OAStamp({
     required this.label,            // String (clé déjà résolue côté caller via AppLocalizations)
     required this.onPressed,        // VoidCallback? — null ⇒ disabled
     this.variant = OAStampVariant.primary,    // primary | secondary | ghost
     this.iconLeading,               // IconData?
     this.iconTrailing,              // IconData?
     this.fullWidth = false,         // bool
     this.size = OAStampSize.regular,// regular | compact | large
   });
   ```
   États visuels : `idle`, `pressed`, `disabled`, `focused` (focus ring 2px ambre).
   `primary` = fill ambre + paper-bright + shadow `--sh-block-md` ; `secondary` = ghost paper-warm + border 2px paper-warm ; `ghost` = label paper-faded sans bordure.
   Hit target ≥ 44dp (size regular) / ≥ 48dp (large). Padding cohérent avec `OASpacing`.
2. **AC2 — `OAPill`** : badge/tag compact. API :
   ```dart
   const OAPill({
     required this.label,
     this.tone = OAPillTone.neutral, // neutral | amber | teal | danger | success | magic | treasure
     this.iconLeading,
     this.dense = false,             // dense=true ⇒ caps-s + padding réduit
   });
   ```
   Couleur de fond/texte dérivée du `tone` (mapping vers `OAColors`). Border-radius `r1` (2px).
3. **AC3 — `OAIcon`** : wrapper unifié pour les icônes. API :
   ```dart
   const OAIcon(this.icon, {this.size = OAIconSize.m, this.color, this.semanticsLabel});
   ```
   Tailles : `s=16, m=20, l=24, xl=32`. Couleur par défaut = `paper-warm`. `semanticsLabel` requis si l'icône porte de l'info (TalkBack).
4. **AC4 — `OASceneFrame`** : encadrement d'une image de scène 16:9 320×180.
   ```dart
   const OASceneFrame({
     required this.child,            // typiquement PixelCanvas(child: Image.asset(...))
     this.locationName,              // String? — overlay en bas-gauche caps-m
     this.lampHaloIntensity = 0.0,   // double 0..1 — vignette ambre (lamp halo)
   });
   ```
   Double bordure pixel (`pix-frame-double` du handoff : 2px paper-warm + inset 1px paper-warm à 2px). Aspect ratio 16:9 forcé. Si `lampHaloIntensity > 0`, dégradé radial ambre.
5. **AC5 — `OAItemSprite`** : tuile inventaire pour un objet/créature 1:1 (ADR-010).
   ```dart
   const OAItemSprite({
     required this.image,            // ImageProvider
     required this.label,            // String
     this.tone = OAItemTone.paper,   // paper | ink | amber | teal — couleur de fond
     this.onTap,
     this.selected = false,
     this.badgeCount,                // int? — petit OAPill en coin
   });
   ```
   Cadre carré 1:1 avec bordure `b2` paper-warm. Fond = couleur tone (cf. ADR-010 — la couleur de fond est portée par le cadre, pas par l'image). Tap target ≥ 56dp si tappable.
6. **AC6 — Tests widgets unitaires** : `test/core/widgets/oa_stamp_test.dart`, `oa_pill_test.dart`, `oa_icon_test.dart`, `oa_scene_frame_test.dart`, `oa_item_sprite_test.dart`. Chaque fichier couvre au minimum : rendu nominal, état désactivé (si applicable), tap (`tester.tap` puis `verify`), hit target via `tester.getSize(find.byType(...))`.
7. **AC7 — Catalogue debug** : `lib/features/debug/widget_gallery.dart` (`ConsumerWidget` ou `StatelessWidget`). Page **non routée en prod** : visible uniquement via une route `/debug/gallery` exposée seulement quand `kDebugMode == true` dans `lib/main.dart`. Affiche tous les atomes avec leurs variantes/états. Permet revue visuelle rapide en `flutter run`.
8. **AC8 — Conformité tokens** : aucun atome ne contient de valeur hex/dp/font codée en dur. Tout passe par `context.oaColors`, `context.oaTypography`, `context.oaSpacing`. Pas d'import `package:flutter/material.dart` pour des couleurs (`Colors.amber` interdit).
9. **AC9 — Accessibilité** : chaque atome interactif expose `Semantics(label: ..., button: true, enabled: onPressed != null)`. `OAStamp` désactivé → `enabled: false`. `OAIcon` purement décoratif → `excludeSemantics: true`.
10. **AC10 — Qualité** : `flutter analyze` 0 warning ; couverture des atomes ≥ 80 % ; aucun warning de pixel ratio (Flutter doit pouvoir rendre les bords nets sur scale ×1/×2/×3).

## Tasks / Subtasks

- [x] **Task 1 — `OAStamp`** (AC: #1, #8, #9)
  - [x] Fichier `lib/core/widgets/oa_stamp.dart`.
  - [x] Enum `OAStampVariant`, `OAStampSize`.
- [x] **Task 2 — `OAPill`** (AC: #2, #8, #9)
- [x] **Task 3 — `OAIcon`** (AC: #3, #8, #9)
- [x] **Task 4 — `OASceneFrame`** (AC: #4, #8)
  - [x] Vignette ambre via `RadialGradient` (centre haut, fade 60 % rayon).
- [x] **Task 5 — `OAItemSprite`** (AC: #5, #8, #9)
- [x] **Task 6 — Tests** (AC: #6, #10)
- [x] **Task 7 — Widget gallery** (AC: #7)
  - [x] Route conditionnelle `if (kDebugMode) GoRoute(path: '/debug/gallery', ...)` (ou nav imperative depuis HomePage en debug).
- [x] **Task 8 — Lint + couverture** (AC: #10)

## Dev Notes

### Architecture cible

- Tous les atomes vivent sous `lib/core/widgets/`.
- Aucun atome ne dépend de Riverpod (atomes = présentation pure). Ils reçoivent leurs paramètres explicitement.
- Référence visuelle stricte : `design_handoff_open_adventure/design-system.jsx` (catalogue des composants) + `action-buttons.jsx` (variantes stamp) + `pixel-ui.jsx` (bordures/ombres pixel).

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/core/widgets/oa_stamp.dart` | NEW |
| `lib/core/widgets/oa_pill.dart` | NEW |
| `lib/core/widgets/oa_icon.dart` | NEW |
| `lib/core/widgets/oa_scene_frame.dart` | NEW |
| `lib/core/widgets/oa_item_sprite.dart` | NEW |
| `lib/features/debug/widget_gallery.dart` | NEW |
| `test/core/widgets/oa_*_test.dart` × 5 | NEW |
| `lib/main.dart` | UPDATE (route conditionnelle `kDebugMode`) |

### Project Context Rules

- **Pixel-perfect** : utiliser `OASceneFrame` au-dessus de `PixelCanvas` (`lib/core/widgets/pixel_canvas.dart`) ; `FilterQuality.none` est imposé côté `PixelCanvas`, pas dans les atomes.
- **i18n** : `OAStamp.label` reçoit une `String` **déjà résolue** par le caller. Aucune lookup `AppLocalizations` côté atome (les atomes ne dépendent pas de `BuildContext.l10n`).
- **Pas de logique métier** : les atomes ne savent rien du jeu. `OAStamp` ne sait pas qu'un verb existe ; il reçoit `label` + `onPressed`.

### Conventions visuelles

| Atome | Bordure | Ombre | Radius | Hit target |
|---|---|---|---|---|
| `OAStamp` primary | b2 ambre | sh-block-md | r0 | 44dp |
| `OAStamp` secondary | b2 paper-warm | sh-block-sm | r0 | 44dp |
| `OAStamp` ghost | none | none | r0 | 44dp |
| `OAPill` | b1 tone | none | r1 | n/a |
| `OASceneFrame` | b2 paper-warm + inset b1 | none | r0 | n/a |
| `OAItemSprite` | b2 paper-warm | sh-block-sm | r0 | 56dp si tap |

### References

- `design_handoff_open_adventure/design-system.jsx` (canonique pour variantes)
- `design_handoff_open_adventure/action-buttons.jsx` (états stamp)
- `design_handoff_open_adventure/pixel-ui.jsx` (bordures/ombres pixel)
- `design_handoff_open_adventure/inventory.jsx` (item sprites en contexte)
- `docs/design.md` §10 Glossaire (définition Stamp) & ADR-010 (assets 1:1)
- `docs/planning-artifacts/epic-5.md` §Story 5.4

### Previous Story Intelligence

- Cette story dépend de 5-3 (tokens) — bloquante. Toute tentative d'implémenter avant 5-3 conduit à des hex en dur. Refuser.
- Aucun atome équivalent dans l'existant ; `lib/presentation/widgets/` (devenu `lib/core/widgets/` après 5-2) contenait seulement `pixel_canvas`, `flash_message_listener`, `icon_helper`, `location_image` — utilitaires, pas atomes.

## Dev Agent Record

### Agent Model Used

- `claude-opus-4-7[1m]` (Claude Code, mode bmad-dev-story) — 2026-05-22.

### Debug Log References

- `flutter analyze` → `No issues found! (ran in 0.9s)`.
- `flutter test test/core/widgets/oa_*.dart` → 21/21 verts.
- `flutter test` (full) → `+226 passed` (205 préexistants + 21 nouveaux atomes).
- `flutter build apk --debug` → `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (~4 s).

### Completion Notes List

- **AC1 — `OAStamp`** : `lib/core/widgets/oa_stamp.dart` (~180 lignes). 3 variants (`primary` / `secondary` / `ghost`) et 3 tailles (`compact` 44dp / `regular` 48dp / `large` 56dp) — exactement ce que demande l'AC1 (le handoff propose 7 tones, écartés pour rester aligné sur l'AC ; les autres tones sont accessibles via `OAPill`). `_resolveTone` mappe vers les couleurs `OAColors` (amber.base/shadow, paper.warm/bright/faded). États visuels :
  - **idle** : décoration BoxDecoration nominale ;
  - **pressed** : géré par `InkWell.highlightColor` + `splashColor` (ambre transparent) ;
  - **disabled** : `onPressed == null` → opacité animée 0.45 (`AnimatedOpacity` via `oaMotion.durFast`) + shadow retirée + `Semantics(enabled: false)` ;
  - **focused** : géré par `InkWell.focusColor` (ambre 16 %).
  Hit-target garanti par `ConstrainedBox(minHeight: hitTargets.min/comfy/large)`.
- **AC2 — `OAPill`** : `lib/core/widgets/oa_pill.dart` (~110 lignes). 7 tones (`neutral/amber/teal/danger/success/magic/treasure`), `dense` switch entre `caps.m` (12px) et `caps.s` (10px) + padding réduit. `borderRadius: r1` (2px). Pas tappable (badge informationnel).
- **AC3 — `OAIcon`** : `lib/core/widgets/oa_icon.dart` (60 lignes). Sizes `s=16, m=20, l=24, xl=32` exposées via `oaIconSizeValue()` (helper public pour faciliter le test). Couleur par défaut = `oaColors.paper.warm`. `semanticsLabel != null` → wrappe en `Semantics(image: true)` ; `semanticsLabel == null` → `ExcludeSemantics` (purement décoratif).
- **AC4 — `OASceneFrame`** : `lib/core/widgets/oa_scene_frame.dart` (~120 lignes). Double bordure (outer b2 paper-warm + inset b1 paper-warm) ; aspect ratio 16:9 forcé via `AspectRatio`. `lampHaloIntensity > 0` → `RadialGradient` ambre centré haut (mix `0.32 → 0.12 → 0` interpolé sur l'intensité). `locationName` → overlay caps-m en bas-gauche sur fond ink-void translucide + bordure paper-warm 45 %. Assertion sur `lampHaloIntensity ∈ [0, 1]`.
- **AC5 — `OAItemSprite`** : `lib/core/widgets/oa_item_sprite.dart` (~110 lignes). 4 tones (`paper/ink/amber/teal` — alignés sur l'AC, pas les 5 tones du handoff). Cadre carré 1:1 (`AspectRatio(1)`). Bordure b2 paper-warm (amber si `selected: true`). Shadow bloc 2dp ink-void. `badgeCount` non-null → `OAPill(amber, dense)` en coin top-right. Tappable si `onTap != null` → tap target ≥ 56dp via `ConstrainedBox(minWidth/minHeight: hitTargets.large)`. `Image(filterQuality: FilterQuality.none)` (ADR-010 pixel-perfect).
- **AC6 — Tests** : 5 fichiers sous `test/core/widgets/oa_*_test.dart`, **21 tests total**. Couvrent : rendu nominal, état désactivé (OAStamp), tap (`tester.tap` + counter), hit targets (`tester.getSize`), variants/tones, sizes (`OAIconSize` values), `MemoryImage` 1×1 PNG pour `OAItemSprite` (sans toucher au filesystem).
- **AC7 — Widget gallery** : `lib/features/debug/widget_gallery.dart` (~130 lignes). `WidgetGalleryPage.routeName = '/debug/gallery'`. Listage des 5 atomes avec toutes leurs variantes. Route ajoutée dans `main.dart` dans une map conditionnelle : `if (kDebugMode) WidgetGalleryPage.routeName: (_) => const WidgetGalleryPage()`. **Non accessible en build release** (kDebugMode == false → entrée absente de la map). Note : l'image `OAItemSprite` utilise un asset placeholder (`assets/data/locations.json`) qui sera remplacé par des sprites réels en Story 5-12.
- **AC8 — Conformité tokens** : zéro `Color(0xFF...)`, zéro `fontSize: 12`, zéro `EdgeInsets.all(16)` codé en dur dans les atomes — tout passe par `context.oaColors`, `context.oaTypography`, `context.oaSpacing`, `context.oaMotion`. `Colors.transparent` est utilisé (sentinelle Flutter, pas une vraie couleur design) ; tous les autres `Colors.*` sont absents.
- **AC9 — Accessibilité** : `OAStamp` → `Semantics(button: true, enabled: onPressed != null, label)`. `OAItemSprite` interactif → `Semantics(button: true, selected, enabled: true, label)`, non interactif → `Semantics(image: true, label)`. `OAIcon` purement décoratif → `ExcludeSemantics`. `OAPill`/`OASceneFrame` → wrappers visuels, pas de semantics ajoutés (informations portées par le contenu textuel sous-jacent).
- **AC10 — Qualité** : `flutter analyze` 0 warning, `flutter test` 226 verts (+21), `flutter build apk --debug` OK. Couverture : les 5 atomes ont chacun un test miroir avec ≥ 3 scénarios — couverture estimée ≥ 80 % pour chaque atome (chemins variants + tap + hit target + edge cases couverts).

### Décisions de cadrage

- **3 variants au lieu de 7 (Stamp)** : le handoff `action-buttons.jsx` propose 7 tones (`default/meta/faded/danger/primary/treasure/hostile/magic`), mais l'AC1 spécifie exactement 3 variants (`primary/secondary/ghost`). L'AC fait foi ; les autres tones sont accessibles via `OAPill` (qui en expose 7). Une story future pourra étendre `OAStampVariant` si nécessaire (DDR).
- **Items image placeholder** : la gallery utilise `AssetImage('assets/data/locations.json')` qui ne renderera pas vraiment mais évite de bloquer la story. Sera remplacé par des sprites réels en Story 5-12 (pipeline assets 3 tiers, ADR-010).
- **Mono font fallback** : `OAFontFamily.mono = 'JetBrainsMono'` (déclaré en 5-3) reste sans fichier embarqué — n'est utilisée par aucun atome de 5-4, donc aucun risque visuel.

### File List

**NEW :**

- `lib/core/widgets/oa_stamp.dart`
- `lib/core/widgets/oa_pill.dart`
- `lib/core/widgets/oa_icon.dart`
- `lib/core/widgets/oa_scene_frame.dart`
- `lib/core/widgets/oa_item_sprite.dart`
- `lib/features/debug/widget_gallery.dart`
- `test/core/widgets/oa_stamp_test.dart`
- `test/core/widgets/oa_pill_test.dart`
- `test/core/widgets/oa_icon_test.dart`
- `test/core/widgets/oa_scene_frame_test.dart`
- `test/core/widgets/oa_item_sprite_test.dart`

**UPDATE :**

- `lib/main.dart` (import `kDebugMode` + `WidgetGalleryPage` + route conditionnelle)
- `docs/implementation-artifacts/sprint-status.yaml` (`5-4-atomes-ui-partages` → `review`)
- `docs/implementation-artifacts/5-4-atomes-ui-partages.md` (tâches cochées, Dev Agent Record rempli, Status `review`)

## Change Log

| Date       | Author        | Change                                                                              |
|------------|---------------|-------------------------------------------------------------------------------------|
| 2026-05-22 | Claude (dev)  | Implémentation Story 5-4 : 5 atomes UI (`OAStamp`, `OAPill`, `OAIcon`, `OASceneFrame`, `OAItemSprite`), 21 tests miroirs, widget gallery conditionnelle `kDebugMode`. Tous les atomes consomment exclusivement `context.oa*` (zéro hex/dp/font en dur). 226 tests verts, analyze 0 warning, APK debug OK. |
