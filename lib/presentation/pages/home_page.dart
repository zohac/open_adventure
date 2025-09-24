import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/application/controllers/home_controller.dart';
import 'package:open_adventure/presentation/pages/adventure_page.dart';
import 'package:open_adventure/presentation/pages/credits_page.dart';
import 'package:open_adventure/presentation/pages/home/widgets/home_hero_banner.dart';
import 'package:open_adventure/presentation/pages/home/widgets/home_menu_button.dart';
import 'package:open_adventure/presentation/pages/saves_page.dart';
import 'package:open_adventure/presentation/pages/settings_page.dart';
import 'package:open_adventure/presentation/theme/app_colors.dart';
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
                final verticalPadding =
                    constraints.maxHeight > 600 ? AppSpacing.xl : AppSpacing.lg;
                final theme = Theme.of(context);
                final scheme = theme.colorScheme;
                final AppActionAccents accents =
                    theme.extension<AppActionAccents>()!;

                final menuConfigurations =
                    _menuConfigurations(state, scheme, accents);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: verticalPadding),
                      const HomeHeroBanner(),
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
                              children: _buildMenu(menuConfigurations),
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

  List<_MenuConfiguration> _menuConfigurations(
    HomeViewState state,
    ColorScheme scheme,
    AppActionAccents accents,
  ) {
    return [
      _MenuConfiguration(
        label: 'Nouvelle partie',
        subtitle: 'Commencer l\'exploration de la caverne',
        icon: Icons.play_arrow_rounded,
        accentColor: scheme.primary,
        onPressed: _openAdventure,
      ),
      _MenuConfiguration(
        label: 'Continuer',
        subtitle: state.autosave != null
            ? 'Dernier tour : ${state.autosave!.turns}, lieu #${state.autosave!.loc}'
            : null,
        icon: Icons.bookmark_rounded,
        accentColor: scheme.secondary,
        onPressed: state.autosave != null ? _openAdventure : null,
      ),
      _MenuConfiguration(
        label: 'Charger',
        subtitle: 'Accéder aux sauvegardes manuelles',
        icon: Icons.folder_open_rounded,
        accentColor: scheme.tertiary,
        onPressed: _openSaves,
      ),
      _MenuConfiguration(
        label: 'Options',
        subtitle: 'Configurer l\'expérience audio et tactile',
        icon: Icons.tune_rounded,
        accentColor: accents.meta,
        onPressed: _openSettings,
      ),
      _MenuConfiguration(
        label: 'Crédits',
        subtitle: 'L\'équipe derrière cette aventure',
        icon: Icons.info_outline_rounded,
        accentColor: accents.meta,
        onPressed: _openCredits,
      ),
    ];
  }

  List<Widget> _buildMenu(List<_MenuConfiguration> configurations) {
    final widgets = <Widget>[];
    for (var i = 0; i < configurations.length; i++) {
      final configuration = configurations[i];
      widgets.add(
        HomeMenuButton(
          label: configuration.label,
          subtitle: configuration.subtitle,
          icon: configuration.icon,
          accentColor: configuration.accentColor,
          onPressed: configuration.onPressed,
        ),
      );
      if (i < configurations.length - 1) {
        widgets.add(const SizedBox(height: AppSpacing.md));
      }
    }
    return widgets;
  }
}

class _MenuConfiguration {
  _MenuConfiguration({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onPressed,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onPressed;
}
