import '../../models/meter.dart';
import 'event_effect.dart';

/// Represents a logged event with actual vs perceived effects
class EventLogEntry {
  final int turnNumber;
  final String eventId;
  final String eventName;
  final String cause;
  final List<EventEffect> actualEffects;
  final List<EventEffect> perceivedEffects; // What player saw (with noise)
  final bool wasObscured; // Whether fog mechanics hid information

  const EventLogEntry({
    required this.turnNumber,
    required this.eventId,
    required this.eventName,
    required this.cause,
    required this.actualEffects,
    required this.perceivedEffects,
    this.wasObscured = false,
  });

  /// Get the perception error for a specific meter
  double getPerceptionError(MeterType meterType) {
    final actual = actualEffects
        .where((e) => e.meterType == meterType)
        .fold(0.0, (sum, e) => sum + e.delta);
    final perceived = perceivedEffects
        .where((e) => e.meterType == meterType)
        .fold(0.0, (sum, e) => sum + e.delta);
    return perceived - actual;
  }

  @override
  String toString() {
    final obscuredNote = wasObscured ? ' [OBSCURED]' : '';
    return 'Turn $turnNumber: $eventName$obscuredNote\n'
        '  Cause: $cause\n'
        '  Effects: ${actualEffects.join(", ")}';
  }
}
