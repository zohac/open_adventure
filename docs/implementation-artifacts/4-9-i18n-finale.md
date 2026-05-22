# Story 4.9: i18n finale — ARB FR/EN exhaustifs + extraction + CI guard

Status: ready-for-dev
Epic: 4
Source ticket: ADVT‑S4‑09 (`docs/EXEC_S4.md`)
Refs : [design.md](../design.md), [project-context](../project-context.md), [architecture](../architecture.md)

---
## 📝 Amendement Design Handoff — 2026-05-22

Intégrer durant le dev :
- **Nouvelles clés ARB** : le handoff (mockups + `docs/features/*.md`) introduit des libellés qui peuvent ne pas être encore couverts. Faire un balayage de `design_handoff_open_adventure/*.jsx` et `docs/features/` pour repérer les chaînes UI nouvelles (labels boutons, headers de catégorie, états vides, dialogs).
- **Convention naming** : préservée — `actions.*`, `menu.*`, `home.*`, etc. (cf. `project-context.md` §i18n)
- **Cohérence** : EN reste source canonique du wording original Crowther/Woods/Raymond (cf. [`docs/design.md`](../design.md) §4 ADR-008)

> ℹ️ Non bloquant — mais dépend implicitement de l'avancement des stories UI 5-7/5-8/5-9 et 4-5/4-6/4-7/4-8 (nouvelles chaînes générées au fil de leur dev).
---

## Story

**En tant que** mainteneur i18n, **je veux** un flux automatisé pour extraire les chaînes source des JSON et du code, garantir l'exhaustivité des ARB FR/EN, et bloquer en CI tout décalage, **afin de** livrer une app sans clé manquante ni chaîne dure dans deux langues.

## Acceptance Criteria

1. **AC1 — Script d'extraction** : `scripts/extract_localization.dart` (NEW) parcourt `assets/data/**` et produit un inventaire des chaînes source (id, contexte, texte d'origine).
2. **AC2 — Champ `i18nKey` dans assets** : JSON enrichis (ou structure équivalente) référencés par le script ; documenté dans `docs/CONVERSION_SPEC.md`.
3. **AC3 — ARB exhaustifs** : `lib/l10n/app_en.arb` (source) + `lib/l10n/app_fr.arb` (cible) complets, triés, sans clé manquante ni traduction manquante.
4. **AC4 — Conventions ARB** : un fichier par locale ; nommage `snake_case`/`camelCase` cohérent ; clés par contexte ; **aucune** chaîne brute en code ; métadonnées `@key` systématiques (description, type, placeholders nommés).
5. **AC5 — Test CI guard** : test automatisé (widget ou `flutter test`) échoue si clé absente, traduction manquante, ou décalage assets↔ARB ; branché en CI.
6. **AC6 — Doc handoff traducteur** : README section ou doc dédiée explique le flux : exécution script → édition ARB → `flutter gen-l10n` → export CSV/XLIFF facultatif.

## Tasks / Subtasks

- [ ] **Task 1 — Script `extract_localization.dart`** (AC: #1).
- [ ] **Task 2 — Enrichir assets avec `i18nKey` ou map externe** (AC: #2).
- [ ] **Task 3 — Compléter ARB FR/EN** (AC: #3, #4).
- [ ] **Task 4 — Test CI guard** (AC: #5).
- [ ] **Task 5 — Documentation handoff** (AC: #6).

## Dev Notes

### Source tree

| Path | NEW / UPDATE |
|---|---|
| `scripts/extract_localization.dart` | NEW |
| `lib/l10n/app_en.arb`, `app_fr.arb` | UPDATE (complétion) |
| `lib/l10n/app_localizations.dart` | régénéré |
| `assets/data/**.json` | UPDATE possible (i18nKey) |
| `docs/CONVERSION_SPEC.md` | UPDATE (section i18n) |
| `README.md` | UPDATE (handoff traducteur) |
| `test/l10n/i18n_completeness_test.dart` | NEW |

### Project Context Rules
- Aucune chaîne brute en code (Presentation).
- ARB triés, métadonnées `@key`.
- mocktail only.

### References
- `docs/EXEC_S4.md` ADVT‑S4‑09
- `docs/project-context.md` §i18n
- Flutter doc `flutter gen-l10n`

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List
