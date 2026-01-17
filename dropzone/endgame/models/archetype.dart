import 'evidence.dart';

/// Behavioral archetype classification (NO moral judgment)
/// Describes HOW player played, not whether it was good/bad
class Archetype {
  /// Archetype dimensions (each 0.0-1.0)
  final Map<ArchetypeDimension, double> dimensions;

  /// Evidence for each dimension
  final Map<ArchetypeDimension, List<Evidence>> evidence;

  /// Archetype label based on dominant dimensions
  final String label;

  /// Description of this archetype (neutral, observational)
  final String description;

  const Archetype({
    required this.dimensions,
    required this.evidence,
    required this.label,
    required this.description,
  });

  /// Get score for a specific dimension
  double getScore(ArchetypeDimension dimension) {
    return dimensions[dimension] ?? 0.5;
  }

  /// Get dominant dimensions (score > 0.6)
  List<ArchetypeDimension> getDominantDimensions() {
    return dimensions.entries
        .where((e) => e.value > 0.6)
        .map((e) => e.key)
        .toList();
  }

  /// Get recessive dimensions (score < 0.4)
  List<ArchetypeDimension> getRecessiveDimensions() {
    return dimensions.entries
        .where((e) => e.value < 0.4)
        .map((e) => e.key)
        .toList();
  }
}

/// Behavioral dimensions (neutral descriptors)
enum ArchetypeDimension {
  /// Reactive (0.0) ←→ Proactive (1.0)
  /// Responds to crises vs prevents them
  proactivity,

  /// Permissive (0.0) ←→ Authoritarian (1.0)
  /// High morale/freedom vs high stability/control
  control,

  /// Risk-averse (0.0) ←→ Risk-tolerant (1.0)
  /// Keeps high reserves vs runs lean
  riskTolerance,

  /// Information-light (0.0) ←→ Information-driven (1.0)
  /// Low clarity acceptable vs always seeks clarity
  informationSeeking,

  /// Efficiency-focused (0.0) ←→ Stability-focused (1.0)
  /// Optimizes for efficiency vs stability
  stabilityFocus,

  /// Conservative (0.0) ←→ Aggressive (1.0)
  /// Slow growth vs rapid expansion
  aggression,
}

/// Extension for human-readable names
extension ArchetypeDimensionNames on ArchetypeDimension {
  /// Low end label (score < 0.4)
  String get lowLabel {
    switch (this) {
      case ArchetypeDimension.proactivity:
        return 'Reactive';
      case ArchetypeDimension.control:
        return 'Permissive';
      case ArchetypeDimension.riskTolerance:
        return 'Risk-Averse';
      case ArchetypeDimension.informationSeeking:
        return 'Intuition-Driven';
      case ArchetypeDimension.stabilityFocus:
        return 'Efficiency-Focused';
      case ArchetypeDimension.aggression:
        return 'Conservative';
    }
  }

  /// High end label (score > 0.6)
  String get highLabel {
    switch (this) {
      case ArchetypeDimension.proactivity:
        return 'Proactive';
      case ArchetypeDimension.control:
        return 'Authoritarian';
      case ArchetypeDimension.riskTolerance:
        return 'Risk-Tolerant';
      case ArchetypeDimension.informationSeeking:
        return 'Information-Driven';
      case ArchetypeDimension.stabilityFocus:
        return 'Stability-Focused';
      case ArchetypeDimension.aggression:
        return 'Aggressive';
    }
  }

  /// Neutral mid-range label (score 0.4-0.6)
  String get neutralLabel {
    switch (this) {
      case ArchetypeDimension.proactivity:
        return 'Balanced Response';
      case ArchetypeDimension.control:
        return 'Mixed Approach';
      case ArchetypeDimension.riskTolerance:
        return 'Moderate Risk';
      case ArchetypeDimension.informationSeeking:
        return 'Pragmatic';
      case ArchetypeDimension.stabilityFocus:
        return 'Balanced Priority';
      case ArchetypeDimension.aggression:
        return 'Moderate Pace';
    }
  }

  /// Get label for a specific score
  String getLabelForScore(double score) {
    if (score < 0.4) return lowLabel;
    if (score > 0.6) return highLabel;
    return neutralLabel;
  }
}

/// Predefined archetype patterns
class ArchetypePatterns {
  /// Generate archetype label from dominant dimensions
  static String generateLabel(Map<ArchetypeDimension, double> dimensions) {
    final dominant = dimensions.entries
        .where((e) => e.value > 0.6 || e.value < 0.4)
        .toList()
      ..sort((a, b) => (b.value - 0.5).abs().compareTo((a.value - 0.5).abs()));

    if (dominant.isEmpty) {
      return 'Balanced Administrator';
    }

    final labels = <String>[];
    for (final entry in dominant.take(2)) {
      labels.add(entry.key.getLabelForScore(entry.value));
    }

    return '${labels.join(' ')} Administrator';
  }

  /// Generate description from dimensions
  static String generateDescription(Map<ArchetypeDimension, double> dimensions) {
    final traits = <String>[];

    final proactivity = dimensions[ArchetypeDimension.proactivity] ?? 0.5;
    if (proactivity > 0.6) {
      traits.add('prevented crises before they emerged');
    } else if (proactivity < 0.4) {
      traits.add('responded to crises as they arose');
    }

    final control = dimensions[ArchetypeDimension.control] ?? 0.5;
    if (control > 0.6) {
      traits.add('maintained order through strong oversight');
    } else if (control < 0.4) {
      traits.add('allowed flexibility and autonomy');
    }

    final riskTolerance = dimensions[ArchetypeDimension.riskTolerance] ?? 0.5;
    if (riskTolerance > 0.6) {
      traits.add('operated with lean reserves');
    } else if (riskTolerance < 0.4) {
      traits.add('maintained substantial safety buffers');
    }

    final infoSeeking = dimensions[ArchetypeDimension.informationSeeking] ?? 0.5;
    if (infoSeeking > 0.6) {
      traits.add('prioritized clear information');
    } else if (infoSeeking < 0.4) {
      traits.add('accepted uncertainty');
    }

    if (traits.isEmpty) {
      return 'Managed with a balanced approach across all dimensions.';
    }

    return 'Managed by: ${traits.join(', ')}.';
  }
}
