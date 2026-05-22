# Story 5.9: Migration `InventoryPage` Riverpod + reskin (refonte 3-15)

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2 ; supersède `3-15-inventory-page`
Refs : [epic-5](../planning-artifacts/epic-5.md#story-59-migration-inventorypage-riverpod--reskin-refonte-3-15), [features/inventory.md](../features/inventory.md), [design_handoff_open_adventure/inventory.jsx](../../design_handoff_open_adventure/inventory.jsx)

## Story

**En tant que** joueur,
**je veux** un inventaire refondu en grille uniforme avec sprites d'objets (1:1, fond contextuel via `OAItemSprite`),
**afin que** la collection visuelle ait la signature DA et que chaque tile soit tappable pour ouvrir l'action sheet (déjà câblée 3-15) — sans régression.

## Acceptance Criteria

1. **AC1 — Localisation** : `lib/features/inventory/inventory_page.dart`. `ConsumerWidget`.
2. **AC2 — Sélecteur ciblé** : `final inventory = ref.watch(gameStateProvider.select((s) => s.game?.inventory ?? const <int>[]));`. Éviter de rebuild sur tout changement de `gameStateProvider` (cf. règle perf 5-7).
3. **AC3 — Grille uniforme** : `GridView.builder(gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 96, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1))`. Chaque cellule = `OAItemSprite` (livré 5-4). Tone contextuel selon catégorie d'objet (treasure → `OAItemTone.amber`, container → `OAItemTone.paper`, par défaut → `OAItemTone.paper`).
4. **AC4 — État vide** : si `inventory.isEmpty`, afficher un message `l10n.inventory.empty` (« Vos poches sont vides. ») centré, en `OATypography.body.l`, `paper-faded`.
5. **AC5 — Tap → action sheet** : `OAItemSprite.onTap` ouvre une `OAItemActionSheet` (bottom sheet, nouveau widget dans `lib/features/inventory/widgets/`). Sheet liste les actions disponibles pour l'objet (TAKE/DROP/EXAMINE/USE selon contexte). Pour cette story, **réutiliser le code 3-15** : si l'existant câble déjà `ListAvailableActions` filtré par objet, ne pas réinventer. Sinon, exposer une callback `onTap(itemId)` qui délègue à la page parent et garde le sheet minimal.
6. **AC6 — Layout DA** : conforme à `design_handoff_open_adventure/inventory.jsx` : header en `OATypography.display.l` (« Inventaire »), grille principale, bouton retour en `OAStamp(variant: ghost)` en bas si nécessaire (ou via `AppBar` simple).
7. **AC7 — Atomes 5-4 consommés** : `OAItemSprite` exclusivement pour les cellules ; `OAPill` si compteur d'objets utilisé (« 4/15 trésors »).
8. **AC8 — Images des objets** : utiliser `AssetPaths.objectImagePath(id)` (introduit par 5-12 — pipeline assets 3 tiers). Si l'asset n'existe pas (objet sans sprite 512²), fallback sur `_objectIndex[id].name` rendu en texte. Pour 5-9, certains sprites peuvent ne pas exister — accepter le fallback texte le temps que 5-12 + art production livrent.
9. **AC9 — Tests widgets** (`test/features/inventory/inventory_page_test.dart`) :
   - **Inventaire vide** : `find.text(l10n.inventory.empty)` présent.
   - **Inventaire 3 items** : 3 `OAItemSprite` trouvés.
   - **Inventaire 20 items** : grille scrollable, vérifier que ≥ 1 sprite hors viewport rendu après scroll (`tester.scrollUntilVisible`).
   - **Tap item** : `tester.tap(find.byKey(Key('item-LAMP')))` → vérifier callback `onItemTap` appelé avec id correct (mock).
10. **AC10 — Story `3-15-inventory-page` supersedée** : bandeau inline.
11. **AC11 — Qualité** : `flutter analyze` 0 warning ; couverture `lib/features/inventory/` ≥ 70 % ; aucun `ValueListenableBuilder` ne subsiste.

## Tasks / Subtasks

- [ ] **Task 1 — `InventoryPage ConsumerWidget`** (AC: #1, #2)
- [ ] **Task 2 — `GridView` + tone mapping** (AC: #3, #6, #7)
- [ ] **Task 3 — État vide** (AC: #4)
- [ ] **Task 4 — `OAItemActionSheet`** (AC: #5)
  - [ ] Réutiliser la logique 3-15 si présente.
- [ ] **Task 5 — Asset path** (AC: #8)
  - [ ] Fallback texte si image absente.
- [ ] **Task 6 — Tests** (AC: #9)
- [ ] **Task 7 — Superseder 3-15** (AC: #10)
- [ ] **Task 8 — Lint + couverture** (AC: #11)

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/features/inventory/inventory_page.dart` | UPDATE (refonte) |
| `lib/features/inventory/widgets/oa_item_action_sheet.dart` | NEW (ou refactor de 3-15) |
| `lib/l10n/app_en.arb` | UPDATE (`inventory.empty`, `inventory.title`) |
| `lib/l10n/app_fr.arb` | UPDATE |
| `test/features/inventory/inventory_page_test.dart` | UPDATE |
| `test/features/inventory/widgets/oa_item_action_sheet_test.dart` | NEW |
| `docs/implementation-artifacts/3-15-inventory-page.md` | UPDATE (bandeau supersedé) |

### Project Context Rules

- **Sélecteur ciblé** (`.select(...)`) obligatoire pour éviter rebuild grille à chaque tour.
- **Aucune logique métier dans la page** : la page lit l'inventaire, déclenche le sheet, et appelle `notifier.perform(option)` au choix d'une action — pas de calcul de filtrage côté UI (ListAvailableActions s'en charge dans Domain).
- **ADR-010** (3 tiers) : `OAItemSprite` reçoit `tone` pour le fond ; jamais `Color(0xFF...)` en dur.

### Coordination avec 5-12

- `AssetPaths.objectImagePath(id)` est livré par 5-12. Si 5-12 n'est pas mergée, accepter fallback texte (cf. AC8) — c'est non bloquant pour 5-9.

### References

- `docs/features/inventory.md`
- `design_handoff_open_adventure/inventory.jsx`
- `docs/planning-artifacts/epic-5.md` §Story 5.9
- Story superseded : `docs/implementation-artifacts/3-15-inventory-page.md`

### Previous Story Intelligence

- **3-15** (done, superseded) : a livré l'inventaire avec action sheet. Réutiliser le code de filtrage des actions par objet. Ne pas réécrire from scratch.
- **5-6** doit être livré avant (besoin de `gameStateProvider`).

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
