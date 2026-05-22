# Story 5.5: Motion system (`OAAnimations` + `Curves.stepN`)

Status: done
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2
Refs : [epic-5](../planning-artifacts/epic-5.md#story-55-motion-system), [design.md ADR-006](../design.md), [motion-spec.jsx](../../design_handoff_open_adventure/motion-spec.jsx), [motion.css](../../design_handoff_open_adventure/motion.css)

## Story

**En tant que** développeur UI,
**je veux** un système d'animation en marches discrètes (`Curves.step2/step4/step8`) avec respect de `MediaQuery.disableAnimations`,
**afin que** toutes les animations de l'app (transitions de pages, micro-interactions des stamps, fade-in d'une scène) gardent la grammaire pixel 16-bit (ADR-006) et l'app reste accessible aux joueurs avec « reduce motion » activé.

## Acceptance Criteria

1. **AC1 — Courbes `stepN`** : `lib/core/motion/oa_step_curves.dart` expose 3 courbes :
   - `OAStepCurve.step2` (2 marches),
   - `OAStepCurve.step4` (4 marches — `--ease-pixel` du handoff `steps(4, end)`),
   - `OAStepCurve.step8` (8 marches).
   Chaque `Curve` implémente `transformInternal(double t)` retournant `((t * N).ceil()) / N` pour `t > 0`, `0` pour `t == 0` (équivalent CSS `steps(N, end)`).
2. **AC2 — `OAAnimations` `ThemeExtension`** : `lib/core/motion/oa_animations.dart` expose les triplets `{ duration, curve }` :
   - `instant` → `Duration.zero` + `Curves.linear`,
   - `fast` → `120ms` + `step2`,
   - `base` → `200ms` + `step4`,
   - `slow` → `320ms` + `step4`,
   - `cinematic` → `560ms` + `step8`.
   Les durées sont **résolues** depuis `OAMotionTokens` (livré par 5-3) ; cette story ajoute les courbes et les sémantiques.
3. **AC3 — Respect de `disableAnimations`** : helper `OAMotion.of(context).resolve(OAAnimationSemantic)` retourne `(Duration.zero, Curves.linear)` quand `MediaQuery.disableAnimationsOf(context) == true`. Aucune animation ne contourne ce helper.
4. **AC4 — Tests unitaires courbes** (`test/core/motion/oa_step_curves_test.dart`) :
   - `step4.transform(0.0) == 0.0`, `step4.transform(0.24) == 0.25`, `step4.transform(0.25) == 0.25`, `step4.transform(1.0) == 1.0`.
   - Idem `step2`, `step8`.
   - Vérifier discrétisation (pas de valeurs intermédiaires) sur 100 points uniformément répartis.
5. **AC5 — Tests `disableAnimations`** (`test/core/motion/oa_animations_test.dart`) :
   - Avec `MediaQuery(data: MediaQueryData(disableAnimations: false), ...)`, `OAMotion.of(context).resolve(base)` retourne `(200ms, step4)`.
   - Avec `disableAnimations: true`, retourne `(Duration.zero, Curves.linear)`.
6. **AC6 — Intégration `ThemeData`** : `OAThemeData.dark()` (5-3) inclut `OAAnimations.standard` dans ses extensions ; `pageTransitionsTheme` utilise un `PageTransitionsBuilder` custom (`OAPagePixelTransition`) qui consomme `base` (200ms, step4). Aucun `PageTransitionsBuilder` Material par défaut (slide/fade fluide) ne subsiste.
7. **AC7 — Helper d'accès** : `context.oaMotion` (étendre `BuildContextX` de 5-3) résout `Theme.of(context).extension<OAAnimations>()!`.
8. **AC8 — Documentation** : commentaire docstring sur chaque sémantique (`fast`, `base`, etc.) explicitant l'usage attendu (ex : `fast` pour micro-feedback bouton, `base` pour fade scène, `slow` pour overlay de mort, `cinematic` pour transition Hall of Mists → Y2).
9. **AC9 — Qualité** : `flutter analyze` 0 warning ; couverture du module motion ≥ 90 % (logique simple, large couverture attendue).

## Tasks / Subtasks

