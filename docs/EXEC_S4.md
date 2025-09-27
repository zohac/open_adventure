# Exécution S4 — Scoring complet, fins de jeu, multi‑saves, polish UX, hardening, CI verte

Statut: exécutable immédiatement. Durée cible: 1 semaine (5 j/h).

Definition of Ready (DoR)

- Seuils de couverture configurés dans la CI (Domain ≥ 90%, Data ≥ 80%, Application ≥ 80%, Presentation ≥ 60%).
- Stratégies de precache image/audio validées; toggles Settings décidés.
- Liste d’assets audio/images finale déclarée dans `pubspec.yaml`.
- ARB de base créés pour FR/EN (fichiers vides avec clés de structure), checklist accessibilité prête (AA), et plan de tests goldens (si activé) défini.
- DDR à jour (`docs/Dossier_de_Référence.md`) : incantations Option A confirmée, messages lampe (DDR-003) cadrés, oracles seedés intégrés au plan QA.
- Sérialisation `GameController.mapGraph` verrouillée (autosave + slots) et golden tests MapPage S3 verts.

Objectif S4

- Finaliser la boucle de jeu: scoring complet fidèle au C, détection et gestion des fins (victoire, fermeture de la caverne, morts), sauvegardes multiples avec compat ascendante intra‑major, polissage UX (accessibilité, i18n, status bar, map), durcissement perfs/résilience, et CI verte avec seuils de couverture.

Dépendances S1–S3 (doivent être vertes)

- Data mappers stables et `AdventureRepository.initialGame()` fonctionnel.
- `ListAvailableActions` (travel + interactions), `ApplyTurn` (goto + interactions de base), `GameController` avec autosave.
- UI v1 (AdventurePage, Inventory/Map/Journal) fonctionnelle.

Livrables

- Domain
  - Scoring complet: implémenter la parité avec `open-adventure-master/score.c`.
    - Composantes: trésors (découverts/déposés au bon endroit), exploration (lieux uniques), pénalités de tours/temps, utilisation d’indices (malus), morts/réincarnations, bonus de fin, classes de score (novice… master).
    - API: `ComputeScore(Game) → ScoreBreakdown { treasures, exploration, penalties, hints, deaths, bonus, total }`.
  - Fins de jeu: conditions et flux (victoire/fermeture, abandon, mort).
    - Détection via flags `closed/closng/clshnt`, état des trésors, seuils de tours (`turn_thresholds.json`), obituaries.
    - Sortie: `EndGame { reason, finalScore, breakdown, transcript? }` + transition UI.
  - Indices: activer système `hints.json` (déblocage contextuel + coût en score); use case `GetHints(Game)` + `UseHint(id)` appliquant malus.
  - Persistences des paramètres de jeu (difficulté novice/normal) si applicable.

- Application
  - `SaveRepository` complet (fichiers): `save(slot, snapshot)`, `load(slot)`, `latest()`, `list()`, `delete(slot)`.
    - Format: JSON versionné `{ schema_version, game_version, created_at, slot, snapshot }`.
    - Compat: lecture tolérante (ignorer inconnus), migration mineure (ajout de champs par défaut).
  - `GameController` :
    - Orchestration de fin de partie (freeze des actions, navigation vers écran de fin, option « Nouvelle partie »/« Charger »).
    - Gestion des slots (sauvegarde manuelle, autosave continue, UI binding).

- Data
  - Validation des assets: script `scripts/validate_json.py` exécuté en CI (job optionnel) pour aligner YAML → JSON.
  - Vérification croisée `travel.json` vs `tkey.json` (cohérence clés/indices) — log en dev si divergence.

