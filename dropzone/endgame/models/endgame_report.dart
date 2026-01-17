import 'optimization_statement.dart';
import 'archetype.dart';

/// Complete endgame analysis report
class EndgameReport {
  /// Run summary
  final RunSummary summary;

  /// Optimization statements (3-5 key patterns)
  final List<OptimizationStatement> optimizations;

  /// Behavioral archetype
  final Archetype archetype;

  /// Timestamp when report was generated
  final DateTime generatedAt;

  const EndgameReport({
    required this.summary,
    required this.optimizations,
    required this.archetype,
    required this.generatedAt,
  });

  /// Generate human-readable report
  String toReadableReport() {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('         ENDGAME ANALYSIS');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln();

    // Summary
    buffer.writeln('RUN SUMMARY');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('Turns Survived: ${summary.turnsSurvived}');
    buffer.writeln('Scenario: ${summary.scenarioName}');
    buffer.writeln('Difficulty: ${summary.difficultyName}');
    if (summary.endCondition != null) {
      buffer.writeln('Ended: ${summary.endCondition}');
    }
    buffer.writeln();

    // Optimizations
    buffer.writeln('WHAT YOU OPTIMIZED FOR');
    buffer.writeln('───────────────────────────────────────');
    for (int i = 0; i < optimizations.length; i++) {
      final opt = optimizations[i];
      buffer.writeln('${i + 1}. ${opt.statement}');

      // Show top evidence
      if (opt.evidence.isNotEmpty) {
        buffer.writeln('   Evidence:');
        for (final evidence in opt.evidence.take(2)) {
          buffer.writeln('   • $evidence');
        }
      }
      buffer.writeln();
    }

    // Archetype
    buffer.writeln('YOUR APPROACH');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('Classification: ${archetype.label}');
    buffer.writeln(archetype.description);
    buffer.writeln();

    buffer.writeln('Behavioral Dimensions:');
    archetype.dimensions.forEach((dimension, score) {
      final label = dimension.getLabelForScore(score);
      final bar = _generateBar(score);
      buffer.writeln('  $label $bar ${(score * 100).toStringAsFixed(0)}%');
    });

    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  String _generateBar(double value) {
    final filled = (value * 20).round();
    final empty = 20 - filled;
    return '[${('█' * filled)}${('░' * empty)}]';
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'optimizations': optimizations.map((o) => {
        'statement': o.statement,
        'prioritized': o.prioritized,
        'sacrificed': o.sacrificed,
        'confidence': o.confidence,
        'evidence': o.evidence.map((e) => e.toString()).toList(),
      }).toList(),
      'archetype': {
        'label': archetype.label,
        'description': archetype.description,
        'dimensions': archetype.dimensions.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
      },
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// Summary of the game run
class RunSummary {
  /// Number of turns survived
  final int turnsSurvived;

  /// Scenario name
  final String scenarioName;

  /// Difficulty name
  final String difficultyName;

  /// How the run ended (if applicable)
  final String? endCondition;

  /// Final meter values
  final Map<String, double> finalMeterValues;

  /// Total events encountered
  final int totalEvents;

  const RunSummary({
    required this.turnsSurvived,
    required this.scenarioName,
    required this.difficultyName,
    this.endCondition,
    required this.finalMeterValues,
    required this.totalEvents,
  });

  Map<String, dynamic> toJson() {
    return {
      'turnsSurvived': turnsSurvived,
      'scenarioName': scenarioName,
      'difficultyName': difficultyName,
      'endCondition': endCondition,
      'finalMeterValues': finalMeterValues,
      'totalEvents': totalEvents,
    };
  }
}
