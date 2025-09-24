import 'package:flutter/material.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';

/// A primary action button displayed in the home menu.
class HomeMenuButton extends StatelessWidget {
  /// Creates a [HomeMenuButton] with a title, subtitle and accent styling.
  const HomeMenuButton({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    this.accentColor,
    this.showAccentStripe = true,
    required this.onPressed,
  });

  /// Main button label.
  final String label;

  /// Supporting description displayed under [label].
  final String subtitle;

  /// Icon representing the action category.
  final IconData icon;

  /// Optional accent tint applied to the stripe and icon.
  final Color? accentColor;

  /// Controls whether the accent stripe is painted on the left side.
  final bool showAccentStripe;

  /// Callback triggered when the button is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;
    final Color backgroundColor = enabled
        ? scheme.surface
        : scheme.onSurface.withValues(alpha: 0.12);
    final bool hasAccent = accentColor != null;
    final Color? baseAccent = accentColor;
    final Color accentForState = hasAccent
        ? (enabled
            ? baseAccent!
            : baseAccent!.withValues(alpha: 0.3))
        : Colors.transparent;
    final Color iconColor = hasAccent
        ? accentForState
        : (enabled
            ? scheme.onSurface
            : scheme.onSurface.withValues(alpha: 0.3));
    final Color labelColor = enabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.38);
    final Color subtitleColor = enabled
        ? scheme.onSurfaceVariant
        : scheme.onSurface.withValues(alpha: 0.38);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  key: ValueKey('homeMenuAccent-$label'),
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: showAccentStripe ? accentForState : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
