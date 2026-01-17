import 'dart:math';
import 'models/event.dart';
import 'models/event_effect.dart';
import 'models/event_log_entry.dart';
import 'event_catalog.dart';
import 'fog_mechanics.dart';

/// Main Event Engine - manages event triggering, delayed effects, and logging
/// Uses seeded RNG for reproducibility
class EventEngine {
  final Random _random;
  final FogMechanics fogMechanics;
  final DelayedEffectQueue _delayedQueue = DelayedEffectQueue();
  final List<EventLogEntry> _eventLog = [];

  // Track which events triggered last turn for compound event logic
  final Set<String> _lastTurnEventIds = {};

  // Track cooldowns to prevent event spam (prevents making game solvable)
  final Map<String, int> _eventCooldowns = {};
  static const int defaultCooldown = 3; // Events can't retrigger for 3 turns

  int _currentTurn = 0;

  EventEngine({int? seed})
      : _random = Random(seed),
        fogMechanics = FogMechanics(Random(seed != null ? seed + 1 : null));

  /// Process a turn: check triggers, apply effects, schedule delayed effects
  /// Returns list of events that triggered this turn
  List<EventLogEntry> processTurn(
    int turnNumber,
    Map<String, double> currentMeterValues,
  ) {
    _currentTurn = turnNumber;
    final triggeredEvents = <GameEvent>[];

    // Step 1: Apply delayed effects from previous turns
    final delayedEffects = _delayedQueue.popEffectsForTurn(turnNumber);
    // Note: Delayed effects would be applied to game state by TurnEngine

    // Step 2: Check threshold-triggered events
    triggeredEvents.addAll(_checkThresholdEvents(currentMeterValues));

    // Step 3: Check compound events (based on last turn's events)
    triggeredEvents.addAll(_checkCompoundEvents());

    // Step 4: Check random events
    triggeredEvents.addAll(_checkRandomEvents());

    // Step 5: Schedule delayed effects and create log entries
    final logEntries = <EventLogEntry>[];
    for (final event in triggeredEvents) {
      // Schedule delayed effects
      for (final effect in event.delayedEffects) {
        _delayedQueue.scheduleEffect(turnNumber, effect, event.id);
      }

      // Create log entry with fog mechanics applied
      final clarity = currentMeterValues['clarity'] ?? 0.5;
      final actualEffects = event.immediateEffects;
      final perceivedEffects = fogMechanics.applyNoiseToEffects(
        actualEffects,
        clarity,
      );

      logEntries.add(EventLogEntry(
        turnNumber: turnNumber,
        eventId: event.id,
        eventName: event.name,
        cause: event.cause,
        actualEffects: actualEffects,
        perceivedEffects: perceivedEffects,
        wasObscured: fogMechanics.shouldObscureInLog(clarity),
      ));

      // Set cooldown for this event
      _eventCooldowns[event.id] = turnNumber + defaultCooldown;
    }

    // Step 6: Update last turn events for compound tracking
    _lastTurnEventIds.clear();
    _lastTurnEventIds.addAll(triggeredEvents.map((e) => e.id));

    // Step 7: Add to log
    _eventLog.addAll(logEntries);

    return logEntries;
  }

  /// Check threshold-triggered events
  List<GameEvent> _checkThresholdEvents(Map<String, double> meterValues) {
    final triggered = <GameEvent>[];

    for (final event in EventCatalog.thresholdEvents) {
      // Skip if on cooldown
      if (_isOnCooldown(event.id)) continue;

      // Check threshold condition
      if (event.thresholdTrigger?.check(meterValues) ?? false) {
        triggered.add(event);
      }
    }

    return triggered;
  }

  /// Check compound events (chain reactions)
  List<GameEvent> _checkCompoundEvents() {
    final triggered = <GameEvent>[];

    for (final event in EventCatalog.compoundEvents) {
      // Skip if on cooldown
      if (_isOnCooldown(event.id)) continue;

      final compoundTrigger = event.compoundTrigger;
      if (compoundTrigger == null) continue;

      // Check if triggering event happened last turn
      if (_lastTurnEventIds.contains(compoundTrigger.triggeringEventId)) {
        // Roll for compound event with boosted probability
        if (_random.nextDouble() < compoundTrigger.probabilityBoost) {
          triggered.add(event);
        }
      }
    }

    return triggered;
  }

  /// Check random events
  List<GameEvent> _checkRandomEvents() {
    final triggered = <GameEvent>[];

    for (final event in EventCatalog.randomEvents) {
      // Skip if on cooldown
      if (_isOnCooldown(event.id)) continue;

      // Roll for random event
      if (_random.nextDouble() < event.baseProbability) {
        triggered.add(event);
      }
    }

    return triggered;
  }

  /// Check if event is on cooldown
  bool _isOnCooldown(String eventId) {
    final cooldownUntil = _eventCooldowns[eventId];
    if (cooldownUntil == null) return false;
    return _currentTurn < cooldownUntil;
  }

  /// Get meter value with fog applied (for UI display)
  double getPerceivedMeterValue(String meterId, double actualValue, double clarity) {
    // Check if meter is in blind spot
    if (fogMechanics.isMeterHidden(meterId, clarity)) {
      return double.nan; // Signal that meter should be hidden
    }

    // Apply noise
    return fogMechanics.applyNoiseToMeterValue(actualValue, clarity);
  }

  /// Get list of meters currently hidden by blind spots
  List<String> getBlindSpotMeters(double clarity) {
    return fogMechanics.getBlindSpotMeters(clarity);
  }

  /// Get event log
  List<EventLogEntry> get eventLog => List.unmodifiable(_eventLog);

  /// Get recent events (last N turns)
  List<EventLogEntry> getRecentEvents(int lastNTurns) {
    final cutoff = _currentTurn - lastNTurns;
    return _eventLog.where((e) => e.turnNumber > cutoff).toList();
  }

  /// Clear all state (for new game)
  void reset() {
    _eventLog.clear();
    _lastTurnEventIds.clear();
    _eventCooldowns.clear();
    _delayedQueue.clear();
    _currentTurn = 0;
  }

  /// Get upcoming delayed effects (for debugging/testing)
  List<EventEffect> getUpcomingDelayedEffects() {
    return _delayedQueue.peekUpcomingEffects();
  }
}
