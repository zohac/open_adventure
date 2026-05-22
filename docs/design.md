# Open Adventure Mobile — Design

> Document vivant. Capture le **quoi** et le **pourquoi** de l'application — pas le **comment** (code).
> À lire avant toute session de dev. Mettre à jour quand une décision est révisée.

**Owner :** @jouan · **Status :** v0.3 · pre-implementation · **Updated :** 2026-05-22

> **Source unique de design.** Supersede `docs/VISUAL_STYLE_GUIDE.md`, `docs/UX_SCREENS.md`, `docs/DESIGN_ADDENDUM.md` (conservés pour historique).
> Spec d'écran détaillée : `docs/features/*.md` + mockups dans `design_handoff_open_adventure/`.

---

## 1. Vision & Goal

> *Faire vivre l'expérience canonique de Colossal Cave Adventure en 2026, sur mobile, avec la patine d'un carnet d'explorateur 16-bit — sans jamais trahir le texte original.*

**On veut :**
- Fidélité gameplay 100% au canon **Open Adventure 2.5** (Eric S. Raymond) — 430 pts, 15 trésors, mots magiques, nain/pirate/troll, mort + réincarnation.
- Interface **tactile sans clavier**, accessible à un joueur qui n'a jamais touché à un parser game.
- Direction artistique **pulpe rétro pixel-art** : encre profonde de grotte, lanterne ambre comme signature lumineuse, papier vieilli pour le texte.
- **100% offline.** Pas de compte, pas de télémétrie, pas de réseau.
- Bilingue **FR / EN**, le texte EN étant la source canon, FR une traduction soignée.

**Non-goals (v1) :**
- Multijoueur, leaderboards, cloud saves.
- Mode "parser" texte libre — le jeu est entièrement boutons contextuels.
- Adaptation tablette / desktop — mobile-first, sera responsive plus tard.
- Génération procédurale ou lieux additionnels — strict canon Open Adventure 2.5.
- Monétisation. Free, BSD 2-clauses.

---

## 2. Public visé

