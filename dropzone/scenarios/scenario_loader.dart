import 'models/scenario.dart';
import 'models/difficulty_profile.dart';
import 'models/scenario_modifiers.dart';

/// Result of loading a scenario with difficulty profile
class ScenarioLoadResult {
  final Scenario scenario;
  final DifficultyProfile difficulty;
  final Map<String, double> initialMeterValues;
  final Map<String, int> initialResources;
  final ScenarioModifiers combinedModifiers;
  final List<String>? unlockedActions;
  final int startingTurn;

  const ScenarioLoadResult({
    required this.scenario,
    required this.difficulty,
    required this.initialMeterValues,
    required this.initialResources,
    required this.combinedModifiers,
    required this.unlockedActions,
    required this.startingTurn,
  });
}

/// Loads and combines scenario + difficulty profile into game initialization data
class ScenarioLoader {
  /// Load a scenario with a difficulty profile
  /// Returns all data needed to initialize GameState
  static ScenarioLoadResult load({
    required Scenario scenario,
    required DifficultyProfile difficulty,
  }) {
    // Combine modifiers from scenario and difficulty
    final combinedModifiers = difficulty.combineWith(scenario.modifiers);

    // Apply difficulty resource adjustments to scenario initial resources
    final adjustedResources = Map<String, int>.from(scenario.initialResources);
    difficulty.resourceAdjustments.forEach((resourceId, adjustment) {
      adjustedResources[resourceId] =
          (adjustedResources[resourceId] ?? 0) + adjustment;
      // Ensure non-negative
      if (adjustedResources[resourceId]! < 0) {
        adjustedResources[resourceId] = 0;
      }
    });

    return ScenarioLoadResult(
      scenario: scenario,
      difficulty: difficulty,
      initialMeterValues: Map<String, double>.from(scenario.initialMeterValues),
      initialResources: adjustedResources,
      combinedModifiers: combinedModifiers,
      unlockedActions: scenario.unlockedActions,
      startingTurn: difficulty.startingTurn,
    );
  }

  /// Apply loaded scenario to game state
  /// This would be called by TurnEngine during initialization
  ///
  /// Example usage:
  /// ```dart
  /// final result = ScenarioLoader.load(
  ///   scenario: ScenarioCatalog.baseline,
  ///   difficulty: DifficultyCatalog.standard,
  /// );
  ///
  /// // Initialize GameState with result.initialMeterValues
  /// // Initialize resources with result.initialResources
  /// // Apply result.combinedModifiers to TurnEngine
  /// // Set unlocked actions from result.unlockedActions
  /// // Set turn counter to result.startingTurn
  /// ```
  static void applyToGameState(
    ScenarioLoadResult result,
    dynamic gameState, // Would be actual GameState type
  ) {
    // This is a placeholder showing what TurnEngine should do
    // Actual implementation would be in TurnEngine, not here
    throw UnimplementedError(
      'applyToGameState should be implemented in TurnEngine. '
      'Use ScenarioLoader.load() to get initialization data, '
      'then apply it manually to your GameState.',
    );
  }

  /// Get a summary description of the loaded scenario+difficulty combo
  static String getSummary(ScenarioLoadResult result) {
    final buffer = StringBuffer();
    buffer.writeln('${result.scenario.name} (${result.difficulty.name})');
    buffer.writeln('---');
    buffer.writeln(result.scenario.description);
    buffer.writeln('');
    buffer.writeln('Difficulty: ${result.difficulty.description}');
    buffer.writeln('');
    buffer.writeln('Starting Meters:');

    // Sort meters for consistent display
    final sortedMeters = result.initialMeterValues.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sortedMeters) {
      final percentage = (entry.value * 100).toStringAsFixed(0);
      buffer.writeln('  ${entry.key}: $percentage%');
    }

    buffer.writeln('');
    buffer.writeln('Starting Resources:');
    final sortedResources = result.initialResources.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sortedResources) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }

    if (result.unlockedActions != null) {
      buffer.writeln('');
      if (result.unlockedActions!.isEmpty) {
        buffer.writeln('Unlocked Actions: None (demo mode)');
      } else {
        buffer.writeln('Unlocked Actions: ${result.unlockedActions!.length}');
        for (final action in result.unlockedActions!) {
          buffer.writeln('  - $action');
        }
      }
    } else {
      buffer.writeln('');
      buffer.writeln('Unlocked Actions: All');
    }

    return buffer.toString();
  }
}
