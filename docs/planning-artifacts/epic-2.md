# Sprint 2 — Moteur travel, UI v0, Autosave, Audio bootstrap, BACK, Incantations

> **Source canonique des DoD détaillés** : [`docs/EXEC_S2.md`](../EXEC_S2.md) (Suivi & tickets ADVT‑S2‑01 → ADVT‑S2‑24).
> Cet epic est une **vue BMad** dérivée de l'EXEC ; en cas de divergence, EXEC_S2 prime.

## Epic 2: Sprint 2 — Moteur minimal jouable

**Status:** done
**Goal:** Livrer un noyau jouable par boutons : `ListAvailableActions(travel)` + `ApplyTurn(goto)` + UI AdventurePage v0 + autosave + audio bootstrap + BACK/RETURN + filtre incantations.
**Acceptance:** `flutter analyze` zéro warning, tests S2 verts, couverture Domain S2 ≥ 80 %, navigation jouable via boutons sur ≥ 10 lieux connectés, autosave reprise au dernier lieu après relance.

### Story 2.1: VOs Command et TurnResult
**Status:** done
**Source ticket:** ADVT‑S2‑01
**Goal:** Classes final/const, égalité valeur ; `Game` et structures embarquées avec égalité/hashCode structurels ; tests construction/égalité.

### Story 2.2: ListAvailableActions (travel only)
**Status:** done
**Source ticket:** ADVT‑S2‑02
**Goal:** Actions `category=travel` uniquement, verbes normalisés via motions.json, pas de doublons, ordre déterministe ; filtre `condtype ≠ cond_goto/0` et `stop=true`.

### Story 2.3: Tests ListAvailableActions (≥ 5 cas)
**Status:** done
**Source ticket:** ADVT‑S2‑03
**Goal:** Cas plusieurs verbes même destination, absence de condition, labels/icônes N/E/S/O/UP/DOWN mappées.

### Story 2.4: ApplyTurn (goto) — mutation Game + messages
**Status:** done
**Source ticket:** ADVT‑S2‑04
**Goal:** Mise à jour `loc/oldloc/newloc/turns` cohérente ; message = longDescription (sinon short) ; met à jour `visitedLocations` (initialGame marque le lieu de départ).

### Story 2.5: Tests ApplyTurn (transitions, turns, messages)
**Status:** done
**Source ticket:** ADVT‑S2‑05
**Goal:** Trois cas — normal, verb sans règle (échec), multi-règles (prend la première).

### Story 2.6: SaveRepository minimal (autosave/latest)
**Status:** done
**Source ticket:** ADVT‑S2‑06
**Goal:** Fichier `autosave.json` valide ; `latest()` reconstruit `GameSnapshot` ; répertoires platform-aware via `path_provider`.

### Story 2.7: Tests SaveRepository (round-trip + absence)
**Status:** done
**Source ticket:** ADVT‑S2‑07
**Goal:** `latest()` retourne null si absent ; round-trip préserve valeurs ; tests isolés du FS réel via mock provider.

### Story 2.8: GameController (init/perform/refreshActions + autosave)
**Status:** done
**Source ticket:** ADVT‑S2‑08
**Goal:** État immuable via `ValueNotifier<GameViewState>` ; dépendances injectées par constructeur ; notifications fines.

### Story 2.9: Tests GameController (autosave appelée exactement 1×)
**Status:** done
**Source ticket:** ADVT‑S2‑09
**Goal:** Vérification mocktail : une seule invocation d'`autosave` par tour ; journal mis à jour.

### Story 2.10: AdventurePage v0 (description + boutons + journal)
**Status:** done
**Source ticket:** ADVT‑S2‑10
**Goal:** Rendu stable ; aucun `UnimplementedError` ; état contrôlé par injection du contrôleur ; respect §17 UX mobile (3–7 actions, overflow « Plus… »).

### Story 2.11: Widget tests AdventurePage
**Status:** done
**Source ticket:** ADVT‑S2‑11
**Goal:** Rendu initial OK ; tap bouton → mise à jour description/titre ; pumpAndSettle sans jank.

