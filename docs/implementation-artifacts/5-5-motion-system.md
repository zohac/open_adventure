# Story 5.5: Motion system (`OAAnimations` + `Curves.stepN`)

Status: ready-for-dev
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

- [ ] **Task 1 — Implémenter `OAStepCurve`** (AC: #1, #4)
  - [ ] Classe `OAStepCurve extends Curve` avec `final int steps` ; `const` constructors `step2/step4/step8`.
  - [ ] Tests unitaires exhaustifs.
- [ ] **Task 2 — `OAAnimations` ThemeExtension** (AC: #2, #6, #7)
  - [ ] Enum `OAAnimationSemantic { instant, fast, base, slow, cinematic }`.
  - [ ] Méthode `resolve(BuildContext, OAAnimationSemantic) → (Duration, Curve)`.
- [ ] **Task 3 — Respect `disableAnimations`** (AC: #3, #5)
- [ ] **Task 4 — `OAPagePixelTransition`** (AC: #6)
  - [ ] `PageTransitionsBuilder` qui utilise `OAAnimations.base` + un fade discrétisé.
- [ ] **Task 5 — Wiring `OAThemeData.dark()`** (AC: #6)
- [ ] **Task 6 — Tests d'intégration** (AC: #4, #5, #6)
- [ ] **Task 7 — Doc + Lint** (AC: #8, #9)

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
### Debug Log References
### Completion Notes List
### File List
