# Feature · Adventure (game screen)

> L'écran principal. Tout ce que voit le joueur en boucle pendant qu'il joue.

**Owner :** @jouan · **Status :** v0.1 · **Updated :** 2026-05-20
**Voir aussi :** [root design](../design.md), [inventory](./inventory.md)

---

## 1. Goal

Permettre au joueur d'**avancer dans l'aventure tour par tour** :
- Lire la situation (scène + texte de description)
- Choisir une action parmi 3-7 propositions contextuelles
- Voir le résultat immédiat (flash message + update scène/state)

**C'est l'écran le plus chargé sémantiquement** : il doit accueillir la lanterne, l'incantation, les pills de status, les flash messages, parfois une rencontre modale, et toujours rester lisible.

**Non-goals :**
- Pas de parser. Pas de mode "tape ta commande".
- Pas d'overlay tutorial après la première partie.
- Pas d'undo (cf. OQ-1 root design).

---

## 2. User stories

| As a | I want to | So that |
|---|---|---|
| Joueur en exploration | Voir où je suis et où je peux aller | Je ne me perde pas |
| Joueur prudent | Voir l'état de ma lampe à tout moment | Je sache quand rebrousser chemin |
| Joueur curieux | Examiner les objets/lieux sans les ramasser | Je découvre le texte canon |
| Joueur qui a appris XYZZY | Pouvoir le prononcer dans un lieu valide | Je profite du shortcut magique |
| Joueur sur le point de mourir | Voir un avertissement clair avant l'action fatale | Je puisse choisir en connaissance de cause |

---

## 3. Anatomie de l'écran

```
┌────────────────────────────┐
│  status bar (faux)         │
├────────────────────────────┤
│  ⊕  💰023  T.047  📍Prof.II│  ← top bar
├────────────────────────────┤
│                            │
│        SCENE 16:9          │
│       (pixel-art)          │
│                       🏮 ◄─┼─ LampShortcut flottant (ancré)
├────────────────────────────┤
│  ◆ Souterrain · Prof. II   │  ← eyebrow caps
│  HALL DES BRUMES           │  ← display L
│                            │
│  Tu te tiens dans…         │  ← body
├────────────────────────────┤
│  ⚠  Flash message          │  ← optional, slide-in
├────────────────────────────┤
│  QUE FAIRE ?       5 OPT.  │  ← section header
│  ┌──────────────────────┐  │
│  │ ✦ MagicWordSurface   │  │  ← only if conditions met
│  └──────────────────────┘  │
│  [▲ Aller au nord     N ] │  ← primary stamp
│  [▶ Aller à l'est     E ] │
│  [▼ Descendre      DOWN] │
│  […]                       │
├────────────────────────────┤
│  Sac · Carte · Journal · …│  ← bottom nav
└────────────────────────────┘
```

### 3.1 Top bar
3 pills max + bouton menu :
- Score (treasure tone, ex. `023`)
- Tour (default, ex. `T.047`)
- Profondeur courante (default avec icon `pin`)
- Bouton menu (32×32, icon `menu`, ouvre `/adventure/menu`)

La lanterne **n'est pas dans la top bar** — elle est diegetic sous la scène.

