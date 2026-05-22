# Story 2-19: Theme tokens baseline (Material indigo)

> ⚠️ **Supersedée par Story 5-3** (Epic 5 Foundation Refresh, 2026-05-22).
>
> Le contenu vivant des tokens de thème est désormais sous `lib/core/theme/oa_*.dart` (cf. `docs/dev-notes/riverpod-playbook.md` et la story [`5-3-port-tokens-design-system.md`](./5-3-port-tokens-design-system.md)). La baseline indigo livrée originellement par 2-19 reste accessible historiquement via `git log --follow lib/core/theme/app_theme.dart`.

Status: done
Epic: 2
Source ticket: EXEC_S2 (rétrospectif — fichier story créé en 2026-05-22 pour matérialiser la dette de référence et satisfaire l'AC9 de 5-3)

## Story

**En tant que** développeur,
**je voulais** disposer d'un thème baseline `AppTheme.light()/.dark()` avec tokens `AppColors`, `AppTypography`, `AppSpacing`,
**afin de** unifier les couleurs/typo/spacing des pages livrées en Sprint 2 sans dupliquer les valeurs Material par défaut.

## Statut historique (résumé)

- Livrée pendant le Sprint 2 (commit antérieur à la création du suivi BMad par fichier story).
- Apportait : `AppTheme` (Material 2/3 hybride, palette indigo), `AppColors` (primary/secondary/neutral), `AppTypography` (Google Material default + override Roboto), `AppSpacing` (0/4/8/16/24/32), `AppActionAccents` (extension `travel/interaction/meta`).
- Référencé par `HomePage`, `AdventurePage`, `InventoryPage`, etc., via `Theme.of(context).colorScheme.*` + `Theme.of(context).extension<AppActionAccents>()!`.
- Annotée `done  # supersedée par 5-3 (Epic 5 Foundation Refresh)` dans `docs/implementation-artifacts/sprint-status.yaml`.

## Pourquoi est-elle supersedée ?

- La DA finale (palette ambre/encre dark-only, fonts pixel chrome + sans-serif body, voir `design_handoff_open_adventure/tokens.css`) n'est pas la baseline indigo Material livrée par 2-19.
- Le travail original reste conservé dans `lib/core/theme/app_*.dart` jusqu'à ce que **toutes** les pages refondues par les Stories 5-7/5-8/5-9 consomment exclusivement `context.oaColors`/`context.oaTypography`/`context.oaSpacing`. À ce moment-là, une story dédiée (probablement intégrée à 5-15) supprimera `app_theme.dart`, `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`.

## Références

- Story de remplacement : [`5-3-port-tokens-design-system.md`](./5-3-port-tokens-design-system.md)
- Sprint Change Proposal : [`../planning-artifacts/sprint-change-proposal-2026-05-22.md`](../planning-artifacts/sprint-change-proposal-2026-05-22.md)
- Tokens canoniques : `design_handoff_open_adventure/tokens.css`

## Dev Agent Record (historique)

Non rempli — la story a été livrée avant l'adoption de BMad pour ce projet. Le suivi vivant des tokens se fait désormais via Story 5-3.

## Change Log

| Date       | Author       | Change                                                                              |
|------------|--------------|-------------------------------------------------------------------------------------|
| _(S2)_     | _(historique)_ | Livraison originale `AppTheme` indigo + `AppActionAccents`.                          |
| 2026-05-22 | Claude (dev) | Création rétrospective de ce fichier placeholder pour satisfaire AC9 de Story 5-3 (bandeau supersedé en tête). |
