import 'models/offer.dart';
import 'models/offer_types.dart';

/// Catalog of all available offers
class OfferCatalog {
  // ========== INFORMATION OFFERS ==========

  /// 1. Forecast Extension - See future turns
  static const Offer forecastExtension = Offer(
    id: 'forecast_extension',
    name: 'Strategic Forecast',
    description: 'Gain visibility into the next 2 turns. See projected meter changes and upcoming events before they happen.',
    benefitText: 'Plan ahead with confidence. Make informed decisions with advance warning.',
    offerType: OfferType.information,
    triggerCondition: TriggerCondition.crisis,
    effects: [
      OfferEffect(
        type: OfferEffectType.forecastExtension,
        magnitude: 2.0, // 2 turns ahead
        duration: 5, // Lasts 5 turns
      ),
    ],
    priceTier: PriceTier.medium,
    cooldownTurns: 10,
    minimumTurn: 5,
    triggerThresholds: {
      'clarity': 0.40, // Triggers when clarity is low (can't see clearly)
    },
  );

  /// 2. Noise Reduction - Clarity boost
  static const Offer clarityBoost = Offer(
    id: 'clarity_boost',
    name: 'Enhanced Monitoring',
    description: 'Deploy advanced sensors to reduce information noise by 70% for the next 8 turns. See the true state of your district.',
    benefitText: 'Cut through the fog. Know what\'s really happening.',
    offerType: OfferType.information,
    triggerCondition: TriggerCondition.crisis,
    effects: [
      OfferEffect(
        type: OfferEffectType.noiseReduction,
        magnitude: 0.7, // Reduce noise by 70%
        duration: 8, // 8 turns
      ),
    ],
    priceTier: PriceTier.medium,
    cooldownTurns: 12,
    minimumTurn: 8,
    triggerThresholds: {
      'clarity': 0.35, // Triggers when clarity is very low
    },
  );

  /// 3. Audit Report - Reveals hidden meters
  static const Offer auditReport = Offer(
    id: 'audit_report',
    name: 'Comprehensive Audit',
    description: 'Commission a full system audit. Reveals all hidden meters and blind spots for 6 turns.',
    benefitText: 'See the complete picture. No more surprises.',
    offerType: OfferType.information,
    triggerCondition: TriggerCondition.crisis,
    effects: [
      OfferEffect(
        type: OfferEffectType.revealBlindSpots,
        magnitude: 1.0, // Reveals all
        duration: 6, // 6 turns
      ),
    ],
    priceTier: PriceTier.small,
    cooldownTurns: 10,
    minimumTurn: 10,
    triggerThresholds: {
      'clarity': 0.30, // Triggers when blind spots are active
    },
  );

  // ========== STABILITY OFFERS ==========

  /// 4. Emergency Veto Token - Prevent one collapse event
  static const Offer emergencyVeto = Offer(
    id: 'emergency_veto',
    name: 'Emergency Override',
    description: 'Obtain emergency authority to veto the next threshold collapse event. One-time use safety net.',
    benefitText: 'A second chance when you need it most.',
    offerType: OfferType.emergency,
    triggerCondition: TriggerCondition.crisis,
    effects: [
      OfferEffect(
        type: OfferEffectType.collapseVeto,
        magnitude: 1.0, // Prevents 1 event
        duration: -1, // Consumable (used when needed)
      ),
    ],
    priceTier: PriceTier.large,
    cooldownTurns: 15,
    minimumTurn: 12,
    purchaseLimit: 3, // Can only buy 3 per game
    triggerThresholds: {
      'stability': 0.30, // Triggers when near collapse
      'reserves': 0.25,
    },
  );

  /// 5. Reserve Injection - Immediate resources
  static const Offer reserveInjection = Offer(
    id: 'reserve_injection',
    name: 'Emergency Reserves',
    description: 'Access emergency district reserves. Immediately boosts reserves meter by 25% and grants budget resources.',
    benefitText: 'Instant relief. Buy time to stabilize.',
    offerType: OfferType.emergency,
    triggerCondition: TriggerCondition.crisis,
    effects: [
      OfferEffect(
        type: OfferEffectType.meterBoost,
        target: 'reserves',
        magnitude: 0.25, // +25% reserves
        duration: -1, // Instant
      ),
      OfferEffect(
        type: OfferEffectType.resourceGrant,
        target: 'budget',
        magnitude: 50.0, // +50 budget
        duration: -1, // Instant
      ),
    ],
    priceTier: PriceTier.medium,
    cooldownTurns: 8,
    minimumTurn: 8,
    triggerThresholds: {
      'reserves': 0.20, // Triggers when reserves critically low
    },
  );

  /// 6. Stability Support - Short-term stability boost
  static const Offer stabilitySupport = Offer(
    id: 'stability_support',
    name: 'Coordination Support',
    description: 'Deploy specialized coordination teams. Reduces system decay by 40% for 6 turns.',
    benefitText: 'Slow the chaos. Give yourself breathing room.',
    offerType: OfferType.stability,
    triggerCondition: TriggerCondition.crisis,
    effects: [
      OfferEffect(
        type: OfferEffectType.permanentModifier,
        target: 'decay',
        magnitude: 0.6, // Multiply decay by 0.6 (40% reduction)
        duration: 6, // 6 turns
      ),
    ],
    priceTier: PriceTier.medium,
    cooldownTurns: 10,
    minimumTurn: 10,
    triggerThresholds: {
      'stability': 0.35,
    },
  );

  // ========== EFFICIENCY OFFERS (Permanent) ==========

