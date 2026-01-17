import 'models/endgame_report.dart';
import 'models/archetype.dart';
import 'models/optimization_statement.dart';
import 'models/evidence.dart';
import 'analyzers/meter_analyzer.dart';
import 'analyzers/archetype_analyzer.dart';
import 'analyzers/optimization_analyzer.dart';

/// Main engine for generating endgame analysis
class AnalysisEngine {
  /// Generate complete endgame report
  static EndgameReport generateReport({
    required int turnsSurvived,
    required String scenarioName,
    required String difficultyName,
    required Map<String, List<double>> meterHistory,
    required Map<String, double> finalMeterValues,
    String? endCondition,
    int totalEvents = 0,
  }) {
    // Build meter histories
    final meterHistories = <String, MeterHistory>{};
    meterHistory.forEach((meterId, values) {
      meterHistories[meterId] = MeterHistory(meterId, values);
    });

    // Generate summary
    final summary = RunSummary(
      turnsSurvived: turnsSurvived,
      scenarioName: scenarioName,
      difficultyName: difficultyName,
      endCondition: endCondition,
      finalMeterValues: finalMeterValues,
      totalEvents: totalEvents,
    );

    // Analyze optimizations
    final optimizations = _analyzeOptimizations(meterHistories);

    // Analyze archetype
    final archetype = _analyzeArchetype(meterHistories, totalEvents, turnsSurvived);

    return EndgameReport(
      summary: summary,
      optimizations: optimizations,
      archetype: archetype,
      generatedAt: DateTime.now(),
    );
  }

  /// Analyze optimization patterns
  static List<OptimizationStatement> _analyzeOptimizations(
    Map<String, MeterHistory> meterHistories,
  ) {
    final allStatements = <OptimizationStatement>[];

    // Detect tradeoffs
    allStatements.addAll(
      OptimizationAnalyzer.detectTradeoffs(meterHistories),
    );

    // Detect focus areas
    allStatements.addAll(
      OptimizationAnalyzer.detectFocusAreas(meterHistories),
    );

    // Detect trend patterns
    allStatements.addAll(
      OptimizationAnalyzer.detectTrendPatterns(meterHistories),
    );

    // Select best 3-5 statements
    return OptimizationAnalyzer.selectBestStatements(
      allStatements,
      min: 3,
      max: 5,
    );
  }

  /// Analyze behavioral archetype
  static Archetype _analyzeArchetype(
    Map<String, MeterHistory> meterHistories,
    int totalEvents,
    int turnsSurvived,
  ) {
    // Get required meter histories (with defaults if missing)
    final stability = meterHistories['stability'] ??
        MeterHistory('stability', List.filled(turnsSurvived, 0.5));
    final capacity = meterHistories['capacity'] ??
        MeterHistory('capacity', List.filled(turnsSurvived, 0.5));
    final reserves = meterHistories['reserves'] ??
        MeterHistory('reserves', List.filled(turnsSurvived, 0.5));
    final clarity = meterHistories['clarity'] ??
        MeterHistory('clarity', List.filled(turnsSurvived, 0.5));
    final morale = meterHistories['morale'] ??
        MeterHistory('morale', List.filled(turnsSurvived, 0.5));
    final efficiency = meterHistories['efficiency'] ??
        MeterHistory('efficiency', List.filled(turnsSurvived, 0.5));

    // Calculate dimension scores
    final dimensions = <ArchetypeDimension, double>{
      ArchetypeDimension.proactivity: ArchetypeAnalyzer.calculateProactivity(
        reserves,
        stability,
        totalEvents,
        turnsSurvived,
      ),
      ArchetypeDimension.control: ArchetypeAnalyzer.calculateControl(
        stability,
        morale,
      ),
      ArchetypeDimension.riskTolerance: ArchetypeAnalyzer.calculateRiskTolerance(
        reserves,
        capacity,
      ),
      ArchetypeDimension.informationSeeking:
          ArchetypeAnalyzer.calculateInformationSeeking(clarity),
      ArchetypeDimension.stabilityFocus: ArchetypeAnalyzer.calculateStabilityFocus(
        stability,
        efficiency,
      ),
      ArchetypeDimension.aggression: ArchetypeAnalyzer.calculateAggression(
        capacity,
        stability,
      ),
    };

    // Generate evidence for each dimension
    final evidence = <ArchetypeDimension, List<Evidence>>{
      ArchetypeDimension.proactivity:
          ArchetypeAnalyzer.generateProactivityEvidence(
        reserves,
        stability,
        totalEvents,
        turnsSurvived,
      ),
      ArchetypeDimension.control: ArchetypeAnalyzer.generateControlEvidence(
        stability,
        morale,
      ),
      ArchetypeDimension.riskTolerance:
          ArchetypeAnalyzer.generateRiskToleranceEvidence(reserves),
      ArchetypeDimension.informationSeeking:
          ArchetypeAnalyzer.generateInformationSeekingEvidence(clarity),
    };

    // Generate label and description
    final label = ArchetypePatterns.generateLabel(dimensions);
    final description = ArchetypePatterns.generateDescription(dimensions);

    return Archetype(
      dimensions: dimensions,
      evidence: evidence,
      label: label,
      description: description,
    );
  }

  /// Quick helper to generate report from simpler input
  static EndgameReport generateFromGameState({
    required int turnsSurvived,
    required String scenarioId,
    required String difficultyId,
    required Map<String, double> finalMeters,
    required List<Map<String, double>> turnByTurnMeters,
    String? endCondition,
    int totalEvents = 0,
  }) {
    // Convert turn-by-turn data to meter history
    final meterHistory = <String, List<double>>{};

    for (final meterId in finalMeters.keys) {
      meterHistory[meterId] = turnByTurnMeters
          .map((turnData) => turnData[meterId] ?? 0.5)
          .toList();
    }

    return generateReport(
      turnsSurvived: turnsSurvived,
      scenarioName: _formatScenarioName(scenarioId),
      difficultyName: _formatDifficultyName(difficultyId),
      meterHistory: meterHistory,
      finalMeterValues: finalMeters,
      endCondition: endCondition,
      totalEvents: totalEvents,
    );
  }

  static String _formatScenarioName(String id) {
    // Convert snake_case to Title Case
    return id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static String _formatDifficultyName(String id) {
    return _formatScenarioName(id);
  }
}