- Presentation
  - `SavesPage`: liste des slots avec `title/progression/date`, actions `Charger/Supprimer`, confirmation de suppression, tri par `updated_at`.
  - `SettingsPage`: thème clair/sombre, taille de police, langue (FR/EN), réinitialiser tutoriel.
  - `AdventurePage` v2 :
    - `StatusBar`: score courant, nombre de tours, nom du lieu, indicateur batterie de lampe.
    - Groupes d’actions avec en‑têtes, scroll performant, focus management.
  - `MapPage` v2: persistance complète des couches visitées (autosave/saves), préselection couche courante, réglages d’accessibilité (semantics, contraste) et validations GD/UX/QA post‑implémentation.
  - `EndGamePage/Dialog`: affichage du score final, breakdown, classe, options (recommencer, charger, crédits).
  - i18n finalisée via ARB (FR/EN), y compris labels d’actions, pages, dialogues et erreurs.
  - Accessibilité: labels semantics complets, contrastes conformes, navigation au lecteur d’écran testée.

UI – livrables & DoD

- [ ] AdventurePage v2 + StatusBar
  - DoD:
    - [ ] StatusBar affiche correctement score/tours/lieu/lampe en temps réel;
    - [ ] Groupes d’actions avec entêtes et focus management (clavier/lecteur d’écran) fonctionnels.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.
- [ ] SavesPage
  - DoD:
    - [ ] Liste des slots triée par `updated_at` avec `title/progression/date`;
    - [ ] Actions Charger/Supprimer avec confirmations; widget tests tap→callbacks OK.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.
- [ ] SettingsPage
  - DoD:
    - [ ] Sélection de thème/texte/langue persistée; changement de langue reflété dans l’UI;
    - [ ] Tests de persistance et de changement de locale.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.
- [ ] EndGamePage/Dialog
  - DoD:
    - [ ] Affiche breakdown complet et classe; actions rejouer/charger/crédits fonctionnelles;
    - [ ] Widget tests valident les boutons et la navigation.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.
