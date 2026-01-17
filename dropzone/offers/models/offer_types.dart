/// Type of offer based on what it provides
enum OfferType {
  /// Information: reveals future or hidden data
  information,

  /// Stability: helps prevent or recover from crises
  stability,

  /// Efficiency: permanent or long-term improvements
  efficiency,

  /// Emergency: immediate rescue from bad situation
  emergency,
}

/// When an offer should trigger
enum TriggerCondition {
  /// Crisis: one or more meters in danger zone
  crisis,

  /// Good performance: sustained high performance
  streak,

  /// Random: occasional surprise offer
  random,

  /// Manual: player can always access (no trigger needed)
  manual,
}

/// Price tier placeholder (no real currency yet)
enum PriceTier {
  /// Small purchase ($0.99 - $1.99 equivalent)
  small,

  /// Medium purchase ($2.99 - $4.99 equivalent)
  medium,

  /// Large purchase ($4.99 - $9.99 equivalent)
  large,

  /// Premium purchase ($9.99+ equivalent)
  premium,
}

/// Effect that an offer provides
class OfferEffect {
  /// Type of effect
  final OfferEffectType type;

  /// Target meter or system (if applicable)
  final String? target;

  /// Magnitude of effect (interpretation depends on type)
  final double magnitude;

  /// Duration in turns (0 = permanent, -1 = instant/consumable)
  final int duration;

  const OfferEffect({
    required this.type,
    this.target,
    required this.magnitude,
    required this.duration,
  });

  @override
  String toString() {
    final durationStr = duration == 0
        ? 'permanent'
        : duration == -1
            ? 'instant'
            : '$duration turns';
    return '$type ${target ?? ''} (${magnitude.toStringAsFixed(2)}, $durationStr)';
  }
}

/// Types of effects offers can provide
enum OfferEffectType {
  /// Boost meter value immediately
  meterBoost,

  /// Reduce noise/fog for duration
  noiseReduction,

  /// Reveal hidden meters for duration
  revealBlindSpots,

  /// See future turns (forecast)
  forecastExtension,

  /// Prevent next collapse event
  collapseVeto,

  /// Permanent multiplier to decay/events
  permanentModifier,

  /// Add resources (budget, influence)
  resourceGrant,

  /// Reduce action costs for duration
  actionCostReduction,
}
