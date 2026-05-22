// OAStamp — primary action button atom for Open Adventure.
// Cf. `design_handoff_open_adventure/action-buttons.jsx` for visual reference.
// Story 5-4 — Atomes UI partagés.

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';
import '../theme/oa_colors.dart';
import '../theme/oa_spacing.dart';
import 'oa_icon.dart';

enum OAStampVariant { primary, secondary, ghost }

enum OAStampSize { compact, regular, large }

@immutable
class OAStamp extends StatelessWidget {
  const OAStamp({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OAStampVariant.primary,
    this.iconLeading,
    this.iconTrailing,
    this.fullWidth = false,
    this.size = OAStampSize.regular,
  });

  /// Label déjà résolu (i18n côté caller).
  final String label;

  /// `null` → bouton désactivé.
  final VoidCallback? onPressed;

  final OAStampVariant variant;
  final IconData? iconLeading;
  final IconData? iconTrailing;
  final bool fullWidth;
  final OAStampSize size;

  bool get _enabled => onPressed != null;

  double _minHeight(OASpacing s) {
    switch (size) {
      case OAStampSize.compact:
        return s.hitTargets.min; // 44
      case OAStampSize.regular:
        return s.hitTargets.comfy; // 48
      case OAStampSize.large:
        return s.hitTargets.large; // 56
    }
  }

  EdgeInsets _padding(OASpacing s) {
    switch (size) {
      case OAStampSize.compact:
        return EdgeInsets.symmetric(horizontal: s.s3, vertical: s.s2);
      case OAStampSize.regular:
        return EdgeInsets.symmetric(horizontal: s.s4, vertical: s.s3);
      case OAStampSize.large:
        return EdgeInsets.symmetric(horizontal: s.s5, vertical: s.s4);
    }
  }

  ({Color bg, Color border, Color fg, double borderWidth, List<BoxShadow> shadow})
      _resolveTone(OAColors c) {
    switch (variant) {
      case OAStampVariant.primary:
        return (
          bg: c.amber.base,
          border: c.amber.shadow,
          fg: c.paper.bright,
          borderWidth: 2,
          shadow: [
            BoxShadow(
              color: c.amber.shadow,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        );
      case OAStampVariant.secondary:
        return (
          bg: Colors.transparent,
          border: c.paper.warm,
          fg: c.paper.warm,
          borderWidth: 2,
          shadow: [
            BoxShadow(
              color: c.ink.voidColor,
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        );
      case OAStampVariant.ghost:
        return (
          bg: Colors.transparent,
          border: Colors.transparent,
          fg: c.paper.faded,
          borderWidth: 0,
          shadow: const <BoxShadow>[],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.oaColors;
    final typo = context.oaTypography;
    final spacing = context.oaSpacing;
    final tone = _resolveTone(colors);

    final content = Padding(
      padding: _padding(spacing),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (iconLeading != null) ...<Widget>[
            OAIcon(iconLeading!, size: OAIconSize.s, color: tone.fg),
            SizedBox(width: spacing.s2),
          ],
          Flexible(
            child: Text(
              label,
              style: typo.action.copyWith(color: tone.fg),
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (iconTrailing != null) ...<Widget>[
            SizedBox(width: spacing.s2),
            OAIcon(iconTrailing!, size: OAIconSize.s, color: tone.fg),
          ],
        ],
      ),
    );

    final decorated = AnimatedOpacity(
      duration: context.oaMotion.durFast,
      opacity: _enabled ? 1.0 : 0.45,
      child: Container(
        constraints: BoxConstraints(minHeight: _minHeight(spacing)),
        decoration: BoxDecoration(
          color: tone.bg,
          border: tone.borderWidth > 0
              ? Border.all(color: tone.border, width: tone.borderWidth)
              : null,
          boxShadow: _enabled ? tone.shadow : const <BoxShadow>[],
        ),
        child: content,
      ),
    );

    final button = Semantics(
      label: label,
      button: true,
      enabled: _enabled,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          focusColor: colors.amber.base.withValues(alpha: 0.16),
          highlightColor: colors.amber.base.withValues(alpha: 0.08),
          splashColor: colors.amber.glow.withValues(alpha: 0.12),
          child: decorated,
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
