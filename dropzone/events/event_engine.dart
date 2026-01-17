import 'dart:math';
import '../../give_me_skeleton/lib/core/models/game_state.dart';
import '../../give_me_skeleton/lib/core/models/meter.dart';
import 'models/event.dart';
import 'models/event_effect.dart';
import 'models/event_log_entry.dart';
import 'event_catalog.dart';
import 'fog_mechanics.dart';

/// Result of applying events for a turn
class EventTurnResult {
  final GameState updatedState;
  final List<EventLogEntry> newEvents;

  const EventTurnResult({
    required this.updatedState,
    required this.newEvents,
  });
}

/// Main Event Engine - manages event triggering, delayed effects, and logging
/// Uses seeded RNG for reproducibility
class EventEngine {
  final int _initialSeed; // Stored for deterministic per-turn seeding
  final FogMechanics fogMechanics;
  final DelayedEffectQueue _delayedQueue = DelayedEffectQueue();
  final List<EventLogEntry> _eventLog = [];
  static const int maxLogEntries = 100; // Ring buffer size

  // Track which events triggered last turn for compound event logic
  final Set<String> _lastTurnEventIds = {};

  // Track cooldowns to prevent event spam (prevents making game solvable)
  final Map<String, int> _eventCooldowns = {};
  static const int defaultCooldown = 3; // Events can't retrigger for 3 turns

  int _currentTurn = 0;

  EventEngine({int? seed})
      : _initialSeed = seed ?? 0,
        fogMechanics = FogMechanics(Random(seed != null ? seed + 1 : null));

  /// Compatibility-safe API: Apply events for a turn and return updated GameState
  /// This is the main integration point for TurnEngine
  /// Uses deterministic seeding: seed = hash(initialSeed, turn) for reproducibility
  EventTurnResult applyTurnEvents(GameState state, int turn) {
    _currentTurn = turn;

    // Create turn-specific RNG for deterministic, reproducible events
    // This ensures same initial seed + same turn = same events
    // Formula: combine initial seed with turn using hash-like mixing
    final turnSeed = (_initialSeed * 31 + turn * 17) & 0x7FFFFFFF;
    final turnRandom = Random(turnSeed);

    // Step 1: Apply delayed effects from previous turns
    final delayedEffects = _delayedQueue.popEffectsForTurn(turn);
    Map<MeterType, double> meters = Map<MeterType, double>.from(state.meters);

    for (final effect in delayedEffects) {
      _applyEffectToMeters(meters, effect);
    }

    // Step 2: Check and trigger events (using turn-specific Random)
    final triggeredEvents = <GameEvent>[];
    triggeredEvents.addAll(_checkThresholdEvents(meters));
    triggeredEvents.addAll(_checkCompoundEvents(turnRandom));
    triggeredEvents.addAll(_checkRandomEvents(turnRandom));

    // Step 3: Apply immediate effects and create log entries
    final logEntries = <EventLogEntry>[];
    for (final event in triggeredEvents) {
      // Apply immediate effects
      for (final effect in event.immediateEffects) {
        _applyEffectToMeters(meters, effect);
      }

      // Schedule delayed effects
      for (final effect in event.delayedEffects) {
        _delayedQueue.scheduleEffect(turn, effect, event.id);
      }

      // Create log entry with fog mechanics applied
      final clarity = state.informationClarity;
      final actualEffects = event.immediateEffects;
      final perceivedEffects = fogMechanics.applyNoiseToEffects(
        actualEffects,
        clarity,
      );

      logEntries.add(EventLogEntry(
        turnNumber: turn,
        eventId: event.id,
        eventName: event.name,
        cause: event.cause,
        actualEffects: actualEffects,
        perceivedEffects: perceivedEffects,
        wasObscured: fogMechanics.shouldObscureInLog(clarity),
      ));

      // Set cooldown for this event
      _eventCooldowns[event.id] = turn + defaultCooldown;
    }

    // Step 4: Update last turn events for compound tracking
    _lastTurnEventIds.clear();
    _lastTurnEventIds.addAll(triggeredEvents.map((e) => e.id));

    // Step 5: Add to log with ring buffer (cap at maxLogEntries)
    _eventLog.addAll(logEntries);
    if (_eventLog.length > maxLogEntries) {
      final overflow = _eventLog.length - maxLogEntries;
      _eventLog.removeRange(0, overflow);
    }

    // Step 6: Return updated state with modified meters
    return EventTurnResult(
      updatedState: state.copyWith(meters: meters),
      newEvents: logEntries,
    );
  }

  /// Apply a single effect to the meters map
  void _applyEffectToMeters(Map<MeterType, double> meters, EventEffect effect) {
    final current = meters[effect.meterType] ?? 50.0;
    meters[effect.meterType] = (current + effect.delta).clamp(0.0, 100.0);
  }

  /// Check threshold-triggered events
  List<GameEvent> _checkThresholdEvents(Map<MeterType, double> meterValues) {
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
  List<GameEvent> _checkCompoundEvents(Random rng) {
    final triggered = <GameEvent>[];

    for (final event in EventCatalog.compoundEvents) {
      // Skip if on cooldown
      if (_isOnCooldown(event.id)) continue;

      final compoundTrigger = event.compoundTrigger;
      if (compoundTrigger == null) continue;

      // Check if triggering event happened last turn
      if (_lastTurnEventIds.contains(compoundTrigger.triggeringEventId)) {
        // Roll for compound event with boosted probability
        if (rng.nextDouble() < compoundTrigger.probabilityBoost) {
          triggered.add(event);
        }
      }
    }

    return triggered;
  }

  /// Check random events
  List<GameEvent> _checkRandomEvents(Random rng) {
    final triggered = <GameEvent>[];

    for (final event in EventCatalog.randomEvents) {
      // Skip if on cooldown
      if (_isOnCooldown(event.id)) continue;

      // Roll for random event
      if (rng.nextDouble() < event.baseProbability) {
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
  double getPerceivedMeterValue(MeterType meterType, double actualValue, double clarity) {
    // Check if meter is in blind spot
    if (fogMechanics.isMeterHidden(meterType, clarity)) {
      return double.nan; // Signal that meter should be hidden
    }

    // Apply noise
    return fogMechanics.applyNoiseToMeterValue(actualValue, clarity);
  }

  /// Get list of meters currently hidden by blind spots
  List<MeterType> getBlindSpotMeters(double clarity) {
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
