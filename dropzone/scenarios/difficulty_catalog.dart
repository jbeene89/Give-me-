import 'models/difficulty_profile.dart';

/// Catalog of all difficulty profiles
class DifficultyCatalog {
  // ========== DIFFICULTY PROFILES (3 required) ==========

  /// 1. Forgiving - Easier difficulty for learning and testing
  static const DifficultyProfile forgiving = DifficultyProfile(
    id: 'forgiving',
    name: 'Forgiving',
    description: 'Slower decay rates, less intense events, clearer information. '
        'Recommended for first playthroughs and scenario testing.',
    decayRateMultiplier: 0.7, // 30% slower decay
    eventIntensityMultiplier: 0.7, // 30% less intense events
    noiseMagnitudeMultiplier: 0.6, // 40% less noise
    collapseThresholdMultiplier: 1.1, // 10% more forgiving thresholds
    resourceAdjustments: {
      'budget': 30, // +30 budget
      'influence': 10, // +10 influence
    },
    startingTurn: 0,
  );

  /// 2. Standard - Balanced difficulty for normal play
  static const DifficultyProfile standard = DifficultyProfile(
    id: 'standard',
    name: 'Standard',
    description: 'Default difficulty with balanced parameters. '
        'Systems decay at normal rates, events occur as designed. '
        'Intended baseline experience.',
    decayRateMultiplier: 1.0, // Normal decay
    eventIntensityMultiplier: 1.0, // Normal events
    noiseMagnitudeMultiplier: 1.0, // Normal noise
    collapseThresholdMultiplier: 1.0, // Normal thresholds
    resourceAdjustments: {}, // No adjustments
    startingTurn: 0,
  );

  /// 3. Unforgiving - Harder difficulty for experienced players
  static const DifficultyProfile unforgiving = DifficultyProfile(
    id: 'unforgiving',
    name: 'Unforgiving',
    description: 'Accelerated decay, more intense events, unreliable information. '
        'Collapse thresholds are tighter, margins for error minimal. '
        'For experienced administrators only.',
    decayRateMultiplier: 1.4, // 40% faster decay
    eventIntensityMultiplier: 1.5, // 50% more intense events
    noiseMagnitudeMultiplier: 1.4, // 40% more noise
    collapseThresholdMultiplier: 0.9, // 10% stricter thresholds (easier to trigger)
    resourceAdjustments: {
      'budget': -20, // -20 budget
      'influence': -10, // -10 influence
    },
    startingTurn: 0,
  );

  // ========== ADDITIONAL DIFFICULTY PROFILES (Bonus) ==========

  /// Brutal - Extreme difficulty for masochists and testing worst-case
  static const DifficultyProfile brutal = DifficultyProfile(
    id: 'brutal',
    name: 'Brutal',
    description: 'Extreme difficulty with punishing parameters. '
        'Everything decays rapidly, events cascade relentlessly. '
        'Survival beyond 20 turns is exceptional.',
    decayRateMultiplier: 1.8, // 80% faster decay
    eventIntensityMultiplier: 2.0, // 100% more intense events
    noiseMagnitudeMultiplier: 1.8, // 80% more noise
    collapseThresholdMultiplier: 0.8, // 20% stricter thresholds
    resourceAdjustments: {
      'budget': -40,
      'influence': -20,
    },
    startingTurn: 0,
  );

  /// Sandbox - Extremely easy for experimentation
  static const DifficultyProfile sandbox = DifficultyProfile(
    id: 'sandbox',
    name: 'Sandbox',
    description: 'Minimal pressure for experimentation and testing. '
        'Very slow decay, rare events, clear information. '
        'Useful for learning mechanics without time pressure.',
    decayRateMultiplier: 0.3, // 70% slower decay
    eventIntensityMultiplier: 0.3, // 70% less intense events
    noiseMagnitudeMultiplier: 0.3, // 70% less noise
    collapseThresholdMultiplier: 1.3, // 30% more forgiving thresholds
    resourceAdjustments: {
      'budget': 100,
      'influence': 50,
    },
    startingTurn: 0,
  );

  /// Time-Lapse - Start at turn 20 with accumulated state
  static const DifficultyProfile timeLapse = DifficultyProfile(
    id: 'time_lapse',
    name: 'Time-Lapse',
    description: 'Begin at turn 20 with systems already degraded. '
        'Test late-game scenarios and recovery strategies. '
        'Standard difficulty, advanced starting point.',
    decayRateMultiplier: 1.0,
    eventIntensityMultiplier: 1.0,
    noiseMagnitudeMultiplier: 1.0,
    collapseThresholdMultiplier: 1.0,
    resourceAdjustments: {},
    startingTurn: 20, // Start at turn 20
  );

  // ========== CATALOG MANAGEMENT ==========

  /// All available difficulty profiles
  static const List<DifficultyProfile> allProfiles = [
    forgiving,
    standard,
    unforgiving,
    brutal,
    sandbox,
    timeLapse,
  ];

  /// Core difficulty profiles (3 main ones)
  static const List<DifficultyProfile> coreProfiles = [
    forgiving,
    standard,
    unforgiving,
  ];

  /// Get difficulty profile by ID
  static DifficultyProfile? getProfileById(String id) {
    try {
      return allProfiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get default profile
  static DifficultyProfile get defaultProfile => standard;
}
