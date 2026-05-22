# Story 4.15: Images — préchargement + cache + toggle Settings

Status: blocked-by-epic-5
Epic: 4
Source ticket: ADVT‑S4‑15 (`docs/EXEC_S4.md`)
Refs : [design.md](../design.md), [project-context](../project-context.md), [asset-inventory](../asset-inventory.md)

---
## 📝 Amendement Design Handoff — 2026-05-22

Cette story est antérieure au handoff design. Avant `dev-story`, intégrer :
- **ADR-010 — 3 tiers d'assets** : le préchargement doit couvrir les 3 tiers (scènes 320×180 WebP + objets 512² PNG + créatures 768² PNG) — pas seulement les scènes
- **Cache** : `ImageCache.maximumSizeBytes` à régler 64–96 Mo (DoD S4) — réviser à la hausse si les 3 tiers saturent le cache courant
- **Toggle Settings** : un toggle global « afficher les images de scène » avec impact sur les 3 tiers (ou ventiler par tier ? à arbitrer)
- **Dépendance** : aligné avec story 5-12 (pipeline assets 3 tiers)

> ⚠️ **Bloquant** : cette story ne peut entrer en dev qu'après livraison de Epic 5 story 5-12 (asset pipeline).
> AC à compléter pour couvrir tiers 2 et 3 — à traiter lors du `Create Story`.
---

## Story

**En tant que** joueur sur appareil avec RAM limitée, **je veux** précharger l'image du prochain lieu (quand connu) et pouvoir désactiver les images de scène depuis Settings, **afin de** maintenir fluidité et éviter les OOM.

## Acceptance Criteria

1. **AC1 — Précharge post-tour** : après un `ApplyTurn` réussi identifiant un prochain lieu probable (via destinations visibles), `precacheImage` est appelé pour son `.webp`.
2. **AC2 — Toggle Settings** : SettingsPage ajoute "Afficher les images de scène" (on/off), persisté via `AppPreferencesRepository` (Story 4-6).
3. **AC3 — Défaut adaptatif** : activé si `RAM total ≥ 3 Go` (détection device best-effort), sinon désactivé par défaut.
4. **AC4 — `ImageCache.maximumSizeBytes`** : ajusté à 64–96 MB selon RAM ; testé sans OOM sur Tab A8 (3 Go).
5. **AC5 — Mode sombre** : overlay/tonemapping léger conserve la lisibilité ; tests visuels manuels notés.
6. **AC6 — Tests** : toggle persisté ; image absente toujours fallback ; cache respecte le plafond.

## Tasks / Subtasks

- [ ] **Task 1 — Précharge post-tour** (AC: #1).
- [ ] **Task 2 — Toggle Settings + persistance** (AC: #2, #3).
- [ ] **Task 3 — Ajuster ImageCache** (AC: #4).
- [ ] **Task 4 — Tests + validation visuelle** (AC: #5, #6).

## Dev Notes

### Source tree

| Path | UPDATE |
|---|---|
| `lib/application/controllers/game_controller.dart` | UPDATE (précharge) |
| `lib/presentation/pages/settings_page.dart` | UPDATE (toggle) |
| `lib/application/controllers/app_preferences_controller.dart` | UPDATE (clé `images.enabled`) |
| `lib/main.dart` | UPDATE (ImageCache config) |
| `test/...` | UPDATE |

### Project Context Rules
- ValueNotifier pattern.
- mocktail only.
- Pas de réseau.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑15
- Story 4-6 (AppPreferencesRepository)

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
