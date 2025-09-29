import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/l10n/app_localizations.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';
import 'package:open_adventure/presentation/widgets/icon_helper.dart';
import 'package:open_adventure/presentation/widgets/location_image.dart';
import 'package:open_adventure/presentation/pages/settings_page.dart';

/// First iteration of the Adventure screen (S2) showing description, travel
/// buttons and a minimal journal backed by the [GameController].
class AdventurePage extends StatefulWidget {
  const AdventurePage({
    super.key,
    required this.controller,
    this.initializeOnMount = true,
    this.disposeController = false,
    this.audioSettingsController,
  });

  /// Application controller orchestrating the game.
  final GameController controller;

  /// If true (default), `init()` is called after the first frame.
  final bool initializeOnMount;

  /// If true, the provided controller will be disposed when the widget is
  /// removed from the tree (useful for local previews/tests).
  final bool disposeController;

  /// Audio settings orchestrator (optional until the Settings page is wired).
  final AudioSettingsController? audioSettingsController;

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
            final l10n = AppLocalizations.of(context);
            final title = state.locationTitle.isEmpty
                ? l10n.appTitle
                : state.locationTitle;
            return Text(title);
          },
        ),
        actions: [
          if (widget.audioSettingsController != null)
            IconButton(
              icon: const Icon(Icons.volume_up_outlined),
              tooltip: AppLocalizations.of(
                context,
              ).adventureAudioSettingsTooltip,
              onPressed: () {
                final controller = widget.audioSettingsController!;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsPage(
                      audioSettingsController: controller,
                      initializeOnMount: false,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: ValueListenableBuilder<GameViewState>(
        valueListenable: widget.controller,
        builder: (context, state, _) {
          final l10n = AppLocalizations.of(context);
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;
                      const double ratio = 16 / 9;
                      final double computedHeight =
                          maxWidth.isFinite && maxWidth > 0
                          ? math.min(maxWidth / ratio, 240)
                          : 180.0;
                      return SizedBox(
                        height: computedHeight,
                        child: LocationImage(
                          mapTag: state.locationMapTag,
                          name: state.locationTitle,
                          id: state.locationId,
                          semanticsLabel: state.locationTitle.isEmpty
                              ? l10n.adventureLocationImageSemanticsFallback
                              : state.locationTitle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DescriptionSection(
                    description: state.locationDescription,
                    l10n: l10n,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ActionsSection(
                    l10n: l10n,
                    actions: state.actions,
                    onActionSelected: widget.controller.perform,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _JournalSection(entries: state.journal, l10n: l10n),
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
  const _DescriptionSection({required this.description, required this.l10n});

  final String description;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adventureDescriptionSectionTitle, style: theme.titleMedium),
        const SizedBox(height: 8),
        Text(
          description.isEmpty
              ? l10n.adventureDescriptionEmptyPlaceholder
              : description,
          style: theme.bodyMedium,
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.l10n,
    required this.actions,
    required this.onActionSelected,
  });

  static const int _maxVisibleWithoutOverflow = 7;
  static const int _visibleBeforeOverflow = 6;

  final AppLocalizations l10n;
  final List<ActionOption> actions;
  final Future<void> Function(ActionOption) onActionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final hasTravelActions = actions.any(
      (action) => action.category == 'travel',
    );
    final hasOverflow = actions.length > _maxVisibleWithoutOverflow;
    final int visibleCount = hasOverflow
        ? math.min(actions.length, _visibleBeforeOverflow)
        : actions.length;
    final visibleActions = actions.take(visibleCount).toList();
    final overflowActions = hasOverflow
        ? actions.skip(_visibleBeforeOverflow).toList()
        : const <ActionOption>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adventureActionsSectionTitle, style: theme.titleMedium),
        const SizedBox(height: 8),
        if (!hasTravelActions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.adventureActionsTravelMissingHint,
              style: theme.bodyMedium,
            ),
          ),
        if (actions.isEmpty)
          Text(l10n.adventureActionsEmptyState, style: theme.bodyMedium)
        else
          ...visibleActions.map(
            (action) => _ActionButton(
              l10n: l10n,
              action: action,
              onActionSelected: onActionSelected,
            ),
          ),
        if (overflowActions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.more_horiz),
                label: Text(l10n.adventureActionsMoreButtonLabel),
                onPressed: () {
                  _showOverflowActions(
                    context,
                    overflowActions,
                    onActionSelected,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showOverflowActions(
    BuildContext context,
    List<ActionOption> overflowActions,
    Future<void> Function(ActionOption) onActionSelected,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        final l10n = AppLocalizations.of(bottomSheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.adventureActionsMoreSheetTitle,
                  style: Theme.of(bottomSheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final action = overflowActions[index];
                    return _ActionButton(
                      l10n: l10n,
                      action: action,
                      onActionSelected: (selected) async {
                        Navigator.of(bottomSheetContext).pop();
                        await onActionSelected(selected);
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemCount: overflowActions.length,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.l10n,
    required this.action,
    required this.onActionSelected,
  });

  final AppLocalizations l10n;
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
          label: Text(l10n.resolveActionLabel(action.label)),
          onPressed: () => onActionSelected(action),
        ),
      ),
    );
  }
}

class _JournalSection extends StatelessWidget {
  const _JournalSection({required this.entries, required this.l10n});

  final List<String> entries;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adventureJournalSectionTitle, style: theme.titleMedium),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text(l10n.adventureJournalEmptyState, style: theme.bodyMedium)
        else
          ...entries.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(entry.value, style: theme.bodySmall),
            ),
          ),
      ],
    );
  }
}

/// Helper bridging icon names from the domain to Material icons for S2.
