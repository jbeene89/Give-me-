import 'dart:math';
import '../models/meter.dart';
import 'models/event_effect.dart';

/// Implements information fog mechanics: noisy data, blind spots, delayed feedback
/// Works with informationClarity in 0-100 range
class FogMechanics {
  final Random _random;

  // Configuration constants (0-100 scale)
  static const double clarityThresholdForNoise = 60.0; // Below 60, noise appears
  static const double clarityThresholdForBlindSpots = 40.0; // Below 40, blind spots appear
  static const double maxNoisePercentage = 0.15; // ±15% error at worst
  static const List<MeterType> blindSpotMeters = [MeterType.corruption, MeterType.underground];

  FogMechanics(this._random);

  /// Apply noise to a meter value based on informationClarity (0-100)
  /// Returns the perceived value (with noise) that should be shown to player
  double applyNoiseToMeterValue(double actualValue, double clarity) {
    if (clarity >= clarityThresholdForNoise) {
      return actualValue; // No noise when clarity is high
    }

    // Calculate noise magnitude based on how low clarity is
    final noiseFactor = 1.0 - (clarity / clarityThresholdForNoise);
    final maxNoise = actualValue * maxNoisePercentage * noiseFactor;

    // Add random noise ±maxNoise
    final noise = (_random.nextDouble() * 2 - 1) * maxNoise;
    final perceivedValue = actualValue + noise;

    // Clamp to valid range [0, 100]
    return perceivedValue.clamp(0.0, 100.0);
  }

  /// Apply noise to event effects based on clarity (0-100)
  /// Returns perceived effects (what player sees) vs actual effects
  List<EventEffect> applyNoiseToEffects(
    List<EventEffect> actualEffects,
    double clarity,
  ) {
    if (clarity >= clarityThresholdForNoise) {
      return actualEffects; // No noise
    }

    final noiseFactor = 1.0 - (clarity / clarityThresholdForNoise);

    return actualEffects.map((effect) {
      // Add proportional noise to the delta
      final maxNoise = effect.delta.abs() * maxNoisePercentage * noiseFactor;
      final noise = (_random.nextDouble() * 2 - 1) * maxNoise;

      return effect.copyWith(
        delta: effect.delta + noise,
      );
    }).toList();
  }

  /// Check if a meter should be hidden (blind spot) based on clarity (0-100)
  bool isMeterHidden(MeterType meterType, double clarity) {
    if (clarity >= clarityThresholdForBlindSpots) {
      return false; // Nothing hidden when clarity is decent
    }

    // Specific meters become blind spots when clarity is low
    return blindSpotMeters.contains(meterType);
  }

  /// Get list of all blind spot meters at current clarity
  List<MeterType> getBlindSpotMeters(double clarity) {
    if (clarity >= clarityThresholdForBlindSpots) {
      return [];
    }
    return List.from(blindSpotMeters);
  }

  /// Determine if information should be obscured in log
  bool shouldObscureInLog(double clarity) {
    return clarity < clarityThresholdForNoise;
  }
}

/// Manages delayed effects that apply in future turns
class DelayedEffectQueue {
  final List<_DelayedEffect> _queue = [];

  /// Add a delayed effect
  void scheduleEffect(int currentTurn, EventEffect effect, String eventId) {
    if (effect.delayTurns <= 0) return;

    _queue.add(_DelayedEffect(
      applyAtTurn: currentTurn + effect.delayTurns,
      effect: effect,
      sourceEventId: eventId,
    ));
  }

  /// Get and remove all effects that should apply this turn
  List<EventEffect> popEffectsForTurn(int turn) {
    final effects = _queue
        .where((d) => d.applyAtTurn == turn)
        .map((d) => d.effect)
        .toList();

    _queue.removeWhere((d) => d.applyAtTurn == turn);

    return effects;
  }

  /// Peek at upcoming delayed effects (for debugging/testing)
  List<EventEffect> peekUpcomingEffects() {
    return _queue.map((d) => d.effect).toList();
  }

  void clear() {
    _queue.clear();
  }
}

class _DelayedEffect {
  final int applyAtTurn;
  final EventEffect effect;
  final String sourceEventId;

  _DelayedEffect({
    required this.applyAtTurn,
    required this.effect,
    required this.sourceEventId,
  });
}
