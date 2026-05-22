# Story 5.7: Migration `AdventurePage` Riverpod + reskin (refonte 2-10)

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2 ; supersède `2-10-adventure-page-v0`
Refs : [epic-5](../planning-artifacts/epic-5.md#story-57-migration-adventurepage-riverpod--reskin-refonte-2-10), [design.md ADR-001/006](../design.md), [features/adventure.md](../features/adventure.md), [design_handoff_open_adventure/screens.jsx](../../design_handoff_open_adventure/screens.jsx)

## Story

**En tant que** joueur,
**je veux** un écran d'aventure refondu graphiquement (palette ambre/encre, atomes UI partagés, motion `stepN`),
**afin que** la signature visuelle « carnet d'explorateur sous la lanterne » remplace la baseline indigo de 2-10, **sans aucune régression fonctionnelle** : description scrollable, ≤ 7 actions visibles + bouton « Plus… » au-delà, ordre `safety → travel → interaction → meta`, FlashMessage SnackBar, image de scène via `OASceneFrame`, et déclenchement de `gameStateProvider.notifier.perform()` au tap.

## Acceptance Criteria

1. **AC1 — Localisation** : la page vit sous `lib/features/adventure/adventure_page.dart` (déplacée par 5-2). Devient `ConsumerWidget` (ou `ConsumerStatefulWidget` si état local — animation de scène).
2. **AC2 — Consommation `gameStateProvider`** : `final state = ref.watch(gameStateProvider);` ; lecture de `state.locationTitle`, `state.locationDescription`, `state.actions`, `state.journal` (dernières N entrées si affichées), `state.locationMapTag`, `state.locationId`, `state.flashMessage`. Aucune lecture directe du `GameNotifier` hors `ref.read(gameStateProvider.notifier).perform(action)` lors d'un tap stamp.
3. **AC3 — Layout DA** : implémentation conforme à `design_handoff_open_adventure/screens.jsx` (section "adventure") et `features/adventure.md` :
   - En-tête (status bar) : nom de lieu (`OATypography.display.l`), pile de pills (lampe, score, turns) — pour cette story le pill score reste **placeholder** (4-7 livrera la status bar finale).
   - Visuel central : `OASceneFrame` avec `PixelCanvas(child: LocationImage(...))` ; halo ambre si lampe allumée et faible (intensité = clamp((30 - limit) / 30, 0, 1)).
   - Description : zone scrollable, `OATypography.body.l`, couleur `paper-warm`.
   - Liste actions : `Column` (ou `ListView.builder` si > 7) de `OAStamp`, classé par catégorie selon l'ordre `safety > travel > interaction > meta` (préserver le tri actuel — vérifier dans `game_controller`).
   - Bouton « Plus… » : si `state.actions.length > 7`, n'afficher que les 6 premiers + un `OAStamp(label: l10n.actionsMore)` qui ouvre une `OAOverflowActionsSheet` (modal bottom sheet, cf. `overflow-actions.jsx`).
4. **AC4 — Atomes 5-4 consommés** : `OAStamp` pour chaque action, `OASceneFrame` pour le visuel, `OAPill` pour les indicateurs status bar. Aucune `ElevatedButton`/`OutlinedButton`/`TextButton` Material standard ne subsiste.
5. **AC5 — i18n préservée** : tout `ActionOption.label` reste une **clé ARB** ; la résolution `AppLocalizations.of(context).<key>` se fait dans `AdventurePage` (caller des atomes). Aucune chaîne FR/EN en dur.
6. **AC6 — FlashMessage** : `state.flashMessage` est consommé via un `Consumer` ciblé qui pousse une `SnackBar` (ou un `Toast` custom pixel — préférer Material `SnackBar` stylée pour cette story) puis appelle `ref.read(gameStateProvider.notifier).clearFlashMessage()` une fois consommé. Conserve le pattern actuel de `FlashMessageListener`.
7. **AC7 — Tests widgets** (`test/features/adventure/adventure_page_test.dart`) :
   - **1ʳᵉ visite long / revisit short** : pumper l'écran avec `state.locationDescription` issu d'un mock de notifier ; vérifier le bon rendu.
   - **≤ 7 actions** : vérifier que les 7 stamps sont visibles, pas de bouton « Plus… ».
   - **> 7 actions** : vérifier 6 stamps + 1 « Plus… » → tap → bottom sheet avec les actions restantes.
   - **Ordre catégoriel** : `safety > travel > interaction > meta` respecté à l'affichage (matcher l'ordre du `state.actions` mocké).
   - **Tap stamp** : `tester.tap(find.text(<label>))` → `verify(() => mockNotifier.perform(any())).called(1)`.
   - **Flash message** : injecter `flashMessage: 'Bonjour'` → vérifier `find.text('Bonjour')` dans la SnackBar → vérifier `clearFlashMessage()` appelé.
   - **Aucun mot magique** : si `state.game.magicWordsUnlocked == false`, vérifier que `find.text('XYZZY')` retourne vide même si on injecte un `ActionOption(verb: 'XYZZY')` (`_visibleActions` filtre).
