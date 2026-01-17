import '../../models/meter.dart';
import 'event_effect.dart';

/// Trigger type for events
enum EventTriggerType {
  random, // Pure random chance each turn
  threshold, // Triggered when meter crosses threshold
  compound, // Triggered by another event occurring
}

/// Trigger condition for threshold-based events
class ThresholdTrigger {
  final MeterType meterType;
  final double threshold; // 0-100 range
  final bool triggerAbove; // true = trigger when above, false = when below

  const ThresholdTrigger({
    required this.meterType,
    required this.threshold,
    required this.triggerAbove,
  });

  bool check(Map<MeterType, double> meterValues) {
    final value = meterValues[meterType] ?? 50.0; // Default to middle value
    return triggerAbove ? value >= threshold : value <= threshold;
  }
}

/// Compound trigger - event triggered by another event
class CompoundTrigger {
  final String triggeringEventId;
  final double probabilityBoost; // How much to boost probability after triggering event

  const CompoundTrigger({
    required this.triggeringEventId,
    required this.probabilityBoost,
  });
}

/// Represents a game event with its triggers and effects
class GameEvent {
  final String id;
  final String name;
  final String cause; // Explainable cause/description
  final EventTriggerType triggerType;
  final double baseProbability; // For random events (0.0 - 1.0)
  final ThresholdTrigger? thresholdTrigger;
  final CompoundTrigger? compoundTrigger;
  final List<EventEffect> effects;
  final bool isVisible; // Some events might be hidden (for blind spots)

  const GameEvent({
    required this.id,
    required this.name,
    required this.cause,
    required this.triggerType,
    this.baseProbability = 0.0,
    this.thresholdTrigger,
    this.compoundTrigger,
    required this.effects,
    this.isVisible = true,
  });

  /// Get only immediate effects (no delay)
  List<EventEffect> get immediateEffects =>
      effects.where((e) => e.delayTurns == 0).toList();

  /// Get only delayed effects
  List<EventEffect> get delayedEffects =>
      effects.where((e) => e.delayTurns > 0).toList();

  @override
  String toString() => '$name ($id)';
}
