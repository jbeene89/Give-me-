import 'package:flutter/material.dart';
import '../models/meter.dart';
import '../events/fog_mechanics.dart';

class MeterCard extends StatelessWidget {
  final String title;
  final String hint;
  final double value; // 0..100
  final double? clarity; // Information clarity (0-100), optional for backwards compatibility
  final MeterType? meterType; // Meter type, optional for backwards compatibility

  const MeterCard({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    this.clarity,
    this.meterType,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this meter should be hidden (blind spot)
    final isHidden = clarity != null &&
                     meterType != null &&
                     clarity! < FogMechanics.clarityThresholdForBlindSpots &&
                     FogMechanics.blindSpotMeters.contains(meterType);

    // Check for NaN value
    final isNaN = value.isNaN;

    // Determine display value
    final displayValue = (isHidden || isNaN) ? '???' : value.toStringAsFixed(0);
    final pct = (isHidden || isNaN) ? 0.5 : (value / 100).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                if (isHidden || isNaN)
                  Row(
                    children: [
                      Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        displayValue,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else
                  Text(displayValue),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pct,
              backgroundColor: (isHidden || isNaN) ? Colors.grey[300] : null,
              color: (isHidden || isNaN) ? Colors.grey[500] : null,
            ),
            const SizedBox(height: 8),
            Text(
              (isHidden || isNaN)
                ? 'Data unavailable (low information clarity)'
                : hint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: (isHidden || isNaN) ? FontStyle.italic : null,
                color: (isHidden || isNaN) ? Colors.grey[600] : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
