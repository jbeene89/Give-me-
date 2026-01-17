import '../models/evidence.dart';

/// Analyzes meter patterns over time
class MeterAnalyzer {
  /// Calculate average meter value over the run
  static double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.5;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate trend (rising/falling/stable)
  /// Returns: positive = rising, negative = falling, ~0 = stable
  static double calculateTrend(List<double> values) {
    if (values.length < 3) return 0.0;

    // Simple linear regression slope
    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = values[i];
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }

  /// Calculate volatility (how much meter fluctuates)
  static double calculateVolatility(List<double> values) {
    if (values.length < 2) return 0.0;

    final avg = calculateAverage(values);
    final variance = values
        .map((v) => (v - avg) * (v - avg))
        .reduce((a, b) => a + b) / values.length;

    return variance; // Return variance (not std dev for easier interpretation)
  }

  /// Determine if meter was consistently maintained in a range
  static bool wasConsistentlyMaintained(
    List<double> values,
    double minThreshold,
    double maxThreshold,
  ) {
    if (values.isEmpty) return false;

    final inRange = values.where((v) => v >= minThreshold && v <= maxThreshold).length;
    final percentage = inRange / values.length;

    return percentage >= 0.7; // 70% of the time in range
  }

  /// Generate evidence for meter level
  static Evidence createMeterLevelEvidence(
    String meterId,
    double average,
    String interpretation,
  ) {
    return Evidence(
      type: EvidenceType.meterLevel,
      observation: '$meterId average: $interpretation',
      value: average,
    );
  }

  /// Generate evidence for meter trend
  static Evidence createMeterTrendEvidence(
    String meterId,
    double trend,
    String timeframe,
  ) {
    String trendWord;
    if (trend > 0.02) {
      trendWord = 'rising';
    } else if (trend < -0.02) {
      trendWord = 'falling';
    } else {
      trendWord = 'stable';
    }

    return Evidence(
      type: EvidenceType.meterTrend,
      observation: '$meterId was $trendWord',
      value: trend,
      timeframe: timeframe,
    );
  }

  /// Compare two meters to determine priority
  static String? determinePriority(
    String meter1,
    double avg1,
    String meter2,
    double avg2,
    double threshold,
  ) {
    final diff = avg1 - avg2;

    if (diff.abs() < threshold) {
      return null; // Too close to call
    }

    return diff > 0 ? meter1 : meter2;
  }
}

/// Tracks meter history over a run
class MeterHistory {
  final String meterId;
  final List<double> values;

  MeterHistory(this.meterId, this.values);

  double get average => MeterAnalyzer.calculateAverage(values);
  double get trend => MeterAnalyzer.calculateTrend(values);
  double get volatility => MeterAnalyzer.calculateVolatility(values);

  double get finalValue => values.isNotEmpty ? values.last : 0.5;
  double get initialValue => values.isNotEmpty ? values.first : 0.5;

  bool wasHigh() => average > 0.6;
  bool wasLow() => average < 0.4;
  bool wasStable() => trend.abs() < 0.02;

  bool wasMaintained(double minThreshold, double maxThreshold) {
    return MeterAnalyzer.wasConsistentlyMaintained(values, minThreshold, maxThreshold);
  }
}
