# Story 3.17: JournalView — fil des évènements append/trim/scroll

Status: ready-for-dev
Epic: 3
Source ticket: ADVT‑S3‑17 (`docs/EXEC_S3.md`)
Refs : [project-context](../project-context.md), [architecture](../architecture.md), [UX_SCREENS](../UX_SCREENS.md)

## Story

**En tant que** joueur, **je veux** un fil chronologique des messages systèmes (descriptions, interactions, nains, lampe) qui s'auto-scrolle sur le dernier message, **afin de** rattraper le contexte sans interrompre la boucle de tour.

## Acceptance Criteria

1. **AC1 — Widget dédié** : `JournalView` (`lib/presentation/widgets/journal_view.dart`) est un `StatelessWidget` qui prend une `List<String> messages` immuable et un `JournalScrollController` injecté. Aucune lecture directe de `GameController` (testabilité).
2. **AC2 — Append-only + trim** : la liste rendue n'affiche que les **200 derniers** messages. Si > 200, ne pas planter — le trim est déjà fait côté `GameController._appendJournal` ; le widget assume cette borne.
3. **AC3 — Scroll-to-bottom** : à chaque rebuild où `messages.length` augmente, le widget appelle `controller.animateTo(maxScrollExtent, duration: 150ms, curve: easeOut)`. Si l'utilisateur a scrollé manuellement vers le haut, **inhiber** l'auto-scroll jusqu'au prochain tap utilisateur sur un bouton « Aller en bas ».
4. **AC4 — Bouton « Aller en bas »** : visible (FAB ou banner) **uniquement** quand l'utilisateur n'est pas au bas (`controller.offset < maxScrollExtent - threshold`). Tap réactive l'auto-scroll.
5. **AC5 — Intégration AdventurePage** : `AdventurePage` rend `JournalView` à la place du bloc journal actuel inline (extraction sans changement de comportement observable).
6. **AC6 — a11y** : chaque entrée a un `Semantics(label: ...)` ; les lots récents sont annoncés (`liveRegion: true` sur le ListView).
7. **AC7 — Tests** : widget tests dans `test/presentation/widgets/journal_view_test.dart` : append, trim au-delà de 200, auto-scroll vers le bas, inhibition après scroll manuel, bouton « Aller en bas » apparaît/disparaît.

## Tasks / Subtasks

- [ ] **Task 1 — Widget `JournalView` + contrôleur** (AC: #1, #3, #4)
  - [ ] Créer `lib/presentation/widgets/journal_view.dart` + `lib/presentation/widgets/journal_scroll_controller.dart` (encapsule `ScrollController` + flag `_userScrolled`).
- [ ] **Task 2 — Trim & semantics** (AC: #2, #6)
  - [ ] Vérifier que le widget n'a pas besoin de re-tronquer (200 garanti par GameController).
  - [ ] Wrap chaque entrée dans `Semantics(label: ...)`.
- [ ] **Task 3 — Intégration AdventurePage** (AC: #5)
  - [ ] Extraire le bloc journal inline existant de `lib/presentation/pages/adventure_page.dart` vers `JournalView` ; injecter le contrôleur depuis l'état de la page.
- [ ] **Task 4 — Tests + i18n** (AC: #7)
  - [ ] `test/presentation/widgets/journal_view_test.dart` (≥ 5 cas).
  - [ ] Ajouter clés ARB `journal.scrollToBottom`, `journal.entrySemantics` dans `app_en.arb` + `app_fr.arb` ; régénérer `app_localizations.dart`.
- [ ] **Task 5 — Doc + completion** (AC: trace PR)
  - [ ] Mettre à jour `docs/component-inventory.md` (ajout `JournalView`).
  - [ ] Compléter `Dev Agent Record` : note de synthèse + File List.

## Dev Notes

### Architecture cible
Widget pur Presentation, injection contrôleur, zéro logique métier. La règle « trim à 200 » reste dans `GameController._appendJournal`.

### Source tree components to touch

| Path | NEW / UPDATE | Reason |
|---|---|---|
| `lib/presentation/widgets/journal_view.dart` | NEW | Widget dédié |
| `lib/presentation/widgets/journal_scroll_controller.dart` | NEW | Encapsule ScrollController + état userScrolled |
| `lib/presentation/pages/adventure_page.dart` | UPDATE | Remplacer le bloc journal inline |
| `lib/l10n/app_en.arb`, `app_fr.arb`, `app_localizations.dart` | UPDATE | Clés ARB `journal.*` |
| `test/presentation/widgets/journal_view_test.dart` | NEW | ≥ 5 cas |
| `docs/component-inventory.md` | UPDATE | Inventaire à jour |

### Project Context Rules (extraits pertinents)
- **Presentation sans logique métier** : le widget consomme `List<String>` ; la liste est déjà trim côté GameController.
- **i18n obligatoire** : aucune chaîne brute (`'Aller en bas'`) — passer par `AppLocalizations`.
- **mocktail only** côté tests (jamais `mockito`).
- **`const` constructors** pour limiter rebuilds.

### Previous Story Intelligence
- Pattern à reprendre de `InventoryPage` : `Scaffold` + `ValueListenableBuilder<GameViewState>` + `FlashMessageListener`. Ici on intègre dans `AdventurePage` existante, pas une page autonome.

### References
- `docs/EXEC_S3.md` ADVT‑S3‑17
- `lib/application/controllers/game_controller.dart` (champ `journal`, méthode `_appendJournal`)
- `docs/UX_SCREENS.md` (mandat Journal)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
