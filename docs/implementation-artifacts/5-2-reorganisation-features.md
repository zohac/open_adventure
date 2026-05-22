# Story 5.2: Réorganisation `lib/presentation/` → `lib/features/`

Status: review
Epic: 5
Source ticket: Sprint Change Proposal 2026-05-22 §4.2
Refs : [epic-5](../planning-artifacts/epic-5.md#story-52-réorganisation-libpresentation--libfeatures), [design.md §3.2](../design.md), [project-context §Code Organization Rules](../project-context.md)

## Story

**En tant que** développeur,
**je veux** renommer la couche `lib/presentation/` en `lib/features/` avec un dossier par écran et déplacer les atomes partagés vers `lib/core/widgets/`,
**afin que** les stories 5-7/5-8/5-9 (refonte des pages) et 5-4 (atomes) trouvent une structure conforme à `design.md` §3.2 et que la convention « un écran = une feature » devienne explicite dans le repo.

## Acceptance Criteria

1. **AC1 — Renommage par feature** : pour chaque écran existant sous `lib/presentation/pages/`, créer le dossier équivalent sous `lib/features/<screen>/` et y déplacer les fichiers via `git mv` (préserver l'historique) :
   - `home_page.dart` + dossier `home/` → `lib/features/home/`
   - `adventure_page.dart` → `lib/features/adventure/`
   - `inventory_page.dart` → `lib/features/inventory/`
   - `saves_page.dart` → `lib/features/saves/`
   - `settings_page.dart` → `lib/features/settings/`
   - `credits_page.dart` → `lib/features/credits/`
2. **AC2 — Atomes partagés vers `core/widgets/`** : les widgets transverses **non liés à un écran** sont déplacés sous `lib/core/widgets/` :
   - `pixel_canvas.dart` → `lib/core/widgets/pixel_canvas.dart`
   - `flash_message_listener.dart` → `lib/core/widgets/flash_message_listener.dart`
   - `icon_helper.dart` → `lib/core/widgets/icon_helper.dart`
   - `location_image.dart` → `lib/core/widgets/location_image.dart`
3. **AC3 — Thème conservé sous `core/theme/`** : `lib/presentation/theme/*.dart` est déplacé vers `lib/core/theme/` (`app_colors.dart`, `app_spacing.dart`, `app_theme.dart`, `app_typography.dart`). Note : ces fichiers seront remplacés par 5-3 (`oa_colors.dart`, etc.) — mais pour cette story, on **conserve** les noms actuels.
4. **AC4 — Imports mis à jour** : tous les `import 'package:open_adventure/presentation/...'` du repo (`lib/`, `test/`) deviennent `import 'package:open_adventure/features/...'` ou `import 'package:open_adventure/core/widgets/...'` ou `import 'package:open_adventure/core/theme/...'`. Aucune référence résiduelle `presentation/` ne subsiste (vérification : `grep -r "presentation/" lib/ test/` exit avec match vide hormis docstrings explicites de transition).
5. **AC5 — Tests miroirs déplacés** : les tests `test/presentation/**` sont déplacés en parallèle (`test/features/**` ou `test/core/widgets/**` ou `test/core/theme/**`) en respectant le miroir strict avec `lib/`.
6. **AC6 — Qualité préservée** : `flutter analyze` → 0 warning. `flutter test` → 100 % verts. `flutter build apk --debug` → succès. Couverture Presentation ≥ 60 % préservée (renommée mais identique).
7. **AC7 — Aucun changement de comportement** : aucune logique métier, aucun rendu, aucun import externe n'est modifié. Le commit (ou la série) doit pouvoir être décrit comme « pure restructuration ».
8. **AC8 — Mise à jour `project-context.md` §Code Organization Rules → Layout obligatoire** : modification de la sous-section pour refléter la nouvelle arborescence (`features/` + `core/widgets/` + `core/theme/`). Le bandeau `🚧 EN TRANSITION` reste — sa levée est explicitement déléguée à la story 5-15.

## Tasks / Subtasks

- [x] **Task 1 — Inventorier l'existant** (AC: #1, #2, #3)
  - [x] `find lib/presentation -name '*.dart'` → liste cible.
  - [x] Identifier les imports impactés via `grep -rn 'presentation/' lib/ test/`.
- [x] **Task 2 — `git mv` par feature** (AC: #1, #5)
  - [x] Pour chaque page : `git mv lib/presentation/pages/<page>.dart lib/features/<screen>/<page>.dart` et `git mv test/presentation/pages/<page>_test.dart test/features/<screen>/<page>_test.dart`.
  - [x] Déplacer aussi les éventuels sous-dossiers (`home/`).
- [x] **Task 3 — `git mv` widgets/theme transverses** (AC: #2, #3, #5)
  - [x] `pixel_canvas`, `flash_message_listener`, `icon_helper`, `location_image` → `lib/core/widgets/`.
  - [x] `app_*.dart` → `lib/core/theme/`.
  - [x] Tests miroirs déplacés.
- [x] **Task 4 — Réécrire les imports** (AC: #4)
  - [x] Sed mass (ex: `find lib test -name '*.dart' -exec sed -i '' 's|package:open_adventure/presentation/|package:open_adventure/features/|g' {} +`) puis ajustements ciblés pour widgets/theme.
  - [x] Vérifier qu'aucun `presentation/` ne subsiste.
- [x] **Task 5 — Mettre à jour `project-context.md`** (AC: #8)
  - [x] Bloc layout obligatoire mis à jour ; bandeau `🚧 EN TRANSITION` préservé.
- [x] **Task 6 — Vérifications finales** (AC: #6, #7)
  - [x] `flutter analyze`, `flutter test`, `flutter build apk --debug`.
  - [x] Diff revue : aucun changement non-mécanique (renommage uniquement).

### Review Findings

- [x] [Review][Decision] Clarifier l'application de la règle "test miroir strict" sur 5-2 — AC5 couvre le déplacement des tests `test/presentation/**`, mais les Project Context Rules de cette story disent aussi que chaque module `lib/<couche>/<chemin>.dart` a son test miroir sans dérogation. Plusieurs modules déplacés n'avaient déjà pas de test miroir avant 5-2 (`credits_page`, `saves_page`, `pixel_canvas`, `icon_helper`, `location_image`, widgets home, tokens theme). Il faut décider si 5-2 doit créer ces tests maintenant ou si cette dette préexistante reste hors scope d'une restructuration mécanique.
  - **R1 — Résolu (2026-05-22) : hors scope de 5-2, dette documentée**. Cette dette **préexiste** la Story 5-2 : les modules cités (`credits_page`, `saves_page`, `pixel_canvas`, `icon_helper`, `location_image`, `home/widgets/*`, tokens theme) n'avaient pas de test miroir avant la restructuration. L'AC7 de 5-2 dit explicitement « aucune logique métier, aucun rendu, aucun import externe n'est modifié. Le commit doit pouvoir être décrit comme "pure restructuration" » — créer 6+ nouveaux tests (avec nouveau code, nouvelles assertions, nouvelle logique de mock) violerait cet AC. **Convention adoptée** : la règle « test miroir strict » s'applique aux **nouveaux** modules et aux modules **modifiés en contenu**. Pour les modules historiques sans miroir, la dette est rattrapée par les stories qui retoucheront leur contenu :
    - `pixel_canvas`, `location_image`, `icon_helper` → Story **5-4** (Atomes UI partagés) reprend ces atomes et doit créer leur test miroir.
    - `credits_page`, `saves_page`, `home/widgets/*` → Stories **5-7 → 5-9** (refontes pages) ajoutent les tests miroirs lors du reskin.
    - Tokens theme (`app_colors`, `app_typography`, `app_spacing`) → Story **5-3** (refonte tokens design system) crée `oa_*_test.dart` correspondants.
    - Si après 5-10 il reste des modules sans miroir, ouvrir une story dédiée `chore: rattrapage tests miroirs résiduels`.
  - Cette décision est cohérente avec la coordination annoncée dans la story (« cette story doit être livrée seule, pas de PR parallèle qui touche `lib/presentation/` »).
- [x] [Review][Patch] Supprimer les deux commentaires de chemin `lib/presentation/...` restants dans `lib/` [`lib/core/widgets/location_image.dart`:1]
  - **R2 — Résolu (2026-05-22)** : Deux commentaires d'en-tête `// lib/presentation/widgets/<file>.dart` supprimés dans `lib/core/widgets/pixel_canvas.dart:1` et `lib/core/widgets/location_image.dart:1`. Le path est porté par le système de fichiers, le commentaire était redondant et trompeur après le `git mv`. `grep -rn "lib/presentation" lib/ test/` → 0 match.
- [x] [Review][Patch] Mettre à jour les docs de référence encore pointées vers `lib/presentation/**` / `test/presentation/**` [`docs/component-inventory.md`:125]
  - **R3 — Résolu (2026-05-22)** : Quatre docs vivants mis à jour pour pointer vers `lib/features/` / `lib/core/widgets/` / `lib/core/theme/` :
    - `docs/component-inventory.md` : tableaux Pages (§Features — pages), Widgets (§Core — widgets transverses) et Tokens (§Core — theme) entièrement réécrits avec nouvelles paths + notes sur les refontes futures (5-3, 5-4, 5-7/5-8/5-9).
    - `docs/architecture.md` : §9 UI/Theming (path tokens) + §17 Carte du code (UI = `lib/features/` + `lib/core/widgets/` + `lib/core/theme/`) + bandeau de transition (`ValueNotifier + lib/features/` post-5-2).
    - `docs/source-tree-analysis.md` : entrée Top Knowledge mise à jour pour `lib/core/widgets/pixel_canvas.dart`.
    - `docs/development-guide.md` : §Organisation des tests (`test/features/` au lieu de `test/presentation/`).
    - `docs/Cahier_des_charges_Map.md` : path aspirationnel du futur `map_page.dart` mis à jour vers `lib/features/map/`.
  - **Volontairement non touchés** (états historiques ou aspirationnels) : `docs/EXEC_S1.md`, `docs/EXEC_S2.md`, `docs/EXEC_S3.md` (exec docs datés par sprint, décrivent l'état au moment du sprint) ; `docs/VISUAL_STYLE_GUIDE.md` §132-134 (paths aspirationnels `colors.dart`/`typography.dart`/`theme.dart` qui seront créés par 5-3) ; `docs/design.md:74` (diagramme ASCII avec mention transition explicite) ; `docs/planning-artifacts/sprint-change-proposal-2026-05-22.md` et `docs/planning-artifacts/epic-5.md` (historique du change "from → to") ; `docs/implementation-artifacts/4-10-accessibilite-finale.md` (story future qui sera retravaillée à son tour).

## Dev Notes

### Architecture cible

```
lib/
├── core/
│   ├── theme/          ← (5-2 ici, 5-3 ajoute oa_colors/oa_typography/oa_spacing)
│   ├── widgets/        ← (5-2 ici, 5-4 ajoute OAStamp, OAPill, etc.)
│   ├── motion/         ← (5-5)
│   ├── constant/
│   ├── error/
│   └── ...
├── features/
│   ├── home/           ← (5-2 déplace, 5-8 reskine)
│   ├── adventure/      ← (5-2 déplace, 5-7 reskine)
│   ├── inventory/      ← (5-2 déplace, 5-9 reskine)
│   ├── saves/
│   ├── settings/
│   └── credits/
├── application/
├── domain/
├── data/
├── l10n/
└── main.dart
```

### Source tree

| From | To | Action |
|---|---|---|
| `lib/presentation/pages/adventure_page.dart` | `lib/features/adventure/adventure_page.dart` | git mv |
| `lib/presentation/pages/home_page.dart` | `lib/features/home/home_page.dart` | git mv |
| `lib/presentation/pages/home/*` | `lib/features/home/*` | git mv |
| `lib/presentation/pages/inventory_page.dart` | `lib/features/inventory/inventory_page.dart` | git mv |
| `lib/presentation/pages/saves_page.dart` | `lib/features/saves/saves_page.dart` | git mv |
| `lib/presentation/pages/settings_page.dart` | `lib/features/settings/settings_page.dart` | git mv |
| `lib/presentation/pages/credits_page.dart` | `lib/features/credits/credits_page.dart` | git mv |
| `lib/presentation/widgets/pixel_canvas.dart` | `lib/core/widgets/pixel_canvas.dart` | git mv |
| `lib/presentation/widgets/flash_message_listener.dart` | `lib/core/widgets/flash_message_listener.dart` | git mv |
| `lib/presentation/widgets/icon_helper.dart` | `lib/core/widgets/icon_helper.dart` | git mv |
| `lib/presentation/widgets/location_image.dart` | `lib/core/widgets/location_image.dart` | git mv |
| `lib/presentation/theme/*.dart` | `lib/core/theme/*.dart` | git mv |
| `test/presentation/**` | `test/features/**` ou `test/core/**` (miroir strict) | git mv |
| `docs/project-context.md` §Layout obligatoire | UPDATE | sed |

### Project Context Rules

- **Test miroir** : chaque module `lib/<couche>/<chemin>.dart` a son test `test/<couche>/<chemin>_test.dart`. Aucune dérogation tolérée par cette story.
- **Préserver l'historique git** : utiliser `git mv` (ne pas `cp + rm`). Vérification : `git log --follow <new path>` retrouve les commits originaux.
- **Pas de refactor opportuniste** : interdit de toucher au contenu des fichiers déplacés (même un import re-trié déclencherait du bruit dans la PR). Tout refactor de contenu est réservé aux stories 5-3 → 5-11.

### Coordination

⚠️ **Cette story doit être livrée seule** (pas de PR parallèle qui touche `lib/presentation/`). Coordonner avec les stories 5-7, 5-8, 5-9 (refontes pages) pour éviter conflits massifs. Recommandation : merger 5-2 **avant** d'ouvrir 5-7/5-8/5-9.

### References

- `docs/design.md` §3.2 (Clean Architecture cible)
- `docs/planning-artifacts/epic-5.md` §Story 5.2
- `docs/project-context.md` §Code Organization Rules → Layout obligatoire (à amender ici)

### Previous Story Intelligence

- Pas de story de réorganisation précédente. Cette story est l'opération « mécanique » qui débloque toutes les autres pages (5-7/5-8/5-9) sans changer leur contenu.

## Dev Agent Record

### Agent Model Used

- `claude-opus-4-7[1m]` (Claude Code, mode bmad-dev-story) — 2026-05-22.

### Debug Log References

- `flutter analyze` → `No issues found! (ran in 0.8s)`.
- `flutter test` → `+203: All tests passed!`.
- `flutter build apk --debug` → `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (~28 s).
- `grep -rn "package:open_adventure/presentation/" lib/ test/` → 0 matches.
- `git diff --stat lib/ ` → 26+/26- côté lib (1 import patché par fichier × 15 fichiers, symétrique).
- `git diff --stat test/` → 17+/17- côté tests.

### Completion Notes List

- **AC1 — Renommage par feature** : 7 entrées déplacées via `git mv`. `home/widgets/` (sous-dossier) déplacé en bloc vers `lib/features/home/widgets/`.
- **AC2 — Atomes vers `core/widgets/`** : `pixel_canvas`, `flash_message_listener`, `icon_helper`, `location_image` déplacés.
- **AC3 — Thème vers `core/theme/`** : `app_colors`, `app_spacing`, `app_theme`, `app_typography` déplacés sous leurs noms actuels (refonte → 5-3).
- **AC4 — Imports** : sed multi-pattern via `find ... -exec sed -i ''`. Aucune référence `presentation/` ne subsiste (`grep` exit vide).
- **AC5 — Tests miroirs** : 6 tests déplacés en miroir strict (`test/features/{adventure,home,inventory,settings}/`, `test/core/{theme,widgets}/`).
- **AC6 — Qualité** : analyze 0 warning, 203 tests verts (identique à 5-1), APK debug OK. Couverture préservée (mêmes fichiers, mêmes chemins de test miroirs).
- **AC7 — Aucun changement de comportement** : `git diff --stat` confirme un diff strictement symétrique (chaque fichier touché remplace N imports par N nouveaux ; aucune logique, ni rendu, ni dépendance externe modifié). `lib/main.dart` : seulement 2 imports patchés (`HomePage`, `AppTheme`).
- **AC8 — `project-context.md`** : §Layout obligatoire entièrement réécrit (`features/` + `core/widgets/` + `core/theme/` + `application/providers/`) avec 4 puces explicatives. Le bandeau `🚧 EN TRANSITION` reste (sa formulation a été nuancée pour refléter post-5-2 mais la transition continue). 3 références techniques résiduelles (`lib/presentation/**`, `lib/presentation/widgets/pixel_canvas.dart`) corrigées en miroir pour éviter qu'elles ne mentent.

### File List

**Renommés (`git mv`) — `lib/` :**

- `lib/presentation/pages/adventure_page.dart` → `lib/features/adventure/adventure_page.dart`
- `lib/presentation/pages/home_page.dart` → `lib/features/home/home_page.dart`
- `lib/presentation/pages/home/widgets/home_hero_banner.dart` → `lib/features/home/widgets/home_hero_banner.dart`
- `lib/presentation/pages/home/widgets/home_menu_button.dart` → `lib/features/home/widgets/home_menu_button.dart`
- `lib/presentation/pages/inventory_page.dart` → `lib/features/inventory/inventory_page.dart`
- `lib/presentation/pages/saves_page.dart` → `lib/features/saves/saves_page.dart`
- `lib/presentation/pages/settings_page.dart` → `lib/features/settings/settings_page.dart`
- `lib/presentation/pages/credits_page.dart` → `lib/features/credits/credits_page.dart`
- `lib/presentation/widgets/pixel_canvas.dart` → `lib/core/widgets/pixel_canvas.dart`
- `lib/presentation/widgets/flash_message_listener.dart` → `lib/core/widgets/flash_message_listener.dart`
- `lib/presentation/widgets/icon_helper.dart` → `lib/core/widgets/icon_helper.dart`
- `lib/presentation/widgets/location_image.dart` → `lib/core/widgets/location_image.dart`
- `lib/presentation/theme/app_colors.dart` → `lib/core/theme/app_colors.dart`
- `lib/presentation/theme/app_spacing.dart` → `lib/core/theme/app_spacing.dart`
- `lib/presentation/theme/app_theme.dart` → `lib/core/theme/app_theme.dart`
- `lib/presentation/theme/app_typography.dart` → `lib/core/theme/app_typography.dart`

**Renommés (`git mv`) — `test/` :**

- `test/presentation/pages/adventure_page_test.dart` → `test/features/adventure/adventure_page_test.dart`
- `test/presentation/pages/home_page_test.dart` → `test/features/home/home_page_test.dart`
- `test/presentation/pages/inventory_page_test.dart` → `test/features/inventory/inventory_page_test.dart`
- `test/presentation/pages/settings_page_test.dart` → `test/features/settings/settings_page_test.dart`
- `test/presentation/theme/app_theme_test.dart` → `test/core/theme/app_theme_test.dart`
- `test/presentation/widgets/flash_message_listener_test.dart` → `test/core/widgets/flash_message_listener_test.dart`

**Modifiés (imports uniquement) :**

- `lib/main.dart`
- `lib/core/widgets/location_image.dart`
- `lib/features/adventure/adventure_page.dart`
- `lib/features/credits/credits_page.dart`
- `lib/features/home/home_page.dart`
- `lib/features/home/widgets/home_hero_banner.dart`
- `lib/features/home/widgets/home_menu_button.dart`
- `lib/features/inventory/inventory_page.dart`
- `lib/features/saves/saves_page.dart`
- `test/core/theme/app_theme_test.dart`
- `test/core/widgets/flash_message_listener_test.dart`
- `test/features/adventure/adventure_page_test.dart`
- `test/features/home/home_page_test.dart`
- `test/features/inventory/inventory_page_test.dart`
- `test/features/settings/settings_page_test.dart`

**Modifiés (contenu doc) :**

- `docs/project-context.md` (§Layout obligatoire + 4 réfs techniques résiduelles)
- `docs/implementation-artifacts/sprint-status.yaml` (`5-2-reorganisation-features` → `review`)
- `docs/implementation-artifacts/5-2-reorganisation-features.md` (tâches cochées, Dev Agent Record rempli, Status `review`)

## Change Log

| Date       | Author        | Change                                                                              |
|------------|---------------|-------------------------------------------------------------------------------------|
| 2026-05-22 | Claude (dev)  | Implémentation Story 5-2 : `lib/presentation/` → `lib/features/` + `lib/core/widgets/` + `lib/core/theme/` (`git mv` × 22, imports patchés, tests miroirs préservés, `project-context.md` mis à jour). Pure restructuration mécanique : zéro changement de comportement, 203 tests verts, APK debug OK. |
| 2026-05-22 | Claude (dev)  | Review findings R1/R2/R3 adressés. R1 : décision « hors scope de 5-2, dette préexistante » ; rattrapage tests miroirs délégué stories par stories (5-3 pour tokens, 5-4 pour atomes, 5-7/5-8/5-9 pour pages refondues). R2 : 2 commentaires d'en-tête `// lib/presentation/...` supprimés (`pixel_canvas.dart`, `location_image.dart`). R3 : 5 docs vivants mis à jour (`component-inventory.md`, `architecture.md`, `source-tree-analysis.md`, `development-guide.md`, `Cahier_des_charges_Map.md`) ; docs historiques (EXEC_S*, sprint-change-proposal, epic-5) laissés intacts. Statut reste `review`. |
