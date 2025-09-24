import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';
import 'package:open_adventure/presentation/pages/credits_page.dart';
import 'package:open_adventure/presentation/pages/saves_page.dart';
import 'package:open_adventure/presentation/pages/settings_page.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';

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
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _HeroBanner(),
                    const SizedBox(height: AppSpacing.xl),
                    _PrimaryMenuButton(
                      label: 'Nouvelle partie',
                      subtitle: 'Commencer l\'exploration de la caverne',
                      icon: Icons.play_arrow_rounded,
                      accentColor: Theme.of(context).colorScheme.primary,
                      onPressed: _openAdventure,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PrimaryMenuButton(
                      label: 'Continuer',
                      subtitle: state.autosave != null
                          ? 'Dernier tour : ${state.autosave!.turns}, lieu #${state.autosave!.loc}'
                          : 'Aucune sauvegarde automatique détectée',
                      icon: Icons.history_rounded,
                      accentColor: Theme.of(context).colorScheme.secondary,
                      onPressed: state.autosave != null ? _openAdventure : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PrimaryMenuButton(
                      label: 'Charger',
                      subtitle: 'Accéder aux sauvegardes manuelles',
                      icon: Icons.folder_open_rounded,
                      accentColor: Theme.of(context).colorScheme.tertiary,
                      onPressed: _openSaves,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryMenuButton(
                            label: 'Options',
                            icon: Icons.tune_rounded,
                            onPressed: _openSettings,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SecondaryMenuButton(
                            label: 'Crédits',
                            icon: Icons.info_outline_rounded,
                            onPressed: _openCredits,
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        vertical: constraints.maxHeight > 600
                            ? AppSpacing.xl
                            : AppSpacing.lg,
                      ),
                      child: content,
                    ),
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer,
              scheme.tertiaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Open Adventure',
              style: textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Partez pour l\'expédition textuelle culte, remasterisée pour mobile.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryMenuButton extends StatelessWidget {
  const _PrimaryMenuButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
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
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        enabled ? accentColor : scheme.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  icon,
                  size: 28,
                  color:
                      enabled ? scheme.onSurface : scheme.onSurfaceVariant.withValues(alpha: 0.6),
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
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryMenuButton extends StatelessWidget {
  const _SecondaryMenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22, color: scheme.primary),
      label: Text(label),
    );
  }
}
