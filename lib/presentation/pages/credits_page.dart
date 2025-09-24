import 'package:flutter/material.dart';
import 'package:open_adventure/presentation/theme/app_spacing.dart';

/// Placeholder Credits page until the full credits module is implemented.
class CreditsPage extends StatelessWidget {
  /// Creates a simple credits placeholder with static copy.
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Crédits')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaster Flutter en cours',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Les crédits complets seront intégrés dans un sprint ultérieur. '
              'Merci de votre patience !',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
