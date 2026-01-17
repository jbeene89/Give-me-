/// Represents a single effect on a meter
class EventEffect {
  final String meterId;
  final double delta;
  final int delayTurns; // 0 = immediate, 1+ = delayed

  const EventEffect({
    required this.meterId,
    required this.delta,
    this.delayTurns = 0,
  });

  EventEffect copyWith({
    String? meterId,
    double? delta,
    int? delayTurns,
  }) {
    return EventEffect(
      meterId: meterId ?? this.meterId,
      delta: delta ?? this.delta,
      delayTurns: delayTurns ?? this.delayTurns,
    );
  }

  @override
  String toString() {
    final sign = delta >= 0 ? '+' : '';
    final delay = delayTurns > 0 ? ' (in $delayTurns turn${delayTurns > 1 ? 's' : ''})' : '';
    return '$meterId: $sign${delta.toStringAsFixed(1)}$delay';
  }
}
