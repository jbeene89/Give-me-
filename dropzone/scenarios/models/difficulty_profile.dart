import 'scenario_modifiers.dart';

/// Defines a difficulty profile that scales game parameters
class DifficultyProfile {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Description of what makes this difficulty different
  final String description;

  /// Multiplier for meter decay rates (higher = faster decay)
  /// 1.0 = normal, 1.3 = 30% faster decay, 0.7 = 30% slower
  final double decayRateMultiplier;

  /// Multiplier for event trigger probabilities and effect magnitudes
  /// 1.0 = normal, 1.5 = 50% more intense events
  final double eventIntensityMultiplier;

  /// Multiplier for information fog noise magnitude
  /// 1.0 = normal noise, 1.5 = 50% more noise, 0.5 = 50% less noise
  final double noiseMagnitudeMultiplier;

  /// Multiplier for collapse thresholds (lower = easier to trigger)
  /// 1.0 = normal (e.g., stability < 0.25), 0.9 = easier (< 0.225)
  /// Applied to threshold values, making danger zones larger
  final double collapseThresholdMultiplier;

  /// Initial resource bonus (difficulty offset)
  /// Easy might give +50 budget, Hard might give -20
  final Map<String, int> resourceAdjustments;

  /// Starting turn number (for testing late-game states)
  final int startingTurn;

  const DifficultyProfile({
    required this.id,
    required this.name,
    required this.description,
    this.decayRateMultiplier = 1.0,
    this.eventIntensityMultiplier = 1.0,
    this.noiseMagnitudeMultiplier = 1.0,
    this.collapseThresholdMultiplier = 1.0,
    this.resourceAdjustments = const {},
    this.startingTurn = 0,
  });

  /// Convert to ScenarioModifiers for application
  ScenarioModifiers toModifiers() {
    return ScenarioModifiers(
      decayRateMultiplier: decayRateMultiplier,
      eventProbabilityMultiplier: eventIntensityMultiplier,
      noiseMagnitudeMultiplier: noiseMagnitudeMultiplier,
      // Threshold adjustments based on collapse threshold multiplier
      thresholdAdjustments: _calculateThresholdAdjustments(),
    );
  }

  /// Calculate threshold adjustments based on multiplier
  Map<String, double> _calculateThresholdAdjustments() {
    if (collapseThresholdMultiplier == 1.0) return {};

    // Lower multiplier = lower thresholds = easier to trigger events
    // If multiplier is 0.9, we want thresholds 10% lower
    final adjustment = -(1.0 - collapseThresholdMultiplier);

    return {
      'stability': adjustment * 0.25, // Base threshold ~0.25
      'capacity': adjustment * 0.30, // Base threshold ~0.30
      'reserves': adjustment * 0.20, // Base threshold ~0.20
      'clarity': adjustment * 0.35, // Base threshold ~0.35
    };
  }

  /// Combine this difficulty profile with scenario modifiers
  ScenarioModifiers combineWith(ScenarioModifiers scenarioMods) {
    return ScenarioModifiers(
      decayRateMultiplier:
          decayRateMultiplier * scenarioMods.decayRateMultiplier,
      eventProbabilityMultiplier:
          eventIntensityMultiplier * scenarioMods.eventProbabilityMultiplier,
      noiseMagnitudeMultiplier:
          noiseMagnitudeMultiplier * scenarioMods.noiseMagnitudeMultiplier,
      thresholdAdjustments: _mergeThresholdAdjustments(
        _calculateThresholdAdjustments(),
        scenarioMods.thresholdAdjustments,
      ),
      actionCostMultiplier: scenarioMods.actionCostMultiplier,
      reserveDrainMultiplier: scenarioMods.reserveDrainMultiplier,
    );
  }

  Map<String, double> _mergeThresholdAdjustments(
    Map<String, double> a,
    Map<String, double> b,
  ) {
    final result = Map<String, double>.from(a);
    b.forEach((key, value) {
      result[key] = (result[key] ?? 0.0) + value;
    });
    return result;
  }

  @override
  String toString() => '$name ($id)';
}
