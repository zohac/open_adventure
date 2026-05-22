# Story 5.11: `MagicWordSurface` composant (ADR-002)

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2
Refs : [epic-5](../planning-artifacts/epic-5.md#story-511-magicwordsurface-composant-adr-002), [design.md ADR-002](../design.md), [Dossier_de_Référence DDR-001](../Dossier_de_Référence.md), [encounters.jsx](../../design_handoff_open_adventure/encounters.jsx)

## Story

**En tant que** joueur connaisseur du canon,
**je veux** une surface dédiée aux mots magiques découverts (XYZZY, PLUGH, PLOVER, FEE-FIE-FOE-FOO),
**afin que** les incantations restent des easter eggs valorisés (jamais exposés en bouton standard) tout en étant utilisables une fois apprises — conforme ADR-002 + DDR-001 Option A.

## Acceptance Criteria

1. **AC1 — Composant** : `lib/core/widgets/magic_word_surface.dart`. `ConsumerWidget` exposant un panneau (carte pixel-art) avec 1 stamp par mot magique pertinent.
2. **AC2 — Visibilité — verrou 1** : la surface est **invisible** (retourne `const SizedBox.shrink()`) tant que `game.magicWordsUnlocked == false`. Vérification via `ref.watch(gameStateProvider.select((s) => s.game?.magicWordsUnlocked ?? false))`.
3. **AC3 — Visibilité — verrou 2** : même après unlock, un mot n'apparaît que si `currentLocation` est un **target valide** pour ce mot (consulté via une logique Domain — soit `MagicWords.validTargetsFor(verb, gameState)`, soit une lookup statique des couples (`from`, `verb`, `to`) issu du canon). Si un mot est unlocked mais non utilisable depuis le lieu courant, il est masqué.
4. **AC4 — Aucun mot dans `state.actions`** : vérifier que `ListAvailableActions` continue de **ne jamais** retourner d'`ActionOption(verb: 'XYZZY' | 'PLUGH' | 'PLOVER' | 'FEE' | 'FIE' | 'FOE' | 'FOO')`. Test d'intégration via `MagicWords.isIncantation`. Si une régression apparaît (un verb magique présent dans `state.actions`), la story est bloquée.
5. **AC5 — Visuel** : conforme à `design.md` ADR-002 + `encounters.jsx` :
   - Panneau séparé visuellement (bordure double `pix-frame-double`, ton magic `OAColors.magic` = `#9870c4`).
   - Titre `l10n.magicWords.title` (ex : « Incantations connues ») en `OATypography.caps.m`, `magic`.
   - Stamps `OAStamp(variant: secondary, label: 'XYZZY', onPressed: () => notifier.perform(ActionOption(verb: 'XYZZY', category: 'magic', ...)))`. Label en majuscules pixel.
6. **AC6 — Insertion dans `AdventurePage`** : la surface est insérée dans `lib/features/adventure/adventure_page.dart` au point marqué par 5-7 (`// TODO 5-11: MagicWordSurface insertion point`). Position : entre la description et la liste d'actions (revoir avec `encounters.jsx`).
7. **AC7 — i18n** : clé ARB `magicWords.title` ajoutée. **Pas** de label par mot — le mot magique est rendu tel quel (« XYZZY »), c'est canonique.
8. **AC8 — Tests widgets** (`test/core/widgets/magic_word_surface_test.dart`) :
   - **Locked (`magicWordsUnlocked: false`)** : `find.byType(MagicWordSurface)` vide (`SizedBox.shrink`). Vérifier l'absence de tout texte « XYZZY ».
   - **Unlocked + bonne location** : `find.text('XYZZY')` présent.
   - **Unlocked + mauvaise location** : `find.text('XYZZY')` absent (la location n'est pas un target valide).
   - **Tap stamp** : `notifier.perform(...)` appelé avec `verb='XYZZY'`.
9. **AC9 — Test d'intégration sur `MagicWords.isIncantation`** (`test/integration/magic_words_not_in_actions_test.dart`) :
   - Pour 5 locations canoniques (Building, Debris Room, Y2, etc.), instancier `ListAvailableActions(game)` avec `magicWordsUnlocked: true` ET `magicWordsUnlocked: false` ; vérifier qu'**aucune** option retournée n'a `MagicWords.isIncantation(option.verb) == true`. (Le filtrage incantations dans `ListAvailableActions` doit retirer XYZZY, etc., même si elles apparaissent par erreur en amont.)
10. **AC10 — ADR-002 marquée « implémentée »** : `docs/design.md` §4 ADR-002 reçoit un suffixe « ✅ Implémentée par story 5-11 (2026-XX-XX). »
11. **AC11 — Qualité** : `flutter analyze` 0 warning ; couverture du module ≥ 90 % (logique simple, branches limitées) ; tests verts.

## Tasks / Subtasks

- [ ] **Task 1 — `MagicWordSurface` widget** (AC: #1, #2, #3, #5)
- [ ] **Task 2 — Logique target valide** (AC: #3)
  - [ ] Identifier où réside la table canonique des couples (`from_loc`, `verb`, `to_loc`) — probablement dans `lib/domain/value_objects/magic_words.dart` ou à étendre.
  - [ ] Exposer `MagicWords.canBeUsedFrom(int locId, String verb) → bool` (méthode pure Domain).
- [ ] **Task 3 — Insertion AdventurePage** (AC: #6)
- [ ] **Task 4 — i18n** (AC: #7)
- [ ] **Task 5 — Tests widgets** (AC: #8)
- [ ] **Task 6 — Test d'intégration `isIncantation`** (AC: #9)
- [ ] **Task 7 — Mettre à jour ADR-002** (AC: #10)
- [ ] **Task 8 — Lint + couverture** (AC: #11)

## Dev Notes

### Architecture cible

- Composant pur (consume `gameStateProvider`, déclenche `perform`).
- Aucune logique métier : la décision « ce mot est utilisable ici » vient du Domain (`MagicWords.canBeUsedFrom`). Si la lookup n'existe pas encore, l'introduire dans Domain pendant cette story (pas dans Presentation).

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `lib/core/widgets/magic_word_surface.dart` | NEW |
| `lib/domain/value_objects/magic_words.dart` | UPDATE (ajout `canBeUsedFrom`) |
| `lib/features/adventure/adventure_page.dart` | UPDATE (insertion) |
| `lib/l10n/app_en.arb` / `app_fr.arb` | UPDATE (`magicWords.title`) |
| `test/core/widgets/magic_word_surface_test.dart` | NEW |
| `test/integration/magic_words_not_in_actions_test.dart` | NEW |
| `docs/design.md` §4 ADR-002 | UPDATE (✅ implémentée) |

### Project Context Rules

- **DDR-001 Option A** : les mots magiques ne sont **jamais** dans `ListAvailableActions`. Ce filtre est **double** (verrou Domain via `_visibleActions` + verrou UI via `MagicWordSurface`). Aucune autre exposition tolérée.
- **i18n** : seul le titre du panneau est traduit ; les mots magiques restent en anglais canonique.
- **Domain pur** : `MagicWords.canBeUsedFrom` ne touche pas Flutter.
- **mocktail** : pour les tests qui ont besoin de mocker `ListAvailableActions`.

### Gotchas spécifiques

- **Unlock condition** : `magicWordsUnlocked` passe à `true` quand le joueur découvre l'oiseau qui souffle XYZZY (canon Open Adventure). Cette mécanique n'est **pas** dans le scope 5-11 (elle est dans `apply_turn` Domain — déjà câblée ou planifiée). 5-11 consomme seulement le flag, ne le manipule pas.
- **Targets valides** (canon) :
  - XYZZY : Building ↔ Debris Room
  - PLUGH : Building ↔ Y2
  - PLOVER : Y2 ↔ Plover Room
  - FEE-FIE-FOE-FOO : sortie qui dépend du contexte (bird capture).
  Source : `open-adventure-master/actions.c` (fonction `bigwords`).

### References

- `docs/design.md` ADR-002 + §4
- `docs/Dossier_de_Référence.md` DDR-001 Option A
- `design_handoff_open_adventure/encounters.jsx` (visuel proche)
- `docs/planning-artifacts/epic-5.md` §Story 5.11
- Code Domain : `lib/domain/value_objects/magic_words.dart` (à étendre)
- Canon : `open-adventure-master/actions.c` (`bigwords`)

### Previous Story Intelligence

- **2-23-filtrer-incantations** + **2-24-tests-incantations-visibilite** (done) : ont câblé le filtrage Domain. Cette story ajoute la **surface dédiée** sans toucher au filtrage existant.
- **5-4** doit être livré avant (`OAStamp` consommé).
- **5-6** doit être livré avant (`gameStateProvider`).

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