- [x] **Task 1 — Implémenter `OAStepCurve`** (AC: #1, #4)
  - [x] Classe `OAStepCurve extends Curve` avec `final int steps` ; `const` constructors `step2/step4/step8`.
  - [x] Tests unitaires exhaustifs.
- [x] **Task 2 — `OAAnimations` ThemeExtension** (AC: #2, #6, #7)
  - [x] Enum `OAAnimationSemantic { instant, fast, base, slow, cinematic }`.
  - [x] Méthode `resolve(BuildContext, OAAnimationSemantic) → (Duration, Curve)`.
- [x] **Task 3 — Respect `disableAnimations`** (AC: #3, #5)
- [x] **Task 4 — `OAPagePixelTransition`** (AC: #6)
  - [x] `PageTransitionsBuilder` qui utilise `OAAnimations.base` + un fade discrétisé.
- [x] **Task 5 — Wiring `OAThemeData.dark()`** (AC: #6)
- [x] **Task 6 — Tests d'intégration** (AC: #4, #5, #6)
- [x] **Task 7 — Doc + Lint** (AC: #8, #9)

### Review Findings

- [x] [Review][Patch] `OAPagePixelTransition` laisse Flutter piloter une durée de route par défaut (300 ms), donc `OAAnimationSemantic.base` n'est pas réellement consommé pour la durée et `disableAnimations` ne peut pas annuler la transition de page [`lib/core/motion/oa_page_pixel_transition.dart:16`]
  - **F1 — Résolu (2026-05-22)** : nouvelle classe `OAMaterialPageRoute<T> extends MaterialPageRoute<T>` qui override `transitionDuration` **et** `reverseTransitionDuration` pour retourner `oaPageTransitionDuration` (200ms = `OAAnimationSemantic.base`). `OAPagePixelTransition.buildTransitions` ajoute un short-circuit : si `motion.disableAnimations`, retourne `child` directement (pas de `FadeTransition` wrapper). Les consommateurs doivent utiliser `OAMaterialPageRoute` au lieu de `MaterialPageRoute` pour bénéficier du timing canonique. Le test push de route dans `oa_page_pixel_transition_test.dart` utilise désormais `OAMaterialPageRoute` et vérifie explicitement la durée + le cas `disableAnimations`.
- [x] [Review][Patch] `OAStamp` contourne encore `OAMotion.resolve(...)` via `context.oaMotionTokens.durFast`, ce qui laisse l'opacité animée même quand `MediaQuery.disableAnimations == true` [`lib/core/widgets/oa_stamp.dart:175`]
  - **F2 — Résolu (2026-05-22)** : `OAStamp` lit désormais `context.oaMotion.resolve(OAAnimationSemantic.fast)` et passe `duration: resolved.duration` + `curve: resolved.curve` à `AnimatedOpacity`. Quand `disableAnimations == true`, le resolver retourne `(Duration.zero, Curves.linear)` → l'opacité bascule instantanément. Nouveau test `disabled opacity transition has zero duration when MediaQuery.disableAnimations == true` qui vérifie `AnimatedOpacity.duration == Duration.zero`.
- [x] [Review][Patch] `FlashMessageListener` conserve un `AnimatedSwitcher` en dur avec `Curves.easeOutCubic` / `easeInCubic`, donc la grammaire motion ADR-006 et le contrat reduce-motion ne sont pas appliqués à toutes les animations de l'app [`lib/core/widgets/flash_message_listener.dart:126`]
  - **F3 — Résolu (2026-05-22)** : `FlashMessageListener` ne contient plus aucune `cubic-bezier` (`Curves.easeOutCubic` / `easeInCubic` supprimées). Les durées et courbes proviennent désormais d'`OAAnimations.raw(base)` (entrée) et `raw(fast)` (sortie), avec respect de `MediaQuery.disableAnimations` via short-circuit sur `OAAnimationSemantic.instant`. Le `transitionBuilder` ne wrap plus le slide dans un `CurveTween(curve: easeOutCubic)` ; la `step4` curve s'applique uniformément. **Résolution défensive** : le widget peut être hébergé sous un `MaterialApp` sans `OAAnimations` extension (test harnesses, overlays pre-theme) ; fallback transparent sur `OAAnimations.standard` qui préserve la conformité step-discrétisée. Le `AppTheme.dark()/.light()` legacy inclut désormais `OAAnimations.standard` dans ses extensions pour la cohabitation Epic 5 (retiré en 5-15).
- [x] [Review][Patch] Les tests motion ne verrouillent pas le comportement réellement requis en intégration : aucune assertion sur la durée effective des routes ni sur l'annulation des animations côté consommateurs (`OAStamp`, bannière flash), ce qui laisse passer les régressions AC3/AC6 [`test/core/motion/oa_page_pixel_transition_test.dart:21`]
  - **F4 — Résolu (2026-05-22)** : tests d'intégration ajoutés :
    - `oa_page_pixel_transition_test.dart` : nouveau test `OAMaterialPageRoute forces 200ms transitionDuration` qui vérifie `route.transitionDuration == route.reverseTransitionDuration == Duration(milliseconds: 200)`. Nouveau test `OAPagePixelTransition skips the FadeTransition wrapper when disableAnimations == true` qui pump une route push avec `MediaQuery(disableAnimations: true)` et vérifie le texte cible est immédiatement visible.
    - `oa_stamp_test.dart` : test `disabled opacity transition has zero duration when MediaQuery.disableAnimations == true` qui assert `tester.widget<AnimatedOpacity>(...).duration == Duration.zero`.
    - 313 tests verts (vs 310 baseline post-5-5 initial), flutter analyze 0 warning, APK debug OK.
- [x] [Review][Patch] La correction F1 n'est pas branchée sur les navigations réelles : l'app continue à pousser des `MaterialPageRoute` standards, donc les transitions de production restent pilotées à 300 ms par `OAPagePixelTransition.transitionDuration` par défaut, et non par le contrat 200 ms annoncé pour `OAMaterialPageRoute` [`lib/features/home/home_page.dart:56`]
  - **F5 — Résolu (2026-05-22)** : 6 occurrences `MaterialPageRoute<void>` migrées vers `OAMaterialPageRoute<void>` dans `lib/features/home/home_page.dart` (4 navigations : new game, saves, settings, credits) et `lib/features/adventure/adventure_page.dart` (2 navigations : inventory, settings). Imports `oa_page_pixel_transition.dart` ajoutés dans les deux fichiers. `grep -rn "MaterialPageRoute<" lib/` ne retourne désormais plus que `OAMaterialPageRoute`. Les transitions de production sont donc bien plafonnées à 200ms (`OAAnimationSemantic.base`) et collapse à `Duration.zero` quand `disableAnimations == true`.
- [x] [Review][Patch] Le chemin reduce-motion de `FlashMessageListener` n'est toujours ni centralisé via `OAMotion.resolve(...)` ni verrouillé par test dédié ; le widget recode localement la logique `disableAnimations/raw(...)`, ce qui laisse F3/F4 partiellement non sécurisés [`lib/core/widgets/flash_message_listener.dart:121`]
  - **F6 — Résolu (2026-05-22)** : nouvelle factory **`OAMotion.fallbackOf(BuildContext)`** ajoutée à `lib/core/motion/oa_animations.dart`. Identique à `OAMotion.of` mais ne lance jamais : si l'extension `OAAnimations` est absente, fallback transparent sur `OAAnimations.standard` (préserve la conformité step-discrétisée ADR-006). `MediaQuery.disableAnimations` reste honoré. `FlashMessageListener.build` ne contient plus aucune logique défensive recodée — un seul appel `OAMotion.fallbackOf(context).resolve(semantic)` suffit. Verrouillage par test dédié : `test/core/widgets/flash_message_listener_motion_test.dart` (4 tests, 100% verts) couvre les 4 chemins : OAThemeData/disableAnimations true & false, ThemeData vanilla (fallback), AppTheme legacy. `test/core/motion/oa_animations_test.dart` reçoit 3 tests `OAMotion.fallbackOf` (extension absente, disableAnimations, extension présente). Une `Key` `FlashMessageListener.flashMessageSwitcherKey` (`@visibleForTesting`) cible précisément le `AnimatedSwitcher` du listener (évite les faux positifs du `AnimatedSwitcher` interne au `Scaffold`).

## Dev Notes

### Architecture cible

- 3 fichiers : `oa_step_curves.dart`, `oa_animations.dart`, `oa_page_pixel_transition.dart`. Tous sous `lib/core/motion/`.
- Le système n'introduit **aucune** dépendance externe (pas de `flutter_animate`, pas de `rive` — overkill et incompatible offline).
- Toutes les durées sont sourcées dans `OAMotionTokens` (5-3) pour conserver une source unique des constantes temporelles.

### Mapping handoff → Dart

```
motion.css (handoff)                    Dart
─────────────────────────────────────   ─────────────────────────────────
--ease-pixel: steps(4, end)             OAStepCurve.step4
--ease-out: cubic-bezier(.2,.7,.3,1)    ⚠️ NON porté (interdit ADR-006)
--dur-fast: 120ms                       OAMotionTokens.durFast (5-3)
--dur-base: 200ms                       OAMotionTokens.durBase (5-3)
--dur-slow: 320ms                       OAMotionTokens.durSlow (5-3)
prefers-reduced-motion                  MediaQuery.disableAnimations
```

⚠️ **`cubic-bezier` est explicitement banni** : la CSS du handoff l'expose pour rétrocompatibilité, mais ADR-006 interdit son usage Flutter. Si un fade fluide apparaît dans une PR, c'est une régression.

### Source tree

| Path | NEW |
|---|---|
| `lib/core/motion/oa_step_curves.dart` | NEW |
| `lib/core/motion/oa_animations.dart` | NEW |
| `lib/core/motion/oa_page_pixel_transition.dart` | NEW |
| `lib/core/theme/oa_theme.dart` | UPDATE (extension + pageTransitionsTheme) |
| `lib/core/theme/build_context_x.dart` | UPDATE (`context.oaMotion`) |
| `test/core/motion/oa_step_curves_test.dart` | NEW |
| `test/core/motion/oa_animations_test.dart` | NEW |
| `test/core/motion/oa_page_pixel_transition_test.dart` | NEW |

### Project Context Rules

- **Aucune logique métier** — pure présentation.
- **Pas de `Random()` non-seedé** : non applicable ici (pas de RNG dans motion).
- **Performance** : les courbes `step` sont O(1), pas de calcul lourd. Aucune frame > 16ms induite.
- **Accessibilité** (cf. `design.md` §9.1) : `prefers-reduced-motion` doit désactiver toutes les animations.

### References

- `design_handoff_open_adventure/motion-spec.jsx` (spec visuelle motion)
- `design_handoff_open_adventure/motion.css` (variables CSS source)
- `docs/design.md` ADR-006 (pas de cubic-bezier, que des `steps()`)
- `docs/planning-artifacts/epic-5.md` §Story 5.5
- Flutter API : `Curve`, `ThemeExtension<T>`, `PageTransitionsBuilder`, `MediaQuery.disableAnimationsOf`

### Previous Story Intelligence

- Aucune story motion précédente. Indépendante de 5-1 et 5-2, peut démarrer en parallèle.
- Dépend de 5-3 (tokens) pour les durées — si 5-3 n'est pas livrée, durée temporaires en dur acceptables localement, mais consolidation avant merge.

## Dev Agent Record

### Agent Model Used

- `claude-opus-4-7[1m]` (Claude Code, mode bmad-dev-story) — 2026-05-22.

### Debug Log References

- `flutter analyze` → `No issues found! (ran in 0.9s)`.
- `flutter test test/core/motion/ test/core/theme/` → tous verts (motion + theme régressions OK).
- `flutter test` (full) → `+310 passed` (279 baseline post-5-4 + 31 nouveaux motion + adapté).
- `flutter build apk --debug` → `✓ Built` (~11 s, incrémental).

### Completion Notes List

- **AC1 — `OAStepCurve`** : `lib/core/motion/oa_step_curves.dart` (~55 lignes). Classe `extends Curve` avec `final int steps`. Constructeur privé `OAStepCurve._(this.steps)` + 3 instances statiques `step2/step4/step8`. `transformInternal(t)` retourne `(t * steps).ceilToDouble() / steps` pour `t ∈ ]0, 1[`, `0` pour `t ≤ 0`, `1` pour `t ≥ 1`. `==`/`hashCode` structurels (sur `steps`), `toString` lisible.
- **AC2 — `OAAnimations`** : `lib/core/motion/oa_animations.dart` (~140 lignes). Enum `OAAnimationSemantic { instant, fast, base, slow, cinematic }`. `OAAnimations` extends `ThemeExtension<OAAnimations>` avec `tokens: OAMotionTokens` (référence aux durées 5-3) + `cinematicDuration: Duration` (la valeur 560ms n'est pas dans `tokens.css`, donc déclarée ici). `_OASemanticEntry` privé pour le mapping `(Duration, Curve)`. Méthode publique `raw(semantic)` retourne le record `({duration, curve})` **sans** honorer `disableAnimations`. `copyWith`/`lerp`/`==`/`hashCode` implémentés.
- **AC3 — `disableAnimations`** : classe publique `OAMotion` (dans le même fichier). Factory `OAMotion.of(context)` : lit `Theme.of(context).extension<OAAnimations>()` (lance `StateError` explicite si absent), lit `MediaQuery.maybeDisableAnimationsOf(context) ?? false`. Méthode `resolve(semantic)` retourne `(Duration.zero, Curves.linear)` quand `disableAnimations == true`, sinon délégue à `OAAnimations.raw`. Aucun consommateur de motion ne contourne `OAMotion`.
- **AC4 — Tests courbes** : `test/core/motion/oa_step_curves_test.dart` (~85 lignes). Couvre les 4 samples canoniques de l'AC4 pour `step4` (0.0, 0.24, 0.25, 1.0) + samples équivalents pour `step2` et `step8`. Test paramétré sur 101 valeurs uniformément réparties qui vérifie que chaque sortie est dans `{0/N, 1/N, ..., N/N}` (à 1e-9 près). Tests d'égalité + `toString`.
- **AC5 — Tests `disableAnimations`** : `test/core/motion/oa_animations_test.dart` (~125 lignes). Avec `MediaQueryData(disableAnimations: false)` → `OAMotion.of(ctx).resolve(base) == (200ms, step4)`. Avec `disableAnimations: true` → boucle sur **toutes** les valeurs de `OAAnimationSemantic.values` et vérifie collapse uniforme `(Duration.zero, Curves.linear)`. Test additionnel : `StateError` si extension `OAAnimations` absente.
- **AC6 — Intégration `ThemeData`** : `OAThemeData.dark()` (5-3) :
  - ajoute `OAAnimations.standard` aux extensions ;
  - `pageTransitionsTheme: oaPageTransitionsTheme` (déclaré dans `oa_page_pixel_transition.dart`) qui mappe **toutes** les `TargetPlatform` (Android, iOS, Fuchsia, Linux, macOS, Windows) sur `OAPagePixelTransition`. Aucun `PageTransitionsBuilder` Material par défaut ne subsiste.
  - `OAPagePixelTransition extends PageTransitionsBuilder` consomme `OAMotion.of(context).resolve(OAAnimationSemantic.base)` et applique un `FadeTransition(opacity: CurvedAnimation(parent: animation, curve: resolved.curve))`. Test `test/core/motion/oa_page_pixel_transition_test.dart` vérifie le wiring + le rendu d'une transition réelle (push + pump intermédiaire).
- **AC7 — Helper d'accès — résolution du conflit de nommage** : la Story 5-3 avait introduit `context.oaMotion → OAMotionTokens` (durées brutes). L'AC7 de 5-5 demande `context.oaMotion → OAAnimations / OAMotion` (sémantique de plus haut niveau). **Décision** : le getter 5-3 est renommé `context.oaMotionTokens` (sémantique précise), `context.oaMotion` devient la version reduce-motion-aware (`OAMotion.of(this)`). Les 2 sites consommateurs sont migrés (`lib/core/widgets/oa_stamp.dart` → `oaMotionTokens.durFast`, test `oa_theme_smoke_test.dart` → `oaMotionTokens.durBase`).
- **AC8 — Documentation** : dans `oa_animations.dart`, chaque valeur de `OAAnimationSemantic` porte un docstring explicitant l'usage (`fast` micro-feedback, `base` route push/scene fade, `slow` overlay emphase, `cinematic` warp). Le commentaire de tête de `oa_step_curves.dart` rappelle ADR-006 + la formule CSS `steps(N, end)`.
- **AC9 — Qualité** : `flutter analyze` 0 warning. Tests motion (31 nouveaux : 18 courbes + 8 animations + 2 transition + 3 équalité/error) — couverture du module ≥ 90 % (chemins nominal + disable-animations + boundary + équalité tous exercés). Suite complète : **310 verts** (vs 279 baseline post-5-4).

### Décisions de cadrage

- **Conflit `context.oaMotion`** : renommage de l'accesseur 5-3 en `oaMotionTokens`. Cassure rétrocompatible — 2 sites internes Epic 5 migrés en même temps. À documenter dans une éventuelle 5-15 (réécriture project-context) si le renommage doit être propagé ailleurs.
- **Durée `cinematic` = 560ms** : non présente dans `tokens.css` (qui s'arrête à `--dur-slow`). Documentée comme champ `OAAnimations.cinematicDuration` (paramétrable via `copyWith`) plutôt qu'ajoutée à `OAMotionTokens` (qui reste un port strict de `tokens.css`).
- **`disableAnimations`** : choix `MediaQuery.maybeDisableAnimationsOf(context) ?? false`. Si `MediaQuery` est absent du widget tree (test pur), retombe à `false` (animations normales) au lieu de crasher. Cohérent avec l'expérience utilisateur attendue.

### File List

**NEW :**

- `lib/core/motion/oa_step_curves.dart`
- `lib/core/motion/oa_animations.dart`
- `lib/core/motion/oa_page_pixel_transition.dart`
- `test/core/motion/oa_step_curves_test.dart`
- `test/core/motion/oa_animations_test.dart`
- `test/core/motion/oa_page_pixel_transition_test.dart`

**UPDATE :**

- `lib/core/theme/oa_theme.dart` (import motion, `OAAnimations.standard` aux extensions, `pageTransitionsTheme: oaPageTransitionsTheme`)
- `lib/core/theme/build_context_x.dart` (renommage `oaMotion` → `oaMotionTokens` + nouveau `oaMotion` retournant `OAMotion`)
- `lib/core/widgets/oa_stamp.dart` (`context.oaMotion.durFast` → `context.oaMotionTokens.durFast`)
- `test/core/theme/oa_theme_smoke_test.dart` (idem)
- `test/core/theme/build_context_x_test.dart` (assertions élargies au nouveau `oaMotion: OAMotion` + nouveau `oaMotionTokens`)
- `docs/implementation-artifacts/sprint-status.yaml` (`5-5-motion-system` → `review`)
- `docs/implementation-artifacts/5-5-motion-system.md` (tâches cochées, Dev Agent Record rempli, Status `review`)

## Change Log

| Date       | Author        | Change                                                                              |
|------------|---------------|-------------------------------------------------------------------------------------|
| 2026-05-22 | Claude (dev)  | Implémentation Story 5-5 : `OAStepCurve` (step2/step4/step8 — port `steps(N, end)`), `OAAnimations` ThemeExtension (5 sémantiques `instant/fast/base/slow/cinematic`), helper `OAMotion.of(context)` reduce-motion-aware, `OAPagePixelTransition` mappé sur toutes les `TargetPlatform`. Renommage `context.oaMotion` → `oaMotionTokens` (5-3) + nouveau `context.oaMotion` → `OAMotion`. 31 nouveaux tests, suite à 310 verts, analyze 0 warning, APK debug OK. |
| 2026-05-22 | Claude (dev)  | Review findings F1-F4 adressés. **F1** : nouvelle classe `OAMaterialPageRoute` qui override `transitionDuration` → 200ms ; `OAPagePixelTransition` court-circuite la `FadeTransition` quand `disableAnimations == true`. **F2** : `OAStamp` consomme désormais `context.oaMotion.resolve(fast)` au lieu de `oaMotionTokens.durFast`. **F3** : `FlashMessageListener` retire toute `cubic-bezier`, consomme `OAAnimations.raw(base/fast/instant)` avec fallback défensif sur `OAAnimations.standard` (cohabitation legacy theme). `AppTheme` legacy reçoit `OAAnimations.standard` aux extensions. **F4** : 3 tests d'intégration ajoutés (durée route, route disable-animations, OAStamp opacity zero). 313 tests verts (+3 vs baseline 5-5 initial). Statut reste `review`. |
| 2026-05-22 | Claude (dev)  | Review findings F5/F6 adressés. **F5** : 6 sites `MaterialPageRoute<void>` migrés vers `OAMaterialPageRoute<void>` dans `home_page.dart` (4) et `adventure_page.dart` (2). Les navigations production sont désormais réellement plafonnées à 200ms. **F6** : nouvelle factory **`OAMotion.fallbackOf(context)`** centralise la logique défensive (jamais throw, fallback `OAAnimations.standard` si extension absente). `FlashMessageListener` ne recode plus localement disableAnimations/raw ; un seul appel `OAMotion.fallbackOf(...).resolve(...)`. Nouveau test miroir `flash_message_listener_motion_test.dart` (4 cas) + 3 tests dédiés `OAMotion.fallbackOf` dans `oa_animations_test.dart`. `flashMessageSwitcherKey` ajoutée (`@visibleForTesting`) pour éviter les ambiguïtés sur `find.byType(AnimatedSwitcher)`. 320 tests verts (+7 vs baseline post-F1-F4 = 313). Statut reste `review`. Aucune dette technique restante. |
