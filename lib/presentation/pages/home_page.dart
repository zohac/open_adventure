import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';
import 'package:open_adventure/presentation/pages/credits_page.dart';
import 'package:open_adventure/presentation/pages/saves_page.dart';
import 'package:open_adventure/presentation/pages/settings_page.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';
import 'package:open_adventure/presentation/widgets/pixel_canvas.dart';

/// HomePage v0 — presents the entry menu for starting or resuming the adventure.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage] wired with the provided controllers.
  const HomePage({
    super.key,
    required this.gameController,
    required this.homeController,
    required this.audioSettingsController,
    this.initializeOnMount = true,
  });

  /// Main game controller used when entering the adventure.
  final GameController gameController;

  /// Controller exposing autosave status and menu state.
  final HomeController homeController;

  /// Controller driving the audio settings page navigation.
  final AudioSettingsController audioSettingsController;

  /// Whether the page should trigger the autosave lookup after mounting.
  final bool initializeOnMount;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (widget.initializeOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.homeController.refreshAutosave();
      });
    }
  }

  void _openAdventure() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdventurePage(
          controller: widget.gameController,
          audioSettingsController: widget.audioSettingsController,
          initializeOnMount: true,
          disposeController: false,
        ),
      ),
    );
  }

  void _openSaves() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SavesPage(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          audioSettingsController: widget.audioSettingsController,
          disposeController: false,
        ),
      ),
    );
  }

  void _openCredits() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CreditsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<HomeViewState>(
          valueListenable: widget.homeController,
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final verticalPadding =
                    constraints.maxHeight > 600 ? AppSpacing.xl : AppSpacing.lg;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: verticalPadding),
                      const _HeroBanner(),
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _PrimaryMenuButton(
                                  label: 'Nouvelle partie',
                                  subtitle:
                                      'Commencer l\'exploration de la caverne',
                                  icon: Icons.play_arrow_rounded,
                                  accentColor:
                                      Theme.of(context).colorScheme.primary,
                                  onPressed: _openAdventure,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _PrimaryMenuButton(
                                  label: 'Continuer',
                                  subtitle: state.autosave != null
                                      ? 'Dernier tour : ${state.autosave!.turns}, lieu #${state.autosave!.loc}'
                                      : 'Aucune sauvegarde automatique détectée',
                                  icon: Icons.history_rounded,
                                  accentColor:
                                      Theme.of(context).colorScheme.secondary,
                                  onPressed:
                                      state.autosave != null ? _openAdventure : null,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _PrimaryMenuButton(
                                  label: 'Charger',
                                  subtitle: 'Accéder aux sauvegardes manuelles',
                                  icon: Icons.folder_open_rounded,
                                  accentColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  onPressed: _openSaves,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _PrimaryMenuButton(
                                  label: 'Options',
                                  subtitle:
                                      'Configurer l\'expérience audio et tactile',
                                  icon: Icons.tune_rounded,
                                  accentColor:
                                      _metaAccent(Theme.of(context).brightness),
                                  showAccentStripe: false,
                                  onPressed: _openSettings,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _PrimaryMenuButton(
                                  label: 'Crédits',
                                  subtitle: 'L\'équipe derrière cette aventure',
                                  icon: Icons.info_outline_rounded,
                                  accentColor:
                                      _metaAccent(Theme.of(context).brightness),
                                  showAccentStripe: false,
                                  onPressed: _openCredits,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PixelCanvas(
            child: CustomPaint(
              painter: _HeroPixelArtPainter(
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
                  'Open Adventure',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Partez pour l\'expédition textuelle culte, remasterisée pour mobile.',
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

class _HeroPixelArtPainter extends CustomPainter {
  _HeroPixelArtPainter({required this.scheme});

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
  bool shouldRepaint(covariant _HeroPixelArtPainter oldDelegate) {
    return oldDelegate.scheme != scheme;
  }
}

class _PrimaryMenuButton extends StatelessWidget {
  const _PrimaryMenuButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.accentColor,
    this.showAccentStripe = true,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;
  /// Controls whether the accent stripe is painted on the left side.
  final bool showAccentStripe;
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
                    color:
                        showAccentStripe ? accentForState : Colors.transparent,
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

Color _metaAccent(Brightness brightness) {
  return brightness == Brightness.dark
      ? const Color(0xFF9E9E9E)
      : const Color(0xFF616161);
}
