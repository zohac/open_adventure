# Annexe Design — Mobile UX, Pixel‑Art, Audio (normatif)

Statut: annexe normative rattachée à `docs/CONVERSION_SPEC.md` (§17–§19). En cas d’écart, aligner le code et les assets sur ce document et la spec.

Règle d’or: 3–7 choix vraiment utiles à chaque instant, zéro clavier.

## UX — Checklist d’implémentation (Dev)

- Actions visibles: ≤ 7. Au‑delà: 6 + `Plus…` (S2) ou scroll/pagination (S3).
- Catégories: `travel`, `interaction`, `meta` (Inventaire, Observer, Carte, Menu toujours présents).
- Priorisation (ordre): sécurité/urgence → travel → interaction → méta (tiebreakers: label asc, dest id asc, objet asc).
- Long/Short: première visite = long; revisites = short; `Observer` rejoue la long si disponible.
- Journal: append‑only, garde 200 derniers; messages uniquement (pas de commandes).
- Images: `PixelCanvas` 16:9, `FilterQuality.none`, fallback silencieux, `locationImageKey`.
- Audio: BGM par zone avec crossfade 250–500 ms; SFX throttle ≥ 150 ms.
- A11y: cibles ≥ 48dp, labels semantics, ordre de focus image→titre→desc→actions→bottom bar.

## Pixel‑Art — Pipeline (Game Artist)

- Base: 320×180 px (16:9). Composer à cette taille. Vérifier la lisibilité à ×1.
- Export: WebP lossless ou qualité visuelle équivalente; ≤ 200 KB/fichier. Nom: `assets/images/locations/<key>.webp`.
- Clé `<key>`: `mapTag` (préféré) → `name` en snake_case ASCII → `id` numérique.
- Style: SNES/Megadrive‑like, pas d’anti‑aliasing; dither léger autorisé; éviter les dégradés continus.
- Palette: 32–64 couleurs par scène, contrastes contrôlés (clair/sombre). Vérifier lisibilité des silhouettes.
- QA: contrôle sur device (×2/×3), contraste thème sombre/clair, bords nets, aucune trace de redimensionnement flou.

## Audio — Pipeline (Game Artist/Dev)

- Formats: OGG/Opus 48 kHz. Niveau: −14 LUFS intégrée, pic ≤ −1 dBFS.
- BGM: 30–60 s loopables; mapping par zone (`surface/grotte/river/sanctuary/danger`).
- SFX: court et percutant (tap, pickup, drop, lamp_on/off, dwarf_alert, discover).
- Intégration: crossfade BGM 250–500 ms sur changement de zone; volumes défaut 60% BGM / 100% SFX.

## Libellés & Icônes — Exemples (UI)

- Travel: `Aller Nord` (icon `arrow_upward`), `Aller Est` (`arrow_forward`), `Entrer` (`login`), `Sortir` (`logout`).
- Interaction: `Prendre la clé`, `Ouvrir la porte`, `Examiner le coffre`.
- Méta: `Inventaire`, `Observer`, `Carte`, `Menu`.

## Acceptation — Gates (CTO)

- UX: widget tests prouvent ≤7 actions visibles et overflow correct; première visite = long, revisit = short.
- Art: taille, nommage, lisibilité validés; rendu net via `PixelCanvas`; budget total ≤ 10 Mo.
- Audio: niveaux respectés, crossfades propres; aucune dépendance réseau; latence ≤ 50 ms au démarrage BGM.
- Accessibilité: labels semantics complets; tailles de police adaptatives; focus management validé.

## Livraison — Paquets attendus

- Art: dossier `assets/images/locations/` + liste `<key> → name` et miniatures; changelog.
- Audio: `assets/audio/music/*.ogg` + `assets/audio/sfx/*.ogg` + table `zoneKey → trackKey`.
- Dev: PRs mentionnant §17–§19 et cette annexe; tests d’UI/Domain ajustés si heuristiques changent.

Références additionnelles

- Bible assets: `docs/ART_ASSET_BIBLE.md` (scènes prioritaires, créatures/objets, VFX/SFX, palettes).
