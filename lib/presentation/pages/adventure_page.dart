import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/presentation/widgets/location_image.dart';

/// First iteration of the Adventure screen (S2) showing description, travel
/// buttons and a minimal journal backed by the [GameController].
class AdventurePage extends StatefulWidget {
  const AdventurePage({
    super.key,
    required this.controller,
    this.initializeOnMount = true,
    this.disposeController = false,
  });

  /// Application controller orchestrating the game.
  final GameController controller;

  /// If true (default), `init()` is called after the first frame.
  final bool initializeOnMount;

  /// If true, the provided controller will be disposed when the widget is
  /// removed from the tree (useful for local previews/tests).
  final bool disposeController;

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage> {
  @override
  void initState() {
    super.initState();
    if (widget.initializeOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.init();
      });
    }
  }

  @override
  void dispose() {
    if (widget.disposeController) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<GameViewState>(
          valueListenable: widget.controller,
          builder: (context, state, _) {
            final title = state.locationTitle.isEmpty
                ? 'Open Adventure'
                : state.locationTitle;
            return Text(title);
          },
        ),
      ),
      body: ValueListenableBuilder<GameViewState>(
        valueListenable: widget.controller,
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;
                      const double ratio = 16 / 9;
                      final double computedHeight = maxWidth.isFinite && maxWidth > 0
                          ? math.min(maxWidth / ratio, 240)
                          : 180.0;
                      return SizedBox(
                        height: computedHeight,
                        child: LocationImage(
                          mapTag: state.locationMapTag,
                          name: state.locationTitle,
                          id: state.locationId,
                          semanticsLabel: state.locationTitle.isEmpty
                              ? 'Illustration du lieu'
                              : state.locationTitle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _DescriptionSection(description: state.locationDescription),
                  const SizedBox(height: 24),
                  _ActionsSection(
                    actions: state.actions,
                    onActionSelected: widget.controller.perform,
                  ),
                  const SizedBox(height: 24),
                  _JournalSection(entries: state.journal),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: theme.titleMedium),
        const SizedBox(height: 8),
        Text(
          description.isEmpty ? '...' : description,
          style: theme.bodyMedium,
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection(
      {required this.actions, required this.onActionSelected});

  final List<ActionOption> actions;
  final Future<void> Function(ActionOption) onActionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final hasTravelActions =
        actions.any((action) => action.category == 'travel');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions', style: theme.titleMedium),
        const SizedBox(height: 8),
        if (!hasTravelActions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Aucune sortie immédiate. Observez les alentours.',
              style: theme.bodyMedium,
            ),
          ),
        if (actions.isEmpty)
          Text('No actions available', style: theme.bodyMedium)
        else
          ...actions.map((action) => _ActionButton(
                action: action,
                onActionSelected: onActionSelected,
              )),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onActionSelected});

  final ActionOption action;
  final Future<void> Function(ActionOption) onActionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(IconsHelper.iconForName(action.icon ?? 'directions_walk')),
          label: Text(_resolveLabel(action.label)),
          onPressed: () => onActionSelected(action),
        ),
      ),
    );
  }
}

class _JournalSection extends StatelessWidget {
  const _JournalSection({required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journal', style: theme.titleMedium),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text('No events yet', style: theme.bodyMedium)
        else
          ...entries.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    entry.value,
                    style: theme.bodySmall,
                  ),
                ),
              ),
      ],
    );
  }
}

/// Helper bridging icon names from the domain to Material icons for S2.
class IconsHelper {
  static IconData iconForName(String iconName) {
    switch (iconName) {
      case 'arrow_upward':
        return Icons.arrow_upward;
      case 'arrow_downward':
        return Icons.arrow_downward;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'undo':
        return Icons.undo;
      case 'redo':
        return Icons.redo;
      case 'north_east':
        return Icons.north_east;
      case 'north_west':
        return Icons.north_west;
      case 'south_east':
        return Icons.south_east;
      case 'south_west':
        return Icons.south_west;
      case 'visibility':
        return Icons.visibility;
      default:
        return Icons.directions_walk;
    }
  }
}

String _resolveLabel(String rawLabel) {
  const mapping = <String, String>{
    'motion.north.label': 'Aller Nord',
    'motion.south.label': 'Aller Sud',
    'motion.east.label': 'Aller Est',
    'motion.west.label': 'Aller Ouest',
    'motion.up.label': 'Monter',
    'motion.down.label': 'Descendre',
    'motion.enter.label': 'Entrer',
    'motion.in.label': 'Entrer',
    'motion.out.label': 'Sortir',
    'motion.forward.label': 'Avancer',
    'motion.back.label': 'Reculer',
    'motion.ne.label': 'Aller Nord-Est',
    'motion.se.label': 'Aller Sud-Est',
    'motion.sw.label': 'Aller Sud-Ouest',
    'motion.nw.label': 'Aller Nord-Ouest',
    'actions.observer.label': 'Observer',
  };

  final resolved = mapping[rawLabel];
  if (resolved != null) {
    return resolved;
  }
  if (rawLabel.startsWith('motion.') && rawLabel.endsWith('.label')) {
    final token = rawLabel.substring(7, rawLabel.length - 6);
    final display = token
        .replaceAll('_', '-')
        .split('-')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join('-');
    return 'Aller $display';
  }
  return rawLabel;
}
