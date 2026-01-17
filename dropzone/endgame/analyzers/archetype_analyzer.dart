import '../models/archetype.dart';
import '../models/evidence.dart';
import 'meter_analyzer.dart';

/// Analyzes player behavior to determine archetype
class ArchetypeAnalyzer {
  /// Calculate proactivity score (reactive vs proactive)
  /// Based on: reserves, stability trends, event response
  static double calculateProactivity(
    MeterHistory reserves,
    MeterHistory stability,
    int eventsTriggered,
    int turnsSurvived,
  ) {
    double score = 0.5; // Start neutral

    // High reserves = more proactive (prepared)
    if (reserves.average > 0.5) {
      score += 0.15;
    } else if (reserves.average < 0.3) {
      score -= 0.15;
    }

    // Stable or rising stability = proactive
    if (stability.trend > 0) {
      score += 0.10;
    } else if (stability.trend < -0.02) {
      score -= 0.10;
    }

    // Fewer crises per turn = more proactive
    final eventsPerTurn = eventsTriggered / turnsSurvived;
    if (eventsPerTurn < 0.3) {
      score += 0.15;
    } else if (eventsPerTurn > 0.6) {
      score -= 0.15;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculate control score (permissive vs authoritarian)
  /// Based on: stability vs morale tradeoff
  static double calculateControl(
    MeterHistory stability,
    MeterHistory morale,
  ) {
    double score = 0.5;

    // High stability, low morale = authoritarian
    if (stability.average > 0.6 && morale.average < 0.4) {
      score += 0.3;
    }

    // Low stability, high morale = permissive
    if (stability.average < 0.4 && morale.average > 0.6) {
      score -= 0.3;
    }

    // Just high stability = somewhat authoritarian
    if (stability.average > 0.65) {
      score += 0.15;
    }

    // Just high morale = somewhat permissive
    if (morale.average > 0.65) {
      score -= 0.15;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculate risk tolerance (risk-averse vs risk-tolerant)
  /// Based on: reserves level
  static double calculateRiskTolerance(
    MeterHistory reserves,
    MeterHistory capacity,
  ) {
    double score = 0.5;

    // Low reserves = high risk tolerance
    if (reserves.average < 0.3) {
      score += 0.3;
    } else if (reserves.average > 0.6) {
      score -= 0.3;
    }

    // High capacity with low reserves = aggressive
    if (capacity.average > 0.6 && reserves.average < 0.4) {
      score += 0.15;
    }

    // Volatile reserves = risk tolerant
    if (reserves.volatility > 0.05) {
      score += 0.10;
    } else if (reserves.volatility < 0.02) {
      score -= 0.10;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculate information seeking (intuition vs data-driven)
  /// Based on: clarity level
  static double calculateInformationSeeking(
    MeterHistory clarity,
  ) {
    double score = 0.5;

    // High clarity = information-driven
    if (clarity.average > 0.65) {
      score += 0.3;
    } else if (clarity.average < 0.35) {
      score -= 0.3;
    }

    // Rising clarity = increasingly information-driven
    if (clarity.trend > 0.02) {
      score += 0.15;
    }

    // Stable high clarity = very information-driven
    if (clarity.average > 0.6 && clarity.volatility < 0.03) {
      score += 0.15;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculate stability focus (efficiency vs stability)
  /// Based on: stability vs efficiency tradeoff
  static double calculateStabilityFocus(
    MeterHistory stability,
    MeterHistory efficiency,
  ) {
    double score = 0.5;

    // High stability, low efficiency = stability-focused
    if (stability.average > 0.6 && efficiency.average < 0.4) {
      score += 0.3;
    }

    // Low stability, high efficiency = efficiency-focused
    if (stability.average < 0.4 && efficiency.average > 0.6) {
      score -= 0.3;
    }

    // Just high stability = somewhat stability-focused
    if (stability.average > 0.65) {
      score += 0.15;
    }

    // Just high efficiency = somewhat efficiency-focused
    if (efficiency.average > 0.65) {
      score -= 0.15;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculate aggression (conservative vs aggressive)
  /// Based on: capacity, growth patterns
  static double calculateAggression(
    MeterHistory capacity,
    MeterHistory stability,
  ) {
    double score = 0.5;

    // High capacity = aggressive expansion
    if (capacity.average > 0.65) {
      score += 0.25;
    } else if (capacity.average < 0.40) {
      score -= 0.25;
    }

    // Rising capacity despite instability = aggressive
    if (capacity.trend > 0.02 && stability.average < 0.5) {
      score += 0.20;
    }

    // Falling capacity = conservative
    if (capacity.trend < -0.02) {
      score -= 0.15;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Generate evidence for proactivity dimension
  static List<Evidence> generateProactivityEvidence(
    MeterHistory reserves,
    MeterHistory stability,
    int eventsTriggered,
    int turnsSurvived,
  ) {
    final evidence = <Evidence>[];

    if (reserves.average > 0.5) {
      evidence.add(Evidence(
        type: EvidenceType.meterLevel,
        observation: 'Maintained high reserves',
        value: reserves.average,
        threshold: 0.5,
      ));
    }

    final eventsPerTurn = eventsTriggered / turnsSurvived;
    if (eventsPerTurn < 0.3) {
      evidence.add(Evidence(
        type: EvidenceType.eventResponse,
        observation: 'Low crisis rate',
        value: eventsPerTurn,
        threshold: 0.3,
      ));
    } else if (eventsPerTurn > 0.6) {
      evidence.add(Evidence(
        type: EvidenceType.eventResponse,
        observation: 'High crisis rate',
        value: eventsPerTurn,
        threshold: 0.6,
      ));
    }

    return evidence;
  }

  /// Generate evidence for control dimension
  static List<Evidence> generateControlEvidence(
    MeterHistory stability,
    MeterHistory morale,
  ) {
    final evidence = <Evidence>[];

    if (stability.average > 0.6 && morale.average < 0.4) {
      evidence.add(Evidence(
        type: EvidenceType.comparativePriority,
        observation: 'High stability, low morale',
        value: stability.average - morale.average,
      ));
    } else if (morale.average > 0.6 && stability.average < 0.4) {
      evidence.add(Evidence(
        type: EvidenceType.comparativePriority,
        observation: 'High morale, low stability',
        value: morale.average - stability.average,
      ));
    }

    return evidence;
  }

  /// Generate evidence for risk tolerance dimension
  static List<Evidence> generateRiskToleranceEvidence(
    MeterHistory reserves,
  ) {
    final evidence = <Evidence>[];

    if (reserves.average < 0.3) {
      evidence.add(Evidence(
        type: EvidenceType.meterLevel,
        observation: 'Operated with low reserves',
        value: reserves.average,
        threshold: 0.3,
      ));
    } else if (reserves.average > 0.6) {
      evidence.add(Evidence(
        type: EvidenceType.meterLevel,
        observation: 'Maintained high reserve buffer',
        value: reserves.average,
        threshold: 0.6,
      ));
    }

    return evidence;
  }

  /// Generate evidence for information seeking dimension
  static List<Evidence> generateInformationSeekingEvidence(
    MeterHistory clarity,
  ) {
    final evidence = <Evidence>[];

    if (clarity.average > 0.65) {
      evidence.add(Evidence(
        type: EvidenceType.meterLevel,
        observation: 'Maintained high clarity',
        value: clarity.average,
        threshold: 0.65,
      ));
    } else if (clarity.average < 0.35) {
      evidence.add(Evidence(
        type: EvidenceType.meterLevel,
        observation: 'Operated with low clarity',
        value: clarity.average,
        threshold: 0.35,
      ));
    }

    return evidence;
  }
}
