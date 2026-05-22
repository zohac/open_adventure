// OAPill — badge/tag compact (status pill, score, lamp gauge).
// Story 5-4 — Atomes UI partagés.

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';
import '../theme/oa_colors.dart';
import 'oa_icon.dart';

enum OAPillTone { neutral, amber, teal, danger, success, magic, treasure }

@immutable
class OAPill extends StatelessWidget {
  const OAPill({
    super.key,
    required this.label,
    this.tone = OAPillTone.neutral,
    this.iconLeading,
    this.dense = false,
  });

  final String label;
  final OAPillTone tone;
  final IconData? iconLeading;

  /// `dense=true` → caps-s + padding réduit.
  final bool dense;

  ({Color bg, Color border, Color fg}) _resolveTone(OAColors c) {
    switch (tone) {
      case OAPillTone.neutral:
        return (
          bg: c.ink.mid.withValues(alpha: 0.6),
          border: c.ink.line,
          fg: c.paper.warm,
        );
      case OAPillTone.amber:
        return (
          bg: c.amber.halo,
          border: c.amber.base,
          fg: c.amber.glow,
        );
      case OAPillTone.teal:
        return (
          bg: c.teal.deep.withValues(alpha: 0.5),
          border: c.teal.glow,
          fg: c.teal.glow,
        );
      case OAPillTone.danger:
        return (
          bg: c.semantic.danger.withValues(alpha: 0.18),
          border: c.semantic.danger,
          fg: c.semantic.danger,
        );
      case OAPillTone.success:
        return (
          bg: c.semantic.success.withValues(alpha: 0.18),
          border: c.semantic.success,
          fg: c.semantic.success,
        );
      case OAPillTone.magic:
        return (
          bg: c.semantic.magic.withValues(alpha: 0.18),
          border: c.semantic.magic,
          fg: c.semantic.magic,
        );
      case OAPillTone.treasure:
        return (
          bg: c.semantic.treasure.withValues(alpha: 0.18),
          border: c.semantic.treasure,
          fg: c.semantic.treasure,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.oaColors;
    final typo = context.oaTypography;
    final spacing = context.oaSpacing;
    final t = _resolveTone(colors);

    final textStyle = (dense ? typo.caps.s : typo.caps.m).copyWith(color: t.fg);
    final padding = dense
        ? EdgeInsets.symmetric(horizontal: spacing.s2, vertical: spacing.s1)
        : EdgeInsets.symmetric(horizontal: spacing.s3, vertical: spacing.s2);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.border, width: spacing.borderWidths.b1),
        borderRadius: BorderRadius.circular(spacing.radii.r1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (iconLeading != null) ...<Widget>[
            OAIcon(
              iconLeading!,
              size: dense ? OAIconSize.s : OAIconSize.s,
              color: t.fg,
            ),
            SizedBox(width: spacing.s1),
          ],
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}
