# Feature design docs — index

Chacun de ces fichiers est un **document vivant** capturant le **quoi** et le **pourquoi** d'une feature.
À mettre à jour quand une décision est révisée.

| Feature | Status | Notes |
|---|---|---|
| [adventure.md](./adventure.md) | v0.1 | Écran de jeu principal — le plus complexe |
| [inventory.md](./inventory.md) | v0.1 | Sac + actions sur objets |
| [saves.md](./saves.md) | v0.1 | Autosave + slots manuels |
| [settings.md](./settings.md) | v0.1 | Audio · visuel · langue · a11y · données |

## À produire (sur le même template)

Quand tu commences à coder une de ces features, dupliquer `adventure.md` comme template, adapter, puis itérer.

- `home.md` — écran d'accueil, menu, "Continuer"
- `onboarding.md` — 3 cartes de premier lancement
- `map.md` — carte des lieux visités
- `journal.md` — fil chronologique
- `encounters.md` — nain · pirate · troll · death scenarios
- `endgame.md` — breakdown des 430 pts
- `death.md` — obituaire + réincarnation canon
- `credits.md` — lignée Crowther/Woods/Raymond

## Structure standard d'un feature design.md

1. **Goal** (et non-goals)
2. **User stories**
3. **Anatomie** (UI breakdown)
4. **State**
5. **Behavior** (interactions)
6. **Décisions feature-spécifiques** (ADRs locaux)
7. **Tests** (domain + widget)
8. **Open questions**
9. **Out of scope (v1)**
