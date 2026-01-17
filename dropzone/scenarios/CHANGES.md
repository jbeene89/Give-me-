# Scenario Presets + Difficulty Profiles - Changes and Assumptions

## What Was Added

### Core Features (Items 45 + light 44 support)

1. **Scenario System (Item 45)**
   - 6 core scenarios with distinct starting conditions
   - 2 bonus scenarios (Tutorial, Crisis Point)
   - Each scenario defines:
     - Initial meter values (0.0-1.0 normalized)
     - Initial meta-resources (budget, influence)
     - Optional unlocked actions list (beginner mode gating)
     - 2-3 line thematic description
     - Optional modifiers to game parameters

2. **Difficulty Profiles (Light Item 44 support)**
   - 3 core difficulty profiles (Forgiving, Standard, Unforgiving)
   - 3 bonus profiles (Brutal, Sandbox, Time-Lapse)
   - Each profile scales:
     - Decay rates (0.3x - 1.8x range)
     - Event intensity (both probability and magnitude)
     - Noise magnitude (fog mechanics)
     - Collapse thresholds (0.8x - 1.3x range)
     - Initial resources (±adjustments)
     - Starting turn number (for late-game testing)

3. **Scenario Modifiers System**
   - Fine-grained parameter adjustments
   - Multipliers for: decay, events, noise, action costs, reserve drain
   - Per-meter threshold adjustments
   - Composable (scenario + difficulty modifiers merge)

4. **Scenario Loader**
   - Combines scenario + difficulty into initialization data
   - Merges modifiers correctly
   - Provides summary generation
   - Returns structured data for TurnEngine integration

### File Structure

```
dropzone/scenarios/
├── models/
│   ├── scenario.dart              # Scenario model with metadata
│   ├── difficulty_profile.dart    # Difficulty scaling model
│   └── scenario_modifiers.dart    # Parameter adjustment model
├── scenario_catalog.dart          # All 8 scenarios
├── difficulty_catalog.dart        # All 6 difficulty profiles
├── scenario_loader.dart           # Combines scenario + difficulty
├── scenario_exports.dart          # Public API exports
├── README.md                      # Integration guide
└── CHANGES.md                     # This file
```

## Scenarios Implemented

### 1. Baseline (Beginner-Friendly)
- **Starting State**: All meters 50%, balanced resources
- **Modifiers**: None
- **Theme**: Standard starting point, learn basic mechanics
- **Difficulty**: Medium (2/3)
- **Unlocked Actions**: All

### 2. Fragile Stability
- **Starting State**: High morale (75%), stability (70%); low reserves (15%)
- **Modifiers**: 1.3x reserve drain, 1.1x event probability
- **Theme**: Apparent prosperity hiding critical vulnerability
- **Difficulty**: Medium (2/3)
- **Unlocked Actions**: All
- **Challenge**: One crisis can shatter everything

### 3. Hardline City
- **Starting State**: High stability (75%), efficiency (65%); low morale (25%)
- **Modifiers**: 0.9x decay (enforcement slows), 1.2x events (tension), morale threshold +0.05
- **Theme**: Order through enforcement, discontent simmers
- **Difficulty**: Hard (3/3)
- **Unlocked Actions**: All
- **Challenge**: Can you maintain control without losing the people?

### 4. Boomtown
- **Starting State**: High capacity (75%), efficiency (70%); low stability (40%), clarity (40%)
- **Modifiers**: 1.4x decay (unsustainable), 1.3x events (volatility), 1.2x action costs (strain)
- **Theme**: Rapid growth outpaces coordination
- **Difficulty**: Hard (3/3)
- **Unlocked Actions**: All
- **Challenge**: Tame the boom before it becomes a bust

### 5. Corrupt Machine
- **Starting State**: Very low clarity (20%), efficiency (30%); high reserves (70%)
- **Modifiers**: 2.0x noise (misinformation), 1.3x action costs (waste), clarity threshold +0.10
- **Theme**: Opacity and waste characterize the system
- **Difficulty**: Hard (3/3)
- **Unlocked Actions**: All
- **Challenge**: Navigate blind through fog of corruption

