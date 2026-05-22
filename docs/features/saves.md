# Feature · Saves

> Persistence de la partie. Autosave + 5 slots manuels, 100% local.

**Owner :** @jouan · **Status :** v0.1 · **Updated :** 2026-05-20
**Voir aussi :** [root](../design.md)

---

## 1. Goal

- **Autosave silencieux** à chaque tour — le joueur ne pense jamais à sauvegarder
- **5 slots manuels** pour marquer des points-clés ("avant d'entrer chez le dragon")
- **Reprise instantanée** depuis Home → "Continuer" → autosave
- **Export / import** pour archiver ou changer d'appareil
- **100% local** — `getApplicationDocumentsDirectory()/saves/`, jamais de cloud

**Non-goals :**
- Cloud sync (iCloud/Google Drive) — pas en v1
- Multi-account (chaque appareil = une partie en cours)
- Time-travel / arbre de saves (linéaire only)

---

## 2. User stories

| As a | I want to | So that |
|---|---|---|
| Joueur quotidien | Reprendre ma partie au tap sur "Continuer" | Je n'oublie rien |
| Joueur prudent | Sauvegarder manuellement avant un choix risqué | Je puisse revenir |
| Joueur curieux | Garder plusieurs parties en parallèle | J'explore différents chemins |
| Joueur qui change de tél | Exporter mon save en JSON | Je continue ailleurs |

---

## 3. Anatomie

### 3.1 SavesPage (`/saves`)
```
Header     : back · "Ton carnet de bord · SAUVEGARDES" · pill "+ NOUVEAU"
Section 1  : "REPRENDRE" → 1 card autosave (primary, ambre)
Section 2  : "SLOTS MANUELS · 3/5" → cards remplis + slots vides
Footer     : Storage info (248 KB / 5 MB) + chemin disque
```

### 3.2 SaveSlot (card)
- Thumbnail 80×56 (MiniScene compressée — pixel-art scene placeholder)
- Eyebrow ("AUTO" ambre ou "SLOT N" paper-faded)
- Lieu courant (Pixelify display 15)
- Métadonnées mono : `T.047 · ● 23 pts`
- Date relative italique : "Il y a 3 jours · 18:30"
- Bouton kebab (3 dots) → menu : Charger / Renommer / Exporter / Supprimer

Slot vide : dashed border, icon `+`, texte "SLOT N · LIBRE / Tap pour sauvegarder ici".

### 3.3 Autosave card
- Always primary tone (border ambre, gradient, ombre offset)
- Eyebrow "◆ AUTO"
- "Sauvegardé à chaque tour · il y a 12 secondes" → date dynamique

---

## 4. State

```dart
class SavesViewModel {
  final SaveFile autosave;
  final List<SaveFile?> manualSlots;  // longueur 5, null si vide
  final StorageInfo storage;
}

class SaveFile {
  final SaveId id;
  final String location;        // localized
  final int turn, score;
  final DateTime savedAt;
  final String? thumbnailScene; // scene name pour MiniScene
  final int sizeBytes;
}
```

---

## 5. Behavior

### 5.1 Autosave
- Triggered **après chaque tour réussi** dans `GameNotifier`
- Écrit `autosave.json` (atomic write : temp file + rename)
- Throttle : si > 1 tour/200ms (cas pathologique), debounce
- En cas d'échec disque : flash danger "Sauvegarde impossible", log, ne bloque pas le tour

### 5.2 Save manuel
- Tap "+ NOUVEAU" → flow rapide :
  1. Si tous slots pleins → modal "Remplacer quel slot ?"
  2. Sinon → écriture sur premier slot vide, prompt facultatif "Nommer cette sauvegarde"
- Anim stamp-press + flash success "Sauvegardé · SLOT N"

### 5.3 Load
- Tap autosave card → confirm si une partie en cours différente → navigate `/adventure` avec game state hydraté
- Tap manual slot → idem

### 5.4 Delete
- Bouton kebab → "Supprimer" → ConfirmDialog (cf. dialogs.jsx) avec destructive tone
- Confirmation obligatoire — pas de "et si je tapais par erreur"

### 5.5 Export
- Bouton kebab → "Exporter" → share sheet OS avec JSON file
- iOS : `share_plus`, Android : `Intent.ACTION_SEND`

### 5.6 Import
- Bouton "+ NOUVEAU" → option "Importer un JSON" → file picker → validate schema → load

---

## 6. Décisions feature-spécifiques

### ADR-SAV-001 · Autosave après chaque tour
**Décidé.** Pas de "save on quit". Toujours frais.
**Pourquoi :** mobile = interruptions constantes (appel, app killed). Le joueur ne doit jamais perdre.
**Tradeoff :** I/O fréquent. Mitigé par : (a) save < 50 KB, (b) atomic write, (c) async.

### ADR-SAV-002 · 5 slots manuels, pas plus
**Décidé.** Limite stricte.
**Pourquoi :** force le joueur à curater. Trop de slots = paradoxe du choix.
**Tradeoff :** un complétionniste peut être frustré. Mitigé par export JSON pour archiver hors app.

### ADR-SAV-003 · JSON versionné avec migrations
**Décidé.** Chaque save commence par `"version": N`. Si on bump le schema, on ship des migrators dans `data/saves/migrations/v1_to_v2.dart`.
**Pourquoi :** une save reste valable même si on bump l'app dans 2 ans.

### ADR-SAV-004 · Pas de cloud sync v1
**Décidé.** Strict offline.
**Pourquoi :** ADR-005 root ("100% offline"). On respecte.
**Réversible :** si forte demande, on ajoute iCloud + Google Drive sync en v1.x sans casser le schéma local.

### ADR-SAV-005 · MiniScene comme thumbnail
**Décidé.** On stocke `thumbnailScene` (string identifier de la scène) dans la save, pas une image rasterisée.
**Pourquoi :** taille minimale, et la scène évolue avec les assets (si on update la pixel-art, les saves bénéficient automatiquement).

---

## 7. Tests

### Repository
- Write → read → equality (golden file tests)
- Migration v1 → v2 préserve `score`, `inventory`, etc.
- Corruption détectée (JSON invalide) → returns `SaveCorrupted`, ne crashe pas

### Widget
- Page avec 5 slots remplis → "+ NOUVEAU" propose replace modal
- Page avec 0 slots → seul autosave visible si présent
- Delete slot → ConfirmDialog → confirm → slot devient vide

---

## 8. Open questions

- **OQ-SAV-1 :** afficher un **diff** entre 2 saves ? Cool pour completionists, hors v1.
- **OQ-SAV-2 :** quota disk visible — 248 KB / 5 MB est arbitraire (5 saves * ~50KB = 250KB). On garde le chiffre 5 MB pour donner de la marge mentale, mais on ne s'en sert pas vraiment. À ré-évaluer.
- **OQ-SAV-3 :** auto-pruning des autosaves anciennes ? Le canon ne tracke qu'**une** autosave (la dernière). Donc pas de pruning. Sauf si on autorise un "recent autosaves" pour annuler 1 tour.

---

## 9. Out of scope (v1)

- Cloud sync
- Save naming (laisse le lieu comme nom)
- Save tagging / favorites
- Differential saves (delta vs base) — overkill pour 50 KB
