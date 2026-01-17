# Event Engine - Changes and Assumptions

## What Was Added

### Core Systems (Items 31-38 from Master List)

1. **Random Crises/Events (Item 31)**
   - Implemented 6 random events with 8-15% base probability
   - Events: System Drift, False Alarm, Unexpected Bottleneck, Coordination Failure, Hidden Decay, Measurement Error
   - Each event affects 1-3 meters with negative deltas
   - 3-turn cooldown prevents spam

2. **Predictable Cycles (Item 32)**
   - Implemented via cooldown system (events can't retrigger for 3 turns)
   - Creates predictable windows where specific events won't occur
   - Prevents stable patterns from emerging

3. **Hidden Chain Reactions (Item 33)**
   - Implemented as compound events with probabilistic triggers
   - 3 compound events: Secondary Collapse (60% after Instability Cascade), Panic Response (50% after Critical Strain), Measurement Cascade (40% after Measurement Error)
   - Chain reactions are not guaranteed, adding uncertainty

4. **False Positives / Misinformation (Item 34)**
   - Implemented as "False Alarm" random event that reduces clarity and wastes capacity
   - Fog mechanics add noise to all event effect reporting when clarity < 0.6
   - Player sees incorrect effect magnitudes

5. **Compound Failures (Item 35)**
   - Threshold events trigger when meters fall too low
   - 4 threshold events: Critical Strain, Instability Cascade, Information Blackout, Reserve Depletion Crisis
   - Each threshold event affects multiple meters, creating cascades

6. **Delayed Feedback (Item 36)**
   - Implemented via `EventEffect.delayTurns` parameter
   - 7 out of 13 events have delayed effects (1-2 turns later)
   - `DelayedEffectQueue` manages scheduling and application
   - Player sees event now, feels effect later

7. **Noisy Data (Item 37)**
   - `FogMechanics.applyNoiseToMeterValue()` adds ±error when clarity < 0.6
   - Maximum noise: ±15% proportional to how low clarity is
   - Applied to both meter displays and event effect reporting
   - `EventLogEntry` tracks actual vs perceived effects

8. **Blind Spots (Item 38)**
   - When clarity < 0.4, two meters become completely hidden: `reserves` and `efficiency`
   - `FogMechanics.isMeterHidden()` determines visibility
   - UI should display hidden meters as "???" or masked
   - Events can still affect hidden meters without player knowledge

### File Structure

```
dropzone/events/
├── event_engine.dart           # Main orchestrator with seeded RNG
├── event_catalog.dart          # All 13 events (6 random, 4 threshold, 3 compound)
├── fog_mechanics.dart          # Noisy data, blind spots, delayed feedback
├── models/
│   ├── event.dart              # Event, trigger, and condition models
│   ├── event_effect.dart       # Effect with meter ID, delta, delay
│   └── event_log_entry.dart    # Log with actual vs perceived effects
├── README.md                   # Integration guide
└── CHANGES.md                  # This file
```

## Assumptions Made

### Meter Assumptions
- Meters exist with IDs: `stability`, `capacity`, `reserves`, `clarity`, `morale`, `efficiency`
- All meter values are normalized to 0.0-1.0 range
- `clarity` meter exists and governs fog mechanics
- Meters can be modified by external code (TurnEngine applies effects)

### Integration Assumptions
- `TurnEngine` owns `GameState` and can provide meter values as `Map<String, double>`
- `TurnEngine` will call `EventEngine.processTurn()` each turn
- `TurnEngine` will apply event effects to meters by calling methods on `GameState`
- UI layer will handle displaying events and meters to player
- UI layer will respect blind spot mechanics and show "???" for hidden meters

### Design Assumptions
- Events are fundamentally entropic (all deltas are negative)
- No single event should be game-ending (max effect: -0.15 on any meter)
- Cooldowns prevent event spam while maintaining unpredictability
- Compound events add uncertainty (probabilistic, not deterministic)
- Delayed effects create 1-2 turn gaps between cause and effect

### Technical Assumptions
- Dart SDK supports standard library (`dart:math`, `Random`)
- No external dependencies required
- Code will be integrated into existing Flutter project
- Seeded RNG can be provided at construction time

## What Was Intentionally NOT Implemented

### Out of Scope

1. **UI/Display Code**
   - No widgets or Flutter UI components
   - No rendering of event log or meters
   - Integration with UI is TurnEngine's responsibility

2. **GameState Modifications**
   - Did not modify `lib/core/models/game_state.dart`
   - Did not modify `lib/core/models/meter.dart`
   - Did not modify `lib/core/state/turn_engine.dart`
   - These files are assumed to exist and remain unchanged

3. **New Meters or Resources**
   - Did not add new meter types
   - Did not add currencies or action points
   - Only affects existing meters

4. **Player Actions**
   - Did not implement any player actions or interventions
   - Events are purely systemic (environment to player, not player to environment)
   - Actions remain in separate system

5. **Real-World References**
   - No real politics, real people, or real geography
   - All events use abstract language: "districts", "systems", "sectors", "coordination", "monitoring"
   - No references to specific countries, cities, or political movements

6. **Positive Events or Equilibrium**
   - No "good news" events
   - No events that restore stability
   - No mechanics that create stable states
   - This upholds core design invariant: no equilibrium

7. **Save/Load Serialization**
   - Did not implement JSON serialization
   - Did not implement persistence
   - EventEngine can be reconstructed with same seed for reproducibility

8. **Advanced Features**
   - No event prerequisites (beyond compound triggers)
   - No event exclusions (events can co-occur)
   - No adaptive difficulty
   - No player feedback loop (events don't adapt to player skill)

## Known Limitations

1. **Event Balance**
   - Event probabilities and effect magnitudes are initial estimates
   - May require tuning based on playtesting
   - No balancing was done (intentionally, per design invariants)

2. **Cooldown System**
   - Fixed 3-turn cooldown for all events
   - Could be per-event configurable in future
   - Prevents some interesting rapid-fire cascades

3. **Blind Spot Meters**
   - Only two meters become blind spots (`reserves`, `efficiency`)
   - Hard-coded in `FogMechanics.blindSpotMeters`
   - Could be made configurable per event or dynamic

4. **Compound Event Chains**
   - Compound events only trigger from events in previous turn
   - Multi-turn chains would require more complex tracking
   - Could lead to runaway cascades (intentionally avoided)

5. **Delayed Effect Limits**
   - Maximum delay is 2 turns
   - Longer delays would require persistence across game sessions
   - Kept simple for initial implementation

## Testing Recommendations

1. **Reproducibility Testing**
   ```dart
   final engine1 = EventEngine(seed: 42);
   final engine2 = EventEngine(seed: 42);
   // Same inputs should produce identical outputs
   ```

2. **Fog Mechanics Testing**
   ```dart
   // Test noisy data at different clarity levels
   final perceived = fogMechanics.applyNoiseToMeterValue(0.5, 0.3);
   // Should have significant error

   // Test blind spots
   final hidden = fogMechanics.isMeterHidden('reserves', 0.3);
   // Should return true
   ```

3. **Compound Event Testing**
   ```dart
   // Trigger threshold_instability
   // Next turn, check if compound_secondary_collapse can trigger
   ```

4. **Delayed Effect Testing**
   ```dart
   // Trigger event with delayed effect
   // Verify effect appears in queue
   // Advance turns and verify effect applies
   ```

## Future Enhancements (Not Implemented)

- Event prerequisites (event X requires event Y to have occurred)
- Event exclusions (event X prevents event Y)
- Multi-turn compound chains (A → B → C)
- Dynamic probability adjustment based on game state
- Per-event configurable cooldowns
- Event severity levels
- Player-visible event predictions (low accuracy)
- Event mitigation actions (would require action system integration)

## Version

- **Version**: 1.0
- **Date**: 2026-01-17
- **Implements**: Items 31-38 from master list
- **Status**: Complete, ready for integration
