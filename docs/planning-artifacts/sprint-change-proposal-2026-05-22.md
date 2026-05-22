# Sprint Change Proposal — Handoff Design / Foundation Refresh

**Date :** 2026-05-22
**Auteur :** Simon (avec assistance Correct Course)
**Statut :** ✅ Approuvé et appliqué
**Scope :** **Major** — refonte DA + migration architecture + restructuration sprint
**Source du déclencheur :** Handoff design tiers livré post-rédaction des stories 3-x/4-x

---

## 1. Issue Summary

Un **handoff design complet** (10 ADRs, design tokens CSS, motion spec, specs visuelles par écran sous forme de mockups JSX) a été livré au format `design_handoff_open_adventure/` + `docs/design.md` + `docs/features/*.md`, après que :
- l'**Epic 1** ait été clôturé (`done`)
- l'**Epic 2** ait été clôturé (`done`) — dont les stories UI `2-10-adventure-page-v0`, `2-19-theme-tokens-baseline`, `2-20-home-page-v0`
- 14 stories de l'**Epic 3** aient été clôturées (`done`) — dont `3-14-game-controller-journal-lampe-nains` et `3-15-inventory-page`
- 8 stories `ready-for-dev` restent sur l'Epic 3
- 19 stories `ready-for-dev` aient été préparées pour l'Epic 4

