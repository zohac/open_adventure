// OASceneFrame — double-bordered 16:9 frame for location scene images.
// Cf. `design_handoff_open_adventure/pixel-ui.jsx` ScenePlaceholder.
// Story 5-4 — Atomes UI partagés.

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

@immutable
class OASceneFrame extends StatelessWidget {
  const OASceneFrame({
    super.key,
    required this.child,
    this.locationName,
    this.lampHaloIntensity = 0.0,
  }) : assert(
          lampHaloIntensity >= 0.0 && lampHaloIntensity <= 1.0,
          'lampHaloIntensity must be in [0, 1]',
        );

  /// Typiquement `PixelCanvas(child: Image.asset(...))`.
  final Widget child;

  /// Overlay caps-m en bas-gauche. `null` → pas d'overlay.
  final String? locationName;

  /// 0 = pas de halo, 1 = halo lampe à pleine intensité.
  final double lampHaloIntensity;

  @override
  Widget build(BuildContext context) {
    final colors = context.oaColors;
    final typo = context.oaTypography;
    final spacing = context.oaSpacing;

    final outerBorderWidth = spacing.borderWidths.b2;
    final innerBorderWidth = spacing.borderWidths.b1;

    // Clamp runtime : l'`assert` du constructeur est strippé en release ; on
    // garantit ici que l'intensité est finie et bornée pour éviter une
    // `RadialGradient` invalide (couleurs avec alpha NaN/Infinity).
    final double safeIntensity = lampHaloIntensity.isFinite
        ? lampHaloIntensity.clamp(0.0, 1.0)
        : 0.0;

    final inner = ClipRect(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxLabelWidth =
                constraints.maxWidth - spacing.s3 * 2;

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                child,
                if (safeIntensity > 0)
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        // Paramètres `Alignment(0,-0.1)`, `radius: 0.85` et
                        // `stops: [0, 0.35, 0.7]` : spécifiques à l'effet lamp
                        // halo (cf. handoff `pixel-ui.jsx` ScenePlaceholder),
                        // pas des tokens design partagés.
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.1),
                          radius: 0.85,
                          colors: <Color>[
                            colors.amber.base
                                .withValues(alpha: 0.32 * safeIntensity),
                            colors.amber.base
                                .withValues(alpha: 0.12 * safeIntensity),
                            colors.amber.base.withValues(alpha: 0),
                          ],
                          stops: const <double>[0.0, 0.35, 0.7],
                        ),
                      ),
                    ),
                  ),
                if (locationName != null)
                  PositionedDirectional(
                    start: spacing.s3,
                    bottom: spacing.s3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxLabelWidth),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.ink.voidColor.withValues(alpha: 0.72),
                          border: Border.all(
                            color: colors.paper.warm.withValues(alpha: 0.45),
                            width: innerBorderWidth,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.s2,
                            vertical: spacing.s1,
                          ),
                          child: Text(
                            locationName!,
                            style: typo.caps.m
                                .copyWith(color: colors.paper.bright),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.paper.warm, width: outerBorderWidth),
      ),
      padding: EdgeInsets.all(outerBorderWidth),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.paper.warm,
            width: innerBorderWidth,
          ),
        ),
        child: inner,
      ),
    );
  }
}