| Persona | Description | Besoins clés |
|---|---|---|
| **Le nostalgique** | A joué Adventure sur PDP/Apple ][/PC en son temps. ~45-65 ans. | Fidélité absolue · ne pas dénaturer · références canon |
| **L'explorateur curieux** | Découvre les IF par podcasts/culture geek. 25-45 ans. | Accessibilité · pas besoin de savoir taper "GO NORTH" · onboarding clair |
| **Le complétionniste** | Cherche à scorer 430/430. Joueur de roguelikes. | Système de score lisible · journal complet · saves multiples |

Ce qu'on **ne cherche pas** : casuals mobile habitués aux match-3, joueurs cherchant action temps réel.

---

## 3. Architecture haut niveau

### 3.1 Stack

- **Flutter 3.35+ · Dart 3** — UI + state + persistence en un seul codebase iOS/Android.
- **Riverpod 2** — state management. Pas de Bloc, pas d'Inherited brute.
- **GoRouter** — navigation déclarative.
- **`just_audio`** + **`audio_session`** — BGM par zone (gapless looping) + SFX + ducking iOS/Android. Préchargé.
- **`shared_preferences`** + JSON manuel — persistence locale. Pas de SQLite.
- **`flutter_localizations` + ARB** — i18n FR/EN.

### 3.2 Clean Architecture (3 couches)

```
lib/
├── core/                  ← infrastructure transverse
│   ├── theme/             ← OAColors, OATypography, OASpacing (ports tokens.css)
│   ├── motion/            ← OAAnimations extension, curves stepN
│   ├── widgets/           ← OAStamp, OAPill, OAIcon, OASceneFrame, OAItemSprite…
│   └── utils/
├── data/                  ← persistence + sources
│   ├── adventure_data/    ← JSON canon (locations, objects, hints…)
│   ├── repositories/      ← SavesRepository, SettingsRepository
│   └── sources/           ← LocalStorageSource, AssetSource
├── domain/                ← gameplay pur, framework-agnostic
│   ├── entities/          ← Location, Object, GameState, Player
│   ├── usecases/          ← MoveTo, TakeObject, UseMagicWord, ListAvailableActions
│   └── services/          ← ActionRanker, ScoreCalculator, LampTimer
├── features/              ← UI par écran (Riverpod + widgets)
│                          (cible Epic 5 ; jusqu'à migration : lib/presentation/)
│   ├── home/
│   ├── onboarding/
│   ├── adventure/         ← l'écran de jeu principal
│   ├── inventory/
│   ├── map/
│   ├── journal/
│   ├── saves/
│   ├── settings/
│   ├── credits/
│   ├── endgame/
│   └── death/
├── assets/                ← assets statiques
│   ├── scenes/            ← <loc_id>.webp 320×180
│   ├── objects/           ← <object_id>.png 512×512 transparent
│   ├── creatures/         ← <creature_id>.png 768×768 transparent
│   ├── fonts/
│   └── audio/
└── main.dart              ← entry point + Riverpod scope
```

**Règle dure :** `domain/` n'importe **rien** de `data/` ni `features/`. C'est testable en isolation, et c'est ce qui garantit la fidélité canon via les tests d'oracle.

### 3.3 Domain ↔ UI

Le `domain/` est un **moteur déterministe** :
- Entrée : `GameState` + `Action`
- Sortie : nouveau `GameState` + `List<Message>` (canon)

L'UI **n'interprète pas** le jeu — elle **affiche** ce que le domain produit. Aucune logique de gameplay dans `features/`.

```
              ┌────────────────────┐
   Tap stamp  │   features/adv     │  flash messages, scene
   ────────►  │   AdventureNotifier│ ◄──────────────
              └────────┬───────────┘
                       │ dispatches Action
                       ▼
              ┌────────────────────┐
              │   domain/usecases  │
              │   GameEngine       │
              └────────┬───────────┘
                       │ new state
                       ▼
              ┌────────────────────┐
              │   data/saves       │
              │   autosave         │
              └────────────────────┘
```

---

## 4. Décisions transverses (ADRs inline)

### ADR-001 · UI tactile par boutons contextuels (pas de parser)
**Décidé.** Le canon original est un parser texte. On le remplace par **3 à 7 boutons contextuels par tour**, classés par priorité (Sécurité → Navigation → Interactions → Méta). Le bouton recommandé est en `primary` (ambre filled).
**Pourquoi :** sans clavier, le parser est inutilisable. Le canon des actions reste accessible via `domain/usecases/ListAvailableActions`.
**Rejeté :** input texte libre (frustrant sur mobile), drag-and-drop d'objets (peu de jeu pour ça), voice commands (offline-only contredit Speech).

### ADR-002 · DDR-001 Option A · les mots magiques sont contextuels
**Décidé.** Un mot magique (XYZZY, PLUGH, PLOVER) **n'apparaît jamais dans `ListAvailableActions`**. Il s'affiche dans une `MagicWordSurface` séparée, **uniquement si** :
- `Game.magicWordsUnlocked == true` (le joueur a vu l'oiseau le souffler), ET
- la `currentLocation` est un target valide pour `word`.

**Pourquoi :** dans le canon parser, ces mots sont des easter eggs qu'il faut connaître. Les exposer en bouton les banalise et trahit le mystère. La surface dédiée les valorise tout en restant utilisable.
**Rejeté :** bouton standard "Prononcer XYZZY" (trop facile).

### ADR-003 · Dark mode only
**Décidé.** Pas de light mode. L'aventure est spéléologique : on joue à la lampe.
**Pourquoi :** la palette repose sur le contraste encre profonde × halo ambre. Light mode dénaturerait la signature visuelle.
**Rejeté :** light mode "cottage" pour la surface — discuté plus tard si pertinent, hors v1.

### ADR-004 · Pixel-art chrome, sans-serif body
**Décidé.** Chrome UI (titres, boutons, status) en `Pixelify Sans` + `Silkscreen`. Descriptions et journal en `DM Sans`.
**Pourquoi :** une aventure textuelle reste lisible long-form en sans-serif humaniste. Tout pixel font dégrade la lecture. L'option "Police pixel partout" est exposée en Settings pour les puristes.

### ADR-005 · Sauvegardes JSON locales, pas SQLite
**Décidé.** Chaque save = un fichier JSON dans `getApplicationDocumentsDirectory()/saves/`. Autosave dans `autosave.json`, slots manuels en `slot_N.json`.
**Pourquoi :** simple, debuggable, exportable. L'état de jeu est < 50 KB. Pas besoin d'index, pas de requêtes.
**Rejeté :** SQLite (overkill), `shared_preferences` seul (taille limite, pas d'export).

### ADR-006 · Pas d'animation cubic-bezier, que des `steps()`
**Décidé.** Toutes les animations utilisent un easing en marches discrètes (`Curves.stepN(N)` custom).
**Pourquoi :** préserve le ressenti 16-bit. Un fade fluide casse la grammaire pixel.

### ADR-007 · Oracle C pour les tests de fidélité
**Décidé.** Le repo Open Adventure 2.5 (C) sert d'**oracle**. Pour chaque scénario testable, on enregistre la séquence de commandes + l'output canon, puis on vérifie que notre `GameEngine` produit la même chose.
**Pourquoi :** la fidélité est la valeur n°1. Sans oracle, on dérive.

### ADR-008 · i18n via ARB, EN canonique
**Décidé.** Tout texte affichable passe par `AppLocalizations`. Le fichier EN reproduit le wording original Crowther/Woods/Raymond mot pour mot (où c'est légalement permis). Le FR est une traduction littéraire fidèle, pas un calque.

### ADR-009 · Pas de scrollIntoView ni de gestures complexes
**Décidé.** Navigation = onglets bottom nav + back. Pas de swipe-to-go-back, pas de pull-to-refresh.
**Pourquoi :** simplicité, accessibilité, et alignement avec l'esthétique "carnet posé".

### ADR-010 · Assets carré 1:1, fond transparent, 3 tiers de tailles master
**Décidé.** Tous les objets et créatures en **carré 1:1 PNG transparent**. Tier 1 objets = 512×512, Tier 2 créatures = 768×768. Scènes en **16:9 320×180 pixel-art natif WebP**. Flutter downscale avec `FilterQuality.none` au runtime.
**Pourquoi :** un seul master par image (pas de @2x/@3x à maintenir), grille uniforme dans l'inventaire, le cadre `OAItemSprite` fournit la couleur de fond selon le tone contextuel.
**Rejeté :** fond gris hardcodé dans l'image (perte de cohérence), variantes multiples par taille (overkill).

---

## 5. State management — convention Riverpod

### 5.1 Forme des providers

```dart
// Domain state (single source of truth pour gameplay)
final gameStateProvider = StateNotifierProvider<GameNotifier, GameState>(...);

// Feature view-models — dérivent de gameStateProvider
final adventureViewModelProvider = Provider<AdventureViewModel>((ref) {
  final game = ref.watch(gameStateProvider);
  return AdventureViewModel.from(game);
});

// Settings, theme — séparés, persistés
final settingsProvider = StateNotifierProvider<SettingsNotifier, OASettings>(...);
```

### 5.2 Règles

- **Un seul `gameStateProvider`** pour l'état de jeu. Tous les écrans dérivent.
- **Pas de Riverpod dans `domain/`** — c'est `features/` qui wrap.
- **`StateNotifier` > `Notifier`** v2 pour cette codebase — plus mature, on bumpera si besoin.
- **Family providers** pour les écrans paramétrés (ex: `inventoryItemProvider.family(itemId)`).

---

## 6. Navigation (GoRouter)

```
/                           → HomeScreen
/onboarding/:step           → OnboardingScreen (step ∈ 1..3)
/adventure                  → AdventureScreen (récupère gameStateProvider)
/adventure/inventory        → InventoryScreen (tab)
/adventure/map              → MapScreen (tab)
/adventure/journal          → JournalScreen (tab)
/adventure/menu             → MenuScreen (tab — settings, quit)
/adventure/item/:itemId     → ItemActionSheet (modal route)
/saves                      → SavesScreen
/settings                   → SettingsScreen
/credits                    → CreditsScreen
/death                      → DeathScreen (replace history)
/end                        → EndGameScreen
```

**Modal routes** (push above current) : encounters (dwarf/pirate/troll), confirmation dialogs.
**Replace** : transitions vers `/death` et `/end` — pas de back.

---

## 7. Persistence — schéma JSON

### 7.1 GameState (save file)

```jsonc
{
  "version": 1,
  "savedAt": "2026-05-19T21:47:12Z",
  "playerId": "uuid",
  "currentLocation": "hall_of_mists",
  "turn": 47,
  "score": 23,
  "lamp": {
    "lit": true,
    "turnsRemaining": 285,
    "oilUses": 0
  },
  "inventory": ["lamp", "bottle_water", "keys", "rod"],
  "magicWordsUnlocked": ["xyzzy"],
  "treasuresCollected": ["nugget", "diamonds"],
  "treasuresDeposited": [],
  "encounters": {
    "dwarvesKilled": 0,
    "pirateMet": false,
    "trollPayment": null
  },
  "journal": [
    { "turn": 47, "ts": "...", "category": "discovery", "text": "..." }
  ],
  "hintsConsulted": ["maze_twisty"],
  "incarnationsLeft": 3
}
```

### 7.2 Settings

```jsonc
{
  "version": 1,
  "audio": { "bgmVolume": 0.6, "sfxVolume": 1.0, "muted": false },
  "display": { "textSize": "m", "pixelFontEverywhere": false, "vfx": true, "lampHalo": true },
  "locale": "fr",
  "a11y": { "highContrast": false, "reduceMotion": false, "confirmEachAction": false }
}
```

---

## 8. Audio strategy

5 zones BGM, boucle gapless, crossfade 250-500ms :
- `surface_loop.ogg` (30s) — forêt, cottage
- `cave_loop.ogg` (48s) — souterrain neutre
- `river_loop.ogg` (42s) — proximité rivière souterraine
- `sanctuary_loop.ogg` (60s) — Y2, hall of mists
- `danger_loop.ogg` (22s) — proche nain, lampe critique, dragon

SFX one-shots : tap stamp, take, drop, lamp on/off, dwarf alert, treasure sparkle, magic word, death.

**Audio session** : ducking sur appels (`AudioSessionCategory.ambient` iOS, équivalent Android).

---

## 9. Cross-cutting concerns

### 9.1 Accessibility
- Tap targets ≥ 44dp (déjà tokenisé `--hit-min`).
- `prefers-reduced-motion` → disable toutes les animations (déjà géré dans `motion.css`, à porter Flutter via `MediaQuery.disableAnimations`).
- TalkBack/VoiceOver labels sur **chaque** stamp et icon.
- Contraste WCAG AA minimum (vérifier `paper-faded` sur `ink-deep`).

### 9.2 Performance
- Scenes 320×180 WebP < 30 KB chacune. Préchargées par zone.
- BGM loops < 200 KB en OGG Vorbis q4.
- Animations sur GPU (transforms, opacity uniquement).
- Pas de rebuild du `AdventureChrome` complet sur tap — utiliser `Consumer` ciblés.

### 9.3 Tests
- **Domain :** 100% coverage, tests d'oracle contre Open Adventure 2.5 C.
- **Data :** repository contracts + golden JSON.
- **Features :** widget tests sur les états-clés (adventure-magic, lamp-critical, encounter, dialog).
- **Pas de tests E2E** — trop coûteux pour le ratio.

### 9.4 Error handling
Le jeu lui-même ne peut **pas** échouer (état déterministe). Les seules erreurs possibles :
- Save corruption → afficher un dialog "Sauvegarde illisible", proposer reset.
- Asset manquant → fallback placeholder + log.
- Pas de réseau, pas d'erreur réseau.

---

## 10. Glossaire

| Terme | Sens |
|---|---|
| **Canon** | Le texte/comportement exact d'Open Adventure 2.5 (Raymond). Source de vérité absolue. |
| **Stamp** | Le composant bouton commun à tout le système (cf. `core/widgets/oa_stamp.dart`). |
| **Tour** | Une action du joueur. Incrémente le compteur, déclenche autosave, peut diminuer la lampe. |
| **Incantation** | Un mot magique (XYZZY, PLUGH, PLOVER, FEE/FIE/FOE/FOO). |
| **Trésor** | Objet à valeur de score (15 au total). +N à la prise, +M au dépôt dans le cottage. |
| **Lampe** | L'objet le plus important du jeu — sans elle, l'obscurité tue. Diminue chaque tour. |
| **Oracle** | Le binaire C d'Open Adventure 2.5 qu'on utilise comme source de vérité pour les tests. |

---

## 11. Roadmap implémentation

1. **Theme + core widgets** (semaine 1) — port tokens, atomes (Stamp, Pill, Icon, etc.)
2. **Domain** (semaine 2-3) — entities, usecases, GameEngine, ScoreCalculator. Tests oracle EN.
3. **Adventure screen + state** (semaine 4-5) — chrome, action list, lamp, magic word surface.
4. **Inventory + Map + Journal** (semaine 6)
5. **Saves + Settings** (semaine 7)
6. **Onboarding + Home + Credits** (semaine 8)
7. **Encounters + Death + End game** (semaine 9)
8. **Motion polish + audio** (semaine 10)
9. **A11y audit + perf + i18n FR final** (semaine 11)
10. **Beta interne + corrections** (semaine 12)

---

## 12. Open questions

- **OQ-1 :** strategy d'undo ? Le canon ne permet pas d'undo. Mais l'autosave par tour ouvre la porte à un "load last turn". Décider : pas d'undo, ou undo de 1 tour max.
- **OQ-2 :** dark room mechanic — quand la lampe meurt et qu'on bouge à l'aveugle, le joueur peut tomber dans une fosse (canon). Comment représenter visuellement ? Écran noir + 1 ou 2 stamps seulement ? Vérifier UX.
- **OQ-3 :** vault / closing of the cave — fin canonique avec timer interne (1000 tours). Le compteur doit-il être visible ? Aucun indice ? Probablement caché.
- **OQ-4 :** vibration haptique sur tap stamp ? À tester, pas dans v1 par défaut.

---

## 13. Références

- Spec design visuelle : `../README.md`
- Maquettes interactives : `../index.html`
- Source canon : https://gitlab.com/esr/open-adventure
- Per-feature designs : `./features/*.md`
