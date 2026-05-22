# Deferred Work

Travail identifié lors de revues mais reporté pour traitement ultérieur. Chaque entrée doit pointer vers la source (revue, story) et indiquer pourquoi le report est acceptable.

## Deferred from: code review of 5-4-atomes-ui-partages (2026-05-22)

- **OAStamp — `AnimatedOpacity` ne synchronise pas la shadow lors du flip enabled↔disabled** [`lib/core/widgets/oa_stamp.dart:616-630`] — l'opacité s'anime sur 200 ms, mais le `boxShadow` disparaît instantanément (recréation du `Container`). Point esthétique mineur ; pas une régression bloquante. À traiter via `AnimatedContainer` ou shadow couleur animée si une story UX le requiert.
- **OAItemSprite — `minWidth` ConstrainedBox vs AspectRatio peut être écrasé par parent contraint** [`lib/core/widgets/oa_item_sprite.dart:213-219`] — la `ConstrainedBox(minWidth: 56)` est efficace seulement quand le parent ne fournit pas de largeur. Dans la gallery et les futurs callers (`SizedBox(width: 80)`), le cas dégradé n'apparaît pas. À documenter ou tester si un caller en `Row` étroit émerge.
