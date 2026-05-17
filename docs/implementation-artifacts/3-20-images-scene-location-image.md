# Story 3.20: Images de scène — déclarer .webp + intégrer LocationImage

Status: ready-for-dev
Epic: 3
Source ticket: ADVT‑S3‑20 (`docs/EXEC_S3.md`)
Refs : [ART_ASSET_BIBLE](../ART_ASSET_BIBLE.md), [VISUAL_STYLE_GUIDE](../VISUAL_STYLE_GUIDE.md), [asset-inventory](../asset-inventory.md)

## Story

**En tant que** joueur, **je veux** voir une image pixel-art 16-bit illustrer chaque lieu (quand disponible), affichée au-dessus de la description, **afin d'**ancrer l'imaginaire visuel du jeu et améliorer l'immersion sans casser la lisibilité textuelle.

## Acceptance Criteria

1. **AC1 — Déclaration assets** : `pubspec.yaml` liste **explicitement** chaque `assets/images/locations/<key>.webp` livré (un par un, pas de glob).
2. **AC2 — Widget `LocationImage` fonctionnel** : le widget existant (`lib/presentation/widgets/location_image.dart`) affiche l'image via `FadeInImage` avec placeholder, calcule la clé via `locationImageKey(Location)` (`mapTag` → `snake_case(name)` → `id`).
3. **AC3 — Fallback silencieux** : si l'image est absente, aucun crash, aucun log d'erreur, le placeholder reste visible.
4. **AC4 — PixelCanvas + FilterQuality.none** : rendu via `PixelCanvas` (320×180, scale entier). `paintImage`/`Image` passe `filterQuality: FilterQuality.none`.
5. **AC5 — `AspectRatio` 16:9** : la zone visuelle respecte le ratio au-dessus du titre dans `AdventurePage`.
6. **AC6 — Budgets** : chaque `.webp` ≤ 200 KB ; total `assets/images/locations/` ≤ 10 MB. Vérifier au build via `flutter build apk --analyze-size` ou manuellement.
7. **AC7 — Tests widget** : `test/presentation/widgets/location_image_test.dart` : image présente → rendue ; image absente → placeholder stable, aucune exception.
8. **AC8 — a11y** : `Semantics(label: location.name)` sur l'image (pas de "decorative" en mode présence d'image).

## Tasks / Subtasks

- [ ] **Task 1 — Déclaration pubspec** (AC: #1)
  - [ ] Lister chaque `.webp` livré (issus de la Story 3-23 Art Bible) dans `flutter.assets`.
- [ ] **Task 2 — Vérifier `LocationImage` widget** (AC: #2, #3, #4, #5)
  - [ ] Confirmer (ou ajuster) `lib/presentation/widgets/location_image.dart` ; vérifier `FilterQuality.none` ; placeholder léger.
- [ ] **Task 3 — Intégration `AdventurePage`** (AC: #5)
  - [ ] Insérer `LocationImage` au-dessus du titre dans `AdventurePage` (zone slot déjà réservée depuis ADVT‑S2‑16).
- [ ] **Task 4 — Vérifier budgets** (AC: #6)
  - [ ] Mesurer tailles via `du -sh assets/images/locations/` ; valider chaque image ≤ 200 KB.
- [ ] **Task 5 — Tests** (AC: #7)
  - [ ] `test/presentation/widgets/location_image_test.dart` : 2 cas (présence/absence) ; aucune exception non capturée.
- [ ] **Task 6 — a11y** (AC: #8)
  - [ ] Ajouter `Semantics(label: ...)` localisé.
- [ ] **Task 7 — Doc + completion**
  - [ ] MAJ `docs/asset-inventory.md` (statut « images livrées : N/M »).

## Dev Notes

### Source tree components to touch

| Path | NEW / UPDATE |
|---|---|
| `pubspec.yaml` | UPDATE (liste explicite des .webp) |
| `lib/presentation/widgets/location_image.dart` | UPDATE (si nécessaire) |
| `lib/presentation/pages/adventure_page.dart` | UPDATE (intégration) |
| `assets/images/locations/*.webp` | NEW (livrés par Story 3-23) |
| `test/presentation/widgets/location_image_test.dart` | UPDATE/NEW |
| `docs/asset-inventory.md` | UPDATE |

### Project Context Rules
- **Pixel-perfect** : `PixelCanvas` + `FilterQuality.none` partout.
- **Pas de réseau** : images embarquées.
- **i18n** : `Semantics(label: ...)` localisé.
- **Asset paths** : si une constante est utile, l'ajouter à `lib/core/constant/asset_paths.dart` ; sinon construire via `locationImageKey(Location)`.

### Previous Story Intelligence
- Story S2 ADVT‑S2‑16 : slot UI + `locationImageKey` + tests fallback déjà livrés. Cette story branche le widget aux fichiers réels.

### References
- `docs/EXEC_S3.md` ADVT‑S3‑20
- `lib/core/utils/location_image.dart` (helper clé)
- `docs/ART_ASSET_BIBLE.md`
- `docs/VISUAL_STYLE_GUIDE.md`

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
