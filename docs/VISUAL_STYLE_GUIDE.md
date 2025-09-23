# Guide Visuel — Typo, Couleurs, Composants, Motion (normatif)

Statut: Normatif. Ce guide fixe l’apparence de l’application (polices, couleurs, composants, états, motion) et aligne UI avec le pixel‑art 16‑bit. Toute dérive visuelle doit être amendée ici avant implémentation. Les tonalités doivent rester cohérentes avec le contexte historique rappelé dans `docs/Dossier_de_Référence.md` (esprit 1976–1977, exploration souterraine).

Règle d’or: l’UI sert la lisibilité des 3–7 actions et le texte. Elle s’efface derrière l’art 16:9 (PixelCanvas), reste contrastée et accessible (AA), sans bruit visuel.

## 1) Typographie

- Famille (V1): police système pour limiter le poids du bundle et maximiser la lisibilité.
  - Android: Roboto (par défaut Material).
  - iOS: SF Pro Text (fallback système).
- Option V1.1 (accessibilité): Atkinson Hyperlegible (embed) — à décider en S4 (impact taille bundle). Ne pas utiliser de police « pixel » pour le corps du texte.
- Échelle (sp) et usages
  - Title (Lieu courant): 22 sp, weight 700, letterSpacing 0.15, lineHeight ~28–30.
  - Body (Description): 16 sp (respect textScale 0.85–1.30), weight 400–500, lineHeight 1.45–1.60.
  - Action (Boutons): 16 sp, weight 600, letterSpacing 0.2, casse phrase (pas d’UPPERCASE).
  - Journal: 14 sp, weight 400, lineHeight 1.45.
  - StatusBar (S4): 12–14 sp selon densité, weight 600 pour valeurs.
- Troncature: labels d’action à ~32–40 caractères avec ellipsis; `Semantics.label` complet conservé.

## 2) Couleurs — Design Tokens (hex)

- Principes: UI neutre qui laisse respirer les images; contrastes AA; catégories d’actions colorées par icon/accents, pas par grands aplats.

Palette claire (Light)

- `color.primary` = #6C63FF  (accent indigo)
- `color.onPrimary` = #FFFFFF
- `color.background` = #FAFAFC
- `color.onBackground` = #111216
- `color.surface` = #FFFFFF
- `color.onSurface` = #121212
- `color.surfaceVariant` = #F2F2F7
- `color.outline` = #D1D5DB

Palette sombre (Dark)

- `color.primary` = #8C88FF
- `color.onPrimary` = #1A1B1E
- `color.background` = #0E0F12
- `color.onBackground` = #E6E7EB
- `color.surface` = #121318
- `color.onSurface` = #E6E7EB
- `color.surfaceVariant` = #1B1D23
- `color.outline` = #2A2E37

États & sémantiques (communs)

- `color.success` = #2E7D32 | Dark tint = #81C784
- `color.info`    = #0288D1 | Dark tint = #64B5F6
- `color.warning` = #ED6C02 | Dark tint = #FFB74D
- `color.danger`  = #C62828 | Dark tint = #EF9A9A

Catégories d’actions (accents)

- `action.travel`      = Light : #2E7D32 | Dark : #81C784
- `action.interaction` = Light : #1565C0 | Dark : #64B5F6
- `action.meta`        = Light : #616161 | Dark : #9E9E9E

Lampe — seuils batterie (StatusBar)

- >50%: #4CAF50 | 20–50%: #ED6C02 | <20%: #D32F2F

## 3) Spacing & Layout

- Grille: base 8 dp (multiples 4 dp autorisés pour fine‑tuning).
- Marges
  - Titre/Description: top 8–12 dp, bottom 8–12 dp.
  - Liste d’actions: item spacing 8–12 dp; padding horizontal 16–20 dp.
  - Journal: padding 12–16 dp; séparation items 8 dp.
  - Bottom bar: 56 dp (min), safe areas respectées.
- Image de scène: `AspectRatio 16/9` en tête; `PixelCanvas` (scale entier, `FilterQuality.none`).

## 4) Composants & États

Boutons d’action (liste verticale)

- Hauteur: 52–56 dp; Rayon: 12 dp; Padding: 16 dp horizontal.
- Style: Filled ton sur `surfaceVariant`; barre d’accent 3–4 dp à gauche selon catégorie (`action.travel|interaction|meta`).
- Icône: 24 dp, teinte = couleur de catégorie; label 16 sp/600.
- États: `enabled` (opacité 1), `pressed` (overlay 8–12%), `disabled` (opacité 38%, icône 30%).
- Overflow: `Plus…` styled comme action meta.

Headers de groupe (S3)

- Style: onSurface 60%, 12–13 sp/600, séparateur fin `outline`.

