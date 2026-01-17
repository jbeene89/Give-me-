import 'offer_types.dart';

/// Represents a monetization offer that can be presented to the player
class Offer {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Description explaining what this offer does
  final String description;

  /// Flavor text emphasizing benefit, not desperation
  final String benefitText;

  /// Type of offer (information, stability, etc.)
  final OfferType offerType;

  /// When this offer can trigger
  final TriggerCondition triggerCondition;

  /// Effects this offer provides
  final List<OfferEffect> effects;

  /// Price tier (placeholder for future IAP)
  final PriceTier priceTier;

  /// Cooldown in turns after purchase/decline before offering again
  final int cooldownTurns;

  /// Minimum turn number before this offer can appear
  final int minimumTurn;

  /// Maximum number of times this can be purchased (0 = unlimited)
  final int purchaseLimit;

  /// Trigger thresholds (meter values that must be met)
  /// For crisis triggers: meter must be BELOW threshold
  /// For streak triggers: meter must be ABOVE threshold
  final Map<String, double>? triggerThresholds;

  /// For streak triggers: number of turns of good performance needed
  final int? streakRequired;

  /// Base probability for random triggers (0.0-1.0)
  final double? randomProbability;

  const Offer({
    required this.id,
    required this.name,
    required this.description,
    required this.benefitText,
    required this.offerType,
    required this.triggerCondition,
    required this.effects,
    required this.priceTier,
    required this.cooldownTurns,
    this.minimumTurn = 5,
    this.purchaseLimit = 0,
    this.triggerThresholds,
    this.streakRequired,
    this.randomProbability,
  });

  /// Check if this offer's trigger conditions are met
  bool canTrigger(Map<String, double> meterValues, int currentTurn, int streakCount) {
    // Check minimum turn
    if (currentTurn < minimumTurn) return false;

    switch (triggerCondition) {
      case TriggerCondition.crisis:
        return _checkCrisisConditions(meterValues);

      case TriggerCondition.streak:
        return _checkStreakConditions(meterValues, streakCount);

      case TriggerCondition.random:
        // Caller should check random probability
        return true;

      case TriggerCondition.manual:
        // Always available (not triggered)
        return true;
    }
  }

  bool _checkCrisisConditions(Map<String, double> meterValues) {
    if (triggerThresholds == null) return false;

    // For crisis: at least one meter must be below threshold
    for (final entry in triggerThresholds!.entries) {
      final meterValue = meterValues[entry.key] ?? 0.5;
      if (meterValue <= entry.value) {
        return true;
      }
    }

    return false;
  }

  bool _checkStreakConditions(Map<String, double> meterValues, int streakCount) {
    if (triggerThresholds == null || streakRequired == null) return false;

    // Check streak length
    if (streakCount < streakRequired!) return false;

    // For streak: all specified meters must be above threshold
    for (final entry in triggerThresholds!.entries) {
      final meterValue = meterValues[entry.key] ?? 0.5;
      if (meterValue < entry.value) {
        return false;
      }
    }

    return true;
  }

  @override
  String toString() => '$name ($id)';
}
