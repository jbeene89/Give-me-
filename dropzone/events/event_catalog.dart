import 'models/event.dart';
import 'models/event_effect.dart';

/// Catalog of all game events
/// Implements requirements:
/// - 5+ random events
/// - 3+ threshold-triggered events
/// - 2+ compound events (chain reactions)
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
        EventEffect(meterId: 'stability', delta: -0.08),
        EventEffect(meterId: 'efficiency', delta: -0.05),
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
        EventEffect(meterId: 'capacity', delta: -0.06),
        EventEffect(meterId: 'clarity', delta: -0.10),
        EventEffect(meterId: 'morale', delta: -0.04),
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
        EventEffect(meterId: 'capacity', delta: -0.10),
        EventEffect(meterId: 'efficiency', delta: -0.08, delayTurns: 1), // Delayed impact
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
        EventEffect(meterId: 'stability', delta: -0.12),
        EventEffect(meterId: 'capacity', delta: -0.07),
        EventEffect(meterId: 'clarity', delta: -0.05),
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
        EventEffect(meterId: 'reserves', delta: -0.10), // Affects blind spot meter
        EventEffect(meterId: 'stability', delta: -0.06, delayTurns: 2), // Very delayed
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
        EventEffect(meterId: 'clarity', delta: -0.15),
        EventEffect(meterId: 'efficiency', delta: -0.04),
      ],
    ),

    // ========== THRESHOLD-TRIGGERED EVENTS (3+) ==========

    // 7. Critical Strain - triggered when capacity drops too low
    GameEvent(
      id: 'threshold_strain',
      name: 'Critical Strain',
      cause: 'Workforce capacity fell below operational minimum, triggering cascading delays',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterId: 'capacity',
        threshold: 0.30,
        triggerAbove: false, // Trigger when below 30%
      ),
      effects: [
        EventEffect(meterId: 'stability', delta: -0.15),
        EventEffect(meterId: 'morale', delta: -0.10),
        EventEffect(meterId: 'efficiency', delta: -0.08, delayTurns: 1),
      ],
    ),

    // 8. Instability Cascade - triggered when stability drops too low
    GameEvent(
      id: 'threshold_instability',
      name: 'Instability Cascade',
      cause: 'District stability fell below critical threshold, causing chain reaction of failures',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterId: 'stability',
        threshold: 0.25,
        triggerAbove: false, // Trigger when below 25%
      ),
      effects: [
        EventEffect(meterId: 'capacity', delta: -0.12),
        EventEffect(meterId: 'reserves', delta: -0.10),
        EventEffect(meterId: 'clarity', delta: -0.08),
      ],
    ),

    // 9. Information Blackout - triggered when clarity drops too low
    GameEvent(
      id: 'threshold_blackout',
      name: 'Information Blackout',
      cause: 'Situational clarity fell so low that coordination became nearly impossible',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterId: 'clarity',
        threshold: 0.35,
        triggerAbove: false, // Trigger when below 35%
      ),
      effects: [
        EventEffect(meterId: 'efficiency', delta: -0.10),
        EventEffect(meterId: 'stability', delta: -0.08),
        EventEffect(meterId: 'capacity', delta: -0.06, delayTurns: 1),
      ],
    ),

    // 10. Reserve Depletion Crisis - triggered when reserves drop too low
    GameEvent(
      id: 'threshold_reserve_crisis',
      name: 'Reserve Depletion Crisis',
      cause: 'Emergency reserves exhausted, leaving no buffer for unexpected demands',
      triggerType: EventTriggerType.threshold,
      thresholdTrigger: ThresholdTrigger(
        meterId: 'reserves',
        threshold: 0.20,
        triggerAbove: false,
      ),
      effects: [
        EventEffect(meterId: 'stability', delta: -0.14),
        EventEffect(meterId: 'capacity', delta: -0.10),
        EventEffect(meterId: 'morale', delta: -0.08),
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
        EventEffect(meterId: 'capacity', delta: -0.10),
        EventEffect(meterId: 'efficiency', delta: -0.12),
        EventEffect(meterId: 'reserves', delta: -0.08, delayTurns: 1),
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
        EventEffect(meterId: 'clarity', delta: -0.12),
        EventEffect(meterId: 'reserves', delta: -0.10),
        EventEffect(meterId: 'stability', delta: -0.06, delayTurns: 1),
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
        EventEffect(meterId: 'clarity', delta: -0.10),
        EventEffect(meterId: 'efficiency', delta: -0.08),
        EventEffect(meterId: 'stability', delta: -0.05, delayTurns: 2),
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
