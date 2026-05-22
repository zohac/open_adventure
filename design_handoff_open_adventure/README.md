# Handoff — Open Adventure (Flutter Mobile)

> **Direction artistique + Design System complet**
> Carnet d'explorateur sous la lanterne · pixel-art 16-bit · dark only · mobile FR/EN · 100% offline.

---

## 1. À propos de ce bundle

Ce dossier contient les **maquettes HTML/CSS/JSX** produites comme référence visuelle. Ce ne sont **pas** des fichiers à intégrer tels quels. Ta tâche :

> **Recréer ces écrans dans Flutter** (l'app cible est Flutter mobile), en respectant l'environnement Clean Architecture déjà en place, les conventions de l'app, et la stack existante (Riverpod, GoRouter, AudioPlayers, etc.).

Les HTML servent à :
- comprendre la grammaire visuelle (palette, typo, spacing, motion)
- voir le résultat attendu pour chaque écran et chaque état
- copier les valeurs exactes (hex, durations, etc.) dans `theme.dart` / tokens

**Pour ouvrir les maquettes** : ouvre `index.html` dans un navigateur. Tout est statique et fonctionne offline (les fonts viennent de Google Fonts CDN — coupe wifi si tu veux voir le fallback).

### 📘 Voir aussi les design.md

Compagnon vivant des maquettes : `docs/design.md` (architecture racine + ADRs cross-cutting) et `docs/features/*.md` (un par feature). C'est là que sont consignées **les décisions** (pourquoi tel choix), **les state shapes**, et **les behaviors**. Le présent README reste un snapshot visuel — les `design.md` évoluent avec l'app.

---

## 2. Fidélité

**High-fidelity.** Les valeurs (couleurs hex, tailles, espacements, durées d'animation) sont définitives et doivent être reproduites précisément.

**Assets pixel-art** : 3 scènes (`loc_start`, `loc_valley`, `loc_winding`), 1 objet (`lantern`) et 1 créature (`dwarf`) sont déjà livrés dans `scenes/`, `objects/` et `creatures/`. Tous les autres sont des placeholders abstraits — à remplacer par les vraies illustrations au fur et à mesure (voir §9 + section 09 du design system pour les specs).

---

## 3. Design tokens (à porter dans `theme.dart`)

Source unique : `tokens.css`. Tous les hex sont exacts.

### 3.1 Couleurs

```dart
// ENCRE · backgrounds (la grotte)
static const inkVoid     = Color(0xFF06101A); // fond système, full-screen base
static const inkDeep     = Color(0xFF0D1D2D); // bg primaire
static const inkMid      = Color(0xFF16304A); // panneaux, cards
static const inkRaised   = Color(0xFF1F4267); // hover, élevé
static const inkLine     = Color(0xFF2A5478); // bordures
static const inkHairline = Color(0xFF1A3A5A); // dividers

// BRUME · cool secondary
static const tealMist = Color(0xFF5A8FA8); // texte secondaire, idle icons
static const tealDeep = Color(0xFF2A4D6E); // surface fond
static const tealGlow = Color(0xFF4EC5B8); // interactif cool, toggles

// PAPIER · texte sur fond sombre
static const paperBright = Color(0xFFFAF2DD); // H1/display, max contraste
static const paperWarm   = Color(0xFFF0E4CC); // corps texte
static const paperFaded  = Color(0xFFC8B896); // tertiaire, captions
static const paperInk    = Color(0xFF7A6A4E); // watermarks, dividers

// AMBRE · signature lanterne
static const amberGlow   = Color(0xFFFFC070); // highlight
static const amber       = Color(0xFFF0A040); // accent principal
static const amberDeep   = Color(0xFFC97432); // pressé
static const amberShadow = Color(0xFF8A4A1A); // ombre token
static const amberHalo   = Color(0x38F0A040); // 22% alpha — wash de lumière

// SÉMANTIQUE
static const treasure = Color(0xFFD4A84A); // or, trésors, score
static const danger   = Color(0xFFD44A3A); // hostile, lampe critique
static const success  = Color(0xFF6EA34A); // découverte
static const magic    = Color(0xFF9870C4); // incantations
```

### 3.2 Typographie

| Token | Famille | Source | Usage |
|---|---|---|---|
| `--f-display` | Pixelify Sans 600/700 | Google Fonts | Titres, lieux, boutons de menu |
| `--f-caps`    | Silkscreen 400/700    | Google Fonts | UPPERCASE caps, status pills, tabs |
| `--f-body`    | DM Sans 400/500/600   | Google Fonts | Description, journal, body long-form |
| `--f-mono`    | JetBrains Mono 400/500| Google Fonts | Timestamps, paths, hints |

**Échelle (mobile, base 16px) :**
```
display-xl 40px / 1.05 / +0.02em — hero (Home, Death "TU AS PÉRI")
display-l  28px / 1.10 / +0.01em — locations names
display-m  22px / 1.15           — section heads (DS cards, page titles)
display-s  18px / 1.20           — sub-heads
caps-m     12px / +0.08em UPPER  — status pills, action labels
caps-s     10px / +0.10em UPPER  — micro labels, eyebrows
body-l     17px / 1.55           — description longue
body-m     15px / 1.50           — body courant
body-s     13px / 1.45           — secondaire, hints
action     16px                  — action button label
```

### 3.3 Spacing (4dp grid)

`--s-1` 4px · `--s-2` 8px · `--s-3` 12px · `--s-4` 16px · `--s-5` 20px · `--s-6` 24px · `--s-7` 32px · `--s-8` 40px · `--s-9` 48px · `--s-10` 64px

### 3.4 Radii — **0px par défaut**

Le système est pixel-art : **pas de coins arrondis** sauf cas exceptionnel.
`--r-0` 0px (défaut) · `--r-1` 2px · `--r-2` 4px · `--r-3` 8px (rare)

### 3.5 Borders & Shadows

Bordures **2px solid** par défaut (`--b-2`), parfois 2.5px pour le chrome principal.

Ombres **dures, offset, jamais flou** :
```
--sh-block-sm:  2px 2px 0 0 #06101A
--sh-block-md:  3px 3px 0 0 #06101A   ← défaut stamp
--sh-block-lg:  4px 4px 0 0 #06101A
--sh-amber-glow: 0 0 24px 4px rgba(240,160,64,0.22)  ← seule ombre douce, pour halo lanterne
```

### 3.6 Tap targets

`44dp` minimum · `48dp` confort · `56dp` large (Home menu items)

---

## 4. Vocabulaire visuel

### 4.1 Le langage Tampons (Stamps)

**Toutes** les actions du jeu utilisent la grammaire **Stamp**. Un stamp = bordure 2.5px + ombre offset 3px + libellé Silkscreen UPPER. Deux familles :

- **Outlined** (transparent, bordure colorée) : `default` (paper), `meta` (teal), `faded` (paper-ink), `danger` (rouge), `magic` (violet)
- **Filled** (encre solide) : `primary` (amber), `treasure` (or), `hostile` (rouge plein)

Composants Flutter à créer :
- `StampButton` : ligne d'action standard (48dp, icon · label · hint mono)
- `StampMenuItem` : entrée de menu Home (56dp, icon · title display · sub mono)

### 4.2 Lanterne diegetic

La lanterne **n'est pas une stat pill** mais un objet visuel ancré flottant sur le coin droit de la scène. 3 états :
- **bright** : halo ambre, icon `lamp_flicker` animée
- **dim** : halo rouge, animation `lamp_pulse_warn` (≤30 tours restants)
- **dark** : éteinte, opacité réduite

Voir `inventory.jsx` → `LampShortcut`.

### 4.3 Incantation contextuelle (DDR-001 Option A)

Le **MagicWordSurface** (`inventory.jsx`) ne s'affiche **JAMAIS** dans la liste d'actions normale. Il est rendu **uniquement si** :
- `Game.magicWordsUnlocked == true` ET
- le lieu courant est un target valide pour le mot

Position : juste avant la liste d'actions (au-dessus), surface dédiée violette avec ornements runiques et icône `magic`.

### 4.4 Surface "papier" vs "encre"

Pour les rendus pixel-art (scènes, sprites d'objets) appliquer `image-rendering: pixelated` (Flutter : `FilterQuality.none` sur Image widgets).

---

## 5. Inventaire des écrans

Le canvas (`index.html`) regroupe **35+ artboards sur 12 sections**. Tous les écrans sont à 360×760 logical (Android-ish), à scaler en runtime.

### 5.1 Design System (1 artboard `ds-spec`)
Documentation de référence (pas à porter en runtime). 9 sections : tokens, type, spacing, icons, components, flashes, gameplay UI, motion, **assets** (dimensions & conventions).

### 5.2 Onboarding (3 artboards) — `onboarding.jsx`
3 cartes de premier lancement :
1. **"Tu n'écris pas, tu choisis"** — illustration : pile de 3 stamps avec halo de tap
2. **"La lanterne est ton souffle"** — illustration : grosse lanterne + les 3 LampShortcut states
3. **"Le carnet retient tout"** — illustration : 3 cartes empilées tournées (Carte, Sauvegardes, Journal)

Shell commun : status bar · hero 320dp · titre + body · footer avec progress dots + CTA stamp.

### 5.3 Home (1 artboard `home-default`) — `screens.jsx > HomeScreen`
Hero pixel-art en plein écran avec halo lanterne, titre OPEN ADVENTURE avec textShadow ambre, sous-titre canon, menu en 5 StampMenuItem (Continuer primary / Nouvelle / Charger / Options / Crédits faded). Footer mono "v1.0.0 · OFFLINE".

### 5.4 Adventure × multiples états — `screens.jsx`, `overflow-actions.jsx`
Le chrome commun (`AdventureChrome`) :
- top bar : menu icon · score pill · turn pill · profondeur pill
- scene 16:9 avec LampShortcut flottant ancré bottom-right (chevauche le titre)
- location header : eyebrow caps amber + titre display
- description body 14px
- flash message optionnel (slide-in)
- liste d'actions (séparée par dashed border) avec eyebrow "QUE FAIRE ?" + compteur d'options
- bottom nav 4 tabs (Sac / Carte / Journal / Menu)

États existants :
- **adv-start** : LOC_START canon — devant le cottage (vraie scène) ✅
- **adv-valley** : LOC_VALLEY — vallée au ruisseau (vraie scène) ✅
- **adv-winding** : LOC_WINDING — corridor sinueux (vraie scène) ✅
- **adv-hall** : exploration calme, primary = nord
- **adv-magic** : XYZZY débloqué (MagicWordSurface visible en tête de liste)
- **adv-lamp** : lampe critique, flash danger, retreat encouragé
- **adv-treasure** : antre du dragon, flash "Trésor découvert", primary = take treasure
- **adv-overflow** : 11 actions disponibles, montre 6 + "Plus d'actions +5" en dashed
- **adv-overflow-sheet** : sheet expandue avec actions groupées par catégorie

### 5.5 Inventaire & objets (3 artboards) — `inventory.jsx`
- **inv-page** : page complète, header + tabs `bag` actif, 7 items groupés en 3 catégories (Outils / Survie / Vivant), capacity meter en bas avec barres pixel. La lanterne utilise la vraie illustration ✅
- **inv-sheet** : Adventure (Fosse Ouest) avec **ItemActionSheet** glissant du bas — bouteille d'eau sélectionnée, 5 verbes
- **inv-lantern** : ItemActionSheet sur la Lanterne en cuivre (vraie illustration cadrée 56×56) avec verbes canon : Éteindre / Examiner / Verser huile / Lâcher

Item sprite : 48×48 cadré (`src` optionnel pour vraies illustrations), tons `default`/`lit`/`treasure`/`danger`/`magic`, prop `glow` pour effet halo.

### 5.6 Carte (1 artboard `map-page`) — `map-page.jsx`
Graphe pixel hand-sketched, 19 nœuds positionnés en 2 zones (Surface vert / Souterrain teal), connexions dashed, annotations italiques façon notes manuscrites, position courante (Hall des Brumes) en halo ambre pulsant, "?" pour zones non explorées. Compass rose + legend en footer.

### 5.7 Rencontres (3 artboards) — `encounters.jsx`
Modales centrées avec scrim sur Adventure :
- **enc-dwarf** : nain hostile (vraie illustration ✅), scrim noir, bordure rouge, 3 actions
- **enc-pirate** : pirate furtif, scrim violet, bordure magic, panneau "OBJETS DÉROBÉS"
- **enc-troll** : troll au pont, bordure rouge, picker de 3 trésors offrables

### 5.8 Dialogues de confirmation (3 artboards) — `dialogs.jsx`
Modales plus légères que les rencontres (pas de big icon) :
- **dlg-delete** : effacer sauvegarde (rouge, hostile)
- **dlg-attack** : attaquer le dragon (rouge, hostile)
- **dlg-quit** : quitter (ambre primary, rappel autosave)

### 5.9 Mort & Obituaire (2 artboards) — `death.jsx`
- **death-1** : 1ère mort avec réincarnation possible
- **death-final** : plus d'incarnation, message canon "les nains convergent en silence"

### 5.10 Fin de partie (1 artboard `end-screen`) — `endgame.jsx`
Score géant 287/430, RankStamp, TreasureTally 15 trésors, bilan détaillé 9 lignes.

### 5.11 Méta (4 artboards) — `journal.jsx`, `saves.jsx`, `settings.jsx`, `credits.jsx`
- **journal** : filter chips, entrées groupées par tour, bordure latérale colorée
- **saves** : autosave primary + 5 slots manuels, storage info
- **settings** : 5 sections (Audio Mixer / Visuel / Langue / A11y / Données)
- **credits** : timeline 50 ans Crowther/Woods/Raymond + Open Adventure Mobile 2026

---

## 6. Iconographie

**~30 pictogrammes pixel-art 16×16** définis dans `pixel-ui.jsx` → `ICONS`. Rendu SVG `<rect>` chunks avec `shapeRendering: crispEdges` + `currentColor`.

Catalogue (voir section 04 du DS) :
- **Navigation** : `north`, `south`, `east`, `west`, `up`, `down`, `back`
- **Interaction** : `take`, `drop`, `lamp`, `lamp_off`, `lamp_dim`, `key`, `bag`, `eye`
- **Objets** : `rod`, `cage`, `bottle`, `food`, `bird`, `gem`, `coin`
- **Méta** : `map`, `book`, `menu`, `gear`, `pin`, `heart`, `plus`, `check`, `close`, `magic`, `speak`, `star`
- **Créatures** : `dwarf`, `troll`, `pirate`

**Pour Flutter** : recréer en sprites PNG/WebP exportés depuis Aseprite OU reproduire avec un `CustomPainter` qui dessine les rect (équivalent du composant React `PixIcon`).

Tailles d'usage standard : 11, 12, 14, 16, 22, 24px.

---

## 7. Motion · 13 keyframes

Source : `motion.css`. **Tous les easings sont `steps()`** — jamais cubic-bezier. Section 08 du DS contient les démos live.

| ID | Nom | Usage | Durée runtime | Easing |
|---|---|---|---|---|
| 01 | `stamp-press` | tap sur stamp button | 240ms | steps(8) |
| 02 | `lamp-flicker` | lanterne idle allumée | 1800ms loop | steps(3) |
| 03 | `lamp-pulse-warn` | lampe ≤30 tours | 1400ms loop | steps(8) |
| 04 | `magic-reveal` | apparition mot magique | 520ms | steps(6) |
| 05 | `magic-pulse` | onde permanente sur surface magic | 2000ms loop | ease-out |
| 06 | `death-tilt` + `death-slash` | lanterne tombe + slash | 3200ms one-shot | steps(8) |
| 07 | `flash-slide-in` | flash banner en haut de liste | 320ms | steps(8) |
| 08 | `sheet-slide-up` | bottom sheet | 280ms | steps(8) |
| 09 | `sparkle` | éclats sur trésor découvert | 1600ms loop | steps(8) |
| 10 | `score-pop` | +N pts qui flotte | 2000ms one-shot | steps(8) |
| 11 | `tap-halo` | onde concentrique | 1400ms one-shot | steps(6) |
| 12 | `dot-blink` | indicateur tour actif (journal) | 1000ms loop | steps(2) |

**`prefers-reduced-motion`** respecté — toutes animations désactivées.

Pour Flutter : `AnimationController` avec curve custom qui clampe à N marches.

---

## 8. Architecture des fichiers source (référence)

```
tokens.css              ← TOUS les design tokens (port → theme.dart)
motion.css              ← keyframes + classes utilitaires

pixel-ui.jsx            ← atomes : Icon, ScenePlaceholder (avec prop src),
                          FakeStatusBar, Pill, CornerBrackets, PixelDivider,
                          FlashMessage
action-buttons.jsx      ← StampButton, StampMenuItem, BottomNav, STAMP_TONES
inventory.jsx           ← LampShortcut, MagicWordSurface, ItemSprite (avec
                          prop src), ItemCard, InventoryPage, ItemActionSheet
screens.jsx             ← PhoneShell, HomeScreen, AdventureChrome + 8 états
                          (start, valley, winding, hall, magic, lamp, treasure,
                          item-sheet, lantern-sheet)
map-page.jsx            ← MapPage, MapNode, MapEdge, MapNote
endgame.jsx             ← EndGamePage, ScoreRow, TreasureTally, RankStamp
journal.jsx             ← JournalPage, JournalEntry, FilterChip
saves.jsx               ← SavesPage, SaveSlot, MiniScene
settings.jsx            ← SettingsPage, PixSlider, PixToggle, PixSegment
credits.jsx             ← CreditsPage, LineageCard
onboarding.jsx          ← Onboarding1/2/3, OnboardingShell
death.jsx               ← DeathPage, DeathPageFinal, FallenLantern
encounters.jsx          ← EncounterModal (avec prop iconSrc), DwarfEncounter,
                          PirateSteal, TrollBridge
overflow-actions.jsx    ← AdventureOverflow, AdventureOverflowSheet
dialogs.jsx             ← ConfirmDialog + 3 examples

design-system.jsx       ← documentation visuelle (DS spec) — pas à porter
motion-spec.jsx         ← documentation motion (12 démos live) — pas à porter
design-canvas.jsx       ← starter component du canvas — pas à porter

index.html              ← assemblage final, sections + artboards

scenes/                 ← scènes pixel-art (vraies illustrations livrées)
  loc_start.png         ← LOC_START — devant le cottage (320×180)
  loc_valley.png        ← LOC_VALLEY — vallée au ruisseau
  loc_winding.png       ← LOC_WINDING — corridor sinueux
objects/                ← sprites d'objets canon
  lantern.png           ← Lanterne en cuivre (512×512 PNG)
creatures/              ← portraits de créatures pour encounters
  dwarf.png             ← Nain hostile (768×768 PNG)

docs/                   ← design vivants (à lire AVANT de coder)
  design.md             ← racine — vision, architecture, 9 ADRs cross-cutting
  features/
    README.md           ← index + template
    adventure.md        ← feature centrale (la plus dense)
    inventory.md        ← contraintes ressources canon
    saves.md            ← persistence + autosave
    settings.md         ← preferences
```

---

## 9. Assets — production guide

Voir section **09 — Assets** dans le DS pour la spec complète avec previews. Résumé :

| Tier | Type | Master | Affichage | Format | Poids | Naming |
|---|---|---|---|---|---|---|
| 1 | Objets | 512×512 | 48/56/64px | PNG transparent | 30-80 KB | `objects/<id>.png` |
| 2 | Créatures | 768×768 (ou 1024) | 64-128px | PNG transparent | 80-150 KB | `creatures/<id>.png` |
| 3 | Scènes | 320×180 (pixel-art natif) | full-bleed (~360×202) | WebP lossy q80 | 20-60 KB | `scenes/<loc_id>.webp` |

**Toutes les images** sont en **carré 1:1** (objets/créatures) ou **16:9** (scènes), **fond transparent** pour permettre au cadre `ItemSprite` de fournir la couleur de fond contextuelle.

### 9.1 Catalogue cible

**Scènes** (10+, dont 3 livrées) : `loc_start` ✅, `loc_valley` ✅, `loc_winding` ✅, `loc_hall_of_mists`, `loc_cottage`, `loc_dragon_lair`, `loc_dark_passage`, `loc_west_pit`, `loc_east_pit`, `loc_maze_twisty`, `loc_troll_bridge`, `loc_king_hall`…

**Objets transportables** (7) : `lantern` ✅, `keys`, `rod`, `cage`, `bottle`, `food`, `bird`

**Trésors** (15) : `nugget`, `diamonds`, `silver`, `jewels`, `coins`, `emerald`, `pyramid`, `pearl`, `vase`, `ruby`, `rug`, `trident`, `eggs`, `chain`, `chest`

**Créatures** (5) : `dwarf` ✅, `troll`, `pirate`, `dragon`, `bird` (variante créature pour bestiary)

### 9.2 BGM par zone (boucle gapless)

Voir `settings.jsx > ZoneChip` : Surface 30s · Grotte 48s · Rivière 42s · Sanctuaire 60s · Danger 22s.

### 9.3 SFX one-shots
Tap stamp, prendre, lâcher, allumer/éteindre lampe, alerte nain, sparkle trésor, mort.

---

## 10. Stratégie d'implémentation recommandée

1. **Theme & tokens d'abord** — porter `tokens.css` en `lib/core/theme/oa_colors.dart` + `oa_typography.dart` + `oa_spacing.dart`. Wrapper Flutter `ThemeData` + `extension OAColors` accessibles via `Theme.of(context).extension<OAColors>()`.
2. **Composants atomiques** dans cet ordre :
   `OAStamp` → `OAPill` → `OACornerBrackets` → `OAPixelDivider` → `OAFlashMessage` → `OAIcon` (custom painter pour les 30 pictogrammes ou export PNG via Aseprite)
3. **Composants gameplay** : `OALampShortcut` (state machine bright/dim/dark) → `OAMagicWordSurface` → `OAItemSprite` (avec support `src` image OU `icon` pictogramme) → `OAItemCard` → `OAStampMenuItem`
4. **Chrome** : `OAAdventureChrome` + `OABottomNav` + `OAPhoneShell` (si scaling needed)
5. **Écrans** : Home → Adventure → Inventory → Map → Journal → Saves → Settings → Credits → EndGame → Death → Onboarding
6. **Motion** : implémenter les 13 animations dans `lib/core/motion/`, exposer en `extension OAAnimations on AnimationController`
7. **Encounters & dialogs** en dernier, par-dessus le reste

---

## 11. Points d'attention spécifiques

- **Pas d'inline-style hardcodé** : tout passe par le theme extension. Les hex visibles dans les `.jsx` viennent tous de `tokens.css` (déjà mappés en variables) — pas d'exception.
- **`textWrap: pretty`** sur les descriptions longues — Flutter équivalent : `Text` avec `softWrap: true`.
- **Status bar** : la `FakeStatusBar` est juste une maquette. En vrai, utiliser `SystemUiOverlayStyle` pour matcher l'inkVoid background.
- **Bottom nav** : badge `marginTop: -2` simule le top border ambre sur tab active — adapter en Flutter avec `Container border`.
- **Item sheet & overflow sheet** : utiliser `showModalBottomSheet` avec `isScrollControlled: true` et un custom shape sans rounded corners.
- **Direction lecture** : tous les libellés sont en français, mais le système supporte FR/EN — prévoir `.arb` files dans `lib/l10n/`.

---

## 12. Licence

Code et données dérivés d'**Open Adventure 2.5** (Eric S. Raymond) sous **BSD 2-clauses**. Aucune télémétrie, aucun trésor pris. Ce design system est livré sans licence séparée — utiliser comme bon te semble dans le contexte du projet Open Adventure Mobile.
