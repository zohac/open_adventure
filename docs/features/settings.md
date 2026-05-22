# Feature · Settings

> Préférences utilisateur : audio, affichage, langue, accessibilité, données.

**Owner :** @jouan · **Status :** v0.1 · **Updated :** 2026-05-20
**Voir aussi :** [root](../design.md), [saves](./saves.md)

---

## 1. Goal

- Laisser le joueur **ajuster** l'expérience à ses préférences
- **Persister** les choix entre sessions
- **Respecter** les conventions OS (a11y, motion, locale par défaut)

**Non-goals :**
- Pas de presets ("Mode arcade / Mode confort") — un seul jeu de réglages
- Pas de profils multiples
- Pas de configuration de gameplay (difficulté, hints) — c'est canon = canon

---

## 2. User stories

| As a | I want to | So that |
|---|---|---|
| Joueur en transports | Réduire le BGM pour entendre les annonces | Je n'embête pas mes voisins |
| Joueur avec petites mains | Augmenter la taille du texte | Je lise sans plisser les yeux |
| Joueur anglophone | Switcher en EN | Je profite du texte canon original |
| Joueur épileptie-sensible | Désactiver le halo pulsant | Je joue sans déclencher |
| Joueur paranoïaque | Effacer tout | Je quitte sans laisser de trace |

---

## 3. Sections (l'ordre est important)

### 3.1 Audio · Mixeur sonore
- **PixSlider** BGM (0-100%) avec ticks tous les 10
- **PixSlider** SFX (0-100%) avec ticks
- **PixToggle** "Couper le son" (master mute)
- **Zone preview** : 5 ZoneChip cliquables (Surface / Grotte / Rivière / Sanctuaire / Danger) avec durée loop. Tap → 4s de preview à volume actuel.

### 3.2 Visuel · Affichage
- **PixSegment** Taille du texte : S / M / L (impacte body 13/15/17 → 14/16/18 → 15/17/19)
- **PixToggle** "Police pixel partout" — bascule body en Pixelify, sacrifice de lisibilité
- **PixToggle** "VFX overlays" (halos, sparkle, brume)
- **PixToggle** "Halo de lanterne dynamique" — pour épileptie

### 3.3 Langue
- **PixSegment** FR / EN

### 3.4 Accessibilité
- **PixToggle** "Contrastes élevés" — renforce bordures et texte
- **PixToggle** "Confirmer chaque action" — pop un mini-confirm avant chaque tap stamp critique

### 3.5 Données
- **Row chevron** "Exporter une sauvegarde" → file picker save
- **Row chevron rouge** "Effacer toutes les sauvegardes" → ConfirmDialog destructive

---

## 4. State

```dart
class OASettings {
  final int version;
  final AudioSettings audio;
  final DisplaySettings display;
  final Locale locale;
  final A11ySettings a11y;
}

class AudioSettings {
  final double bgmVolume;     // 0.0 - 1.0
  final double sfxVolume;
  final bool muted;
}

class DisplaySettings {
  final TextSize textSize;    // s | m | l
  final bool pixelFontEverywhere;
  final bool vfx;
  final bool lampHalo;
}

class A11ySettings {
  final bool highContrast;
  final bool confirmEachAction;
  final bool reduceMotion;    // miroir de MediaQuery.disableAnimations
}
```

Provider : `settingsProvider` (StateNotifierProvider). Persistance dans `shared_preferences` (small, fast, sync).

---

## 5. Behavior

### 5.1 Defaults (au premier lancement)
- BGM 60%, SFX 100%, muted false
- TextSize M, pixelFontEverywhere false, vfx true, lampHalo true
- Locale = **OS default** si FR ou EN, sinon EN
- A11y : tout false sauf si MediaQuery indique sinon (reduceMotion, highContrast)

### 5.2 Lecture OS settings
- `MediaQuery.disableAnimations` → si true au cold-start, set `reduceMotion = true` (mais respecte un override user manuel)
- `MediaQuery.boldText` → bump textSize by 1 si user n'a pas explicitement choisi

### 5.3 Toggle vs apply
- **Tout est instantané.** Un slider qui bouge → audio update live. Pas de bouton "Appliquer".
- Sauf locale : appliquer demande un rebuild du widget tree → faire à la fin via `MaterialApp.locale`. Confirmer avec flash "Langue changée".

### 5.4 Effacer toutes les sauvegardes
- ConfirmDialog double : 1ère "Effacer toutes les sauvegardes ?" → 2ème "Vraiment ? Cette action est irréversible." → wipe `saves/` directory.
- Settings restent.

---

## 6. Décisions feature-spécifiques

### ADR-SET-001 · 3 crans de textSize uniquement
**Décidé.** S/M/L, pas un slider continu.
**Pourquoi :** simple, prévisible, et les 3 crans couvrent 90% des besoins. Si un user veut > L, c'est qu'il a besoin de vrais a11y tools OS.

### ADR-SET-002 · BGM par zone, pas par état
**Décidé.** Le BGM change quand on **change de zone géographique** (Surface → Grotte), pas quand on entre dans une rencontre.
**Pourquoi :** ADR-001 root (immersion). Le "danger loop" est l'exception : il joue par-dessus en duck rapide quand un nain rôde.
**Tradeoff :** moins dramatique qu'un système full event-driven. Acceptable pour v1.

### ADR-SET-003 · Locale auto-detect sans demander
**Décidé.** Au cold-start, on prend l'OS locale. Pas de modal "Quelle langue ?".
**Pourquoi :** réduit la friction d'entrée. Le joueur peut switcher en 2 taps après si besoin.

### ADR-SET-004 · "Confirmer chaque action" pour les seniors
**Décidé.** Toggle a11y dédié.
**Pourquoi :** notre public "le nostalgique" (cf root §2) inclut des 60+ ans qui peuvent tap par accident. Ce toggle pop un mini "Êtes-vous sûr ?" avant chaque action destructive ou navigation hostile.

### ADR-SET-005 · Pas de réglages gameplay
**Décidé.** Aucune option "difficulté", "hints toujours visibles", "lampe infinie", etc.
**Pourquoi :** trahit le canon. Si tu veux un mode facile, tu joues une autre app.

---

## 7. Tests

### Repository
- Read defaults au premier lancement
- Write + reload → values équivalentes
- Migration v1 → v2 (si version change) sans perte

### Widget
- Slider BGM → audio service `setBgmVolume` appelé
- Toggle reduceMotion true → AnimationController dans Adventure ne run pas
- Locale switch → `intl` rebuild, toute string change
- Effacer saves → 2 confirms, puis directory vide

---

## 8. Open questions

- **OQ-SET-1 :** afficher un **preview** de la taille de texte avant d'appliquer ? L'utilisateur sent immédiatement le diff sur les autres screens, donc non.
- **OQ-SET-2 :** export full backup (saves + settings) en un zip ? Tentant. Post-v1.
- **OQ-SET-3 :** dark mode "ambient" qui suit l'heure ? Non, on est dark only (ADR-003 root).
- **OQ-SET-4 :** vibration haptique master toggle ? Add when haptic shipped.

---

## 9. Out of scope (v1)

- Multi-profile
- Cloud sync de settings
- Themes (couleurs custom)
- Difficulty presets
- Custom keybinds (pas de clavier, donc N/A)
