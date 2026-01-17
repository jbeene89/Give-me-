import '../models/optimization_statement.dart';
import '../models/evidence.dart';
import 'meter_analyzer.dart';

/// Analyzes patterns to generate optimization statements
class OptimizationAnalyzer {
  /// Minimum difference between meters to call it a tradeoff
  static const double tradeoffThreshold = 0.20;

  /// Minimum average to consider meter "prioritized"
  static const double highThreshold = 0.60;

  /// Maximum average to consider meter "sacrificed"
  static const double lowThreshold = 0.40;

  /// Detect tradeoffs between meter pairs
  static List<OptimizationStatement> detectTradeoffs(
    Map<String, MeterHistory> meterHistories,
  ) {
    final statements = <OptimizationStatement>[];

    // Common tradeoff pairs
    final tradeoffPairs = [
      ['stability', 'morale'], // Control vs freedom
      ['efficiency', 'stability'], // Speed vs safety
      ['capacity', 'reserves'], // Growth vs safety
      ['clarity', 'efficiency'], // Information vs speed
      ['morale', 'efficiency'], // Satisfaction vs productivity
      ['stability', 'capacity'], // Order vs expansion
    ];

    for (final pair in tradeoffPairs) {
      final meter1 = meterHistories[pair[0]];
      final meter2 = meterHistories[pair[1]];

      if (meter1 == null || meter2 == null) continue;

      final diff = meter1.average - meter2.average;

      if (diff.abs() >= tradeoffThreshold) {
        final prioritized = diff > 0 ? pair[0] : pair[1];
        final sacrificed = diff > 0 ? pair[1] : pair[0];
        final prioritizedHistory = diff > 0 ? meter1 : meter2;
        final sacrificedHistory = diff > 0 ? meter2 : meter1;

        // Only if prioritized is high enough and sacrificed is low enough
        if (prioritizedHistory.average >= highThreshold &&
            sacrificedHistory.average <= lowThreshold) {
          final confidence = (diff.abs() - tradeoffThreshold) /
              (1.0 - tradeoffThreshold);

          final evidence = <Evidence>[
            Evidence(
              type: EvidenceType.meterLevel,
              observation: '$prioritized maintained high',
              value: prioritizedHistory.average,
              threshold: highThreshold,
            ),
            Evidence(
              type: EvidenceType.meterLevel,
              observation: '$sacrificed remained low',
              value: sacrificedHistory.average,
              threshold: lowThreshold,
            ),
            Evidence(
              type: EvidenceType.comparativePriority,
              observation: 'Gap: ${diff.toStringAsFixed(2)}',
              value: diff.abs(),
              threshold: tradeoffThreshold,
            ),
          ];

          final template = StatementTemplates.getTemplate(true, confidence);
          final statement = template.generate(prioritized, sacrificed, confidence);

          statements.add(OptimizationStatement(
            id: '${template.idPrefix}_${prioritized}_${sacrificed}',
            statement: statement,
            prioritized: prioritized,
            sacrificed: sacrificed,
            evidence: evidence,
            confidence: confidence.clamp(0.0, 1.0),
          ));
        }
      }
    }

    return statements;
  }

  /// Detect single focus areas (high emphasis without clear tradeoff)
  static List<OptimizationStatement> detectFocusAreas(
    Map<String, MeterHistory> meterHistories,
  ) {
    final statements = <OptimizationStatement>[];

    for (final entry in meterHistories.entries) {
      final meterId = entry.key;
      final history = entry.value;

      // Highly prioritized
      if (history.average >= 0.70) {
        final confidence = (history.average - 0.70) / 0.30;

        final evidence = <Evidence>[
          Evidence(
            type: EvidenceType.meterLevel,
            observation: '$meterId maintained very high',
            value: history.average,
            threshold: 0.70,
          ),
        ];

        if (history.volatility < 0.03) {
          evidence.add(Evidence(
            type: EvidenceType.meterTrend,
            observation: '$meterId kept stable',
            value: history.volatility,
            threshold: 0.03,
          ));
        }

        final template = StatementTemplates.getTemplate(false, confidence);
        final statement = template.generate(meterId, null, confidence);

        statements.add(OptimizationStatement(
          id: '${template.idPrefix}_$meterId',
          statement: statement,
          prioritized: meterId,
          evidence: evidence,
          confidence: confidence.clamp(0.0, 1.0),
        ));
      }

      // Neglected
      else if (history.average <= 0.30) {
        final confidence = (0.30 - history.average) / 0.30;

        final evidence = <Evidence>[
          Evidence(
            type: EvidenceType.meterLevel,
            observation: '$meterId remained low',
            value: history.average,
            threshold: 0.30,
          ),
        ];

        statements.add(OptimizationStatement(
          id: 'focus_neglected_$meterId',
          statement: 'You deprioritized $meterId',
          prioritized: meterId,
          evidence: evidence,
          confidence: confidence.clamp(0.0, 1.0),
        ));
      }
    }

    return statements;
  }

  /// Detect trend-based optimizations (improving/declining focus)
  static List<OptimizationStatement> detectTrendPatterns(
    Map<String, MeterHistory> meterHistories,
  ) {
    final statements = <OptimizationStatement>[];

    for (final entry in meterHistories.entries) {
      final meterId = entry.key;
      final history = entry.value;

      // Strong rising trend
      if (history.trend > 0.05 && history.finalValue > 0.6) {
        final evidence = <Evidence>[
          Evidence(
            type: EvidenceType.meterTrend,
            observation: '$meterId steadily increased',
            value: history.trend,
            threshold: 0.05,
            timeframe: 'entire run',
          ),
          Evidence(
            type: EvidenceType.meterLevel,
            observation: 'Final $meterId: ${(history.finalValue * 100).toStringAsFixed(0)}%',
            value: history.finalValue,
          ),
        ];

        statements.add(OptimizationStatement(
          id: 'trend_building_$meterId',
          statement: 'You built up $meterId over time',
          prioritized: meterId,
          evidence: evidence,
          confidence: (history.trend * 10).clamp(0.0, 1.0),
        ));
      }
    }

    return statements;
  }

  /// Select best statements (limit to 3-5)
  static List<OptimizationStatement> selectBestStatements(
    List<OptimizationStatement> allStatements,
    {int min = 3, int max = 5},
  ) {
    if (allStatements.isEmpty) return [];

    // Sort by confidence
    final sorted = List<OptimizationStatement>.from(allStatements)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    // Take top N, ensuring variety
    final selected = <OptimizationStatement>[];
    final usedPriorities = <String>{};

    for (final statement in sorted) {
      // Avoid duplicate priorities
      if (usedPriorities.contains(statement.prioritized)) {
        continue;
      }

      selected.add(statement);
      usedPriorities.add(statement.prioritized);

      if (selected.length >= max) break;
    }

    // If we don't have enough, add more allowing duplicates
    if (selected.length < min) {
      for (final statement in sorted) {
        if (!selected.contains(statement)) {
          selected.add(statement);
          if (selected.length >= min) break;
        }
      }
    }

    return selected;
  }
}
