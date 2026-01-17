# Scenario Presets + Difficulty Profiles - Give (Me)

## Overview

The Scenario system provides predefined starting conditions to:
- Quickly test game balance under different conditions
- Reduce first-run complexity for new players (tutorial/beginner scenarios)
- Create interesting asymmetric challenges
- Combine with difficulty profiles for varied experiences

## Architecture

### Core Components

1. **Scenario** (`models/scenario.dart`)
   - Defines initial meter values, resources, and unlocked actions
   - Includes optional modifiers to game parameters
   - Contains description and metadata (difficulty rating, beginner-friendly flag)

2. **DifficultyProfile** (`models/difficulty_profile.dart`)
   - Scales decay rates, event intensity, noise magnitude
   - Adjusts collapse thresholds
   - Provides resource bonuses/penalties
   - Can set starting turn number for late-game testing

3. **ScenarioModifiers** (`models/scenario_modifiers.dart`)
   - Fine-grained parameter adjustments
   - Multipliers for decay, events, noise, action costs, reserve drain
   - Threshold adjustments for specific meters

4. **ScenarioCatalog** (`scenario_catalog.dart`)
   - Contains all 6 core scenarios + 2 bonus scenarios
   - Filtering by difficulty, beginner-friendly, etc.

5. **DifficultyCatalog** (`difficulty_catalog.dart`)
   - Contains 3 core difficulty profiles + 3 bonus profiles
   - Default profile getter

6. **ScenarioLoader** (`scenario_loader.dart`)
   - Combines scenario + difficulty into initialization data
   - Merges modifiers from both sources
   - Provides summary generation

## Available Scenarios

### Core Scenarios (6)

1. **Baseline** (Beginner-Friendly)
   - All meters at 50%
   - Balanced starting point
   - Difficulty: Medium (2/3)

2. **Fragile Stability**
   - High morale (75%) and stability (70%), but very low reserves (15%)
   - One crisis away from collapse
   - Faster reserve drain, slightly more events
   - Difficulty: Medium (2/3)

3. **Hardline City**
   - High stability (75%) and efficiency (65%), very low morale (25%)
   - Order through enforcement, but discontent simmers
   - More events due to tension, slower decay due to control
   - Difficulty: Hard (3/3)

4. **Boomtown**
   - High capacity (75%) and efficiency (70%), low stability (40%) and clarity (40%)
   - Rapid growth outpaces coordination
   - Accelerated decay (1.4x), more events (1.3x), higher action costs (1.2x)
   - Difficulty: Hard (3/3)

5. **Corrupt Machine**
   - Very low clarity (20%) and efficiency (30%), high reserves (70%)
   - Opacity and waste characterize the system
   - Extreme noise (2.0x), higher action costs (1.3x)
   - Difficulty: Hard (3/3)

6. **Blind Administrator**
   - Extremely low clarity (15%), fog mechanics fully active
   - All decisions made with unreliable information
   - Very high noise (1.8x), faster decay (1.2x)
   - Difficulty: Hard (3/3)

### Bonus Scenarios (2)

7. **Tutorial District** (Beginner-Friendly)
   - All meters at 60%, high clarity (70%)
   - Limited unlocked actions (only basic 4)
   - Much slower decay (0.6x), fewer events (0.5x), less noise (0.5x)
   - Difficulty: Easy (1/3)

8. **Crisis Point**
   - All meters at 28-38% (near collapse)
   - Test emergency response protocols
   - Accelerated decay (1.5x), more frequent events (1.6x)
   - Difficulty: Hard (3/3)

## Available Difficulty Profiles

### Core Profiles (3)

1. **Forgiving**
   - Decay: 0.7x (30% slower)
   - Events: 0.7x (30% less intense)
   - Noise: 0.6x (40% less)
   - Thresholds: 1.1x (10% more forgiving)
   - Resources: +30 budget, +10 influence

2. **Standard** (Default)
   - All multipliers at 1.0x
   - No resource adjustments
   - Baseline experience as designed

3. **Unforgiving**
   - Decay: 1.4x (40% faster)
   - Events: 1.5x (50% more intense)
   - Noise: 1.4x (40% more)
   - Thresholds: 0.9x (10% stricter)
   - Resources: -20 budget, -10 influence

