// OAItemSprite — 1:1 inventory tile for objects/creatures (ADR-010).
// Cf. `design_handoff_open_adventure/inventory.jsx` ItemSprite.
// Story 5-4 — Atomes UI partagés.

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';
import '../theme/oa_colors.dart';
import 'oa_pill.dart';

enum OAItemTone { paper, ink, amber, teal }

/// Maximum integer badge rendered as-is ; au-delà, l'UI affiche `"99+"`.
const int _kBadgeCountClampMax = 99;

@immutable
class OAItemSprite extends StatelessWidget {
  const OAItemSprite({
    super.key,
    required this.image,
    required this.label,
    this.tone = OAItemTone.paper,
    this.onTap,
    this.selected = false,
    this.badgeCount,
  }) : assert(
          badgeCount == null || badgeCount > 0,
          'OAItemSprite.badgeCount must be null or a positive integer.',
        );

  final ImageProvider image;

  /// Label utilisé pour `Semantics`. Pas affiché en surimpression.
  final String label;

  final OAItemTone tone;
  final VoidCallback? onTap;
  final bool selected;

  /// Si non null, un petit [OAPill] s'affiche dans le coin haut-droit.
  /// Valeurs > 99 sont rendues `"99+"`.
  final int? badgeCount;

  bool get _tappable => onTap != null;

  Color _bgColor(OAColors c) {
    switch (tone) {
      case OAItemTone.paper:
        return c.paper.warm.withValues(alpha: 0.08);
      case OAItemTone.ink:
        return c.ink.mid.withValues(alpha: 0.6);
      case OAItemTone.amber:
        return c.amber.halo;
      case OAItemTone.teal:
        return c.teal.deep.withValues(alpha: 0.5);
    }
  }

  String _formatBadge(int n) =>
      n > _kBadgeCountClampMax ? '$_kBadgeCountClampMax+' : n.toString();

  @override
  Widget build(BuildContext context) {
    final colors = context.oaColors;
    final spacing = context.oaSpacing;
    final shadows = context.oaShadows;

    final borderColor = selected ? colors.amber.base : colors.paper.warm;

    final tile = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _bgColor(colors),
        border: Border.all(
          color: borderColor,
          width: spacing.borderWidths.b2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.ink.voidColor,
            offset: shadows.blockSmall,
            blurRadius: 0,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: image,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
            if (badgeCount != null)
              Positioned(
                top: spacing.s1,
                right: spacing.s1,
                child: OAPill(
                  label: _formatBadge(badgeCount!),
                  tone: OAPillTone.amber,
                  dense: true,
                ),
              ),
          ],
        ),
      ),
    );

    final framed = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _tappable ? spacing.hitTargets.large : 0,
        minHeight: _tappable ? spacing.hitTargets.large : 0,
      ),
      child: tile,
    );

    if (!_tappable) {
      return Semantics(label: label, image: true, child: framed);
    }

    return Semantics(
      label: label,
      button: true,
      enabled: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, child: framed),
      ),
    );
  }
}
