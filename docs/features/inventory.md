# Feature · Inventory

> Le sac à dos du joueur. Voir, sélectionner, agir sur les objets transportés.

**Owner :** @jouan · **Status :** v0.1 · **Updated :** 2026-05-20
**Voir aussi :** [root](../design.md), [adventure](./adventure.md), [saves](./saves.md)

---

## 1. Goal

- **Voir** ce qu'on transporte et l'état de chaque objet (lampe allumée, bouteille pleine, oiseau en cage…)
- **Agir** sur un objet via ses verbes contextuels (Boire, Verser sur X, Lâcher…)
- **Respecter** la capacité de 7 objets — limite canon, force le joueur à choisir

**Non-goals :**
- Pas de tri/filtrage. La liste est ordonnée par catégorie fixe (Outils/Survie/Vivant).
- Pas de drag-and-drop pour réorganiser.
- Pas d'équipement / slots (le canon n'a pas cette notion).

---

## 2. User stories

| As a | I want to | So that |
|---|---|---|
| Joueur chargé | Voir d'un coup d'œil mes 7 objets | Je sache quoi lâcher avant de prendre autre chose |
| Joueur face à un puzzle | Voir les verbes possibles sur un objet | Je trouve la solution sans deviner |
| Joueur prudent | Voir l'état actuel (lampe allumée ? bouteille vide ?) | Je gère mes ressources |

---

## 3. Anatomie

### 3.1 InventoryPage (`/adventure/inventory`)
```
Header  : back · "Ton sac · INVENTAIRE" · pill capacité 7/7
Body    : 3 sections (Outils 4 / Survie 2 / Vivant 1) avec ItemCard chacune
Footer  : capacity meter (barres pixel × 7)
BottomNav active = inventory
```

### 3.2 ItemCard (réutilisable)
- Sprite 48×48 cadré (tone selon contexte, prop `src` pour vraie illustration)
- Nom (Pixelify display 15px bold)
- État (caps colorée par tone : "ALLUMÉE · 204 TOURS")
- Hint (body 12px italique, optionnel)
- Chevron à droite

### 3.3 ItemActionSheet (modal sur Adventure)
Bottom sheet glissant du bas (`sheet-slide-up`). Anatomie :
- Drag handle (40×3, paper-ink)
- Header : sprite agrandi 56×56 (vraie illustration en `src` si dispo) + nom + state + bouton close
- Description italique entre guillemets « … »
- Section "QUE FAIRE AVEC ?"
- Liste de stamps verbe (3-6 options selon objet)

---

## 4. State

```dart
class InventoryViewModel {
  final List<ItemInstance> items;     // ordered by category fixe
  final int capacity;                 // 7 (canon)
  final ItemId? selected;             // pour la sheet
}

class ItemInstance {
  final ItemId id;                    // canon ID
  final ItemCategory category;        // tools | survival | living
  final ItemState state;              // lit, dim, full, empty, occupied…
  final String? assetPath;            // assets/objects/<id>.png — null si pas livré
  final SpriteIcon fallbackIcon;      // pictogramme SVG si pas d'asset
  final SpriteTone spriteTone;
  final List<VerbAction> verbs;       // actions possibles ici/maintenant
}
```

Le state est dérivé de `GameState.inventory` + le lieu courant (un verbe "Verser sur la plante" n'apparaît que si plante présente).

---

## 5. Behavior

### 5.1 Sur tap d'un ItemCard
- Navigate `/adventure/item/:itemId` (modal route)
- Crée l'ItemActionSheet, slide-up
- Sheet bloque l'interaction Adventure derrière (scrim 55%)

### 5.2 Sur tap d'un verbe dans la sheet
- Anim stamp-press
- Dispatch `Action.useItemVerb(itemId, verb)`
- Domain produit nouveau state + messages
- Sheet se ferme (slide-down 280ms steps)
- Adventure update avec flash message

### 5.3 Sur tap close ou tap scrim
- Sheet slide-down, route pop

### 5.4 Tap sur lampe inventory item
- C'est le seul item avec **deux** actions principales : "Allumer/Éteindre" ET "Lâcher"
- L'allumage est aussi accessible via LampShortcut sur Adventure — les deux routes coexistent

---

## 6. Décisions feature-spécifiques

### ADR-INV-001 · Capacité dure de 7 (canon), pas de surcharge
**Décidé.** Si le joueur tape "Prendre X" alors qu'il a déjà 7 objets, **flash danger** "Tu portes déjà beaucoup. Il faudrait en lâcher un."
**Pourquoi :** le canon force ce choix tactique. C'est central à la difficulté du jeu.
**Rejeté :** surcharge avec malus (déstabilise le canon).

### ADR-INV-002 · Catégories fixes Outils/Survie/Vivant
**Décidé.** 3 catégories statiques. La cage avec ou sans oiseau reste dans "Outils".
**Pourquoi :** lisibilité. Le joueur sait toujours où trouver sa lampe.
**Tradeoff :** un peu arbitraire pour quelques objets (la bouteille est dans Survie).

### ADR-INV-003 · Bottom sheet pour les actions, pas une page dédiée
**Décidé.** Pas de `/inventory/item/:id` plein écran. Toujours sheet.
**Pourquoi :** garder Adventure visible derrière le scrim donne un sentiment de continuité ("je sors un truc de mon sac sans quitter la grotte").

### ADR-INV-004 · Sprite tones reflètent l'état actuel
**Décidé.** La lampe a `tone: lit` quand allumée, `tone: default` éteinte. La bouteille `tone: default` (pleine ou vide). Le treasure a `tone: treasure`.
**Pourquoi :** signal visuel immédiat sans avoir à lire le texte d'état.

### ADR-INV-005 · Fallback pictogramme si pas d'asset
**Décidé.** `OAItemSprite` accepte un `assetPath` optionnel. S'il est `null` ou file 404, fallback automatique sur le pictogramme pixel-art SVG défini dans `OAIcon`.
**Pourquoi :** permet de dev avant que tous les assets soient livrés. Les écrans restent fonctionnels.

---

## 7. Tests

### Domain
- Prendre un objet en lieu valide → state.inventory contient l'objet
- Prendre alors que capacity == 7 → state inchangé + message canon
- Verb "Verser eau sur plante" en lieu valide → plante.state change + treasure unlock

### Widget
- InventoryPage avec 0 items → message "Ton sac est vide"
- InventoryPage avec 7 items → capacity meter plein, pill rouge "danger"
- ItemActionSheet ouverte → tap scrim ferme sans dispatch
- Tap stamp dans sheet → verb dispatched + sheet closes
- ItemSprite avec `assetPath` invalide → fallback pictogramme rendu

---

## 8. Open questions

- **OQ-INV-1 :** afficher le **poids** estimé ? Le canon n'utilise pas le poids, mais la perception "ce sac est trop lourd" pourrait améliorer l'UX. Probablement non.
- **OQ-INV-2 :** drag pour réorganiser ? Non en v1.
- **OQ-INV-3 :** quick-actions sur long-press d'un ItemCard (skip the sheet, exec verbe par défaut) ? Tentant mais ajoute de la complexité. Post-v1.

---

## 9. Out of scope (v1)

- Equipment slots
- Item search
- Item comparison
- Combinaisons custom (combine X with Y) — le canon a ces verbs mais ils sont exposés dans la sheet, pas dans une UI dédiée