### Bonus Profiles (3)

4. **Brutal**
   - Decay: 1.8x, Events: 2.0x, Noise: 1.8x, Thresholds: 0.8x
   - Resources: -40 budget, -20 influence
   - Survival beyond 20 turns is exceptional

5. **Sandbox**
   - Decay: 0.3x, Events: 0.3x, Noise: 0.3x, Thresholds: 1.3x
   - Resources: +100 budget, +50 influence
   - For experimentation and learning

6. **Time-Lapse**
   - Standard multipliers, but starts at turn 20
   - Test late-game recovery scenarios

## Integration with TurnEngine

### Step 1: Initialize Game with Scenario

```dart
import 'package:give_me/dropzone/scenarios/scenario_exports.dart';

class TurnEngine {
  ScenarioLoadResult? _loadedScenario;
  ScenarioModifiers _activeModifiers = const ScenarioModifiers.none();

  void initializeFromScenario({
    required Scenario scenario,
    required DifficultyProfile difficulty,
  }) {
    // Load scenario
    _loadedScenario = ScenarioLoader.load(
      scenario: scenario,
      difficulty: difficulty,
    );

    // Apply to game state
    _initializeGameState(_loadedScenario!);
  }

  void _initializeGameState(ScenarioLoadResult result) {
    // Set meters
    for (final entry in result.initialMeterValues.entries) {
      gameState.getMeter(entry.key).value = entry.value;
    }

    // Set resources
    for (final entry in result.initialResources.entries) {
      gameState.setResource(entry.key, entry.value);
    }

    // Set unlocked actions
    if (result.unlockedActions != null) {
      gameState.setUnlockedActions(result.unlockedActions!);
    }

    // Set starting turn
    currentTurn = result.startingTurn;

    // Store modifiers for ongoing use
    _activeModifiers = result.combinedModifiers;
  }
}
```

### Step 2: Apply Modifiers During Gameplay

#### Decay Rates
```dart
void applyDecay(Meter meter) {
  final baseDecay = meter.baseDecayRate;
  final modifiedDecay = baseDecay * _activeModifiers.decayRateMultiplier;
  meter.value -= modifiedDecay;
}
```

#### Event Intensity
```dart
void processEvents() {
  // When checking event probabilities
  for (final event in possibleEvents) {
    final baseProbability = event.baseProbability;
    final modifiedProbability = baseProbability *
        _activeModifiers.eventProbabilityMultiplier;

    if (random.nextDouble() < modifiedProbability) {
      triggerEvent(event);
    }
  }

  // When applying event effects
  final effect = eventEffect.delta *
      _activeModifiers.eventProbabilityMultiplier; // Scale magnitude
}
```

#### Noise Magnitude (integrate with Event Engine)
```dart
// In EventEngine initialization
EventEngine({
  required ScenarioModifiers modifiers,
}) : _fogMechanics = FogMechanics(
  noiseMagnitudeMultiplier: modifiers.noiseMagnitudeMultiplier,
);

// In FogMechanics.applyNoiseToMeterValue
double applyNoiseToMeterValue(double actualValue, double clarity) {
  // ... existing noise calculation
  final baseNoise = maxNoisePercentage * noiseFactor;
  final modifiedNoise = baseNoise * noiseMagnitudeMultiplier; // From modifier
  // ... apply noise
}
```

#### Threshold Adjustments
```dart
bool checkThresholdEvent(GameEvent event) {
  final threshold = event.thresholdTrigger!.threshold;

  // Apply adjustment from modifiers
  final meterId = event.thresholdTrigger!.meterId;
  final adjustment = _activeModifiers.thresholdAdjustments[meterId] ?? 0.0;
  final modifiedThreshold = threshold + adjustment;

  final meterValue = gameState.getMeter(meterId).value;
  return event.thresholdTrigger!.triggerAbove
      ? meterValue >= modifiedThreshold
      : meterValue <= modifiedThreshold;
}
```

#### Action Costs
```dart
int getActionCost(Action action) {
  final baseCost = action.baseCost;
  final modifiedCost = (baseCost * _activeModifiers.actionCostMultiplier).round();
  return modifiedCost;
}
```

