/// Evidence supporting an analysis conclusion
class Evidence {
  /// Type of evidence
  final EvidenceType type;

  /// Specific data point or observation
  final String observation;

  /// Numerical value (if applicable)
  final double? value;

  /// Threshold used for comparison (if applicable)
  final double? threshold;

  /// Turn number or range (if applicable)
  final String? timeframe;

  const Evidence({
    required this.type,
    required this.observation,
    this.value,
    this.threshold,
    this.timeframe,
  });

  @override
  String toString() {
    final parts = <String>[observation];

    if (value != null && threshold != null) {
      parts.add('(${value!.toStringAsFixed(2)} vs threshold ${threshold!.toStringAsFixed(2)})');
    } else if (value != null) {
      parts.add('(${value!.toStringAsFixed(2)})');
    }

    if (timeframe != null) {
      parts.add('[$timeframe]');
    }

    return parts.join(' ');
  }
}

/// Types of evidence
enum EvidenceType {
  /// Meter maintained at certain level
  meterLevel,

  /// Meter trend over time (rising/falling)
  meterTrend,

  /// Action frequency or pattern
  actionPattern,

  /// Resource allocation pattern
  resourceAllocation,

  /// Event response pattern
  eventResponse,

  /// Comparative priority (X over Y)
  comparativePriority,
}
