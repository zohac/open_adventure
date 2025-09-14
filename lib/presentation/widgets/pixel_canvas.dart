// lib/presentation/widgets/pixel_canvas.dart
// Pixel-perfect canvas for 16-bit style rendering with integer scaling.

import 'package:flutter/material.dart';

class PixelCanvas extends StatelessWidget {
  const PixelCanvas({
    super.key,
    required this.child,
    this.baseWidth = 320,
    this.baseHeight = 180,
    this.backgroundColor = Colors.black,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final int baseWidth;
  final int baseHeight;
  final Color backgroundColor;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screen = MediaQuery.of(context).size;
        final double maxW = constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screen.width;
        final double maxH = constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : screen.height;

        final double sx = maxW / baseWidth;
        final double sy = maxH / baseHeight;
        double scale = sx.isFinite && sy.isFinite ? (sx < sy ? sx : sy) : 1.0;
        final int intScale = scale.floor().clamp(1, 1000);
        scale = intScale.toDouble();

        final double usedW = baseWidth * scale;
        final double usedH = baseHeight * scale;

        return ColoredBox(
          color: backgroundColor,
          child: Center(
            child: SizedBox(
              width: usedW,
              height: usedH,
              child: Transform.scale(
                alignment: alignment,
                // Keep pixels crisp.
                filterQuality: FilterQuality.none,
                scale: scale,
                child: SizedBox(
                  width: baseWidth.toDouble(),
                  height: baseHeight.toDouble(),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

