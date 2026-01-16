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

    return Scaffold(
      appBar: AppBar(
        title: Text('Turn ${state.turn}'),
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Budget',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      state.budget.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
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
                          onPressed: state.budget >= a.cost ? () => controller.applyAction(a) : null,
                          child: Text('-${a.cost}'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: controller.endTurn,
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
