/// Public API exports for Endgame Analysis
/// Import this file to use the endgame analysis system
library endgame;

// Main engine
export 'analysis_engine.dart' show AnalysisEngine;

// Models
export 'models/endgame_report.dart' show EndgameReport, RunSummary;
export 'models/optimization_statement.dart' show OptimizationStatement;
export 'models/archetype.dart' show Archetype, ArchetypeDimension, ArchetypeDimensionNames;
export 'models/evidence.dart' show Evidence, EvidenceType;

// Analyzers (for advanced usage)
export 'analyzers/meter_analyzer.dart' show MeterAnalyzer, MeterHistory;
export 'analyzers/archetype_analyzer.dart' show ArchetypeAnalyzer;
export 'analyzers/optimization_analyzer.dart' show OptimizationAnalyzer;
