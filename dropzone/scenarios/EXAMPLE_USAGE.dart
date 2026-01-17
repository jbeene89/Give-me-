/// Example usage of Scenario and Difficulty system
/// Demonstrates how to load scenarios, apply modifiers, and integrate with game

import 'scenario_exports.dart';

void main() {
  print('=== Scenario System Examples ===\n');

  exampleBasicLoading();
  print('\n---\n');

  exampleAllScenarios();
  print('\n---\n');

  exampleDifficultyCombinations();
  print('\n---\n');

  exampleModifierStacking();
  print('\n---\n');

  exampleBeginnerPath();
  print('\n---\n');

  exampleExtremeCombos();
}

/// Example 1: Basic scenario loading
void exampleBasicLoading() {
  print('Example 1: Basic Loading\n');

  final result = ScenarioLoader.load(
    scenario: ScenarioCatalog.baseline,
    difficulty: DifficultyCatalog.standard,
  );

  print('Loaded: ${result.scenario.name} (${result.difficulty.name})');
  print('\nInitial Meters:');
  result.initialMeterValues.forEach((meter, value) {
    print('  $meter: ${(value * 100).toStringAsFixed(0)}%');
  });

  print('\nInitial Resources:');
  result.initialResources.forEach((resource, amount) {
    print('  $resource: $amount');
  });

  print('\nModifiers:');
  print('  Decay rate: ${result.combinedModifiers.decayRateMultiplier}x');
  print('  Event intensity: ${result.combinedModifiers.eventProbabilityMultiplier}x');
  print('  Noise magnitude: ${result.combinedModifiers.noiseMagnitudeMultiplier}x');
}

/// Example 2: Browse all scenarios
void exampleAllScenarios() {
  print('Example 2: All Available Scenarios\n');

  for (final scenario in ScenarioCatalog.allScenarios) {
    final beginner = scenario.beginnerFriendly ? ' [BEGINNER]' : '';
    final difficulty = '★' * scenario.recommendedDifficulty;
    print('${scenario.name} $difficulty$beginner');
    print('  ${scenario.description}');
    print('');
  }
}

/// Example 3: Same scenario, different difficulties
void exampleDifficultyCombinations() {
  print('Example 3: Fragile Stability Across Difficulties\n');

  final scenario = ScenarioCatalog.fragileStability;

  for (final difficulty in DifficultyCatalog.coreProfiles) {
    final result = ScenarioLoader.load(
      scenario: scenario,
      difficulty: difficulty,
    );

    print('${scenario.name} + ${difficulty.name}:');
    print('  Starting budget: ${result.initialResources['budget']}');
    print('  Decay rate: ${result.combinedModifiers.decayRateMultiplier}x');
    print('  Reserve drain: ${result.combinedModifiers.reserveDrainMultiplier}x');
    print('  Event intensity: ${result.combinedModifiers.eventProbabilityMultiplier}x');
    print('');
  }
}

/// Example 4: Modifier stacking
void exampleModifierStacking() {
  print('Example 4: Modifier Stacking (Corrupt Machine + Unforgiving)\n');

  final result = ScenarioLoader.load(
    scenario: ScenarioCatalog.corruptMachine,
    difficulty: DifficultyCatalog.unforgiving,
  );

  print('Scenario modifiers (Corrupt Machine):');
  print('  Noise: ${ScenarioCatalog.corruptMachine.modifiers.noiseMagnitudeMultiplier}x');
  print('  Action cost: ${ScenarioCatalog.corruptMachine.modifiers.actionCostMultiplier}x');
  print('');

  print('Difficulty modifiers (Unforgiving):');
  print('  Noise: ${DifficultyCatalog.unforgiving.noiseMagnitudeMultiplier}x');
  print('  Decay: ${DifficultyCatalog.unforgiving.decayRateMultiplier}x');
  print('');

  print('Combined modifiers:');
  print('  Noise: ${result.combinedModifiers.noiseMagnitudeMultiplier}x ' +
      '(2.0 * 1.4 = 2.8x)');
  print('  Action cost: ${result.combinedModifiers.actionCostMultiplier}x');
  print('  Decay: ${result.combinedModifiers.decayRateMultiplier}x');
  print('');

  print('Starting clarity: ${(result.initialMeterValues['clarity']! * 100).toStringAsFixed(0)}%');
  print('→ With 2.8x noise multiplier, this will be VERY foggy!');
}