Chips/Badges (StatusBar S4)

- Forme: pill 10–12 dp radius, hauteur 24–28 dp, couleurs sémantiques.

Dialogues

- Rayon 16 dp, fond `surface`, `onSurface` 87%, boutons primaires `primary`.

Haptics

- Action validée: légère (light impact); erreurs: medium; toggle: selection click (si plateforme disponible).

## 5) Iconographie

- Matériel: Material Symbols Outlined 24 dp.
- Motions (travel): `arrow_upward, arrow_downward, arrow_forward, arrow_back, north_east, north_west, south_east, south_west, login, logout`.
- Interactions: `file_download` (prendre), `file_upload` (poser), `lock_open` (ouvrir), `lock` (fermer), `flash_on` (allumer), `flash_off` (éteindre), `search` (examiner), `inventory_2` (inventaire).
- Méta: `map`, `menu_book` (journal), `menu`.

## 6) Motion & Transitions

- Tap → feedback: 80–120 ms ripple; haptic léger.
- Fade image scène: 200–250 ms (si déjà précachée), crossfade audio 250–500 ms.
- Navigation onglets: fade‑through 220 ms; changement de lieu: fade + slide légère (≤ 12 dp), durée 180–220 ms.
- Aucune animation coûteuse; conserver < 16 ms par frame.

## 7) Accessibilité & Contrastes

- Contraste texte/surface ≥ 4.5:1 (AA); petites labels ≥ 3:1 si bold ≥ 18.66 sp.
- TextScale: supporter 0.85–1.30 sans clipping ni overlap; boutons se wrap sur 2 lignes max.
- Focus visible: outline 2 dp (`color.primary` 70%) sur composants focusables.

## 8) Implémentation (guidelines Flutter)

- `ThemeData` (Material 3), `useMaterial3: true`.
- Fichiers de thème (à créer côté dev):
  - `lib/presentation/theme/colors.dart` — export des tokens ci‑dessus (Light/Dark).
  - `lib/presentation/theme/typography.dart` — TextStyles mappées à l’échelle.
  - `lib/presentation/theme/theme.dart` — `ThemeData` light/dark avec composants (Buttons/Chips/Dialog) conformes à ce guide.
- N’utiliser `FilterQuality.none` que pour les images de scène (PixelCanvas); conserver `high` par défaut sur icônes UI si flou perceptible.

## 9) Exemples de mapping (UI)

- Bouton travel « Aller Nord »
  - Icône `arrow_upward`, accent `action.travel`, label 16 sp/600.
- Bouton interaction « Prendre la clé »
  - Icône `file_download`, accent `action.interaction`.
- Bouton méta « Inventaire »
  - Icône `inventory_2`, accent `action.meta`.

---

Références: `docs/CONVERSION_SPEC.md` (§17–§19), `docs/UX_SCREENS.md`, `docs/ART_ASSET_BIBLE.md`.

## 10) Home — Style A (normatif)

Objectif: page d’accueil sobre et moderne, image 16:9 en héros (pixel‑art), liste d’entrées en cartes Material 3 avec accent latéral de 3–4 dp, icône 24 dp à gauche et chevron optionnel à droite.

Layout

- Héros: image 16:9, largeur max vue; marge inférieure 12–16 dp; rendu via PixelCanvas (FilterQuality.none) si pixel‑art, sinon filtrage par défaut.
- Titre: 22 sp/700, letterSpacing 0.15; centré ou aligné à gauche; marge top 8–12 dp.
- Tagline (facultative): 14 sp/400 (ex: description/lieu); opacité 72%; une ligne max, ellipsis.
- Liste: cartes hauteur 56–64 dp; radius 12 dp; padding horizontal 16–20 dp; espacement vertical 12–16 dp; safe areas respectées.

Composant « AccentCard » (entrées Home)