### 6. Blind Administrator
- **Starting State**: Extremely low clarity (15%), all other meters varied 35-55%
- **Modifiers**: 1.8x noise (unreliable info), 1.2x decay (can't intervene timely), clarity threshold +0.15
- **Theme**: All decisions made with unreliable information
- **Difficulty**: Hard (3/3)
- **Unlocked Actions**: All
- **Challenge**: Survive with blind spots active and maximum fog

### 7. Tutorial District (Bonus, Beginner-Friendly)
- **Starting State**: All meters 60%, high clarity (70%)
- **Modifiers**: 0.6x decay, 0.5x events, 0.5x noise (forgiving)
- **Theme**: Learn mechanics without pressure
- **Difficulty**: Easy (1/3)
- **Unlocked Actions**: Only 4 basic actions (stabilize, allocate_reserves, improve_clarity, boost_morale)
- **Purpose**: Reduce first-run complexity

### 8. Crisis Point (Bonus)
- **Starting State**: All meters 28-38% (near collapse thresholds)
- **Modifiers**: 1.5x decay, 1.6x events (crisis cascade)
- **Theme**: Test emergency response protocols
- **Difficulty**: Hard (3/3)
- **Unlocked Actions**: All
- **Purpose**: Late-game balance testing

## Difficulty Profiles Implemented

### 1. Forgiving
- Decay: 0.7x (30% slower)
- Events: 0.7x (30% less intense)
- Noise: 0.6x (40% less)
- Thresholds: 1.1x (10% more forgiving, e.g., 0.25 → 0.275)
- Resources: +30 budget, +10 influence
- **Purpose**: Learning, testing, accessibility

### 2. Standard (Default)
- All multipliers: 1.0x
- No resource adjustments
- **Purpose**: Intended baseline experience

### 3. Unforgiving
- Decay: 1.4x (40% faster)
- Events: 1.5x (50% more intense)
- Noise: 1.4x (40% more)
- Thresholds: 0.9x (10% stricter, e.g., 0.25 → 0.225)
- Resources: -20 budget, -10 influence
- **Purpose**: Challenge for experienced players

### 4. Brutal (Bonus)
- Decay: 1.8x, Events: 2.0x, Noise: 1.8x, Thresholds: 0.8x
- Resources: -40 budget, -20 influence
- **Purpose**: Extreme difficulty, testing worst-case

### 5. Sandbox (Bonus)
- Decay: 0.3x, Events: 0.3x, Noise: 0.3x, Thresholds: 1.3x
- Resources: +100 budget, +50 influence
- **Purpose**: Experimentation without pressure

### 6. Time-Lapse (Bonus)
- Standard multipliers, but starts at turn 20
- **Purpose**: Test late-game scenarios and recovery

## Assumptions Made

### Meter Assumptions
- Meters exist with IDs: `stability`, `capacity`, `reserves`, `clarity`, `morale`, `efficiency`
- All meters use normalized 0.0-1.0 range
- Meters have a concept of decay/degradation per turn
- Meters can be initialized to specific values

### Resource Assumptions
- At least two meta-resources exist: `budget` and `influence`
- Resources are integer values (not normalized)
- Resources can be positive or zero
- Additional resources may exist but are optional

### Action Assumptions
- Actions have string IDs
- Actions can be locked/unlocked programmatically
- There's a concept of "basic" vs "advanced" actions
- Assumed basic action IDs for tutorial: `stabilize`, `allocate_reserves`, `improve_clarity`, `boost_morale`
- Actions have costs that can be modified by multipliers
- If `unlockedActions` is null, all actions are available (expert mode)
- If `unlockedActions` is empty list, no actions available (demo/observation mode)

### Game State Assumptions
- `GameState` can be initialized with specific meter/resource values
- `TurnEngine` can apply modifiers to ongoing gameplay
- Turn counter exists and can be set to non-zero (for Time-Lapse)
- Existing core files are not modified (as per constraints)

### Event Engine Integration Assumptions
- Event Engine exists (from items 31-38)
- Event Engine can accept noise magnitude multiplier
- Events have base probabilities that can be scaled
- Events have effect magnitudes that can be scaled
- Threshold events have configurable thresholds
- Event Engine can be initialized with modifiers

### TurnEngine Integration Assumptions
- TurnEngine handles initialization from scenario data
- TurnEngine stores and applies active modifiers during gameplay
- TurnEngine can gate actions based on unlocked list
- TurnEngine integrates with Event Engine for modifier passthrough

## What Was Intentionally NOT Implemented

### Out of Scope

1. **UI Components**
   - No Flutter widgets for scenario/difficulty selection
   - No visual scenario cards or difficulty indicators
   - Integration example code only, not actual UI

2. **Core File Modifications**
   - Did not modify `lib/core/models/game_state.dart`
   - Did not modify `lib/core/models/meter.dart`
   - Did not modify `lib/core/state/turn_engine.dart`
   - These files assumed to exist and support needed operations

3. **Actual TurnEngine Integration**
   - Did not implement `applyToGameState()` in TurnEngine
   - Provided integration guide only
   - TurnEngine must implement modifier application

4. **Persistence/Serialization**
   - No JSON serialization for scenarios
   - No save/load for active scenario+difficulty
   - Assumed scenarios are code-defined constants

5. **Dynamic Scenarios**
   - No runtime scenario generation
   - No scenario editor
   - No procedural scenario creation

6. **Scenario-Specific Events**
   - Did not add events that only trigger in certain scenarios
   - Events remain universal (from Event Engine)
   - Could be future enhancement

7. **Achievements/Progression**
   - No scenario unlock system
   - No completion tracking
   - No difficulty-based rewards

8. **AI Assistance**
   - No difficulty auto-adjustment
   - No "adaptive" profiles that respond to player performance
   - Static modifiers only

9. **Multiplayer Scenarios**
   - No co-op or competitive scenarios
   - Single-player focus only

10. **Real-World Themes**
    - No real politics, real cities, real events
    - All scenarios use abstract language
    - Maintained design invariant of political neutrality

## Design Choices & Rationale

### Why These 6 Scenarios?

1. **Baseline**: Required reference point for all other scenarios
2. **Fragile Stability**: Tests "hidden vulnerability" - looks good but isn't
3. **Hardline City**: Tests "authoritarian tradeoff" - order vs trust
4. **Boomtown**: Tests "unsustainable growth" - boom/bust cycles
5. **Corrupt Machine**: Tests "information warfare" - fog at maximum
6. **Blind Administrator**: Tests "decision under uncertainty" - can't see the board

Each represents a distinct challenge type that feels different to play.

### Why These 3 Difficulty Profiles?

- **Forgiving**: Accessibility, onboarding, testing
- **Standard**: Baseline as designed
- **Unforgiving**: Challenge for mastery

This provides clear easy/medium/hard ladder without overwhelming choice.

### Modifier Design Philosophy

- Multipliers (not additive) so effects scale proportionally
- Range 0.3x - 2.0x keeps gameplay recognizable
- Threshold adjustments are small (±10-20%) to avoid breaking game logic
- Resource adjustments are moderate to maintain economy balance

### Beginner-Friendly Criteria

A scenario is beginner-friendly if:
1. Difficulty rating ≤ 2 (medium or easier)
2. No extreme meter values (nothing below 15% except in forgiving scenarios)
3. Higher clarity (≥ 60%) for clearer feedback
4. Optional: limited actions to reduce choice paralysis

### Abstract Language Choices

- "District" not "city" (more abstract)
- "Systems" not "government" (neutral)
- "Enforcement" not "police" (abstract authority)
- "Coordination" not "politics" (technical)
- "Morale" not "happiness" (less loaded)
- "Reserves" not "money" (abstract buffer)

## Known Limitations

1. **Modifier Stacking**
   - Scenario + Difficulty modifiers multiply
   - Can create extreme values (e.g., 2.0x noise * 1.8x noise = 3.6x)
   - Intentional for extreme combos (Corrupt Machine + Brutal)

2. **No Modifier Caps**
   - No maximum/minimum multiplier enforcement
   - Assumes reasonable combinations chosen
   - Could add clamping if needed

3. **Static Action Lists**
   - Unlocked actions hard-coded in scenario definitions
   - No dynamic unlock based on progress
   - Future: progression system could override

4. **No Scenario Validation**
   - Doesn't verify meter values are in 0.0-1.0 range
   - Doesn't check for impossible starting states
   - Assumes scenario designers test their scenarios

5. **Threshold Calculation Assumptions**
   - Base thresholds hard-coded in DifficultyProfile
   - Must match Event Engine actual thresholds
   - Fragile if Event Engine thresholds change

6. **Resource ID Coupling**
   - Assumes 'budget' and 'influence' exist
   - Other resources ignored if not in GameState
   - Could be made more flexible with resource registry

## Testing Recommendations

### Unit Testing
```dart
test('Scenario load applies modifiers correctly', () {
  final result = ScenarioLoader.load(
    scenario: ScenarioCatalog.baseline,
    difficulty: DifficultyCatalog.unforgiving,
  );
  expect(result.combinedModifiers.decayRateMultiplier, 1.4);
});

test('Resource adjustments apply correctly', () {
  final result = ScenarioLoader.load(
    scenario: ScenarioCatalog.baseline, // 100 budget
    difficulty: DifficultyCatalog.forgiving, // +30 budget
  );
  expect(result.initialResources['budget'], 130);
});
```

### Integration Testing
```dart
test('Fragile Stability fails on first crisis', () {
  // Load scenario
  // Trigger threshold event
  // Verify rapid collapse due to low reserves
});

test('Blind Administrator has active blind spots', () {
  // Load scenario (clarity = 15%)
  // Check FogMechanics.isMeterHidden('reserves', 0.15)
  // Verify returns true
});
```

### Balance Testing
- Run each scenario + standard difficulty for 50 turns
- Measure survival rate, final meter values
- Ensure scenarios create distinct experiences
- Verify no scenario is trivially easy or impossible

## Future Enhancements (Not Implemented)

- Custom scenario builder (JSON import/export)
- Scenario achievements (complete X with difficulty Y)
- Dynamic difficulty (modifiers adjust based on performance)
- Scenario chains (story mode progression)
- Seasonal/event scenarios (limited-time challenges)
- Community scenario sharing
- Procedural scenario generation
- Scenario-specific events that only trigger in certain scenarios
- Visual scenario preview (meter charts, modifier icons)
- Recommended action hints per scenario

## Version

- **Version**: 1.0
- **Date**: 2026-01-17
- **Implements**: Items 45 + light 44 support
- **Dependencies**: Event Engine (items 31-38)
- **Status**: Complete, ready for TurnEngine integration
