/// Example usage of Endgame Analysis
/// Demonstrates report generation and display

import 'endgame_exports.dart';

void main() {
  print('=== Endgame Analysis Examples ===\n');

  exampleBasicReport();
  print('\n---\n');

  exampleAuthoritarianPlay();
  print('\n---\n');

  exampleRiskyPlay();
  print('\n---\n');

  exampleBalancedPlay();
  print('\n---\n');

  exampleOptimizationDetection();
}

/// Example 1: Basic report generation
void exampleBasicReport() {
  print('Example 1: Basic Report Generation\n');

  // Simulate 30 turns of meter data
  final meterHistory = <String, List<double>>{
    'stability': List.generate(30, (i) => 0.6 + (i * 0.005)),
    'capacity': List.generate(30, (i) => 0.5),
    'reserves': List.generate(30, (i) => 0.4 - (i * 0.002)),
    'clarity': List.generate(30, (i) => 0.7),
    'morale': List.generate(30, (i) => 0.35),
    'efficiency': List.generate(30, (i) => 0.5),
  };

  final report = AnalysisEngine.generateReport(
    turnsSurvived: 30,
    scenarioName: 'Baseline',
    difficultyName: 'Standard',
    meterHistory: meterHistory,
    finalMeterValues: {
      'stability': 0.75,
      'capacity': 0.50,
      'reserves': 0.34,
      'clarity': 0.70,
      'morale': 0.35,
      'efficiency': 0.50,
    },
    totalEvents: 8,
  );

  print(report.toReadableReport());
}

/// Example 2: Authoritarian playstyle
void exampleAuthoritarianPlay() {
  print('Example 2: Authoritarian Playstyle\n');

  // High stability, low morale throughout
  final meterHistory = <String, List<double>>{
    'stability': List.generate(40, (_) => 0.75),
    'capacity': List.generate(40, (_) => 0.50),
    'reserves': List.generate(40, (_) => 0.55),
    'clarity': List.generate(40, (_) => 0.70),
    'morale': List.generate(40, (_) => 0.30),
    'efficiency': List.generate(40, (_) => 0.60),
  };

  final report = AnalysisEngine.generateReport(
    turnsSurvived: 40,
    scenarioName: 'Hardline City',
    difficultyName: 'Standard',
    meterHistory: meterHistory,
    finalMeterValues: meterHistory.map((k, v) => MapEntry(k, v.last)),
    totalEvents: 5,
  );

  print('Archetype: ${report.archetype.label}');
  print('Description: ${report.archetype.description}\n');

  print('Key Optimization:');
  if (report.optimizations.isNotEmpty) {
    final opt = report.optimizations.first;
    print('  ${opt.statement}');
    print('  Confidence: ${opt.confidencePercent}%');
    print('  Evidence:');
    for (final evidence in opt.evidence) {
      print('    • $evidence');
    }
  }

  final controlScore = report.archetype.getScore(ArchetypeDimension.control);
  print('\nControl dimension: ${(controlScore * 100).toStringAsFixed(0)}% (Authoritarian)');
}

/// Example 3: Risk-tolerant playstyle
void exampleRiskyPlay() {
  print('Example 3: Risk-Tolerant Playstyle\n');

  // Low reserves, high capacity (aggressive growth)
  final meterHistory = <String, List<double>>{
    'stability': List.generate(25, (i) => 0.45 - (i * 0.005)),
    'capacity': List.generate(25, (i) => 0.55 + (i * 0.01)),
    'reserves': List.generate(25, (_) => 0.25),
    'clarity': List.generate(25, (_) => 0.50),
    'morale': List.generate(25, (_) => 0.55),
    'efficiency': List.generate(25, (_) => 0.65),
  };

  final report = AnalysisEngine.generateReport(
    turnsSurvived: 25,
    scenarioName: 'Boomtown',
    difficultyName: 'Unforgiving',
    meterHistory: meterHistory,
    finalMeterValues: {
      'stability': 0.32,
      'capacity': 0.80,
      'reserves': 0.25,
      'clarity': 0.50,
      'morale': 0.55,
      'efficiency': 0.65,
    },
    endCondition: 'Stability collapse',
    totalEvents: 15,
  );

  print('Run ended: ${report.summary.endCondition}');
  print('Turns survived: ${report.summary.turnsSurvived}\n');

  print('Archetype: ${report.archetype.label}\n');

  final riskScore = report.archetype.getScore(ArchetypeDimension.riskTolerance);
  print('Risk Tolerance: ${(riskScore * 100).toStringAsFixed(0)}%');

  final aggressionScore = report.archetype.getScore(ArchetypeDimension.aggression);
  print('Aggression: ${(aggressionScore * 100).toStringAsFixed(0)}%\n');

  print('Optimizations detected:');
  for (int i = 0; i < report.optimizations.length; i++) {
    print('${i + 1}. ${report.optimizations[i].statement}');
  }
}

/// Example 4: Balanced playstyle
void exampleBalancedPlay() {
  print('Example 4: Balanced Playstyle\n');

  // All meters around 0.5
  final meterHistory = <String, List<double>>{
    'stability': List.generate(50, (_) => 0.50),
    'capacity': List.generate(50, (_) => 0.52),
    'reserves': List.generate(50, (_) => 0.48),
    'clarity': List.generate(50, (_) => 0.51),
    'morale': List.generate(50, (_) => 0.49),
    'efficiency': List.generate(50, (_) => 0.50),
  };

  final report = AnalysisEngine.generateReport(
    turnsSurvived: 50,
    scenarioName: 'Baseline',
    difficultyName: 'Standard',
    meterHistory: meterHistory,
    finalMeterValues: meterHistory.map((k, v) => MapEntry(k, v.last)),
    totalEvents: 12,
  );

  print('Archetype: ${report.archetype.label}');
  print('All dimensions balanced:\n');

  report.archetype.dimensions.forEach((dimension, score) {
    final label = dimension.getLabelForScore(score);
    print('  $label: ${(score * 100).toStringAsFixed(0)}%');
  });

  print('\nOptimizations: ${report.optimizations.length}');
  print('(Balanced play may have fewer clear optimizations)');
}