### Story 2.12: Table canonicalMotion + mapping icônes/labels
**Status:** done
**Source ticket:** ADVT‑S2‑12
**Goal:** Aliases N/S/E/W/NE/NW/SE/SW/UP/DOWN/IN/OUT couverts ; tests de mapping verts.

### Story 2.13: Gestion absence d'actions (cul-de-sac → Observer)
**Status:** done
**Source ticket:** ADVT‑S2‑13
**Goal:** Fallback `meta:observer` injecté ; pas de crash ; test dédié.

### Story 2.14: Lint/Analyze zéro warning + null-safety
**Status:** done
**Source ticket:** ADVT‑S2‑14
**Goal:** `flutter analyze` zéro warning ; CI locale verte.

### Story 2.15: Mesure perf interaction bouton → render < 16 ms
**Status:** done
**Source ticket:** ADVT‑S2‑15
**Goal:** Mesure consignée (Samsung Tab A8 Build 1.5/Layout 3.4/Raster 12.4 ms ; POCO F4 Build 1.4/Layout 6.6/Raster 4.5 ms).

### Story 2.16: Slot image scène + locationImageKey + tests fallback
**Status:** done
**Source ticket:** ADVT‑S2‑16
**Goal:** `lib/core/utils/location_image.dart` créé et testé ; placeholder stable dans AdventurePage v0 ; absence d'asset ne crashe pas.

### Story 2.17: AudioController bootstrap (cycle de vie + focus)
**Status:** done
**Source ticket:** ADVT‑S2‑17
**Goal:** `playBgm/stopBgm/playSfx` n'échouent pas (mocks) ; pause/resume sur lifecycle ; pas d'accès réseau.

### Story 2.18: Settings volumes Musique/SFX persistés
**Status:** done
**Source ticket:** ADVT‑S2‑18
**Goal:** Sliders reflétés en temps réel ; persistance via `shared_preferences` ; restauration au démarrage.

### Story 2.19: Theme/tokens baseline (VISUAL_STYLE_GUIDE)
**Status:** done
**Source ticket:** ADVT‑S2‑19
**Goal:** `ThemeData` light/dark + ColorScheme/TextTheme/spacing ; règles 16-bit (`PixelCanvas`/`FilterQuality.none`) intégrées.

### Story 2.20: HomePage v0 (wireframe UX_SCREENS)
**Status:** done
**Source ticket:** ADVT‑S2‑20
**Goal:** Menu Nouvelle/Continuer/Charger/Options/Crédits ; Continuer disabled si pas d'autosave ; navigation vers chaque écran fonctionnelle.

### Story 2.21: Mouvement BACK/RETURN (Domain/App/UI)
**Status:** done
**Source ticket:** ADVT‑S2‑21
**Goal:** `ListAvailableActionsTravel` expose « Revenir » si `oldLoc` accessible ; `ApplyTurnGoto` gère `BACK` via historique (respecte `COND_NOBACK` et `FORCED`) ; widget test valide bouton dans un cul-de-sac.

### Story 2.22: Tests non-régression BACK (bloqué/autorisé)
**Status:** done
**Source ticket:** ADVT‑S2‑22
**Goal:** Tests Domain retour simple/forcé/impossible ; tests Application historique mis à jour ; widget test absence sur lieu initial.

### Story 2.23: Filtrer incantations tant que non découvertes
**Status:** done
**Source ticket:** ADVT‑S2‑23
**Goal:** `ListAvailableActionsTravel` exclut `MagicWords.isIncantation` tant que `Game.magicWordsUnlocked == false` ; widget test absence en début de partie.

### Story 2.24: Tests non-régression incantations (visibilité conditionnelle)
**Status:** done
**Source ticket:** ADVT‑S2‑24
**Goal:** Tests Domain simulant l'apprentissage d'un mot magique → action disponible uniquement dans les salles concernées ; tests Application/Widget pour apparition dynamique.
