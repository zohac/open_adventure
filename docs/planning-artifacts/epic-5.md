# Sprint 5 — Foundation Refresh (Design System, Architecture Migration, Atomes UI)

> **Source canonique des DoD détaillés** : ce fichier (self-contained — pas de `docs/EXEC_S5.md`).
> Inséré par le **Sprint Change Proposal du 2026-05-22** (Correct Course) suite au handoff design.
> Référence design : [`docs/design.md`](../design.md) + [`docs/features/`](../features/) + `design_handoff_open_adventure/`.

## Epic 5: Sprint 5 — Foundation Refresh

**Status:** backlog
**Goal:** Migrer l'architecture UI de `ValueNotifier` + `lib/presentation/` vers Riverpod 2 + `lib/features/`, porter le design system (palette ambre/encre dark-only, fonts Pixelify/Silkscreen/DM Sans, motion `steps()`, atomes UI partagés), introduire la `MagicWordSurface` (ADR-002), étendre le pipeline d'assets à 3 tiers (ADR-010), refondre les pages UI livrées (`AdventurePage`, `HomePage`, `InventoryPage`) sans régression fonctionnelle ni perte de fidélité gameplay.
**Acceptance:** `flutter analyze` zéro warning ; tests existants verts (Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 % préservés) ; oracle tests O1–O3 verts ; `architecture.md` et `project-context.md` à jour ; aucun écart visuel observable entre les mockups `design_handoff_open_adventure/*.jsx` et les écrans portés ; aucun mot magique exposé tant que `magicWordsUnlocked == false`.

---

### Story 5.1: Riverpod foundation
**Status:** backlog
**Goal:** Installer Riverpod 2 et établir le scope racine, la convention de providers, et le playbook de migration pour les stories suivantes.

**DoD:**
- `pubspec.yaml` : ajout `flutter_riverpod ^2.x` (verrouiller version mineure)
- `main.dart` wrappé d'un `ProviderScope`
- Doc interne `docs/dev-notes/riverpod-playbook.md` (5-10 lignes) : convention `StateNotifierProvider` vs `Provider`, family providers, test overrides via `ProviderContainer`
- `flutter analyze` zéro warning, tests existants verts
- Aucune migration de contrôleur dans cette story — uniquement le socle

**Dépendances:** aucune (peut démarrer en parallèle de 5-2, 5-3, 5-4, 5-5)

---

### Story 5.2: Réorganisation `lib/presentation/` → `lib/features/`
**Status:** backlog
**Goal:** Renommer la couche presentation en features avec une structure par écran ; déplacer les atomes partagés vers `lib/core/widgets/`.

**DoD:**
- `git mv lib/presentation/pages/<screen> → lib/features/<screen>/` pour chaque écran (home, adventure, inventory, etc.)
- Atomes partagés existants déplacés vers `lib/core/widgets/`
- Tous les imports mis à jour (sed + flutter analyze)
- `flutter analyze` zéro warning ; tests existants verts ; app build OK (`flutter build apk --debug`)
- `project-context.md` §Code Organization Rules → Layout obligatoire amendé en 5-15

**Dépendances:** aucune (mais à coordonner avec 5-7/5-8/5-9 pour éviter conflits de merge)

---

### Story 5.3: Port `tokens.css` → Dart (remplace 2-19)
**Status:** backlog
**Goal:** Porter les design tokens du handoff (`design_handoff_open_adventure/tokens.css`) en classes Dart typées exposées via `ThemeData` extensions.

**DoD:**
- `lib/core/theme/oa_colors.dart`, `oa_typography.dart`, `oa_spacing.dart` (extensions `ThemeExtension`)
- Palette dark-only conforme à `design.md` §4 ADR-003 (encre profonde, halo ambre, papier vieilli)
- Fonts : Pixelify Sans + Silkscreen embarqués sous `assets/fonts/` ; DM Sans embed ou via `google_fonts`
- Smoke widget test affichant tous les tokens (régression visuelle minimale)
- Story `2-19-theme-tokens-baseline` marquée `done-superseded` avec commentaire inline pointant vers `5-3`

**Dépendances:** aucune

---

### Story 5.4: Atomes UI partagés
**Status:** backlog
**Goal:** Implémenter les composants de base réutilisables consommés par toutes les pages.

