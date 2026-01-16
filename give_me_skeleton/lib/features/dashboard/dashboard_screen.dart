import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Give (Me)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Balance economy, stability, and trust.\nNo perfect answers—only tradeoffs.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/game'),
              child: const Text('Play'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/shop'),
              child: const Text('Shop'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/settings'),
              child: const Text('Settings'),
            ),
            const Spacer(),
            Text(
              'Prototype skeleton: tune the TurnEngine to shape the world.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
