import 'package:flutter/material.dart';

class MeterCard extends StatelessWidget {
  final String title;
  final String hint;
  final double value; // 0..100

  const MeterCard({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / 100).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                Text(value.toStringAsFixed(0)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pct),
            const SizedBox(height: 8),
            Text(hint, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