Les décisions portées par le handoff (palette ambre/encre dark-only, fonts pixel chrome + sans-serif body, motion en `Curves.stepN`, 3 tiers d'assets 1:1, `MagicWordSurface` dédiée, écrans Map/Journal/Settings/Saves/EndGame spécifiés visuellement, migration architecturale `ValueNotifier` → Riverpod 2 et `lib/presentation/` → `lib/features/`) entrent en **conflit substantiel** avec les docs normatifs existants (`VISUAL_STYLE_GUIDE.md`, `UX_SCREENS.md`, `DESIGN_ADDENDUM.md`) ainsi qu'avec l'architecture livrée et tracée dans `project-context.md`.

**Type :** nouvelle exigence émergeant des parties prenantes (le designer a travaillé hors cycle de planification).

---

## 2. Impact Analysis

### 2.1 Conflits docs normatifs ↔ handoff

| Axe | Existant (normatif) | design.md (handoff) | Verdict |
|---|---|---|---|
| Palette | Indigo `#6C63FF` + light & dark | Encre profonde × halo ambre, dark-only | ❌ Refonte DA |
| Fonts | Roboto/SF Pro système, interdit pixel pour body | Pixelify Sans + Silkscreen + DM Sans | ❌ Stack inversée |
| Theme modes | Light + Dark | Dark only (ADR-003) | ❌ Light supprimé |
| Motion | Non spécifié finement | `steps()` obligatoire (ADR-006) | ➕ Additif |
| Asset specs | 16:9 320×180 scènes uniquement | + 1:1 512² objets, + 1:1 768² créatures (ADR-010) | ➕ Pipeline à étendre |
| MagicWords | Bouton contextuel (DDR-001) | Surface dédiée (ADR-002) | ❓ Raffinement |
| State mgmt | `ValueNotifier` + DI manuelle | Riverpod 2 + `StateNotifierProvider` | ❌ Migration |
| Layout `lib/` | `lib/presentation/` | `lib/features/` | ❌ Réorg |
| Audio backend | `just_audio` + `audio_session` | `audioplayers` | ⚠️ **Patché** : `just_audio` conservé (gapless looping) |

### 2.2 Impact par epic

- **Epic 1** (Data layer) : **aucun impact**. Pur Domain/Data.
- **Epic 2** (Moteur + UI v0) : impact moyen-fort sur 4 stories `done` (`2-10`, `2-19`, `2-20`) ; backend (`2-1`–`2-9`, `2-12`, `2-21`–`2-24`) non impacté. Stack audio `2-17` confirmée OK.
- **Epic 3** (in-progress) : 2 stories `done` à refondre (`3-14` GameController, `3-15` InventoryPage) ; 8 stories `ready-for-dev` impactées dont 4 deviennent `blocked-by-epic-5` (3-16, 3-17, 3-20, 3-23) et 3 ont un bandeau d'amendement léger (3-18, 3-21, 3-22). Backend Domain (3-1 à 3-13) non impacté.
- **Epic 4** (planifié) : impact fort. 7 stories deviennent `blocked-by-epic-5` (4-5, 4-6, 4-7, 4-8, 4-15, 4-18, 4-19) ; 3 ont un bandeau léger (4-9, 4-10, 4-17) ; 9 restent intactes (4-1, 4-2, 4-3, 4-4, 4-11, 4-12, 4-13, 4-14, 4-16).

### 2.3 Gaps non couverts par les stories existantes

Items du handoff sans story dédiée préalablement :
- Migration Riverpod 2 (foundation + playbook)
- Réorganisation `lib/presentation/` → `lib/features/`
- Atomes UI partagés (`OAStamp`, `OAPill`, `OAIcon`, `OASceneFrame`, `OAItemSprite`)
- Motion system `OAAnimations` + `Curves.stepN`
- Composant `MagicWordSurface` dédié (ADR-002)
- Pipeline assets 3 tiers (ADR-010)
- Audit fidélité post-migration (garde-fou)
- Réécriture des docs normatifs (architecture.md, project-context.md sections State/DI)

### 2.4 Impact technique

- Bump `pubspec.yaml` : ajout `flutter_riverpod ^2.x` ; ajout fonts (`Pixelify Sans`, `Silkscreen`, `DM Sans`) sous `assets/fonts/`
- Pas de changement sur Domain/Data (Clean Architecture frontières préservées)
- Risque de régression gameplay : **mitigé** par l'introduction de la story 5-13 (audit fidélité O1–O3 pre/post)
- Risque CI/lint : **mitigé** par les DoD de chaque story 5-x (`flutter analyze` zéro warning + tests verts requis)

---

## 3. Recommended Approach

### Option retenue : **Hybride — Epic 5 "Foundation Refresh" inséré + amendement ciblé des stories existantes**

| Option | Effort | Risque | Délai | Verdict |
|---|---|---|---|---|
| 1. Direct Adjustment (amender stories sans refonte) | Faible | Élevé (incohérence visuelle persistante) | Court | Non viable |
| 2. Rollback des 5 stories done (2-10, 2-19, 2-20, 3-14, 3-15) | Moyen | Moyen | Moyen | Inclus dans hybride |
| 3. MVP Review (réduire scope) | Faible | Élevé (compromettrait fidélité produit) | Court | Non viable |
| **Hybride retenu — Epic 5 + amendements** | **Élevé** | **Maîtrisé (story-par-story)** | **Long (+1 sprint estimé)** | **✅ Recommandé** |

### Rationale

- La **fidélité gameplay 430 pts** est intouchable (cf. `project-context.md` §Doctrine) → MVP Review exclu.
- Le handoff porte de **vraies valeurs produit** (cohérence DA, signature lumineuse, pipeline assets industrialisable) qu'un Direct Adjustment ne capturerait pas.
- Un Rollback complet aurait perdu le travail Domain/Application déjà livré dans 3-14 et l'effort d'intégration de 3-15 → préférer la refonte ciblée en Epic 5 avec préservation des contrats publics.
- L'introduction d'un Epic dédié donne **traçabilité** et **dépendances explicites** entre stories impactées.

---

## 4. Detailed Change Proposals

Toutes les modifications listées ci-dessous ont été **appliquées au moment de la rédaction de ce proposal** (incremental mode validé par Simon).

### 4.1 Batch A — Documents normatifs

| ID | Fichier | Action |
|---|---|---|
| A1 | `docs/design.md` | Bump version v0.2 → v0.3 ; en-tête supersedes ; §3.1 audio backend `audioplayers` → `just_audio + audio_session` ; §3.2 commentaire transition `features/` |
| A2 | `docs/VISUAL_STYLE_GUIDE.md` | Bandeau ⚠️ SUPERSEDED en tête |
| A2 | `docs/UX_SCREENS.md` | Bandeau ⚠️ SUPERSEDED en tête |
| A2 | `docs/DESIGN_ADDENDUM.md` | Bandeau ⚠️ SUPERSEDED en tête |
| A3 | `docs/project-context.md` | Bandeau 🚧 EN TRANSITION en tête ; sections State/DI à réécrire dans 5-15 |
| A4 | `docs/architecture.md` | Bandeau 🚧 EN TRANSITION en tête ; doc à réécrire dans 5-14 |

### 4.2 Batch B — Epic 5 "Foundation Refresh"

| Fichier | Action |
|---|---|
| `docs/planning-artifacts/epic-5.md` | **Créé** — 15 stories + 1 retrospective optionnelle |
| `docs/implementation-artifacts/sprint-status.yaml` | Ajout du bloc `epic-5 backlog` + 15 stories `backlog` + retrospective optional ; documentation du statut `blocked-by-epic-5` dans l'en-tête |

**Détail des 15 stories 5-x :** voir [`docs/planning-artifacts/epic-5.md`](./epic-5.md).

### 4.3 Batch C — Amendements stories Epic 3

| Story | Statut avant | Statut après | Bandeau |
|---|---|---|---|
| 3-14-game-controller-journal-lampe-nains | done | done (commentaire inline) | (refondu en 5-6) |
| 3-15-inventory-page | done | done (commentaire inline) | (supersedée par 5-9) |
| 3-16-map-page-v1 | ready-for-dev | **blocked-by-epic-5** | Pilote — complet |
| 3-17-journal-view | ready-for-dev | **blocked-by-epic-5** | Complet |
| 3-18-accessibilite-de-base | ready-for-dev | ready-for-dev | Léger (ADR-006 motion) |
| 3-19-lint-couverture-domain-85 | ready-for-dev | ready-for-dev | Aucun (non impacté) |
| 3-20-images-scene-location-image | ready-for-dev | **blocked-by-epic-5** | Complet (ADR-010 3 tiers) |
| 3-21-audio-zones-bgm-crossfade | ready-for-dev | ready-for-dev | Léger (just_audio confirmé) |
| 3-22-audio-sfx-interaction-throttle | ready-for-dev | ready-for-dev | Léger (just_audio confirmé) |
| 3-23-art-15-20-scenes-prioritaires | ready-for-dev | **blocked-by-epic-5** | Complet (palette imposée) |

### 4.4 Batch D — Amendements stories Epic 4

| Story | Statut avant | Statut après | Bandeau |
|---|---|---|---|
| 4-1 à 4-4 (scoring/fins/indices/save-repo) | ready-for-dev | ready-for-dev | Aucun (backend) |
| 4-5-saves-page | ready-for-dev | **blocked-by-epic-5** | Complet |
| 4-6-settings-page-theme-langue | ready-for-dev | **blocked-by-epic-5** | Complet (⚠️ AC1 thème à réécrire — ADR-003 dark-only) |
| 4-7-adventure-page-v2-status-bar | ready-for-dev | **blocked-by-epic-5** | Pilote — complet |
| 4-8-end-game-page | ready-for-dev | **blocked-by-epic-5** | Complet (endgame.jsx + death.jsx) |
| 4-9-i18n-finale | ready-for-dev | ready-for-dev | Léger (nouvelles clés à scanner) |
| 4-10-accessibilite-finale | ready-for-dev | ready-for-dev | Léger (à planifier post Epic 5) |
| 4-11 à 4-14 (CI/perf/résilience/lint) | ready-for-dev | ready-for-dev | Aucun (infra/backend) |
| 4-15-images-precache-toggle | ready-for-dev | **blocked-by-epic-5** | Complet (ADR-010 3 tiers) |
| 4-16-audio-preload-ducking | ready-for-dev | ready-for-dev | Aucun (couvert par 4-17) |
| 4-17-audio-settings-avances | ready-for-dev | ready-for-dev | Léger (just_audio + schéma settings) |
| 4-18-art-scenes-restantes | ready-for-dev | **blocked-by-epic-5** | Complet (palette + ADR-010) |
| 4-19-home-page-v1 | ready-for-dev | **blocked-by-epic-5** | Complet (devient polish post-5-8) |

### 4.5 Récapitulatif quantitatif

- **2 stories done** marquées avec commentaire inline (`2-10`, `2-19`, `2-20`, `3-14`, `3-15` — total 5)
- **15 nouvelles stories** Epic 5 (5-1 à 5-15) + 1 retrospective optionnelle
- **11 stories** passées en `blocked-by-epic-5` (3-16, 3-17, 3-20, 3-23, 4-5, 4-6, 4-7, 4-8, 4-15, 4-18, 4-19)
- **6 stories** avec bandeau léger (3-18, 3-21, 3-22, 4-9, 4-10, 4-17)
- **9 stories backend/infra** intactes (3-19, 4-1, 4-2, 4-3, 4-4, 4-11, 4-12, 4-13, 4-14, 4-16 — total 10)
- **6 fichiers docs** modifiés (design.md, VISUAL_STYLE_GUIDE.md, UX_SCREENS.md, DESIGN_ADDENDUM.md, project-context.md, architecture.md)
- **1 fichier sprint status** mis à jour (`sprint-status.yaml`)
- **1 fichier epic créé** (`epic-5.md`)

---

## 5. Implementation Handoff

### 5.1 Scope classification : **Major**

Cette correction de course implique :
- Architecture migration (ValueNotifier → Riverpod 2)
- DA refresh complet (palette, fonts, motion, atomes UI)
- Pipeline assets étendu (3 tiers)
- Rewrite de 3 docs normatifs (1 en cours d'écriture, 2 reportés à 5-14/5-15)

### 5.2 Recipients

Routing standard BMad pour scope Major : **PM / Solution Architect**. Dans ce projet personnel, ces rôles sont assumés par Simon — toutes les décisions ont été validées en mode incrémental durant la session Correct Course 2026-05-22.

### 5.3 Next steps

1. **Engagement développement Epic 5** : démarrer story 5-1 (Riverpod foundation) puis 5-2/5-3/5-4/5-5 (atomes + tokens + motion) en parallèle si possible.
2. **Snapshot pré-migration** à capturer **avant** démarrage de 5-6 (pour audit 5-13).
3. **Re-évaluation des stories `blocked-by-epic-5`** au fil de la livraison des stories 5-x dont elles dépendent.
4. **Retour en `ready-for-dev`** des stories débloquées au fil de l'eau (à mesure que leurs dépendances sont livrées).
5. **Retrospective Epic 5** (optionnelle, 5-16) — recommandée vu l'ampleur du changement.

### 5.4 Success criteria

- `flutter analyze` zéro warning préservé tout au long
- Tests Domain ≥ 90 %, Data ≥ 80 %, Application ≥ 80 %, Presentation ≥ 60 % préservés
- Oracle tests O1–O3 verts post-migration (audit 5-13)
- Aucun écart visuel observable entre les mockups `design_handoff_open_adventure/*.jsx` et les écrans portés
- `architecture.md` et `project-context.md` réécrits, sans bandeau `🚧 EN TRANSITION`
- `MagicWordSurface` implémentée, **aucun** mot magique exposé tant que `magicWordsUnlocked == false`

---

## 6. Approbation

✅ **Approuvé par Simon** le 2026-05-22 en mode incrémental (toutes les éditions ont été présentées, validées, puis appliquées au fil de la session Correct Course).

**Fin du Sprint Change Proposal.**
