import 'package:flutter/material.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';

/// Placeholder Saves page used while the save manager is under construction.
class SavesPage extends StatelessWidget {
  /// Creates a placeholder saves list to validate navigation flows.
  const SavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegardes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'La gestion détaillée des sauvegardes arrive dans un sprint ultérieur.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
