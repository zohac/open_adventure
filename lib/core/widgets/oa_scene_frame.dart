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

    final inner = ClipRect(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            child,
            if (lampHaloIntensity > 0)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.1),
                      radius: 0.85,
                      colors: <Color>[
                        colors.amber.base
                            .withValues(alpha: 0.32 * lampHaloIntensity),
                        colors.amber.base
                            .withValues(alpha: 0.12 * lampHaloIntensity),
                        colors.amber.base.withValues(alpha: 0),
                      ],
                      stops: const <double>[0.0, 0.35, 0.7],
                    ),
                  ),
                ),
              ),
            if (locationName != null)
              Positioned(
                left: spacing.s3,
                bottom: spacing.s3,
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
                      style: typo.caps.m.copyWith(color: colors.paper.bright),
                    ),
                  ),
                ),
              ),
          ],
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
