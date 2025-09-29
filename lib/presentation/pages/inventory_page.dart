import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/l10n/app_localizations.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';
import 'package:open_adventure/presentation/widgets/icon_helper.dart';

/// InventoryPage renders the list of carried objects alongside contextual
/// actions that reuse the domain [ActionOption] contracts.
class InventoryPage extends StatelessWidget {
  /// Creates an inventory view bound to a [GameController].
  const InventoryPage({super.key, required this.controller});

  /// Game orchestrator providing access to the current state and action API.
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.inventoryTitle)),
      body: ValueListenableBuilder<GameViewState>(
        valueListenable: controller,
        builder: (context, state, _) {
          final Game? game = state.game;
          if (state.isLoading || game == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<_InventoryEntry> inventory = _buildInventory(
            game: game,
            actions: state.actions,
            l10n: l10n,
          );

          if (inventory.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.inventoryEmptyState,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: inventory.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final entry = inventory[index];
              return _InventoryCard(
                entry: entry,
                onActionSelected: controller.perform,
              );
            },
          );
        },
      ),
    );
  }

  List<_InventoryEntry> _buildInventory({
    required Game game,
    required List<ActionOption> actions,
    required AppLocalizations l10n,
  }) {
    final List<GameObjectState> carried = game.objectStates.values
        .where((state) => state.isCarried)
        .toList(growable: false);

    if (carried.isEmpty) {
      return const <_InventoryEntry>[];
    }

    final List<_InventoryEntry> entries = carried
        .map((state) {
          final object = controller.objectById(state.id);
          final String objectKey = object?.name ?? 'OBJ_${state.id}';
          final String label = l10n.inventoryItemLabel(objectKey);
          final String objectId = state.id.toString();
          final List<ActionOption> itemActions = actions
              .where(
                (action) =>
                    action.category == 'interaction' &&
                    action.objectId == objectId,
              )
              .toList(growable: false);
          itemActions.sort((a, b) {
            final labelA = l10n.resolveActionLabel(a.label);
            final labelB = l10n.resolveActionLabel(b.label);
            final compare = labelA.compareTo(labelB);
            if (compare != 0) {
              return compare;
            }
            return a.id.compareTo(b.id);
          });
          return _InventoryEntry(
            objectId: state.id,
            label: label,
            actions: itemActions,
          );
        })
        .toList(growable: false);

    entries.sort((a, b) {
      final compare = a.label.compareTo(b.label);
      if (compare != 0) {
        return compare;
      }
      return a.objectId.compareTo(b.objectId);
    });

    return entries;
  }
}

class _InventoryEntry {
  const _InventoryEntry({
    required this.objectId,
    required this.label,
    required this.actions,
  });

  final int objectId;
  final String label;
  final List<ActionOption> actions;
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.entry, required this.onActionSelected});

  final _InventoryEntry entry;
  final Future<void> Function(ActionOption) onActionSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.label, style: theme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (entry.actions.isEmpty)
              Text(l10n.inventoryNoActions, style: theme.bodyMedium)
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: entry.actions
                    .map(
                      (action) => FilledButton.tonalIcon(
                        onPressed: () => onActionSelected(action),
                        icon: Icon(
                          IconsHelper.iconForName(action.icon ?? 'inventory'),
                        ),
                        label: Text(l10n.resolveActionLabel(action.label)),
                      ),
                    )
                    .toList(growable: false),
              ),
          ],
        ),
      ),
    );
  }
}
