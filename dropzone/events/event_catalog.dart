import '../../give_me_skeleton/lib/core/models/meter.dart';
import 'models/event.dart';
import 'models/event_effect.dart';

/// Catalog of all game events
/// Implements requirements:
/// - 5+ random events
/// - 3+ threshold-triggered events
/// - 2+ compound events (chain reactions)
///
/// Meter mapping from original design to canonical MeterType:
/// - stability -> instability (INVERTED: -stability = +instability)
/// - capacity -> productivity
/// - morale -> happiness
/// - efficiency -> productivity
/// - reserves -> safety (thematic: reserves provide safety net)
/// - clarity -> trust (thematic: good information builds trust)
class EventCatalog {
  static const List<GameEvent> allEvents = [
    // ========== RANDOM EVENTS (5+) ==========

    // 1. System Drift - pure entropy, no equilibrium
    GameEvent(
      id: 'random_drift',
      name: 'System Drift',
      cause: 'Distributed systems naturally degrade without active maintenance',
      triggerType: EventTriggerType.random,
      baseProbability: 0.15,
      effects: [
        EventEffect(meterType: MeterType.instability, delta: +8.0), // was -stability
        EventEffect(meterType: MeterType.productivity, delta: -5.0), // was -efficiency
      ],
    ),

    // 2. False Alarm - misinformation event
    GameEvent(
      id: 'random_false_alarm',
      name: 'False Alarm',
      cause: 'Monitoring system generated incorrect alert, resources diverted unnecessarily',
      triggerType: EventTriggerType.random,
      baseProbability: 0.12,
      effects: [
        EventEffect(meterType: MeterType.productivity, delta: -6.0), // was -capacity
        EventEffect(meterType: MeterType.trust, delta: -10.0), // was -clarity
        EventEffect(meterType: MeterType.happiness, delta: -4.0), // was -morale
      ],
    ),

    // 3. Unexpected Bottleneck - delayed feedback event
    GameEvent(
      id: 'random_bottleneck',
      name: 'Unexpected Bottleneck',
      cause: 'Earlier decisions created unforeseen constraint in district coordination',
      triggerType: EventTriggerType.random,
      baseProbability: 0.10,
      effects: [
        EventEffect(meterType: MeterType.productivity, delta: -10.0), // was -capacity
        EventEffect(meterType: MeterType.productivity, delta: -8.0, delayTurns: 1), // delayed efficiency hit
      ],
    ),

    // 4. Coordination Failure - no action is purely good
    GameEvent(
      id: 'random_coordination_fail',
      name: 'Coordination Failure',
      cause: 'Multiple districts operating independently created conflicting policies',
      triggerType: EventTriggerType.random,
      baseProbability: 0.08,
      effects: [
        EventEffect(meterType: MeterType.instability, delta: +12.0), // was -stability
        EventEffect(meterType: MeterType.productivity, delta: -7.0), // was -capacity
        EventEffect(meterType: MeterType.trust, delta: -5.0), // was -clarity
      ],
    ),

    // 5. Hidden Decay - blind spot event
    GameEvent(
      id: 'random_hidden_decay',
      name: 'Hidden Decay',
      cause: 'Infrastructure degradation in poorly monitored sectors went unnoticed',
      triggerType: EventTriggerType.random,
      baseProbability: 0.10,
      effects: [
        EventEffect(meterType: MeterType.safety, delta: -10.0), // was -reserves
        EventEffect(meterType: MeterType.instability, delta: +6.0, delayTurns: 2), // was -stability delayed
      ],
    ),

    // 6. Measurement Error - noisy data event
    GameEvent(
      id: 'random_measurement_error',
      name: 'Measurement Error',
      cause: 'Sensor calibration drift introduced systematic bias into district reports',
      triggerType: EventTriggerType.random,
      baseProbability: 0.11,
      effects: [
        EventEffect(meterType: MeterType.trust, delta: -15.0), // was -clarity
        EventEffect(meterType: MeterType.productivity, delta: -4.0), // was -efficiency
      ],
    ),

    // ========== THRESHOLD-TRIGGERED EVENTS (3+) ==========

    // 7. Critical Strain - triggered when productivity drops too low
    GameEvent(
      id: 'threshold_strain',
      name: 'Critical Strain',
      cause: 'Workforce capacity fell below operational minimum, triggering cascading delays',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterType: MeterType.productivity,
        threshold: 30.0,
        triggerAbove: false, // Trigger when below 30
      ),
      effects: [
        EventEffect(meterType: MeterType.instability, delta: +15.0), // was -stability
        EventEffect(meterType: MeterType.happiness, delta: -10.0), // was -morale
        EventEffect(meterType: MeterType.productivity, delta: -8.0, delayTurns: 1), // was -efficiency delayed
      ],
    ),

