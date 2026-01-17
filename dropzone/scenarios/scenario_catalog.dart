import 'models/scenario.dart';
import 'models/scenario_modifiers.dart';

/// Catalog of all predefined scenarios
class ScenarioCatalog {
  // ========== CORE SCENARIOS (6 required) ==========

  /// 1. Baseline - Balanced starting conditions for normal play
  static const Scenario baseline = Scenario(
    id: 'baseline',
    name: 'Baseline',
    description: 'Balanced district in stable conditions. '
        'All systems operating at moderate capacity. '
        'Standard starting point for new administrators.',
    initialMeterValues: {
      'stability': 0.50,
      'capacity': 0.50,
      'reserves': 0.50,
      'clarity': 0.50,
      'morale': 0.50,
      'efficiency': 0.50,
    },
    initialResources: {
      'budget': 100,
      'influence': 50,
    },
    unlockedActions: null, // All actions available
    modifiers: ScenarioModifiers.none(),
    recommendedDifficulty: 2,
    beginnerFriendly: true,
  );

  /// 2. Fragile Stability - High satisfaction but depleted reserves
  static const Scenario fragileStability = Scenario(
    id: 'fragile_stability',
    name: 'Fragile Stability',
    description: 'District appears prosperous with high morale and apparent stability. '
        'However, emergency reserves are critically depleted from recent investments. '
        'One crisis could shatter the illusion of security.',
    initialMeterValues: {
      'stability': 0.70, // High stability
      'capacity': 0.55,
      'reserves': 0.15, // Very low reserves - the fragility
      'clarity': 0.60,
      'morale': 0.75, // High morale
      'efficiency': 0.50,
    },
    initialResources: {
      'budget': 80, // Lower than baseline
      'influence': 60, // Higher influence due to current satisfaction
    },
    unlockedActions: null, // All actions available
    modifiers: ScenarioModifiers(
      reserveDrainMultiplier: 1.3, // Reserves drain faster
      eventProbabilityMultiplier: 1.1, // Slightly more events to test fragility
    ),
    recommendedDifficulty: 2,
    beginnerFriendly: false,
  );

  /// 3. Hardline City - High enforcement, low trust
  static const Scenario hardlineCity = Scenario(
    id: 'hardline_city',
    name: 'Hardline City',
    description: 'District maintains order through strict enforcement systems. '
        'Stability is high but achieved at the cost of popular morale. '
        'Efficiency gains mask underlying discontent and brittleness.',
    initialMeterValues: {
      'stability': 0.75, // Very high stability (enforcement)
      'capacity': 0.45,
      'reserves': 0.50,
      'clarity': 0.55, // Decent clarity (monitoring systems)
      'morale': 0.25, // Very low morale (low trust)
      'efficiency': 0.65, // High efficiency (enforcement)
    },
    initialResources: {
      'budget': 110, // Higher budget from efficiency
      'influence': 30, // Lower influence due to unpopularity
    },
    unlockedActions: null,
    modifiers: ScenarioModifiers(
      decayRateMultiplier: 0.9, // Slower decay due to enforcement
      eventProbabilityMultiplier: 1.2, // More events due to tension
      thresholdAdjustments: {
        'morale': 0.05, // Morale events trigger earlier
      },
    ),
    recommendedDifficulty: 3,
    beginnerFriendly: false,
  );

  /// 4. Boomtown - High productivity, high strain
  static const Scenario boomtown = Scenario(
    id: 'boomtown',
    name: 'Boomtown',
    description: 'Rapid expansion has brought high efficiency and workforce capacity. '
        'However, infrastructure is strained and systems are overloaded. '
        'Growth outpaces coordination capability, creating cascading pressure.',
    initialMeterValues: {
      'stability': 0.40, // Low stability (rapid change)
      'capacity': 0.75, // Very high capacity (migration/expansion)
      'reserves': 0.35, // Lower reserves (invested in growth)
      'clarity': 0.40, // Low clarity (too fast to track)
      'morale': 0.60, // Good morale (opportunity)
      'efficiency': 0.70, // High efficiency (productivity boom)
    },
    initialResources: {
      'budget': 130, // High budget from productivity
      'influence': 55,
    },
    unlockedActions: null,
    modifiers: ScenarioModifiers(
      decayRateMultiplier: 1.4, // Much faster decay (unsustainable)
      eventProbabilityMultiplier: 1.3, // More events (volatility)
      actionCostMultiplier: 1.2, // Actions cost more (strained systems)
    ),
    recommendedDifficulty: 3,
    beginnerFriendly: false,
  );

