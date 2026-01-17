/// Optional modifiers that adjust game parameters for a scenario
class ScenarioModifiers {
  /// Multiplier for all meter decay rates (1.0 = normal, 1.5 = 50% faster decay)
  final double decayRateMultiplier;

  /// Multiplier for event base probabilities (1.0 = normal, 1.3 = 30% more likely)
  final double eventProbabilityMultiplier;

  /// Multiplier for fog noise magnitude (1.0 = normal, 0.5 = half noise)
  final double noiseMagnitudeMultiplier;

  /// Adjustments to specific meter thresholds for events
  /// e.g., {'stability': -0.05} lowers stability threshold by 5%
  final Map<String, double> thresholdAdjustments;

  /// Action cost multiplier (1.0 = normal, 1.2 = 20% more expensive)
  final double actionCostMultiplier;

  /// Reserve drain rate multiplier (1.0 = normal, 1.5 = drains 50% faster)
  final double reserveDrainMultiplier;

  const ScenarioModifiers({
    this.decayRateMultiplier = 1.0,
    this.eventProbabilityMultiplier = 1.0,
    this.noiseMagnitudeMultiplier = 1.0,
    this.thresholdAdjustments = const {},
    this.actionCostMultiplier = 1.0,
    this.reserveDrainMultiplier = 1.0,
  });

  /// Create modifiers with all values at 1.0 (no modifications)
  const ScenarioModifiers.none()
      : decayRateMultiplier = 1.0,
        eventProbabilityMultiplier = 1.0,
        noiseMagnitudeMultiplier = 1.0,
        thresholdAdjustments = const {},
        actionCostMultiplier = 1.0,
        reserveDrainMultiplier = 1.0;

  ScenarioModifiers copyWith({
    double? decayRateMultiplier,
    double? eventProbabilityMultiplier,
    double? noiseMagnitudeMultiplier,
    Map<String, double>? thresholdAdjustments,
    double? actionCostMultiplier,
    double? reserveDrainMultiplier,
  }) {
    return ScenarioModifiers(
      decayRateMultiplier: decayRateMultiplier ?? this.decayRateMultiplier,
      eventProbabilityMultiplier:
          eventProbabilityMultiplier ?? this.eventProbabilityMultiplier,
      noiseMagnitudeMultiplier:
          noiseMagnitudeMultiplier ?? this.noiseMagnitudeMultiplier,
      thresholdAdjustments: thresholdAdjustments ?? this.thresholdAdjustments,
      actionCostMultiplier: actionCostMultiplier ?? this.actionCostMultiplier,
      reserveDrainMultiplier:
          reserveDrainMultiplier ?? this.reserveDrainMultiplier,
    );
  }
}