#### Reserve Drain
```dart
void drainReserves(double amount) {
  final modifiedDrain = amount * _activeModifiers.reserveDrainMultiplier;
  gameState.getMeter('reserves').value -= modifiedDrain;
}
```

### Step 3: UI Integration (Example)

```dart
// Scenario selection screen
class ScenarioSelectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Show beginner scenarios first
        ...ScenarioCatalog.beginnerScenarios.map((scenario) =>
          ScenarioCard(scenario: scenario)
        ),

        Divider(),

        // Show other scenarios
        ...ScenarioCatalog.allScenarios
            .where((s) => !s.beginnerFriendly)
            .map((scenario) => ScenarioCard(scenario: scenario)),
      ],
    );
  }
}

// Difficulty selection
class DifficultySelectScreen extends StatelessWidget {
  final Scenario selectedScenario;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: DifficultyCatalog.coreProfiles.map((difficulty) =>
        DifficultyCard(
          difficulty: difficulty,
          onSelect: () => _startGame(selectedScenario, difficulty),
        )
      ).toList(),
    );
  }

  void _startGame(Scenario scenario, DifficultyProfile difficulty) {
    final turnEngine = TurnEngine();
    turnEngine.initializeFromScenario(
      scenario: scenario,
      difficulty: difficulty,
    );
    // Navigate to game screen
  }
}
```

## How Modifiers Affect Gameplay

### Decay Rate Multiplier
- Applied to all meter natural decay
- Higher = meters degrade faster
- Lower = more time to react

### Event Probability/Intensity Multiplier
- Scales both trigger probability AND effect magnitude
- Makes events more/less frequent and impactful
- Compounds with scenario volatility

### Noise Magnitude Multiplier
- Scales ± error in fog mechanics
- Higher = less reliable information
- Compounds with low clarity meter

### Threshold Adjustments
- Shifts when threshold events trigger
- Negative adjustment = triggers earlier (harder)
- Positive adjustment = triggers later (easier)

### Action Cost Multiplier
- Makes all actions more/less expensive
- Affects resource economy

### Reserve Drain Multiplier
- How fast emergency reserves deplete
- Critical for fragile scenarios

## Testing & Balance

### Quick Testing Flow
```dart
// Test each scenario with standard difficulty
void testAllScenarios() {
  for (final scenario in ScenarioCatalog.coreScenarios) {
    final result = ScenarioLoader.load(
      scenario: scenario,
      difficulty: DifficultyCatalog.standard,
    );
    print(ScenarioLoader.getSummary(result));
    // Run simulation...
  }
}

// Test difficulty scaling on baseline
void testDifficulties() {
  for (final difficulty in DifficultyCatalog.coreProfiles) {
    final result = ScenarioLoader.load(
      scenario: ScenarioCatalog.baseline,
      difficulty: difficulty,
    );
    // Run simulation...
  }
}
```

### Recommended Test Matrix
- **New players**: Tutorial + Forgiving
- **Learning**: Baseline + Standard
- **Challenge**: Fragile Stability + Unforgiving
- **Expert**: Boomtown/Hardline + Unforgiving
- **Stress test**: Crisis Point + Brutal

## Design Principles Upheld

1. **No new meters/actions**: Scenarios only adjust existing parameters
2. **Abstract language**: "districts", "systems", "enforcement", "coordination"
3. **No equilibrium**: Even "forgiving" difficulty still has decay
4. **Explainable asymmetry**: Each scenario has clear thematic reason for its values
5. **Tradeoffs visible**: High values in one area mean low values elsewhere

## Assumptions

- Meters exist: `stability`, `capacity`, `reserves`, `clarity`, `morale`, `efficiency`
- Resources exist: `budget`, `influence` (at minimum)
- Actions have IDs and can be locked/unlocked
- TurnEngine can apply modifiers to decay/events/costs
- EventEngine can accept noise multiplier
- GameState can set initial values and unlocked actions

## Future Extensions

- Scenario-specific events (events that only trigger in certain scenarios)
- Dynamic difficulty (modifiers that adjust based on performance)
- Scenario chaining (complete one, unlock next)
- Custom scenario editor
- Scenario achievements/challenges
