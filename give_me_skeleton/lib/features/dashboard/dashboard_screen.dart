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
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You are the Allocator',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Give resources to the system. Or keep them for yourself.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The tension between "Give" and "Me" defines every choice. '
                      'No action is purely good. Every decision has hidden costs. '
                      'Survive as long as you can—there is no perfect equilibrium.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
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