- [ ] MapPage v2
  - DoD:
    - [ ] État de découverte (couches, nœuds, arêtes, badge « vous êtes ici ») restauré depuis autosave/saves multiples, incluant transitions magiques révélées;
    - [ ] Chips de couche, zoom/drag et CustomPainter conformes aux budgets art/accessibilité; logs QA (#nœuds/#arêtes) exposés en debug;
    - [ ] Golden tests par couche mis à jour + test widget multi-sauvegarde; revue croisée Game Design/UX/QA validant lisibilité tactile.
- [ ] Images — polish & contrôles
  - DoD:
    - [ ] Préchargement de l’image du prochain lieu (si connu) lors d’un `ApplyTurn` réussi;
    - [ ] Paramètre `Settings`: toggle « Afficher les images de scène » (on/off) persisté; par défaut activé sur appareils ≥ 3 Go RAM, sinon off;
    - [ ] Gestion du cache: limite `ImageCache.maximumSizeBytes` ajustée (64–96 MB) et testée sans OOM;
    - [ ] Mode sombre: overlay/tonemapping léger pour conserver la lisibilité; tests manuels visuels notés.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.
- [ ] Thème 16‑bit
  - DoD:
    - [ ] Palette/typographie/espacement cohérents avec un style 16‑bit; icônes pixelisées;
    - [ ] `FilterQuality.none` vérifié sur toutes les images pixel art; pas de scaling non entier dans `PixelCanvas`.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.

Audio – livrables & DoD (polish)

- [ ] Preload & mémoire
  - DoD:
    - [ ] Préchargement BGM de la zone suivante (si déterminable) via `just_audio` (ou warm‑up minimal);
    - [ ] BGM/SFX chargés/déchargés pour maintenir l’empreinte mémoire audio < 20 Mo.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.
- [ ] Ducking et mixage final
  - DoD:
    - [ ] Ducking BGM (−4 dB / 200 ms) sur SFX majeurs (alerte/danger/victoire);
    - [ ] Courbes de volume lissées (pas de clicks); validation d’écoute.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.
- [ ] Settings audio avancés
  - DoD:
    - [ ] Toggles Musique/SFX (on/off) + sliders; reset défaut; persistance prouvée;
    - [ ] Option « Audio rétro » appliquant un léger EQ (facultatif) — si non implémenté, masquer.
    - [ ] Revue Game Designer (UX/Art/Audio): polish final 16‑bit validé, images nettes et budgets respectés, BGM/SFX équilibrés (ducking, niveaux), i18n/a11y complètes.

Contrats — Domain (extraits)

```dart
class ScoreBreakdown {
  final int treasures, exploration, penalties, hintsPenalty, deathsPenalty, bonus, total;
  const ScoreBreakdown({required this.treasures,required this.exploration,required this.penalties,
    required this.hintsPenalty, required this.deathsPenalty, required this.bonus, required this.total});
}

class EndGame {
  final String reason; // 'victory' | 'death' | 'quit' | 'closing'
  final ScoreBreakdown score;
  const EndGame({required this.reason, required this.score});
}
```

Algorithmes — Parité score.c (lignes directrices)

- Reprendre les règles de `open-adventure-master/score.c`:
  - Trésors: points attribués à l’état « properly stored » (référence aux définitions dans YAML/classes).
  - Exploration: points pour lieux spécifiques visités (weights), plafonds.
  - Pénalités: incréments par `turns`/états (p.ex. lamp penalties), malus d’indices.
  - Bonus de fin: selon conditions de victoire/fermeture; classes de score dérivées des seuils.
- Tester chaque composante séparément + tests d’intégration de scénarios end‑to‑end (seed déterministe).

Multi‑saves — Spécification

- Emplacements :
  - iOS: `NSApplicationSupportDirectory/open_adventure/saves/`
  - Android: `filesDir/open_adventure/saves/`
- Fichiers: `save_v{schemaVersion}_{slot}.json`, `autosave.json`.
- Métadonnées dans chaque slot: `{ updated_at, turns, score, locationName }` pour lister sur `SavesPage`.
- Rétention: conserver N=10 slots + autosave; politique FIFO simple.

Polish UX

- Temps de démarrage à froid: < 1,0 s; warm start < 500 ms.
- Scroll fluide (listes actions/journal/inventaire) — pas de jank (>16 ms).
- Feedback d’état sur boutons (enabled/disabled) et haptique léger optionnel.
- États d’erreur user‑friendly (ex: chargement corrompu → dernier autosave).

CI, Qualité & Couverture

- CI: `flutter analyze`, `flutter test --coverage`, artefact LCOV.
- Seuils: Domain ≥ 90%, Data ≥ 80%, Presentation ≥ 60% (widgets clés), Application ≥ 80%.
- Job optionnel `data-validate`: `python3 scripts/validate_json.py` (dev only); rapporter divergences sans bloquer mobile si environnement indisponible.

Tests & validations

- Domain
  - `ComputeScore` (complet): tests unitaires par catégorie + tests intégrés reproduisant cas du C (ex: `turnpenalties`, `specials`, trésors complets).
  - Détection fins: scénarios « victoire », « mort », « closing » → `EndGame.reason` attendu et scoring final.
  - Hints: usage applique malus et verrouille la répétition.
- Application
  - `SaveRepository`: round‑trip `save→list→load→delete`; compat lecture avec champ inconnu; fallback corruption.
  - `GameController`: à la fin → gèle actions, navigue vers `EndGamePage`.
- Presentation
  - `SavesPage`: charge/supprime correctement (tests widgets + oracles sur callbacks).
  - `SettingsPage`: persiste préférences; langue modifie labels.
  - `EndGamePage`: breakdown correct et actions fonctionnelles.
- Perf
  - Mesures via devtools: frames budget OK, aucune GC majeure durant interaction continue de 2 min.

Definition of Done (S4)

- Jouable de bout en bout jusqu’aux fins prévues; multi‑saves fonctionnels; autosave robuste; i18n FR/EN; accessibilité valide.
- `flutter analyze` zéro warning; couverture aux seuils; CI verte.
- Démarrage à froid < 1,0 s; interaction 60 FPS; bundle Android < 30 Mo.

Risques & mitigations (S4)

- Divergence avec `score.c`: écrire tests miroirs par catégorie + oracles simplifiés; documenter toute divergence justifiée.
- Corruption de sauvegarde: validations strictes + sauvegarde atomique (écriture temp puis rename) + rollback.
- Régressions de perf: profiler avant merge; activer traces de temps de parse en dev; déporter en Isolate.
- Localisation incomplète: extraction ARB + vérif de clés manquantes en test.

Suivi & tickets

- [ ] ADVT‑S4‑01: Implémenter `ComputeScore` complet (parité `score.c`) — trésors, exploration, pénalités, indices, morts, bonus, classes + tests miroirs.
  - DoD:
    - [ ] Chaque composante testée isolément; scénarios intégrés reproduisent sorties attendues; écart justifié documenté si non nul.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑02: Détection des fins de jeu — conditions victoire/closing/mort/abandon, structure `EndGame` + tests de scénarios.
  - DoD:
    - [ ] Détection correcte des quatre raisons; `EndGame` porte reason/score; UI reçoit l’événement; tests verts.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑03: Système d’indices — `GetHints` (disponibilité contextuelle) + `UseHint(id)` (malus, idempotence) + tests.
  - DoD:
    - [ ] Indices proposés seulement en contexte; malus appliqué une seule fois par indice; tests couvrant répétition.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑04: `SaveRepository` complet — `save/load/list/latest/delete`, écriture atomique (temp+rename), tolérance champs inconnus + tests.
  - DoD:
    - [ ] Liste triée par `updated_at`; delete retire le fichier; write atomicité simulée/testée; lecture ignore champs inconnus.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑05: `SavesPage` — liste des slots (tri, métadonnées), charger/supprimer avec confirmations + widget tests.
  - DoD:
    - [ ] Affiche slots avec `title/progression/date`; actions fonctionnelles; tests widgets tap→callbacks OK.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (UX flows, wording, lisibilité).
- [ ] ADVT‑S4‑06: `SettingsPage` — thème, taille de police, langue (FR/EN), persistance préférences + tests.
  - DoD:
    - [ ] Préférences persistées et restaurées; changement de langue reflété dans l’UI; tests.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (UX réglages, i18n terminologie).
- [ ] ADVT‑S4‑07: `AdventurePage` v2 — `StatusBar` (score/tours/lampe), groupes d’actions, focus management + tests UI.
  - DoD:
    - [ ] StatusBar affiche valeurs correctes; navigation au clavier/lecteur d’écran cohérente; tests.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (lisibilité, hiérarchie visuelle, focus management).
- [ ] ADVT‑S4‑08: `EndGamePage/Dialog` — affichage breakdown, classe, actions (rejouer/charger/crédits) + tests.
  - DoD:
    - [ ] Breakdown complet; actions mènent aux écrans attendus; tests widgets verts.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (UX de fin, textes et classements).
- [ ] ADVT‑S4‑09: i18n finale — ARB FR/EN, extraction/validation des clés, test « clés manquantes ».
  - DoD:
    - [ ] Aucun placeholder dur dans l’UI; script de validation garantit l’existence des clés; tests de locale passent.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (traductions/tonalité FR/EN).
- [ ] ADVT‑S4‑10: Accessibilité finale — vérif voice‑over/lecteur d’écran, contrastes, navigation clavier (émulée) + correctifs.
  - DoD:
    - [ ] Audit accessibilité passé (checklist interne); problèmes critiques corrigés; tests semantics clés.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (a11y perçue, confort de lecture).
- [ ] ADVT‑S4‑11: Job `data-validate` (optionnel) — exécuter `scripts/validate_json.py`, rapporter divergences en CI (non bloquant mobile).
  - DoD:
    - [ ] Job CI configuré; sortie lisible; pipeline mobile non bloqué si indisponible.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑12: Perf & hardening — parse en Isolate (flag ON si >1 Mo), bench démarrage, traçage jank, profil mémoire + correctifs.
  - DoD:
    - [ ] Démarrage à froid < 1,0 s; aucune frame > 16 ms sur parcours nominal; mémoire < 150 Mo; traces enregistrées.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑13: Résilience sauvegardes — stratégie de rollback, gestion corruption (fallback autosave) + tests d’erreurs.
  - DoD:
    - [ ] Corruption simulée → fallback sur dernier autosave; aucun crash; logs informatifs.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑14: Lint/Analyze + Couverture — Domain ≥ 90%, Data ≥ 80%, Application ≥ 80%, Presentation ≥ 60% (enforcer CI).
  - DoD:
    - [ ] Rapports LCOV au‑dessus des seuils; `flutter analyze` zéro warning; CI verte.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
- [ ] ADVT‑S4‑15: Images — préchargement et gestion mémoire (cache) + toggle Settings.
  - DoD:
    - [ ] `precacheImage` appelé post‑tour pour le prochain lieu quand identifiable;
    - [ ] Toggle Settings fonctionnel et persisté; défaut basé sur heuristique RAM;
    - [ ] Ajustement du cache et validation sans OOM sur devices cibles.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (DA 16‑bit finale, budgets, lisibilité sombre/clair).
- [ ] ADVT‑S4‑16: Audio — preload/mémoire (empreinte < 20 Mo) + ducking mixage final.
  - DoD:
    - [ ] Preload du prochain BGM opérationnel; ducking audible propre; mesure mémoire conforme;
    - [ ] Tests unitaires manager (états/volumes), validation d’écoute manuelle documentée.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (mixage final, ducking, niveaux relatifs BGM/SFX).
- [ ] ADVT‑S4‑17: Audio — Settings avancés (toggles + sliders + reset + persistance).
  - DoD:
    - [ ] Persistance prouvée; UI réagit instantanément; test d’intégration traverse ON/OFF sans erreur.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (UX audio — sliders/toggles compréhensibles).
- [ ] ADVT‑S4‑18: Art — compléter les scènes restantes (Asset Bible) + QA finale 16‑bit.
  - DoD:
    - [ ] Toutes les scènes planifiées livrées; budgets respectés; rendu net via PixelCanvas; checklists DA/A11y passées.
    - [ ] Revue de code CTO: scoring conforme `score.c`, fins de jeu stables, multi‑saves robustes, perfs/coverage aux seuils.
    - [ ] Revue Game Designer validée (DA finale, conformité Asset Bible et qualité perçue).

- [ ] ADVT‑S4‑19: HomePage v1 (style 16‑bit final, i18n/a11y)
  - DoD:
    - [ ] Application VISUAL_STYLE_GUIDE (typographies, spacing, états); “Continuer” disabled si absence d’autosave;
    - [ ] i18n FR/EN complètes; a11y AA (focus/labels/contraste);
    - [ ] Revue CTO validée (UI/tests/a11y/i18n);
    - [ ] Revue Game Designer validée (DA/UX finales).

Références C (source canonique)

- open-adventure-master/score.c
- open-adventure-master/saveresume.c
- open-adventure-master/actions.c
- open-adventure-master/advent.h
- open-adventure-master/tests/turnpenalties.chk
- open-adventure-master/tests/specials.chk
- open-adventure-master/tests/saveresume.1.chk
- open-adventure-master/tests/saveresume.2.chk
- open-adventure-master/tests/saveresume.3.chk
- open-adventure-master/tests/saveresume.4.chk
- open-adventure-master/tests/panic.chk
- open-adventure-master/tests/panic2.chk
- open-adventure-master/tests/cheatresume2.chk