/// Example 5: Beginner learning path
void exampleBeginnerPath() {
  print('Example 5: Recommended Beginner Path\n');

  print('Step 1: Tutorial + Forgiving');
  var result = ScenarioLoader.load(
    scenario: ScenarioCatalog.tutorial,
    difficulty: DifficultyCatalog.forgiving,
  );
  print('  ${result.unlockedActions!.length} actions available (limited)');
  print('  Decay: ${result.combinedModifiers.decayRateMultiplier}x (very slow)');
  print('  Clarity: ${(result.initialMeterValues['clarity']! * 100).toStringAsFixed(0)}% (clear feedback)');
  print('');

  print('Step 2: Baseline + Standard');
  result = ScenarioLoader.load(
    scenario: ScenarioCatalog.baseline,
    difficulty: DifficultyCatalog.standard,
  );
  print('  All actions available');
  print('  Decay: ${result.combinedModifiers.decayRateMultiplier}x (normal)');
  print('  All meters balanced at 50%');
  print('');

  print('Step 3: Fragile Stability + Standard');
  result = ScenarioLoader.load(
    scenario: ScenarioCatalog.fragileStability,
    difficulty: DifficultyCatalog.standard,
  );
  print('  Test handling asymmetric start');
  print('  Reserves: ${(result.initialMeterValues['reserves']! * 100).toStringAsFixed(0)}% (critical!)');
  print('  Reserve drain: ${result.combinedModifiers.reserveDrainMultiplier}x');
  print('');

  print('Step 4: Any Hard Scenario + Unforgiving');
  print('  Ready for full challenge!');
}

/// Example 6: Extreme difficulty combinations
void exampleExtremeCombos() {
  print('Example 6: Extreme Combinations\n');

  print('EASIEST: Tutorial + Sandbox');
  var result = ScenarioLoader.load(
    scenario: ScenarioCatalog.tutorial,
    difficulty: DifficultyCatalog.sandbox,
  );
  print('  Decay: ${result.combinedModifiers.decayRateMultiplier}x (0.6 * 0.3 = 0.18x!)');
  print('  Budget: ${result.initialResources['budget']}');
  print('  → Nearly impossible to lose');
  print('');

  print('HARDEST: Crisis Point + Brutal');
  result = ScenarioLoader.load(
    scenario: ScenarioCatalog.crisisPoint,
    difficulty: DifficultyCatalog.brutal,
  );
  print('  Decay: ${result.combinedModifiers.decayRateMultiplier}x (1.5 * 1.8 = 2.7x!)');
  print('  Events: ${result.combinedModifiers.eventProbabilityMultiplier}x (1.6 * 2.0 = 3.2x!)');
  print('  Starting stability: ${(result.initialMeterValues['stability']! * 100).toStringAsFixed(0)}%');
  print('  Budget: ${result.initialResources['budget']}');
  print('  → Surviving 10 turns is exceptional');
  print('');

  print('MOST CONFUSING: Blind Administrator + Unforgiving');
  result = ScenarioLoader.load(
    scenario: ScenarioCatalog.blindAdministrator,
    difficulty: DifficultyCatalog.unforgiving,
  );
  print('  Clarity: ${(result.initialMeterValues['clarity']! * 100).toStringAsFixed(0)}% (blind spots active)');
  print('  Noise: ${result.combinedModifiers.noiseMagnitudeMultiplier}x (1.8 * 1.4 = 2.52x)');
  print('  → Can barely see the game state');
}

/// Example 7: Simulating TurnEngine integration
void exampleTurnEngineIntegration() {
  print('Example 7: TurnEngine Integration Pattern\n');

  // Pseudo-code showing how TurnEngine would use this

  final result = ScenarioLoader.load(
    scenario: ScenarioCatalog.boomtown,
    difficulty: DifficultyCatalog.standard,
  );

  print('// In TurnEngine.initializeFromScenario():');
  print('');
  print('// 1. Set meter values');
  result.initialMeterValues.forEach((meterId, value) {
    print('gameState.getMeter("$meterId").value = $value;');
  });
  print('');

  print('// 2. Set resources');
  result.initialResources.forEach((resourceId, amount) {
    print('gameState.setResource("$resourceId", $amount);');
  });
  print('');

  print('// 3. Set unlocked actions');
  if (result.unlockedActions != null) {
    print('gameState.setUnlockedActions([');
    for (final action in result.unlockedActions!) {
      print('  "$action",');
    }
    print(']);');
  } else {
    print('// All actions unlocked');
  }
  print('');

  print('// 4. Store modifiers for ongoing use');
  print('_activeModifiers = result.combinedModifiers;');
  print('');

  print('// 5. Apply modifiers during gameplay');
  print('');
  print('// When applying decay:');
  print('final decayAmount = baseDecay * _activeModifiers.decayRateMultiplier;');
  print('// = baseDecay * ${result.combinedModifiers.decayRateMultiplier}');
  print('');

  print('// When checking events:');
  print('final eventProb = baseProb * _activeModifiers.eventProbabilityMultiplier;');
  print('// = baseProb * ${result.combinedModifiers.eventProbabilityMultiplier}');
  print('');

  print('// When calculating action cost:');
  print('final cost = baseCost * _activeModifiers.actionCostMultiplier;');
  print('// = baseCost * ${result.combinedModifiers.actionCostMultiplier}');
}

/// Example 8: Scenario summary generation
void exampleSummaryGeneration() {
  print('Example 8: Generated Summary\n');

  final result = ScenarioLoader.load(
    scenario: ScenarioCatalog.hardlineCity,
    difficulty: DifficultyCatalog.unforgiving,
  );

  print(ScenarioLoader.getSummary(result));
}