  /// 5. Corrupt Machine - Low transparency, high short-term resources
  static const Scenario corruptMachine = Scenario(
    id: 'corrupt_machine',
    name: 'Corrupt Machine',
    description: 'Opaque systems obscure true district conditions. '
        'Emergency reserves appear ample, but efficiency is compromised by waste. '
        'Information is unreliable, and true state of affairs is uncertain.',
    initialMeterValues: {
      'stability': 0.55, // Moderate stability
      'capacity': 0.45,
      'reserves': 0.70, // High reserves (hoarded/misallocated)
      'clarity': 0.20, // Very low clarity (corruption/opacity)
      'morale': 0.40, // Below average (distrust)
      'efficiency': 0.30, // Very low efficiency (waste)
    },
    initialResources: {
      'budget': 140, // High budget (from unclear sources)
      'influence': 40, // Low influence (distrust)
    },
    unlockedActions: null,
    modifiers: ScenarioModifiers(
      noiseMagnitudeMultiplier: 2.0, // Much higher noise (misinformation)
      eventProbabilityMultiplier: 0.9, // Slightly fewer events (hidden)
      actionCostMultiplier: 1.3, // Higher costs (inefficiency)
      thresholdAdjustments: {
        'clarity': 0.10, // Clarity events trigger later (already low)
      },
    ),
    recommendedDifficulty: 3,
    beginnerFriendly: false,
  );

  /// 6. Blind Administrator - Low clarity, high volatility
  static const Scenario blindAdministrator = Scenario(
    id: 'blind_admin',
    name: 'Blind Administrator',
    description: 'Monitoring systems have degraded, leaving situational awareness minimal. '
        'Meters fluctuate unpredictably with limited visibility into true conditions. '
        'Every decision is made in fog, with delayed and unreliable feedback.',
    initialMeterValues: {
      'stability': 0.45, // Below average, varying
      'capacity': 0.55,
      'reserves': 0.40,
      'clarity': 0.15, // Extremely low clarity (blind spots active)
      'morale': 0.50,
      'efficiency': 0.35, // Low efficiency (can't see to optimize)
    },
    initialResources: {
      'budget': 90,
      'influence': 45,
    },
    unlockedActions: null,
    modifiers: ScenarioModifiers(
      noiseMagnitudeMultiplier: 1.8, // Very high noise
      decayRateMultiplier: 1.2, // Faster decay (can't intervene in time)
      eventProbabilityMultiplier: 1.1,
      thresholdAdjustments: {
        'clarity': 0.15, // Clarity already so low, adjust threshold
      },
    ),
    recommendedDifficulty: 3,
    beginnerFriendly: false,
  );

  // ========== ADDITIONAL SCENARIOS (Bonus) ==========

  /// Tutorial - Very forgiving, limited actions to teach basics
  static const Scenario tutorial = Scenario(
    id: 'tutorial',
    name: 'Tutorial District',
    description: 'Simplified scenario for learning basic mechanics. '
        'Limited actions available, slower decay, clearer feedback. '
        'Ideal for first-time administrators.',
    initialMeterValues: {
      'stability': 0.60,
      'capacity': 0.60,
      'reserves': 0.60,
      'clarity': 0.70, // Higher clarity for learning
      'morale': 0.60,
      'efficiency': 0.60,
    },
    initialResources: {
      'budget': 150, // Extra resources for learning
      'influence': 70,
    },
    unlockedActions: [
      // Only basic actions unlocked
      'stabilize',
      'allocate_reserves',
      'improve_clarity',
      'boost_morale',
    ],
    modifiers: ScenarioModifiers(
      decayRateMultiplier: 0.6, // Much slower decay
      eventProbabilityMultiplier: 0.5, // Fewer events
      noiseMagnitudeMultiplier: 0.5, // Less noise
    ),
    recommendedDifficulty: 1,
    beginnerFriendly: true,
  );

  /// Crisis Point - All meters critical, test emergency response
  static const Scenario crisisPoint = Scenario(
    id: 'crisis_point',
    name: 'Crisis Point',
    description: 'District on the brink of collapse. '
        'Multiple systems failing simultaneously. '
        'Only for experienced administrators testing emergency protocols.',
    initialMeterValues: {
      'stability': 0.28, // Just above collapse
      'capacity': 0.32,
      'reserves': 0.22,
      'clarity': 0.38,
      'morale': 0.30,
      'efficiency': 0.35,
    },
    initialResources: {
      'budget': 60, // Low resources
      'influence': 30,
    },
    unlockedActions: null,
    modifiers: ScenarioModifiers(
      decayRateMultiplier: 1.5, // Accelerated decay
      eventProbabilityMultiplier: 1.6, // More frequent events
    ),
    recommendedDifficulty: 3,
    beginnerFriendly: false,
  );

  // ========== CATALOG MANAGEMENT ==========

  /// All available scenarios
  static const List<Scenario> allScenarios = [
    baseline,
    fragileStability,
    hardlineCity,
    boomtown,
    corruptMachine,
    blindAdministrator,
    tutorial,
    crisisPoint,
  ];

  /// Get core scenarios only (6 main scenarios)
  static const List<Scenario> coreScenarios = [
    baseline,
    fragileStability,
    hardlineCity,
    boomtown,
    corruptMachine,
    blindAdministrator,
  ];

  /// Get beginner-friendly scenarios
  static List<Scenario> get beginnerScenarios =>
      allScenarios.where((s) => s.beginnerFriendly).toList();

  /// Get scenario by ID
  static Scenario? getScenarioById(String id) {
    try {
      return allScenarios.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get scenarios by difficulty level
  static List<Scenario> getScenariosByDifficulty(int difficulty) {
    return allScenarios.where((s) => s.recommendedDifficulty == difficulty).toList();
  }
}