### 3.2 Scene
- 16:9, ~360×202 logique
- Pixel-art `image-rendering: pixelated` / `FilterQuality.none`
- Halo lanterne radial superposé si `lamp.lit && lamp.state == bright`
- LampShortcut ancré `bottom: -22dp, right: 12dp` (chevauche la marge titre — c'est volontaire)
- Asset : `assets/scenes/<loc_id>.webp` (320×180 master)

### 3.3 Description body
`DM Sans 14px / 1.5 / paper-warm`. Multi-paragraphes possibles. Le texte vient **directement du domain** (canon). On ne le réécrit jamais en UI.

### 3.4 Flash message (optionnel)
Apparait au-dessus de la liste d'actions quand le dernier tour a produit un message canon notable. Slide-in 320ms. Persistance : reste à l'écran jusqu'au prochain tour (pas de timer). Tap = dismiss manuel.

### 3.5 Action list
- Header : "QUE FAIRE ?" + compteur d'options
- **MagicWordSurface** (si conditions ADR-002), en première position, distinct visuellement
- Liste de **3 à 7 stamps**. Si > 7 : afficher 6 + "Plus d'actions +N" qui ouvre un bottom sheet par catégorie
- Stamps classés par priorité : Sécurité (1) → Navigation (2) → Interactions (3) → Méta (4)
- Le **premier** stamp (le plus prioritaire) est en `primary` (filled ambre)

### 3.6 Bottom nav
4 tabs : Sac · Carte · Journal · Menu. Active highlight ambre top-border + tint amber.

---

## 4. State

```dart
class AdventureViewModel {
  final Location current;         // scene, description, available exits
  final List<RankedAction> actions; // already sorted, ≤ 7 visible
  final List<RankedAction> overflow; // si > 7
  final LampState lamp;           // bright | dim | dark + turns
  final MagicWord? availableMagic; // null si conditions ADR-002 pas réunies
  final FlashMessage? flash;       // dernier message canon
  final int score, turn;
  final Depth depth;
}
```

`ListAvailableActions(GameState)` est un **usecase pur** dans `domain/` qui retourne une liste rankée. L'UI affiche, ne décide pas.

---

## 5. Behavior

### 5.1 Sur tap d'un stamp
1. Animation `stamp-press` (240ms) sur le stamp tapé
2. Dispatch action au `gameStateProvider`
3. Domain produit le nouveau `GameState` + messages
4. Nouveau frame :
   - Scene crossfade si lieu a changé (200ms, steps)
   - Description update
   - Flash slide-in si nouveau message
   - Lamp update si tour décrémenté
   - Score-pop si +N pts
5. Autosave écrit le nouveau state

### 5.2 Sur tap LampShortcut
- État bright/dim → toggle off
- État dark → si oil disponible : relight ; sinon : flash "Pas de combustible"
- Si l'action n'est pas légale dans le lieu (water on lamp etc.) : flash danger

### 5.3 Sur tap MagicWordSurface
- Animation `magic-reveal` au reveal initial
- Tap → confirme prononciation → dispatch UseMagicWord → téléport canonique

### 5.4 Sur tap "Plus d'actions"
- Bottom sheet slide-up (`sheet-slide-up` 280ms)
- Affiche **toutes** les actions groupées par catégorie
- Tap sur action → ferme la sheet + dispatch

### 5.5 Rencontres (encounters)
- Si le tour déclenche une rencontre (nain random ~10%, pirate, troll-bridge entry), monter une modale **par-dessus** l'écran Adventure
- L'Adventure reste visible derrière (scrim)
- Pas de back possible — le joueur doit choisir une option de la modale

### 5.6 Mort
- Si l'action choisie tue le joueur : navigate replace `/death` avec context
- Pas de transition d'écran fluide — cut sec, c'est volontaire et choquant

---

## 6. Décisions feature-spécifiques

### ADR-ADV-001 · Lampe diegetic, pas en top bar
**Décidé.** La lanterne est traitée comme un objet "scénique" ancré sous la scène, pas comme une pill de status au même niveau que Score/Tour.
**Pourquoi :** elle est **l'objet du jeu**, pas une métrique abstraite. La voir dans le coin de la scène réécrit le lien émotionnel : "ma lanterne éclaire ce que je vois".

### ADR-ADV-002 · Le premier stamp est toujours primary
**Décidé.** Même si le ranker n'a pas de "favorite", il y en a toujours une en filled ambre pour guider le joueur.
**Pourquoi :** sans guide, un joueur novice patauge. Le ranker garantit que c'est l'action **canon-recommandée** dans la situation.
**Tradeoff :** un joueur expert peut trouver ça paternaliste. Mitigé par Settings "Désactiver l'action recommandée" (post-v1).

### ADR-ADV-003 · Pas de scrollIntoView automatique
**Décidé.** L'action list scrolle naturellement quand elle dépasse, mais on **ne force jamais** un scroll programmatique.
**Pourquoi :** désorientant sur mobile.

---

## 7. Tests

### Domain (oracle)
- `MoveTo(currentLocation, direction)` produit le même `Location` que C oracle pour les 50 lieux principaux
- `UseMagicWord(word, currentLocation)` retourne `null` (silent fail) ou téléporte correctement
- `ListAvailableActions` retourne au moins toutes les directions valides de la `Location`

### Widget
- `AdventureScreen` rend `MagicWordSurface` **uniquement** si `availableMagic != null`
- Tap sur primary stamp dispatche le bon `Action` et trigger l'animation `stamp-press`
- Lamp critique (`turns ≤ 30`) affiche flash danger ET met la lamp en state `dim`
- Action list > 7 → affiche 6 stamps + "Plus d'actions +N"

---

## 8. Open questions

- **OQ-ADV-1 :** comment gérer un lieu avec **aucune** action valide ? (peu probable mais possible si lampe morte dans un lieu sans exits). Fallback : afficher seulement "Observer le lieu" + "Inventaire".
- **OQ-ADV-2 :** swipe horizontal pour aller à Inventory/Journal — pratique mobile mais conflit avec bottom nav. Pas en v1.
- **OQ-ADV-3 :** vibration haptique sur stamp tap ? À tester.

---

## 9. Out of scope (v1)

- Mini-carte intégrée à la scène
- Voice-over de la description (TTS)
- Animations pixel sur la scène elle-même (eau, brume) — assets pour plus tard
- Replay / undo
