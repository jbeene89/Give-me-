import 'dart:math';
import 'models/offer.dart';
import 'models/offer_types.dart';
import 'offer_catalog.dart';

/// Tracks the state of an offer (cooldown, purchases, etc.)
class OfferState {
  final String offerId;
  int lastOfferedTurn;
  int lastDeclinedTurn;
  int purchaseCount;
  bool isActive;

  OfferState({
    required this.offerId,
    this.lastOfferedTurn = -999,
    this.lastDeclinedTurn = -999,
    this.purchaseCount = 0,
    this.isActive = false,
  });
}

/// Tracks player performance for streak detection
class PerformanceTracker {
  final List<bool> _recentPerformance = [];
  static const int _windowSize = 15; // Track last 15 turns

  /// Record performance for current turn
  /// Good performance = most meters above 0.5
  void recordTurn(Map<String, double> meterValues) {
    final goodMeters = meterValues.values.where((v) => v >= 0.50).length;
    final totalMeters = meterValues.length;

    final isGoodTurn = goodMeters >= (totalMeters * 0.6); // 60%+ meters good

    _recentPerformance.add(isGoodTurn);

    // Keep only recent history
    if (_recentPerformance.length > _windowSize) {
      _recentPerformance.removeAt(0);
    }
  }

  /// Get current streak of consecutive good turns
  int getCurrentStreak() {
    int streak = 0;
    for (int i = _recentPerformance.length - 1; i >= 0; i--) {
      if (_recentPerformance[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Get overall performance rating (0.0-1.0)
  double getPerformanceRating() {
    if (_recentPerformance.isEmpty) return 0.5;
    final goodTurns = _recentPerformance.where((t) => t).length;
    return goodTurns / _recentPerformance.length;
  }

  void reset() {
    _recentPerformance.clear();
  }
}

/// Result of checking for offers
class OfferCheckResult {
  final List<Offer> availableOffers;
  final String reason;

  const OfferCheckResult({
    required this.availableOffers,
    this.reason = '',
  });

  bool get hasOffers => availableOffers.isNotEmpty;
}

/// Main Offer Engine - decides when to show offers
class OfferEngine {
  final Random _random;
  final Map<String, OfferState> _offerStates = {};
  final PerformanceTracker _performanceTracker = PerformanceTracker();

  int _currentTurn = 0;

  /// Maximum number of offers to show at once
  static const int maxSimultaneousOffers = 2;

  /// Minimum turns between ANY offers (prevents offer spam)
  static const int globalOfferCooldown = 3;

  int _lastOfferTurn = -999;

  OfferEngine({int? seed}) : _random = Random(seed);

  /// Process a turn and check for offers
  OfferCheckResult checkForOffers(
    int turnNumber,
    Map<String, double> meterValues,
  ) {
    _currentTurn = turnNumber;

    // Record performance for streak tracking
    _performanceTracker.recordTurn(meterValues);

    // Check global cooldown
    if (_currentTurn - _lastOfferTurn < globalOfferCooldown) {
      return OfferCheckResult(
        availableOffers: [],
        reason: 'Global cooldown active',
      );
    }

    // Collect eligible offers
    final eligibleOffers = <Offer>[];

    // Check crisis offers
    eligibleOffers.addAll(_checkCrisisOffers(meterValues));

    // Check streak offers (less frequent, only if performance is good)
    if (_performanceTracker.getPerformanceRating() > 0.65) {
      eligibleOffers.addAll(_checkStreakOffers(meterValues));
    }

    // Check random offers
    eligibleOffers.addAll(_checkRandomOffers());

    // Remove duplicates and limit
    final uniqueOffers = eligibleOffers.toSet().toList();
    uniqueOffers.shuffle(_random);

    final offersToShow = uniqueOffers.take(maxSimultaneousOffers).toList();

    if (offersToShow.isNotEmpty) {
      _lastOfferTurn = _currentTurn;

      // Mark offers as offered
      for (final offer in offersToShow) {
        _getOrCreateState(offer.id).lastOfferedTurn = _currentTurn;
      }
    }

    return OfferCheckResult(
      availableOffers: offersToShow,
      reason: offersToShow.isEmpty ? 'No eligible offers' : '',
    );
  }

  /// Check crisis-triggered offers
  List<Offer> _checkCrisisOffers(Map<String, double> meterValues) {
    final eligible = <Offer>[];

    for (final offer in OfferCatalog.crisisOffers) {
      if (_isOfferEligible(offer, meterValues)) {
        eligible.add(offer);
      }
    }

    return eligible;
  }

  /// Check streak-triggered offers
  List<Offer> _checkStreakOffers(Map<String, double> meterValues) {
    final eligible = <Offer>[];
    final currentStreak = _performanceTracker.getCurrentStreak();

    for (final offer in OfferCatalog.streakOffers) {
      if (_isOfferEligible(offer, meterValues, streakCount: currentStreak)) {
        // Streak offers are rarer - only 30% chance even when eligible
        if (_random.nextDouble() < 0.30) {
          eligible.add(offer);
        }
      }
    }

    return eligible;
  }

  /// Check random offers
  List<Offer> _checkRandomOffers() {
    final eligible = <Offer>[];

    for (final offer in OfferCatalog.randomOffers) {
      final state = _getOrCreateState(offer.id);

      // Check cooldown
      if (_currentTurn - state.lastOfferedTurn < offer.cooldownTurns) {
        continue;
      }

      // Check purchase limit
      if (offer.purchaseLimit > 0 && state.purchaseCount >= offer.purchaseLimit) {
        continue;
      }

      // Check minimum turn
      if (_currentTurn < offer.minimumTurn) {
        continue;
      }

      // Check random probability
      if (offer.randomProbability != null &&
          _random.nextDouble() < offer.randomProbability!) {
        eligible.add(offer);
      }
    }

    return eligible;
  }

  /// Check if offer is eligible
  bool _isOfferEligible(
    Offer offer,
    Map<String, double> meterValues, {
    int streakCount = 0,
  }) {
    final state = _getOrCreateState(offer.id);

    // Check cooldown
    if (_currentTurn - state.lastOfferedTurn < offer.cooldownTurns) {
      return false;
    }

    // Check purchase limit
    if (offer.purchaseLimit > 0 && state.purchaseCount >= offer.purchaseLimit) {
      return false;
    }

    // Check trigger conditions
    if (!offer.canTrigger(meterValues, _currentTurn, streakCount)) {
      return false;
    }

    return true;
  }

  /// Record that an offer was purchased
  void recordPurchase(String offerId) {
    final state = _getOrCreateState(offerId);
    state.purchaseCount++;
    state.isActive = true;
    state.lastOfferedTurn = _currentTurn;
  }

  /// Record that an offer was declined
  void recordDecline(String offerId) {
    final state = _getOrCreateState(offerId);
    state.lastDeclinedTurn = _currentTurn;
    state.lastOfferedTurn = _currentTurn; // Also triggers cooldown
  }

  /// Get active effects from purchased offers
  /// Returns map of effect type -> magnitude for active effects
  Map<OfferEffectType, double> getActiveEffects() {
    final effects = <OfferEffectType, double>{};

    for (final entry in _offerStates.entries) {
      if (entry.value.isActive) {
        final offer = OfferCatalog.getOfferById(entry.key);
        if (offer != null) {
          for (final effect in offer.effects) {
            // Aggregate effects of same type
            effects[effect.type] = (effects[effect.type] ?? 0.0) + effect.magnitude;
          }
        }
      }
    }

    return effects;
  }

  /// Get current streak count
  int getCurrentStreak() {
    return _performanceTracker.getCurrentStreak();
  }

  /// Get performance rating
  double getPerformanceRating() {
    return _performanceTracker.getPerformanceRating();
  }

  /// Get purchase count for an offer
  int getPurchaseCount(String offerId) {
    return _getOrCreateState(offerId).purchaseCount;
  }

  /// Check if offer has reached purchase limit
  bool hasReachedPurchaseLimit(String offerId) {
    final offer = OfferCatalog.getOfferById(offerId);
    if (offer == null || offer.purchaseLimit == 0) return false;

    return getPurchaseCount(offerId) >= offer.purchaseLimit;
  }

  /// Reset engine state (for new game)
  void reset() {
    _offerStates.clear();
    _performanceTracker.reset();
    _currentTurn = 0;
    _lastOfferTurn = -999;
  }

  OfferState _getOrCreateState(String offerId) {
    return _offerStates.putIfAbsent(
      offerId,
      () => OfferState(offerId: offerId),
    );
  }

  /// Get offer states (for serialization/debugging)
  Map<String, OfferState> getOfferStates() {
    return Map.unmodifiable(_offerStates);
  }

  /// Restore offer states (from save)
  void restoreStates(Map<String, OfferState> states) {
    _offerStates.clear();
    _offerStates.addAll(states);
  }
}