**DoD:**
- `OAStamp` (bouton commun, voir glossaire `design.md` §10) avec variantes `primary/secondary/ghost`
- `OAPill`, `OAIcon`, `OASceneFrame`, `OAItemSprite` (avec tone contextuel pour fond, ADR-010)
- Tests widgets unitaires pour chaque (rendu, états enabled/pressed/disabled)
- Catalogue dans une page debug `lib/features/debug/widget_gallery.dart` (non routée en prod, accessible via debug build)

**Dépendances:** 5-3 (tokens nécessaires)

---

### Story 5.5: Motion system (`OAAnimations` + `Curves.stepN`)
**Status:** backlog
**Goal:** Implémenter le système d'animation en marches discrètes (ADR-006).

**DoD:**
- `lib/core/motion/oa_animations.dart` avec `Curves.step2`, `step4`, `step8` custom
- Extension `MotionExtension` exposée via `ThemeData`
- Respect de `MediaQuery.disableAnimations` (reduced-motion)
- Tests unitaires sur les courbes (valeurs aux extrémités, discrétisation)

**Dépendances:** aucune (peut démarrer en parallèle des autres atomes)

---

### Story 5.6: Migration `GameController` → `StateNotifier`
**Status:** backlog
**Goal:** Refactor du contrôleur principal de `ValueNotifier<GameViewState>` vers `StateNotifier<GameViewState>` exposé via `StateNotifierProvider`.

**DoD:**
- `lib/application/controllers/game_controller.dart` migré ; signature publique préservée (`perform`, `initNew`, `loadSnapshot`, etc.)
- `gameStateProvider` dans `lib/application/providers/game_state_provider.dart`
- Tests Application : autosave appelé exactement 1 fois par tour réussi (préservé, cf. §Testing Rules)
- Oracle tests O1–O3 verts (snapshot fidélité)
- Boucle de tour de `project-context.md` §6 (ordre 1→11) préservée intégralement

**Dépendances:** 5-1

---

### Story 5.7: Migration `AdventurePage` Riverpod + reskin (refonte 2-10)
**Status:** backlog
**Goal:** Réécrire l'écran de jeu principal contre `gameStateProvider` et appliquer la DA du handoff.

**DoD:**
- `lib/features/adventure/adventure_page.dart` consume `gameStateProvider` via `ConsumerWidget`
- Layout conforme à `design_handoff_open_adventure/adventure-page.jsx` (ou `screens.jsx` équivalent)
- Atomes 5-4 utilisés : `OAStamp` pour actions, `OASceneFrame` pour image de scène
- Tests widgets : 1ʳᵉ visite long / revisit short ; ≤7 actions visibles ; bouton « Plus… » si >7 ; ordre sécurité→travel→interaction→meta préservé
- Story `2-10-adventure-page-v0` marquée `done-superseded` avec commentaire inline pointant vers `5-7`

**Dépendances:** 5-2, 5-3, 5-4, 5-6

---

### Story 5.8: Migration `HomePage` Riverpod + reskin (refonte 2-20)
**Status:** backlog
**Goal:** Réécrire la home contre des providers et appliquer le visual du handoff.

**DoD:**
- `lib/features/home/home_page.dart` migré, consume `saveRepositoryProvider`
- Layout conforme à `design_handoff_open_adventure/screens.jsx` (section home)
- « Continuer » désactivé si autosave absente (préservé)
- Tests widgets sur les états (autosave présent/absent)
- Story `2-20-home-page-v0` marquée `done-superseded` avec commentaire inline pointant vers `5-8`

**Dépendances:** 5-2, 5-3, 5-4

---

### Story 5.9: Migration `InventoryPage` Riverpod + reskin (refonte 3-15)
**Status:** backlog
**Goal:** Réécrire l'inventaire contre les providers et appliquer la grille du handoff.

**DoD:**
- `lib/features/inventory/inventory_page.dart` migré, consume `gameStateProvider` (sélecteur sur `game.inventory`)
- Grille uniforme avec `OAItemSprite` (tone contextuel pour fond — ADR-010)
- Layout conforme à `design_handoff_open_adventure/inventory.jsx`
- Tests widgets : grille vide, grille pleine, tap → callback `onItemTap`
- Story `3-15-inventory-page` marquée `done-superseded` avec commentaire inline pointant vers `5-9`

**Dépendances:** 5-2, 5-3, 5-4, 5-6

---

### Story 5.10: Migration `AudioController` + `SettingsController` vers providers
**Status:** backlog
**Goal:** Migrer les deux contrôleurs auxiliaires sur Riverpod sans changer leur logique métier.

