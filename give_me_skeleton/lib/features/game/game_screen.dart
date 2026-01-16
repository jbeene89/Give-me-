import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/meter.dart';
import '../../core/models/policy_action.dart';
import '../../core/state/game_controller.dart';
import '../../core/ui/meter_card.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    // Show collapse dialog if collapsed
    if (state.isCollapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('System Collapse'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.collapseReason ?? 'Unknown failure',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Survived ${state.turn} turns',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'There is no perfect equilibrium—only survival.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.reset();
                },
                child: const Text('Try Again'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/');
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Turn ${state.turn}', style: const TextStyle(fontSize: 18)),
            const Text('Allocator', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: controller.reset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Budget',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          state.budget.toString(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Currency refreshes each turn based on productivity and corruption',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legitimacy',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: state.legitimacy / 100,
                            backgroundColor: Colors.grey[300],
                            minHeight: 6,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.legitimacy.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Info Clarity',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: state.informationClarity / 100,
                            backgroundColor: Colors.grey[300],
                            color: Colors.blue,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.informationClarity.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  Text('Meters', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.35,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: kMeterDefs.length,
                    itemBuilder: (context, i) {
                      final def = kMeterDefs[i];
                      final value = state.meters[def.type] ?? 0;
                      return MeterCard(title: def.label, hint: def.hint, value: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Actions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...kPolicyActions.map(
                    (a) => Card(
                      child: ListTile(
                        title: Text(a.name),
                        subtitle: Text(a.description),
                        trailing: FilledButton(
                          onPressed: (!state.isCollapsed && state.budget >= a.cost)
                              ? () => controller.applyAction(a)
                              : null,
                          child: Text('-${a.cost}'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: state.isCollapsed ? null : controller.endTurn,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('End Turn'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