    // 8. Instability Cascade - triggered when instability rises too high
    GameEvent(
      id: 'threshold_instability',
      name: 'Instability Cascade',
      cause: 'District instability exceeded critical threshold, causing chain reaction of failures',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterType: MeterType.instability,
        threshold: 75.0,
        triggerAbove: true, // Trigger when above 75
      ),
      effects: [
        EventEffect(meterType: MeterType.productivity, delta: -12.0), // was -capacity
        EventEffect(meterType: MeterType.safety, delta: -10.0), // was -reserves
        EventEffect(meterType: MeterType.trust, delta: -8.0), // was -clarity
      ],
    ),

    // 9. Information Blackout - triggered when trust drops too low
    GameEvent(
      id: 'threshold_blackout',
      name: 'Information Blackout',
      cause: 'Situational clarity fell so low that coordination became nearly impossible',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterType: MeterType.trust,
        threshold: 35.0,
        triggerAbove: false, // Trigger when below 35
      ),
      effects: [
        EventEffect(meterType: MeterType.productivity, delta: -10.0), // was -efficiency
        EventEffect(meterType: MeterType.instability, delta: +8.0), // was -stability
        EventEffect(meterType: MeterType.productivity, delta: -6.0, delayTurns: 1), // was -capacity delayed
      ],
    ),

    // 10. Safety Crisis - triggered when safety drops too low
    GameEvent(
      id: 'threshold_safety_crisis',
      name: 'Safety Crisis',
      cause: 'Safety reserves exhausted, leaving no buffer for unexpected demands',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterType: MeterType.safety,
        threshold: 20.0,
        triggerAbove: false,
      ),
      effects: [
        EventEffect(meterType: MeterType.instability, delta: +14.0), // was -stability
        EventEffect(meterType: MeterType.productivity, delta: -10.0), // was -capacity
        EventEffect(meterType: MeterType.happiness, delta: -8.0), // was -morale
      ],
    ),

    // ========== COMPOUND EVENTS (2+) - Chain Reactions ==========

    // 11. Secondary Collapse - triggered by Instability Cascade
    GameEvent(
      id: 'compound_secondary_collapse',
      name: 'Secondary Collapse',
      cause: 'Initial instability cascade triggered secondary failures in dependent systems',
      triggerType: EventTriggerType.compound,
      compoundTrigger: CompoundTrigger(
        triggeringEventId: 'threshold_instability',
        probabilityBoost: 0.60, // 60% chance after triggering event
      ),
      effects: [
        EventEffect(meterType: MeterType.productivity, delta: -10.0), // was -capacity
        EventEffect(meterType: MeterType.productivity, delta: -12.0), // was -efficiency
        EventEffect(meterType: MeterType.safety, delta: -8.0, delayTurns: 1), // was -reserves delayed
      ],
    ),

    // 12. Panic Response - triggered by Critical Strain
    GameEvent(
      id: 'compound_panic',
      name: 'Panic Response',
      cause: 'Critical strain event caused hasty, poorly coordinated emergency actions',
      triggerType: EventTriggerType.compound,
      compoundTrigger: CompoundTrigger(
        triggeringEventId: 'threshold_strain',
        probabilityBoost: 0.50, // 50% chance after triggering event
      ),
      effects: [
        EventEffect(meterType: MeterType.trust, delta: -12.0), // was -clarity
        EventEffect(meterType: MeterType.safety, delta: -10.0), // was -reserves
        EventEffect(meterType: MeterType.instability, delta: +6.0, delayTurns: 1), // was -stability delayed
      ],
    ),

    // 13. Measurement Cascade - triggered by Measurement Error (compound chain)
    GameEvent(
      id: 'compound_measurement_cascade',
      name: 'Measurement Cascade',
      cause: 'Initial measurement errors propagated through dependent monitoring systems',
      triggerType: EventTriggerType.compound,
      compoundTrigger: CompoundTrigger(
        triggeringEventId: 'random_measurement_error',
        probabilityBoost: 0.40, // 40% chance after measurement error
      ),
      effects: [
        EventEffect(meterType: MeterType.trust, delta: -10.0), // was -clarity
        EventEffect(meterType: MeterType.productivity, delta: -8.0), // was -efficiency
        EventEffect(meterType: MeterType.instability, delta: +5.0, delayTurns: 2), // was -stability delayed
      ],
    ),
  ];

  /// Get all events by trigger type
  static List<GameEvent> getEventsByType(EventTriggerType type) {
    return allEvents.where((e) => e.triggerType == type).toList();
  }

  /// Get event by ID
  static GameEvent? getEventById(String id) {
    try {
      return allEvents.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all random events
  static List<GameEvent> get randomEvents =>
      getEventsByType(EventTriggerType.random);

  /// Get all threshold events
  static List<GameEvent> get thresholdEvents =>
      getEventsByType(EventTriggerType.threshold);

  /// Get all compound events
  static List<GameEvent> get compoundEvents =>
      getEventsByType(EventTriggerType.compound);
}
