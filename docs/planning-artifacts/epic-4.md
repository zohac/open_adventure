# Sprint 4 — Scoring complet, Fins de jeu, Multi-saves, Polish UX, Hardening, CI

> **Source canonique des DoD détaillés** : [`docs/EXEC_S4.md`](../EXEC_S4.md) (Suivi & tickets ADVT‑S4‑01 → ADVT‑S4‑19).
> Cet epic est une **vue BMad** dérivée de l'EXEC ; en cas de divergence, EXEC_S4 prime.

## Epic 4: Sprint 4 — Finalisation production-ready

**Status:** backlog
**Goal:** Finaliser la boucle de jeu (scoring complet fidèle au C, fins, multi-saves), polir UX (a11y AA, i18n FR/EN, status bar, map), durcir perfs/résilience, livrer CI verte avec seuils de couverture.
**Acceptance:** Jouable de bout en bout jusqu'aux fins ; multi-saves robustes ; `flutter analyze` zéro warning ; couverture Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 % ; cold start < 1 s ; bundle Android < 30 Mo.

### Story 4.1: ComputeScore complet (parité score.c)
**Status:** backlog
**Source ticket:** ADVT‑S4‑01
**Goal:** Composantes trésors/exploration/pénalités/indices/morts/bonus/classes testées isolément ; scénarios intégrés reproduisent sorties attendues ; écart justifié documenté.

### Story 4.2: Détection fins de jeu (victoire/closing/mort/abandon)
**Status:** backlog
**Source ticket:** ADVT‑S4‑02
**Goal:** Détection correcte des 4 raisons ; structure `EndGame { reason, finalScore, breakdown }` ; UI reçoit l'événement ; tests verts.

### Story 4.3: Système d'indices (GetHints + UseHint malus idempotent)
**Status:** backlog
**Source ticket:** ADVT‑S4‑03
**Goal:** Indices proposés en contexte ; malus appliqué une seule fois par indice ; tests répétition.

### Story 4.4: SaveRepository complet (save/load/list/delete + atomique)
**Status:** backlog
**Source ticket:** ADVT‑S4‑04
**Goal:** Liste triée par `updated_at` ; delete retire le fichier ; écriture atomique temp+rename ; lecture ignore champs inconnus.

### Story 4.5: SavesPage (liste slots + charger/supprimer)
**Status:** backlog
**Source ticket:** ADVT‑S4‑05
**Goal:** Slots avec `title/progression/date` ; actions fonctionnelles ; widget tests tap → callbacks.

### Story 4.6: SettingsPage (thème + taille police + langue FR/EN)
**Status:** backlog
**Source ticket:** ADVT‑S4‑06
**Goal:** Préférences persistées et restaurées ; changement de langue reflété dans l'UI ; tests.

### Story 4.7: AdventurePage v2 (StatusBar + groupes actions)
**Status:** backlog
**Source ticket:** ADVT‑S4‑07
**Goal:** StatusBar score/tours/lampe en temps réel ; groupes d'actions avec entêtes ; focus management ; tests.

### Story 4.8: EndGamePage/Dialog (breakdown + classe + actions)
**Status:** backlog
**Source ticket:** ADVT‑S4‑08
**Goal:** Breakdown complet ; actions rejouer/charger/crédits ; widget tests valident boutons et navigation.

### Story 4.9: i18n finale (ARB FR/EN + automatisation + CI guard)
**Status:** backlog
**Source ticket:** ADVT‑S4‑09
**Goal:** Script `scripts/extract_localization.dart` parcourt `assets/data/**` ; JSON enrichis `i18nKey` ; `app_en.arb` (source) + `app_fr.arb` (cible) complets via `flutter gen-l10n` ; test CI échouant si clé manquante ; documentation handoff traducteur.

### Story 4.10: Accessibilité finale (voice-over + contrastes + clavier)
**Status:** backlog
**Source ticket:** ADVT‑S4‑10
**Goal:** Audit a11y passé ; problèmes critiques corrigés ; tests semantics clés.

### Story 4.11: Job CI data-validate (optionnel, non bloquant mobile)
**Status:** backlog
**Source ticket:** ADVT‑S4‑11
**Goal:** Job CI configuré ; sortie lisible ; pipeline mobile non bloqué si Python indisponible.

### Story 4.12: Perf & hardening (Isolate + bench démarrage + jank + mémoire)
**Status:** backlog
**Source ticket:** ADVT‑S4‑12
**Goal:** Cold start < 1 s ; aucune frame > 16 ms ; mémoire < 150 Mo ; traces enregistrées.

### Story 4.13: Résilience sauvegardes (rollback + corruption + fallback autosave)
**Status:** backlog
**Source ticket:** ADVT‑S4‑13
**Goal:** Corruption simulée → fallback sur dernier autosave sain ; aucun crash ; logs informatifs.

### Story 4.14: Lint/Analyze + couverture (Domain≥90/Data≥80/App≥80/UI≥60)
**Status:** backlog
**Source ticket:** ADVT‑S4‑14
**Goal:** Rapports LCOV au-dessus des seuils ; `flutter analyze` zéro warning ; CI verte.

### Story 4.15: Images — préchargement, cache, toggle Settings
**Status:** backlog
**Source ticket:** ADVT‑S4‑15
**Goal:** `precacheImage` post-tour pour le prochain lieu ; toggle Settings « afficher images de scène » persisté (défaut activé si RAM ≥ 3 Go) ; `ImageCache.maximumSizeBytes` ajusté 64–96 Mo sans OOM.

### Story 4.16: Audio — preload/mémoire (< 20 Mo) + ducking final
**Status:** backlog
**Source ticket:** ADVT‑S4‑16
**Goal:** Preload prochain BGM opérationnel ; ducking audible propre (−4 dB / 200 ms) ; mémoire conforme ; tests + validation d'écoute documentée.

### Story 4.17: Audio — Settings avancés (toggles + sliders + reset + persistance)
**Status:** backlog
**Source ticket:** ADVT‑S4‑17
**Goal:** Persistance prouvée ; UI réagit instantanément ; test d'intégration traverse ON/OFF sans erreur.

### Story 4.18: Art — compléter scènes restantes (Asset Bible) + QA finale 16-bit
**Status:** backlog
**Source ticket:** ADVT‑S4‑18
**Goal:** Toutes scènes planifiées livrées ; budgets respectés ; rendu net via PixelCanvas ; checklists DA/A11y passées.

### Story 4.19: HomePage v1 (style 16-bit final + i18n/a11y)
**Status:** backlog
**Source ticket:** ADVT‑S4‑19
**Goal:** Application VISUAL_STYLE_GUIDE (typographies, spacing, états) ; Continuer disabled si pas d'autosave ; i18n FR/EN complètes ; a11y AA (focus/labels/contraste).
