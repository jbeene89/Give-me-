# Event Engine - Give (Me)

## Overview

The Event Engine implements a seeded, reproducible event system that creates unpredictable but explainable crises, chain reactions, and information fog mechanics. It is designed to prevent stable equilibria and ensure every intervention has downstream costs.

## Architecture

### Core Components

1. **EventEngine** (`event_engine.dart`)
   - Main orchestrator that processes turns
   - Uses seeded `Random` for reproducibility
   - Manages event triggering, cooldowns, delayed effects, and logging
   - Integrates fog mechanics for information uncertainty

2. **Event Models** (`models/`)
   - `event.dart`: Defines `GameEvent` with trigger types (random, threshold, compound)
   - `event_effect.dart`: Defines `EventEffect` with meter deltas and delay timing
   - `event_log_entry.dart`: Records actual vs perceived effects for transparency

3. **EventCatalog** (`event_catalog.dart`)
   - Contains all 13 events:
     - 6 random events (pure probability-based)
     - 4 threshold events (meter-based triggers)
     - 3 compound events (chain reactions)

4. **FogMechanics** (`fog_mechanics.dart`)
   - Implements noisy data (±15% error when clarity < 0.6)
   - Implements blind spots (hides `reserves` and `efficiency` when clarity < 0.4)
   - Implements delayed feedback (effects apply 1-2 turns later)

5. **DelayedEffectQueue** (`fog_mechanics.dart`)
   - Manages effects scheduled for future turns
   - Automatically applies effects at the correct turn

## How It Works

### Turn Processing Flow

```
TurnEngine.advanceTurn()
  ↓
1. Get current meter values
  ↓
2. EventEngine.processTurn(turnNumber, meterValues)
   │
   ├─→ Apply delayed effects from previous turns
   ├─→ Check threshold-triggered events
   ├─→ Check compound events (chain reactions)
   ├─→ Check random events
   ├─→ Schedule new delayed effects
   ├─→ Apply fog mechanics (noise, blind spots)
   └─→ Create log entries (actual vs perceived)
  ↓
3. Apply event effects to meters
  ↓
4. Display events to player (with fog)
```

### Event Types

#### Random Events
- Triggered by probability each turn (8-15% base chance)
- Examples: System Drift, False Alarm, Coordination Failure
- Cooldown: 3 turns between triggers

#### Threshold Events
- Triggered when a meter crosses a threshold
- Examples: Critical Strain (capacity < 30%), Instability Cascade (stability < 25%)
- Only trigger once until condition clears and recurs

#### Compound Events
- Triggered by another event occurring
- Implements chain reactions and cascading failures
- Examples: Secondary Collapse follows Instability Cascade (60% chance)

### Information Fog Mechanics

#### Noisy Data (clarity < 0.6)
When clarity drops below 0.6, all meter values and event effects shown to the player include ±error:
```dart
final perceivedValue = fogMechanics.applyNoiseToMeterValue(actualValue, clarity);
// Error magnitude scales with how low clarity is (up to ±15%)
```

#### Blind Spots (clarity < 0.4)
When clarity drops below 0.4, certain meters become completely hidden:
- `reserves` (emergency buffer capacity)
- `efficiency` (operational effectiveness)

UI should display these meters as "???" or masked.

#### Delayed Feedback
Many events have effects with `delayTurns: 1` or `delayTurns: 2`:
```dart
EventEffect(meterId: 'stability', delta: -0.06, delayTurns: 2)
```
The player sees the event happen, but the effect applies later, creating confusion about cause and effect.

## Wiring Into TurnEngine

### Integration Steps

1. **Initialize EventEngine in TurnEngine constructor:**
```dart
class TurnEngine {
  late final EventEngine eventEngine;

  TurnEngine({int? seed}) {
    eventEngine = EventEngine(seed: seed);
  }
}
```

2. **Call processTurn during turn advancement:**
```dart
void advanceTurn(GameState state) {
  currentTurn++;

  // Get current meter values as Map<String, double>
  final meterValues = _getMeterValuesMap(state);

  // Process events
  final triggeredEvents = eventEngine.processTurn(currentTurn, meterValues);

  // Apply event effects to meters
  for (final logEntry in triggeredEvents) {
    for (final effect in logEntry.actualEffects) {
      _applyEffectToMeter(state, effect);
    }
  }

  // Rest of turn logic...
}
```

3. **Display events to player with fog:**
```dart
void showEventsToPlayer(GameState state, List<EventLogEntry> events) {
  final clarity = state.getMeter('clarity').value;

  for (final event in events) {
    // Show event name and cause
    print('${event.eventName}: ${event.cause}');

    // Show perceived effects (with noise), not actual
    for (final effect in event.perceivedEffects) {
      print('  ${effect}');
    }

    if (event.wasObscured) {
      print('  [Some information may be unclear]');
    }
  }
}
```

4. **Display meters with fog applied:**
```dart
double getDisplayValue(GameState state, String meterId) {
  final meter = state.getMeter(meterId);
  final clarity = state.getMeter('clarity').value;

  final perceived = eventEngine.getPerceivedMeterValue(
    meterId,
    meter.value,
    clarity,
  );

  // Check if hidden (NaN means blind spot)
  if (perceived.isNaN) {
    return double.nan; // UI should show "???"
  }

  return perceived;
}
```

5. **Check for blind spots:**
```dart
List<String> getHiddenMeters(GameState state) {
  final clarity = state.getMeter('clarity').value;
  return eventEngine.getBlindSpotMeters(clarity);
}
```

## Design Invariants Upheld

1. **No stable equilibrium**: Events are fundamentally entropic (System Drift, Hidden Decay)
2. **No purely good actions**: Every event has multi-meter impacts, tradeoffs are implicit
3. **Seeded randomness**: EventEngine accepts seed, all RNG is reproducible
4. **Unfair but explainable**: Every event has a `cause` string explaining why it happened
5. **Abstract world**: Events reference "districts", "systems", "sectors", not real entities
6. **No new resources**: Events only affect existing meters, never add new meters or currencies

## Anti-Solvability Features

- **Cooldowns**: Events can't retrigger for 3 turns, prevents predictable patterns
- **Compound probabilities**: Chain reactions use probability, not certainty
- **Fog mechanics**: Player can't see true state when clarity is low
- **Delayed effects**: Cause and effect are separated in time
- **Threshold jitter**: Events trigger on thresholds, but thresholds are slightly different

## Event Log

The `EventLogEntry` model records:
- Turn number
- Event name and ID
- Cause (explanation)
- Actual effects (ground truth)
- Perceived effects (what player saw with noise)
- Whether information was obscured

This allows post-game analysis to understand what actually happened vs what the player perceived.

## Testing & Reproducibility

Create with a seed for deterministic behavior:
```dart
final engine = EventEngine(seed: 12345);
```

Same seed + same meter values = same events every time.

## Assumptions

- Meter IDs: `stability`, `capacity`, `reserves`, `clarity`, `morale`, `efficiency`
- Meters are normalized 0.0-1.0 range
- TurnEngine owns GameState and can apply effects to meters
- UI layer handles displaying meters and events to player