- Structure: [Barre d’accent 3–4 dp] [Icône 24 dp] [Label 16 sp/600] [Sublabel 14 sp/400 (optionnel)] [Chevron → 24 dp (optionnel)].
- Couleurs (Light): fond = `surface` (#FFFFFF) ou `surfaceVariant` (#F2F2F7); texte = `onSurface` (#121212); accent = selon mapping ci‑dessous; outline 1 dp = `outline` (#D1D5DB) à 40% d’opacité (facultatif).
- Couleurs (Dark): fond = `surface` (#121318); texte = `onSurface` (#E6E7EB); outline 1 dp = `outline` (#2A2E37) 40% (facultatif).
- États: enabled (opacité 1); pressed (overlay 8–12%); focused (outline 2 dp `primary` 70%); disabled (fond `onSurface` 12–16%, texte `onSurface` 38%, icône 30%).
- Haptics: tap léger; aucune animation coûteuse.

Mapping accents (Home)

- Nouvelle partie: accent `primary` (#6C63FF Light / #8C88FF Dark), icône `play_arrow`.
- Continuer: accent `success` (#2E7D32 / #81C784), icône `bookmark`; sublabel: « Slot N – JJ/MM/AAAA ».
- Charger: accent `info` (#0288D1 / #64B5F6), icône `folder_open`.
- Inspecter le sac (Inventaire): accent `warning` (#ED6C02 / #FFB74D), icône `backpack` (ou `inventory_2`).
- Paramètres: accent `action.meta` (gris) (#616161 / #9E9E9E), icône `tune` (ou `settings`).
- Crédits: accent `action.meta` (gris), icône `info`.

Variantes et contraintes

- Police: rester sur la police système (pas de police « pixel » pour les labels). Aucune fonte chargée en HTTP.
- Image: poids ≤ 200 KB; si absente, utiliser un placeholder neutre et conserver le layout.
- Thèmes: Light et Dark doivent conserver un contraste AA (≥ 4.5:1) pour labels vs fond de carte.

DoD visuel (Home)

- Héros 16:9 en tête; 5 entrées max visibles; marges et espacements conformes au layout ci‑dessus.
- « Continuer » désactivé si aucune autosave; sinon sublabel (1 ligne) avec ellipsis si trop long.
- Tap → ripple 80–120 ms + haptic; focus visible; aucune frame > 16 ms.

## 11) Micro‑composant — AccentCard (spec illustrée)

But: carte d’action unifiée pour la Home (et usages dérivés). Composant touch‑friendly, lisible et réutilisable.

Dimensions & contraintes

- Hauteur: 56 dp (sans sublabel) → 64 dp (avec sublabel).
- Largeur: pleine largeur moins marges latérales 16–20 dp.
- Rayon: 12 dp. Ombre très légère (optionnelle) ou outline 1 dp `outline` à 40%.
- Barre d’accent: 3–4 dp (plein), collée au bord gauche.
- Icône: 24 dp; chevron/trailing: 24 dp (optionnel).
- Padding: horizontal 16–20 dp; vertical 12 dp; espacement entre icône et texte 12 dp; entre label et sublabel 4–6 dp.

Schéma (non à l’échelle)

```txt
┌───────────────────────────────────────────────────────────────────┐
│ ████  12dp  [icon 24dp]  12dp  Label 16sp/600                     │
│ accent                        4–6dp  Sublabel 14sp/400 (optionnel)│
│ 3–4dp                                             12dp  ▶  24dp   │
│                               padding→ ←16–20dp                   │
└───────────────────────────────────────────────────────────────────┘
Hauteur: 56dp (sans sublabel) / 64dp (avec sublabel)
```

Tokens & couleurs

- Fond: `surface` (Light #FFFFFF / Dark #121318) ou `surfaceVariant` (Light #F2F2F7 / Dark #1B1D23).
- Texte: `onSurface` (Light #121212 / Dark #E6E7EB).
- Accent (gauche): dépend de l’entrée (voir §10 Mapping accents).
- Outline (facultatif): `outline` (Light #D1D5DB / Dark #2A2E37) à 40%.

États

- Enabled: opacité 1.
- Pressed: overlay 8–12% sur le fond (ne pas altérer l’accent).
- Focused: outline 2 dp `primary` à 70% d’opacité (périmètre extérieur).
- Disabled: fond = `onSurface` 12–16%; label = `onSurface` 38%; icône/chevron = 30%; sublabel masqué.

Accessibilité

- Cible tactile ≥ 48×48 dp (la carte entière est cliquable).
- Contraste AA ≥ 4.5:1 entre label et fond (Light & Dark).
- Lecture screen reader: ordre « icône → label → sublabel → état/chevron ». `Semantics(label)` complet; rôle `button`.
- TextScale support: 0.85–1.30 sans clipping; label sur 2 lignes max; sublabel 1 ligne, ellipsis.

Variantes

- Sans icône (réserver un espace de 24 dp pour l’alignement).
- Avec trailing spécifique (ex: chevron ▶ ou badge discret).
- Avec sublabel (ex: « Slot A — AAAA‑MM‑JJ HH:MM »).

Motion & feedback

- Ripple 80–120 ms; haptic léger à l’activation; aucune animation coûteuse.

Pseudo‑implémentation Flutter (structure)

```dart
Widget accentCard({
  required Color accent,
  required IconData icon,
  required String label,
  String? sublabel,
  bool enabled = true,
  VoidCallback? onTap,
}) {
  // Container (radius 12, surface/surfaceVariant), InkWell (ripple),
  // Row: [Accent 3–4dp] [12dp] [Icon 24dp] [12dp] [Texts] [spacer] [Chevron 24dp?]
}
```
