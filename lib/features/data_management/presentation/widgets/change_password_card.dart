import 'package:flutter/material.dart';

class ChangePasswordCard extends StatelessWidget {
  const ChangePasswordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline,
                    color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 12),
                Text('Change Password',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Update the application password used to protect patient data.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              // Phase 9 — auth not yet implemented
              onPressed: null,
              icon: const Icon(Icons.password),
              label: const Text('Change Password'),
            ),
            const SizedBox(height: 8),
            Text(
              'Password management will be available in the next update.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