/// Example 5: Optimization detection thresholds
void exampleOptimizationDetection() {
  print('Example 5: Optimization Detection\n');

  // Demonstrate tradeoff detection
  print('TRADEOFF DETECTION:');
  print('Requires:');
  print('  • Gap >= 0.20 between meters');
  print('  • Prioritized >= 0.60');
  print('  • Sacrificed <= 0.40\n');

  // Create data with clear tradeoff
  final meterHistory1 = <String, List<double>>{
    'stability': List.generate(20, (_) => 0.75), // High
    'capacity': List.generate(20, (_) => 0.50),
    'reserves': List.generate(20, (_) => 0.50),
    'clarity': List.generate(20, (_) => 0.50),
    'morale': List.generate(20, (_) => 0.30), // Low
    'efficiency': List.generate(20, (_) => 0.50),
  };

  final report1 = AnalysisEngine.generateReport(
    turnsSurvived: 20,
    scenarioName: 'Test',
    difficultyName: 'Test',
    meterHistory: meterHistory1,
    finalMeterValues: meterHistory1.map((k, v) => MapEntry(k, v.last)),
  );

  print('Test 1: stability=0.75, morale=0.30 (gap=0.45)');
  final tradeoffs1 = report1.optimizations.where((o) => o.isTradeoff).toList();
  if (tradeoffs1.isNotEmpty) {
    print('  ✓ Tradeoff detected: ${tradeoffs1.first.statement}');
    print('    Confidence: ${tradeoffs1.first.confidencePercent}%');
  } else {
    print('  ✗ No tradeoff detected');
  }

  print('');

  // Create data below threshold
  final meterHistory2 = <String, List<double>>{
    'stability': List.generate(20, (_) => 0.55), // Not high enough
    'capacity': List.generate(20, (_) => 0.50),
    'reserves': List.generate(20, (_) => 0.50),
    'clarity': List.generate(20, (_) => 0.50),
    'morale': List.generate(20, (_) => 0.40), // Not low enough
    'efficiency': List.generate(20, (_) => 0.50),
  };

  final report2 = AnalysisEngine.generateReport(
    turnsSurvived: 20,
    scenarioName: 'Test',
    difficultyName: 'Test',
    meterHistory: meterHistory2,
    finalMeterValues: meterHistory2.map((k, v) => MapEntry(k, v.last)),
  );

  print('Test 2: stability=0.55, morale=0.40 (gap=0.15, both in neutral zone)');
  final tradeoffs2 = report2.optimizations.where((o) => o.isTradeoff).toList();
  if (tradeoffs2.isNotEmpty) {
    print('  ✓ Tradeoff detected: ${tradeoffs2.first.statement}');
  } else {
    print('  ✗ No tradeoff detected (gap < 0.20 or values not extreme enough)');
  }
}

/// Example 6: Using the report programmatically
void exampleProgrammaticUsage() {
  print('Example 6: Programmatic Usage\n');

  final report = _generateSampleReport();

  // Access summary data
  print('Turns: ${report.summary.turnsSurvived}');
  print('Events: ${report.summary.totalEvents}');

  // Check for specific optimization
  final hasStabilityFocus = report.optimizations
      .any((o) => o.prioritized == 'stability');
  print('Prioritized stability: $hasStabilityFocus');

  // Get archetype dimensions
  final proactivity = report.archetype.getScore(ArchetypeDimension.proactivity);
  print('Proactivity score: ${proactivity.toStringAsFixed(2)}');

  // Get dominant traits
  final dominant = report.archetype.getDominantDimensions();
  print('Dominant dimensions: ${dominant.map((d) => d.highLabel).join(", ")}');

  // Export to JSON
  final json = report.toJson();
  print('\nJSON keys: ${json.keys.join(", ")}');
}

EndgameReport _generateSampleReport() {
  final meterHistory = <String, List<double>>{
    'stability': List.generate(30, (i) => 0.6 + (i * 0.005)),
    'capacity': List.generate(30, (_) => 0.5),
    'reserves': List.generate(30, (_) => 0.65),
    'clarity': List.generate(30, (_) => 0.7),
    'morale': List.generate(30, (_) => 0.45),
    'efficiency': List.generate(30, (_) => 0.5),
  };

  return AnalysisEngine.generateReport(
    turnsSurvived: 30,
    scenarioName: 'Test',
    difficultyName: 'Test',
    meterHistory: meterHistory,
    finalMeterValues: meterHistory.map((k, v) => MapEntry(k, v.last)),
    totalEvents: 8,
  );
}

/// Example 7: Avoiding preachy language
void exampleNeutralLanguage() {
  print('Example 7: Neutral Language\n');

  print('✓ GOOD (Descriptive, Neutral):');
  print('  • "You prioritized stability over morale"');
  print('  • "You operated with low reserves"');
  print('  • "You maintained high clarity"');
  print('  • "Reactive Authoritarian Administrator"');
  print('');

  print('✗ BAD (Preachy, Judgmental):');
  print('  • "You were too harsh on your people"');
  print('  • "You foolishly ran out of money"');
  print('  • "You obsessively tracked everything"');
  print('  • "Control Freak Dictator"');
  print('');

  print('The difference:');
  print('  • Describes BEHAVIOR, not CHARACTER');
  print('  • Shows DATA, not JUDGMENT');
  print('  • Neutral TERMS, not VALUE-LADEN');
}
