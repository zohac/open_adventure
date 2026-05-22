# Story 5.14: Réécriture `architecture.md`

Status: ready-for-dev
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.1 (A4)
Refs : [epic-5](../planning-artifacts/epic-5.md#story-514-réécriture-architecturemd), [architecture.md](../architecture.md), [design.md](../design.md)

## Story

**En tant que** Solution Architect / nouveau contributeur,
**je veux** un `docs/architecture.md` aligné sur la nouvelle stack (Riverpod 2 + `lib/features/`),
**afin que** la documentation reflète l'architecture **effectivement livrée** après Epic 5 et que le bandeau `🚧 EN TRANSITION` puisse être retiré.

## Acceptance Criteria

1. **AC1 — §1 Executive Summary mis à jour** : remplacer toute mention `ValueNotifier` par `Riverpod 2 + StateNotifierProvider` ; remplacer `lib/presentation/` par `lib/features/`. Mentionner explicitement le `ProviderScope` racine.
2. **AC2 — §2 Technology Stack** : ligne « State management » mise à jour : `flutter_riverpod ^2.x + StateNotifierProvider (one provider per controller)`. Lignes audio/persistance/i18n inchangées (`just_audio` + `audio_session`, `shared_preferences`, ARB).
3. **AC3 — §Couches Clean Architecture** : diagramme et description reflètent `core/{theme,widgets,motion}/`, `features/<screen>/`, `application/{controllers,providers,services}/`, `domain/{entities,value_objects,repositories,usecases,services}/`, `data/`. Aucune mention de `presentation/` ne subsiste hors note historique.
4. **AC4 — Diagrammes Mermaid** : tout diagramme représentant le flux UI ↔ Application ↔ Domain ↔ Data est actualisé pour inclure le `ProviderScope` racine et les providers principaux (`gameStateProvider`, `audioSettingsProvider`, etc.). Si Mermaid est utilisé, syntaxe vérifiée avec le viewer (ex : VSCode Markdown Preview Enhanced).
5. **AC5 — Retrait du bandeau `🚧 EN TRANSITION`** en tête du fichier.
6. **AC6 — Liens** : `docs/index.md` continue à pointer vers `architecture.md` ; vérifier qu'aucun lien cassé n'est introduit. Lien explicite vers `docs/dev-notes/riverpod-playbook.md` (livré 5-1) ajouté dans la section appropriée.
7. **AC7 — Lecture autonome** : un nouveau contributeur qui lit `architecture.md` doit pouvoir poser le contexte sans avoir besoin de lire le Sprint Change Proposal. Toute décision majeure est référencée (ADR-X.X du `design.md`).
8. **AC8 — Date de mise à jour** : section « Last Updated » mise à jour avec la date du merge de cette story.

## Tasks / Subtasks

- [ ] **Task 1 — Audit du contenu actuel** (AC: #1, #2, #3)
  - [ ] Lister section par section les mentions à mettre à jour.
- [ ] **Task 2 — Réécriture §1 Executive Summary** (AC: #1)
- [ ] **Task 3 — §2 Technology Stack** (AC: #2)
- [ ] **Task 4 — Diagrammes Clean Architecture** (AC: #3, #4)
- [ ] **Task 5 — Retrait bandeau transition** (AC: #5)
- [ ] **Task 6 — Vérification liens** (AC: #6)
- [ ] **Task 7 — Date + relecture** (AC: #7, #8)

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `docs/architecture.md` | UPDATE complet |
| `docs/index.md` | UPDATE (vérification liens) |

### Project Context Rules

- **La spec prime sur le code** : si une divergence apparaît entre l'état du code et `architecture.md`, c'est `architecture.md` qui est aligné — mais à condition que le code reflète bien les ADRs.
- **Pas de réinvention** : la source des décisions reste `design.md` (ADRs). `architecture.md` traduit en langage technique pour développeurs.
- **Diagrammes Mermaid OK** ; les imager (export PNG) seulement si le rendu Markdown standard ne fonctionne pas dans l'IDE cible.

### Coordination

- Cette story se livre **après** que 5-1 → 5-12 soient mergées. Elle clôture (avec 5-15) la transition documentaire.
- 5-15 (réécriture `project-context.md`) est complémentaire — coordonner les deux PRs pour qu'elles soient cohérentes.

### References

- `docs/architecture.md` (état actuel — bandeau transition en tête)
- `docs/design.md` (source des décisions)
- `docs/dev-notes/riverpod-playbook.md` (livré 5-1)
- `docs/planning-artifacts/epic-5.md` §Story 5.14

### Previous Story Intelligence

- L'`architecture.md` actuel décrit l'état antérieur. Lire intégralement avant d'écrire — préserver les sections qui restent valides (Domain pur, RNG déterministe, immutabilité, etc.) et ne réécrire que ce qui a réellement changé.

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
