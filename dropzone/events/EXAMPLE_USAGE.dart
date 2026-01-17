/// Example usage of Event Engine
/// This file demonstrates how to integrate the Event Engine into TurnEngine

import 'event_engine_exports.dart';

/// Example: Basic usage
void exampleBasicUsage() {
  // Create engine with seed for reproducibility
  final eventEngine = EventEngine(seed: 12345);

  // Simulate game state meters
  final meterValues = {
    'stability': 0.45,
    'capacity': 0.60,
    'reserves': 0.30,
    'clarity': 0.50,
    'morale': 0.55,
    'efficiency': 0.40,
  };

  // Process turn 1
  final events = eventEngine.processTurn(1, meterValues);

  // Display events to player
  for (final event in events) {
    print('EVENT: ${event.eventName}');
    print('  ${event.cause}');
    print('  Effects (as perceived):');
    for (final effect in event.perceivedEffects) {
      print('    $effect');
    }
    if (event.wasObscured) {
      print('  [Information may be unclear due to low situational clarity]');
    }
    print('');
  }
}

/// Example: Displaying meters with fog
void exampleDisplayMetersWithFog() {
  final eventEngine = EventEngine(seed: 42);

  final meterValues = {
    'stability': 0.45,
    'capacity': 0.60,
    'reserves': 0.30,
    'clarity': 0.35, // Low clarity - fog active
    'morale': 0.55,
    'efficiency': 0.40,
  };

  print('Meter Display:');
  for (final entry in meterValues.entries) {
    final perceived = eventEngine.getPerceivedMeterValue(
      entry.key,
      entry.value,
      meterValues['clarity']!,
    );

    if (perceived.isNaN) {
      // Blind spot - meter is hidden
      print('  ${entry.key}: ???');
    } else {
      // Show perceived value (with noise)
      print('  ${entry.key}: ${(perceived * 100).toStringAsFixed(0)}%');
      print('    (actual: ${(entry.value * 100).toStringAsFixed(0)}%)');
    }
  }

  // Show which meters are blind spots
  final blindSpots = eventEngine.getBlindSpotMeters(meterValues['clarity']!);
  if (blindSpots.isNotEmpty) {
    print('\nBlind spots (hidden): ${blindSpots.join(", ")}');
  }
}

/// Example: Threshold event triggering
void exampleThresholdEvent() {
  final eventEngine = EventEngine(seed: 100);

  // Simulate low capacity that should trigger Critical Strain
  final meterValues = {
    'stability': 0.50,
    'capacity': 0.25, // Below 30% threshold
    'reserves': 0.40,
    'clarity': 0.60,
    'morale': 0.50,
    'efficiency': 0.45,
  };

  print('Turn 1: Capacity at 25% (below critical threshold)');
  final events = eventEngine.processTurn(1, meterValues);

  if (events.any((e) => e.eventId == 'threshold_strain')) {
    print('  → Critical Strain triggered!');
  }
}

/// Example: Compound event (chain reaction)
void exampleCompoundEvent() {
  final eventEngine = EventEngine(seed: 200);

  // Turn 1: Trigger Instability Cascade
  var meterValues = {
    'stability': 0.20, // Below 25% threshold
    'capacity': 0.50,
    'reserves': 0.40,
    'clarity': 0.60,
    'morale': 0.50,
    'efficiency': 0.45,
  };

  print('Turn 1: Stability at 20% (triggering Instability Cascade)');
  var events = eventEngine.processTurn(1, meterValues);

  for (final event in events) {
    print('  → ${event.eventName} triggered');
  }

  // Turn 2: Check for compound event (Secondary Collapse)
  // Instability Cascade has 60% chance to trigger Secondary Collapse
  meterValues = {...meterValues, 'stability': 0.30}; // Improved slightly

  print('\nTurn 2: Checking for compound event (Secondary Collapse)...');
  events = eventEngine.processTurn(2, meterValues);

  if (events.any((e) => e.eventId == 'compound_secondary_collapse')) {
    print('  → Secondary Collapse triggered! (chain reaction)');
  } else {
    print('  → No compound event (probabilistic - may not trigger)');
  }
}

/// Example: Delayed effects
void exampleDelayedEffects() {
  final eventEngine = EventEngine(seed: 300);

  print('Turn 1: Event with delayed effect occurs');
  // Manually checking upcoming delayed effects (normally TurnEngine handles this)

  final upcomingEffects = eventEngine.getUpcomingDelayedEffects();
  if (upcomingEffects.isNotEmpty) {
    print('  Scheduled delayed effects:');
    for (final effect in upcomingEffects) {
      print('    $effect');
    }
  }
}

/// Example: Event log and post-game analysis
void exampleEventLog() {
  final eventEngine = EventEngine(seed: 400);

  final meterValues = {
    'stability': 0.45,
    'capacity': 0.60,
    'reserves': 0.30,
    'clarity': 0.40, // Low clarity - noisy data
    'morale': 0.55,
    'efficiency': 0.40,
  };

  // Simulate 5 turns
  for (int turn = 1; turn <= 5; turn++) {
    eventEngine.processTurn(turn, meterValues);
    // (Game would modify meterValues here based on effects)
  }

  // View event log
  print('Event Log (5 turns):');
  for (final entry in eventEngine.eventLog) {
    print('Turn ${entry.turnNumber}: ${entry.eventName}');
    print('  Cause: ${entry.cause}');
    print('  Actual effects: ${entry.actualEffects.map((e) => e.toString()).join(", ")}');
    print('  Perceived effects: ${entry.perceivedEffects.map((e) => e.toString()).join(", ")}');

    // Calculate perception error
    for (final effect in entry.actualEffects) {
      final error = entry.getPerceptionError(effect.meterId);
      if (error.abs() > 0.001) {
        print('  Perception error on ${effect.meterId}: ${error >= 0 ? '+' : ''}${error.toStringAsFixed(3)}');
      }
    }
    print('');
  }
}

void main() {
  print('=== Event Engine Examples ===\n');

  print('--- Example 1: Basic Usage ---');
  exampleBasicUsage();

  print('\n--- Example 2: Fog Mechanics ---');
  exampleDisplayMetersWithFog();

  print('\n--- Example 3: Threshold Event ---');
  exampleThresholdEvent();

  print('\n--- Example 4: Compound Event ---');
  exampleCompoundEvent();

  print('\n--- Example 5: Delayed Effects ---');
  exampleDelayedEffects();

  print('\n--- Example 6: Event Log ---');
  exampleEventLog();
}