  /// 7. Advisor Hire - Permanent small buff
  static const Offer advisorHire = Offer(
    id: 'advisor_hire',
    name: 'Expert Advisor',
    description: 'Hire a permanent advisor. Permanently reduces action costs by 10% and improves efficiency.',
    benefitText: 'Long-term investment. Pays off every turn.',
    offerType: OfferType.efficiency,
    triggerCondition: TriggerCondition.streak,
    effects: [
      OfferEffect(
        type: OfferEffectType.actionCostReduction,
        magnitude: 0.1, // 10% reduction
        duration: 0, // Permanent
      ),
      OfferEffect(
        type: OfferEffectType.meterBoost,
        target: 'efficiency',
        magnitude: 0.05, // Small permanent boost
        duration: 0, // Permanent
      ),
    ],
    priceTier: PriceTier.premium,
    cooldownTurns: 0, // No cooldown (purchase limit prevents spam)
    minimumTurn: 15,
    purchaseLimit: 2, // Max 2 advisors
    triggerThresholds: {
      'stability': 0.60, // Only offered during good times
      'efficiency': 0.55,
    },
    streakRequired: 8, // Need 8 turns of good performance
  );

  /// 8. Infrastructure Upgrade - Permanent efficiency
  static const Offer infrastructureUpgrade = Offer(
    id: 'infrastructure_upgrade',
    name: 'System Modernization',
    description: 'Invest in infrastructure improvements. Permanently reduces decay rate by 8%.',
    benefitText: 'Build for the future. Make every turn easier.',
    offerType: OfferType.efficiency,
    triggerCondition: TriggerCondition.streak,
    effects: [
      OfferEffect(
        type: OfferEffectType.permanentModifier,
        target: 'decay',
        magnitude: 0.92, // Multiply decay by 0.92 (8% reduction)
        duration: 0, // Permanent
      ),
    ],
    priceTier: PriceTier.premium,
    cooldownTurns: 0,
    minimumTurn: 20,
    purchaseLimit: 1, // Only once per game
    triggerThresholds: {
      'stability': 0.65,
      'capacity': 0.60,
    },
    streakRequired: 10, // Need strong performance
  );

  // ========== RANDOM/BONUS OFFERS ==========

  /// 9. Morale Boost - Occasional goodwill offer
  static const Offer moraleBoost = Offer(
    id: 'morale_boost',
    name: 'Community Initiative',
    description: 'Launch a community engagement program. Immediately boosts morale by 20% and improves clarity.',
    benefitText: 'Strengthen trust. Improve cooperation.',
    offerType: OfferType.stability,
    triggerCondition: TriggerCondition.random,
    effects: [
      OfferEffect(
        type: OfferEffectType.meterBoost,
        target: 'morale',
        magnitude: 0.20, // +20% morale
        duration: -1, // Instant
      ),
      OfferEffect(
        type: OfferEffectType.meterBoost,
        target: 'clarity',
        magnitude: 0.10, // +10% clarity
        duration: -1, // Instant
      ),
    ],
    priceTier: PriceTier.small,
    cooldownTurns: 12,
    minimumTurn: 6,
    randomProbability: 0.15, // 15% chance per turn (when not on cooldown)
  );

  /// 10. Capacity Expansion - Random opportunity
  static const Offer capacityExpansion = Offer(
    id: 'capacity_expansion',
    name: 'Workforce Initiative',
    description: 'Expand operational capacity. Boosts capacity meter by 15% immediately and grants influence.',
    benefitText: 'Scale up operations. Handle more complexity.',
    offerType: OfferType.efficiency,
    triggerCondition: TriggerCondition.random,
    effects: [
      OfferEffect(
        type: OfferEffectType.meterBoost,
        target: 'capacity',
        magnitude: 0.15, // +15% capacity
        duration: -1, // Instant
      ),
      OfferEffect(
        type: OfferEffectType.resourceGrant,
        target: 'influence',
        magnitude: 20.0, // +20 influence
        duration: -1, // Instant
      ),
    ],
    priceTier: PriceTier.medium,
    cooldownTurns: 15,
    minimumTurn: 10,
    randomProbability: 0.10, // 10% chance
  );

  // ========== CATALOG MANAGEMENT ==========

  /// All available offers
  static const List<Offer> allOffers = [
    // Information
    forecastExtension,
    clarityBoost,
    auditReport,

    // Stability/Emergency
    emergencyVeto,
    reserveInjection,
    stabilitySupport,

    // Efficiency/Permanent
    advisorHire,
    infrastructureUpgrade,

    // Random/Bonus
    moraleBoost,
    capacityExpansion,
  ];

  /// Get offers by type
  static List<Offer> getOffersByType(OfferType type) {
    return allOffers.where((o) => o.offerType == type).toList();
  }

  /// Get offers by trigger condition
  static List<Offer> getOffersByTrigger(TriggerCondition trigger) {
    return allOffers.where((o) => o.triggerCondition == trigger).toList();
  }

  /// Get offer by ID
  static Offer? getOfferById(String id) {
    try {
      return allOffers.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get crisis offers (shown during emergencies)
  static List<Offer> get crisisOffers =>
      getOffersByTrigger(TriggerCondition.crisis);

  /// Get streak offers (rewards for good play)
  static List<Offer> get streakOffers =>
      getOffersByTrigger(TriggerCondition.streak);

  /// Get random offers (surprise opportunities)
  static List<Offer> get randomOffers =>
      getOffersByTrigger(TriggerCondition.random);
}