**DoD:**
- `audioControllerProvider` et `settingsProvider` (`StateNotifierProvider`)
- `just_audio` + `audio_session` préservés (cf. édition A1 — `design.md` §3.1 patché)
- Throttle SFX 150 ms préservé
- Tests existants verts (notamment volumes persistés sur `shared_preferences`)

**Dépendances:** 5-1

---

### Story 5.11: `MagicWordSurface` composant (ADR-002)
**Status:** backlog
**Goal:** Implémenter la surface dédiée aux mots magiques découverts, séparée de la liste d'actions standard.

**DoD:**
- `lib/core/widgets/magic_word_surface.dart`
- Visible **uniquement si** `game.magicWordsUnlocked == true` ET `currentLocation` est target valide pour le mot (XYZZY / PLUGH / PLOVER / FEE-FIE-FOE-FOO)
- **Aucun mot exposé** dans `ListAvailableActions` (vérification via test d'intégration sur `MagicWords.isIncantation`)
- Tests widgets : caché par défaut, affiché après unlock, contextuel par location
- ADR-002 marquée « implémentée » dans `design.md`

**Dépendances:** 5-4

---

### Story 5.12: Pipeline assets 3 tiers (ADR-010)
**Status:** backlog
**Goal:** Étendre les scripts `scripts/*.py` pour gérer les nouveaux tiers d'assets (objets 1:1 512² PNG, créatures 1:1 768² PNG).

**DoD:**
- `scripts/update_assets.py` détecte et copie les 3 tiers (scènes 16:9 320×180 WebP, objets 1:1 512², créatures 1:1 768²)
- `docs/ART_ASSET_BIBLE.md` mis à jour avec les 3 tiers
- `pubspec.yaml` section `assets:` étendue pour `assets/objects/` et `assets/creatures/`
- Test d'intégration scripts (`python3 scripts/validate_json.py` exit 0 + check de présence des dossiers)
- `AssetPaths` étendu avec `objectImagePath(id)` et `creatureImagePath(id)`

**Dépendances:** aucune

---

### Story 5.13: Audit fidélité 430 pts post-migration
**Status:** backlog
**Goal:** Vérifier que l'oracle gameplay n'a pas régressé après les migrations Bloc 2.

**DoD:**
- Snapshot pré-migration capturé **avant** démarrage de `5-6` (état tests Domain + run intégration 50 tours seed fixe)
- Oracle tests O1–O3 (cf. `Dossier_de_Référence.md` §7.4) verts post-migration
- Couverture Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 % (préservées)
- Rapport `docs/dev-notes/epic-5-fidelity-report.md` consigne les écarts (idéalement zéro)

**Dépendances:** 5-6, 5-7, 5-8, 5-9, 5-10

---

### Story 5.14: Réécriture `architecture.md`
**Status:** backlog
**Goal:** Aligner le doc architecture sur la nouvelle stack Riverpod + `features/`.

**DoD:**
- §1 Executive Summary mis à jour (`ValueNotifier` → Riverpod, `presentation/` → `features/`)
- §2 Technology Stack ligne « State » : `flutter_riverpod 2.x + StateNotifierProvider` au lieu de `ValueNotifier`
- Diagrammes Mermaid (si présents) actualisés
- Retrait du bandeau `🚧 EN TRANSITION`
- Lien depuis `docs/index.md` vérifié

**Dépendances:** 5-1 à 5-12 (réécriture après migration effective)

---

### Story 5.15: Réécriture `project-context.md` (sections State/DI)
**Status:** backlog
**Goal:** Aligner les sections « State management » et « Composition root » + anti-patterns associés.

**DoD:**
- §Framework-Specific Rules / « Composition root unique » remplacée par « `ProviderScope` racine + DI via providers »
- §Anti-patterns Flutter : retirer `setState dans une page qui dispose déjà d'un ValueNotifier` ; ajouter `Lecture directe de ProviderScope.containerOf hors widgets`
- Toutes les autres sections (Domain, Data, immutabilité, i18n, boucle de tour, RNG, PixelCanvas, perfs, tests, plateformes) **préservées telles quelles**
- Retrait du bandeau `🚧 EN TRANSITION`

**Dépendances:** 5-1 à 5-12

---

### Story 5.16: Retrospective (optionnel)
**Status:** optional
**Goal:** Capturer les apprentissages de la migration : surprises, écarts de scope, métriques avant/après.
