// OAStamp — primary action button atom for Open Adventure.
// Cf. `design_handoff_open_adventure/action-buttons.jsx` for visual reference.
// Story 5-4 — Atomes UI partagés.

import 'package:flutter/material.dart';

import '../motion/oa_animations.dart';
import '../theme/build_context_x.dart';
import '../theme/oa_colors.dart';
import '../theme/oa_shadows.dart';
import '../theme/oa_spacing.dart';
import 'oa_icon.dart';

enum OAStampVariant { primary, secondary, ghost }

enum OAStampSize { compact, regular, large }

class OAStamp extends StatefulWidget {
  OAStamp({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OAStampVariant.primary,
    this.iconLeading,
    this.iconTrailing,
    this.fullWidth = false,
    this.size = OAStampSize.regular,
  }) : assert(
          label.isNotEmpty || iconLeading != null || iconTrailing != null,
          'OAStamp must have a label or at least one icon for accessibility.',
        );

  /// Label déjà résolu (i18n côté caller).
  final String label;

  /// `null` → bouton désactivé.
  final VoidCallback? onPressed;

  final OAStampVariant variant;
  final IconData? iconLeading;
  final IconData? iconTrailing;
  final bool fullWidth;
  final OAStampSize size;

  @override
  State<OAStamp> createState() => _OAStampState();
}

class _OAStampState extends State<OAStamp> {
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  double _minHeight(OASpacing s) {
    switch (widget.size) {
      case OAStampSize.compact:
        return s.hitTargets.min; // 44
      case OAStampSize.regular:
        return s.hitTargets.comfy; // 48
      case OAStampSize.large:
        return s.hitTargets.large; // 56
    }
  }

  EdgeInsets _padding(OASpacing s) {
    switch (widget.size) {
      case OAStampSize.compact:
        return EdgeInsets.symmetric(horizontal: s.s3, vertical: s.s2);
      case OAStampSize.regular:
        return EdgeInsets.symmetric(horizontal: s.s4, vertical: s.s3);
      case OAStampSize.large:
        return EdgeInsets.symmetric(horizontal: s.s5, vertical: s.s4);
    }
  }

  ({
    Color bg,
    Color border,
    Color fg,
    double borderWidth,
    List<BoxShadow> shadow,
  }) _resolveTone(OAColors c, OASpacing s, OAShadows sh) {
    switch (widget.variant) {
      case OAStampVariant.primary:
        return (
          bg: c.amber.base,
          border: c.amber.shadow,
          fg: c.paper.bright,
          borderWidth: s.borderWidths.b2,
          shadow: <BoxShadow>[
            BoxShadow(
              color: c.amber.shadow,
              offset: sh.blockMedium,
              blurRadius: 0,
            ),
          ],
        );
      case OAStampVariant.secondary:
        return (
          bg: Colors.transparent,
          border: c.paper.warm,
          fg: c.paper.warm,
          borderWidth: s.borderWidths.b2,
          shadow: <BoxShadow>[
            BoxShadow(
              color: c.ink.voidColor,
              offset: sh.blockSmall,
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
    final shadows = context.oaShadows;
    final tone = _resolveTone(colors, spacing, shadows);

    final content = Padding(
      padding: _padding(spacing),
      child: Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (widget.iconLeading != null) ...<Widget>[
            OAIcon(widget.iconLeading!, size: OAIconSize.s, color: tone.fg),
            SizedBox(width: spacing.s2),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: typo.action.copyWith(color: tone.fg),
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.iconTrailing != null) ...<Widget>[
            SizedBox(width: spacing.s2),
            OAIcon(widget.iconTrailing!, size: OAIconSize.s, color: tone.fg),
          ],
        ],
      ),
    );

    // Focus ring : outline 2px ambre, rendu **en plus** de la bordure
    // habituelle, sans recalculer le layout (Stack + Positioned.fill).
    final focusOutline = _focused
        ? Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.amber.base,
                    width: spacing.borderWidths.b2,
                  ),
                ),
              ),
            ),
          )
        : null;

    final fast = context.oaMotion.resolve(OAAnimationSemantic.fast);
    final decorated = AnimatedOpacity(
      duration: fast.duration,
      curve: fast.curve,
      opacity: _enabled ? 1.0 : 0.45,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _minHeight(spacing),
          minWidth: _minHeight(spacing), // hit target horizontal (WCAG 2.5.5)
        ),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: tone.bg,
                border: tone.borderWidth > 0
                    ? Border.all(color: tone.border, width: tone.borderWidth)
                    : null,
                boxShadow: _enabled ? tone.shadow : const <BoxShadow>[],
              ),
              child: content,
            ),
            ?focusOutline,
          ],
        ),
      ),
    );

    final button = Semantics(
      label: widget.label.isEmpty ? null : widget.label,
      button: true,
      enabled: _enabled,
      child: Material(
        type: MaterialType.transparency,
        child: FocusableActionDetector(
          enabled: _enabled,
          onShowFocusHighlight: (focused) {
            if (focused != _focused) setState(() => _focused = focused);
          },
          child: InkWell(
            onTap: widget.onPressed,
            highlightColor: colors.amber.base.withValues(alpha: 0.08),
            splashColor: colors.amber.glow.withValues(alpha: 0.12),
            child: decorated,
          ),
        ),
      ),
    );

    return widget.fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
