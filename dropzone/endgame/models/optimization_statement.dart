import 'evidence.dart';

/// Statement describing what the player optimized for
/// Uses neutral, descriptive language without moral judgment
class OptimizationStatement {
  /// Unique identifier for this type of statement
  final String id;

  /// The optimization pattern in neutral language
  /// Examples:
  /// - "You prioritized stability over morale"
  /// - "You traded reserves for immediate capacity"
  /// - "You maintained clarity at the cost of efficiency"
  final String statement;

  /// What was prioritized (the gain)
  final String prioritized;

  /// What was sacrificed (the cost)
  final String? sacrificed;

  /// Evidence supporting this conclusion
  final List<Evidence> evidence;

  /// Strength of this pattern (0.0-1.0)
  /// Higher = more clear/consistent pattern
  final double confidence;

  const OptimizationStatement({
    required this.id,
    required this.statement,
    required this.prioritized,
    this.sacrificed,
    required this.evidence,
    required this.confidence,
  });

  /// Whether this represents a tradeoff (X for Y)
  bool get isTradeoff => sacrificed != null;

  /// Confidence as percentage
  int get confidencePercent => (confidence * 100).round();

  @override
  String toString() => statement;
}

/// Templates for generating statements
class StatementTemplate {
  /// ID pattern
  final String idPrefix;

  /// Statement template with {prioritized} and {sacrificed} placeholders
  final String template;

  /// Minimum confidence to use this template
  final double minConfidence;

  const StatementTemplate({
    required this.idPrefix,
    required this.template,
    this.minConfidence = 0.6,
  });

  String generate(String prioritized, String? sacrificed, double confidence) {
    if (sacrificed != null) {
      return template
          .replaceAll('{prioritized}', prioritized)
          .replaceAll('{sacrificed}', sacrificed);
    } else {
      return template.replaceAll('{prioritized}', prioritized);
    }
  }
}

/// Predefined neutral statement templates
class StatementTemplates {
  static const List<StatementTemplate> templates = [
    // Tradeoff templates
    StatementTemplate(
      idPrefix: 'tradeoff_priority',
      template: 'You prioritized {prioritized} over {sacrificed}',
      minConfidence: 0.6,
    ),
    StatementTemplate(
      idPrefix: 'tradeoff_traded',
      template: 'You traded {sacrificed} for {prioritized}',
      minConfidence: 0.65,
    ),
    StatementTemplate(
      idPrefix: 'tradeoff_maintained',
      template: 'You maintained {prioritized} at the cost of {sacrificed}',
      minConfidence: 0.7,
    ),
    StatementTemplate(
      idPrefix: 'tradeoff_sacrificed',
      template: 'You sacrificed {sacrificed} to preserve {prioritized}',
      minConfidence: 0.75,
    ),

    // Single priority templates
    StatementTemplate(
      idPrefix: 'focus_emphasized',
      template: 'You emphasized {prioritized} throughout',
      minConfidence: 0.65,
    ),
    StatementTemplate(
      idPrefix: 'focus_invested',
      template: 'You invested heavily in {prioritized}',
      minConfidence: 0.7,
    ),
    StatementTemplate(
      idPrefix: 'focus_neglected',
      template: 'You deprioritized {prioritized}',
      minConfidence: 0.6,
    ),
  ];

  /// Get appropriate template based on confidence and context
  static StatementTemplate getTemplate(bool isTradeoff, double confidence) {
    final eligible = templates
        .where((t) =>
            (isTradeoff ? t.idPrefix.startsWith('tradeoff_') : !t.idPrefix.startsWith('tradeoff_')) &&
            confidence >= t.minConfidence)
        .toList();

    if (eligible.isEmpty) {
      return templates.first;
    }

    // Return highest confidence threshold that's met
    eligible.sort((a, b) => b.minConfidence.compareTo(a.minConfidence));
    return eligible.first;
  }
}
