import '../../../give_me_skeleton/lib/core/models/meter.dart';

/// Represents a single effect on a meter
class EventEffect {
  final MeterType meterType;
  final double delta; // Change in meter value (0-100 range)
  final int delayTurns; // 0 = immediate, 1+ = delayed

  const EventEffect({
    required this.meterType,
    required this.delta,
    this.delayTurns = 0,
  });

  EventEffect copyWith({
    MeterType? meterType,
    double? delta,
    int? delayTurns,
  }) {
    return EventEffect(
      meterType: meterType ?? this.meterType,
      delta: delta ?? this.delta,
      delayTurns: delayTurns ?? this.delayTurns,
    );
  }

  @override
  String toString() {
    final sign = delta >= 0 ? '+' : '';
    final delay = delayTurns > 0 ? ' (in $delayTurns turn${delayTurns > 1 ? 's' : ''})' : '';
    return '${meterType.name}: $sign${delta.toStringAsFixed(1)}$delay';
  }
}
