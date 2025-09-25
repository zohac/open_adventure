import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';
import 'package:open_adventure/presentation/widgets/pixel_canvas.dart';

/// Displays the hero pixel art banner rendered inside the pixel canvas.
class HomeHeroBanner extends StatelessWidget {
  /// Creates a [HomeHeroBanner] ready to paint the cavern illustration.
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PixelCanvas(
            child: CustomPaint(
              painter: _HomeHeroPixelArtPainter(
                scheme: scheme,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeHeroTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.homeHeroSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeroPixelArtPainter extends CustomPainter {
  _HomeHeroPixelArtPainter({required this.scheme});

  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    const double unit = 4;
    final Paint paint = Paint()..isAntiAlias = false;

    void draw(double x, double y, double w, double h, Color color) {
      paint.color = color;
      canvas.drawRect(
        Rect.fromLTWH(x * unit, y * unit, w * unit, h * unit),
        paint,
      );
    }

    // Background cavern gradient blocks.
    draw(0, 0, 80, 45, const Color(0xFF0B0D16));
    draw(0, 0, 80, 18, const Color(0xFF11162A));
    draw(0, 18, 80, 12, const Color(0xFF151D34));
    draw(0, 30, 80, 8, const Color(0xFF1C223A));
    draw(0, 38, 80, 7, const Color(0xFF0B0D16));

    // Cave walls and stalactites.
    draw(4, 4, 6, 14, const Color(0xFF2D223D));
    draw(10, 2, 8, 16, const Color(0xFF372B4C));
    draw(26, 1, 6, 20, const Color(0xFF2A203B));
    draw(36, 3, 6, 22, const Color(0xFF433359));
    draw(50, 2, 7, 18, const Color(0xFF2F2343));
    draw(60, 5, 6, 16, const Color(0xFF3B2D4F));
    draw(68, 6, 5, 12, const Color(0xFF2A1F39));

    // Floor stones.
    draw(0, 42, 12, 3, const Color(0xFF3C2E44));
    draw(12, 41, 10, 4, const Color(0xFF4A3955));
    draw(24, 40, 14, 5, const Color(0xFF3A2B4E));
    draw(40, 41, 12, 4, const Color(0xFF4F3A5C));
    draw(52, 42, 10, 3, const Color(0xFF3B2B48));
    draw(62, 41, 18, 4, const Color(0xFF34203F));

    // Torch and light glow near entrance.
    final Color torchBase = const Color(0xFF5D3A1F);
    final Color torchFlame = const Color(0xFFFFB547);
    draw(20, 20, 2, 10, torchBase);
    draw(20, 18, 2, 2, torchFlame);
    draw(19, 21, 4, 4, torchFlame.withValues(alpha: 0.6));

    // Entrance arch with subtle highlight influenced by theme primary/secondary.
    final Color highlight = Color.alphaBlend(
      scheme.secondary.withValues(alpha: 0.35),
      const Color(0xFF2E243E),
    );
    draw(44, 18, 14, 14, highlight);
    draw(48, 22, 6, 10, const Color(0xFF120F1F));

    // Foreground silhouette framing bottom corners.
    draw(0, 36, 6, 9, const Color(0xFF07060D));
    draw(74, 34, 6, 11, const Color(0xFF07060D));
  }

  @override
  bool shouldRepaint(covariant _HomeHeroPixelArtPainter oldDelegate) {
    return oldDelegate.scheme != scheme;
  }
}