8. **AC8 — Story `2-10-adventure-page-v0` marquée supersedée** : commentaire inline en tête du fichier story `2-10-adventure-page-v0.md` : `> ⚠️ Supersedée par 5-7 (Epic 5 Foundation Refresh, 2026-05-22).` Statut `done (#supersedée par 5-7)` conservé dans `sprint-status.yaml`.
9. **AC9 — Pas de régression boucle de tour** : un tap stamp → `gameStateProvider.notifier.perform(option)` → cycle complet (cf. story 5-6 AC6) → UI rebuild. Aucun raccourci (ex : ne pas appeler `_applyTurn` directement depuis la page). Vérification : oracle tests O1 (navette mots magiques) verts.
10. **AC10 — Performance** : aucune frame > 16 ms sur le parcours nominal tap → render. Utiliser `Consumer` ciblés (1 pour le titre, 1 pour les actions, 1 pour la scène) pour éviter rebuild complet. `state.actions` passe par `select((s) => s.actions)` si possible.
11. **AC11 — Qualité** : `flutter analyze` 0 warning ; couverture Presentation ≥ 60 % préservée ; couverture du module `lib/features/adventure/` ≥ 70 %.

## Tasks / Subtasks

- [ ] **Task 1 — `AdventurePage ConsumerWidget`** (AC: #1, #2)
- [ ] **Task 2 — Layout DA** (AC: #3, #4)
  - [ ] Status bar simplifiée (placeholder pill).
  - [ ] `OASceneFrame` + halo ambre dynamique.
  - [ ] Description scrollable.
  - [ ] Liste actions `OAStamp`.
  - [ ] Overflow `OAOverflowActionsSheet` (nouveau widget dans `lib/features/adventure/`).
- [ ] **Task 3 — FlashMessage** (AC: #6)
- [ ] **Task 4 — i18n** (AC: #5)
  - [ ] Vérifier toutes les clés ARB nécessaires existent (`actions.more`, etc.) — ajouter dans `lib/l10n/app_en.arb` + `app_fr.arb` + `flutter gen-l10n`.
- [ ] **Task 5 — Tests widgets** (AC: #7)
- [ ] **Task 6 — Superseder 2-10** (AC: #8)
- [ ] **Task 7 — Oracle O1** (AC: #9)
- [ ] **Task 8 — Perf check** (AC: #10)
- [ ] **Task 9 — Lint + couverture** (AC: #11)

## Dev Notes

### Architecture cible

- `ConsumerWidget` consume `gameStateProvider` + appelle `notifier.perform(...)` au tap.
- Aucune logique métier dans la page (`if (object.isTreasure) score += 2` interdit côté UI — cf. `project-context.md` §Anti-patterns).
- L'overflow sheet vit dans `lib/features/adventure/widgets/oa_overflow_actions_sheet.dart` (spécifique à la feature — pas dans `core/widgets/`).

### Mapping handoff → Dart

| Handoff (`screens.jsx` / `adventure.md`) | Implémentation Dart |
|---|---|
| Stamp action grid | `Column` ou `Wrap` de `OAStamp(variant: primary/secondary)` |
| Scene frame double-border | `OASceneFrame(child: PixelCanvas(child: Image.asset(...)))` |
| Status pills (lamp, score, turns) | `Row` de `OAPill` |
| Lamp halo critical | `OASceneFrame(lampHaloIntensity: ...)` |
| Flash message | Material `SnackBar` ou widget custom léger |
| "Plus…" overflow | `showModalBottomSheet` avec liste `OAStamp` |

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/features/adventure/adventure_page.dart` | UPDATE (refonte complète) |
| `lib/features/adventure/widgets/oa_overflow_actions_sheet.dart` | NEW |
| `lib/features/adventure/widgets/lamp_status_pill.dart` | NEW (extrait pour testabilité) |
| `lib/l10n/app_en.arb` | UPDATE (nouvelles clés `actions.more`, etc.) |
| `lib/l10n/app_fr.arb` | UPDATE |
| `lib/l10n/app_localizations.dart` | REGEN (via `flutter gen-l10n`) |
| `test/features/adventure/adventure_page_test.dart` | UPDATE |
| `test/features/adventure/widgets/oa_overflow_actions_sheet_test.dart` | NEW |
| `docs/implementation-artifacts/2-10-adventure-page-v0.md` | UPDATE (bandeau supersedé) |

### Project Context Rules

- **Pas de `setState`** : `ConsumerWidget` + `ref.watch` + `select` (cf. anti-patterns).
- **Pas de chaîne FR/EN en dur** : clés ARB obligatoires.
- **PixelCanvas** : toute image scène passe par lui (déjà imposé).
- **Aucun mot magique** dans `state.actions` tant que `magicWordsUnlocked == false` — c'est `GameNotifier._visibleActions` qui filtre, pas la page. La page ne doit **pas** re-filtrer (sinon doublon, risque de divergence).

### Coordination avec 5-11 (`MagicWordSurface`)

- Cette story livre l'écran **sans** `MagicWordSurface` (livrée par 5-11). Prévoir un slot dédié dans le layout pour l'insertion future (commentaire `// TODO 5-11: MagicWordSurface insertion point`). Aucune anticipation des UI mots magiques dans 5-7.

### Coordination avec 4-7 (`adventure-page-v2-status-bar`)

- La status bar livrée ici est volontairement minimaliste (placeholder). 4-7 finalisera la status bar avec compteurs scores/turns/lampe. Ne **pas** sur-investir dans la status bar dans 5-7.

### References

- `docs/features/adventure.md` (spec écran)
- `design_handoff_open_adventure/screens.jsx` (mockup adventure)
- `design_handoff_open_adventure/action-buttons.jsx` (stamps)
- `design_handoff_open_adventure/overflow-actions.jsx` (bottom sheet)
- `docs/design.md` ADR-001 (boutons contextuels), ADR-006 (motion)
- `docs/planning-artifacts/epic-5.md` §Story 5.7
- Story superseded : `docs/implementation-artifacts/2-10-adventure-page-v0.md`

### Previous Story Intelligence

- **2-10** (done, superseded) : a livré l'écran v0 avec `ValueListenableBuilder` + atomes Material. Le tri d'actions, le filtre incantations, l'overflow `Plus…` y sont déjà câblés — réutiliser la logique de tri pour ne pas regresser.
- **3-14** : a livré `flashMessage` lifecycle. Préserver `clearFlashMessage()` côté UI.
- **5-2** (réorganisation) doit être livré avant — la page doit déjà être sous `lib/features/adventure/`.

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
