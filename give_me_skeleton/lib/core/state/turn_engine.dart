import '../models/game_state.dart';
import '../models/meter.dart';
import '../models/policy_action.dart';

/// A deliberately simple "toy" simulation.
///
/// The goal is to give you something that runs, is easy to tune,
/// and is clearly separable from UI.
class TurnEngine {
  const TurnEngine();

  GameState applyAction(GameState state, PolicyAction action) {
    if (state.budget < action.cost) return state;

    final meters = Map<MeterType, double>.from(state.meters);

    void bump(MeterType m, double delta) {
      meters[m] = (meters[m]! + delta).clamp(0.0, 100.0);
    }

    // Immediate effects
    switch (action.id) {
      case 'social':
        bump(MeterType.happiness, +8);
        bump(MeterType.instability, -2);
        bump(MeterType.productivity, -1);
        break;
      case 'enforce':
        bump(MeterType.instability, -7);
        bump(MeterType.trust, -4);
        bump(MeterType.underground, +3);
        break;
      case 'infra':
        bump(MeterType.productivity, +5);
        bump(MeterType.happiness, +2);
        bump(MeterType.corruption, +1);
        break;
      case 'intel':
        bump(MeterType.underground, -2);
        bump(MeterType.trust, +1);
        break;
    }

    final next = state.copyWith(
      budget: state.budget - action.cost,
      meters: meters,
    );

    return next;
  }

  /// End-of-turn drift. This is where you can add events, thresholds, etc.
  GameState endTurn(GameState state) {
    final meters = Map<MeterType, double>.from(state.meters);

    void bump(MeterType m, double delta) {
      meters[m] = (meters[m]! + delta).clamp(0.0, 100.0);
    }

    // Core drift rules (intentionally a bit mean):
    // - High instability eats safety and happiness.
    // - Low trust fuels underground activity.
    // - Corruption slowly rises unless actively countered.
    final instability = meters[MeterType.instability]!;
    final trust = meters[MeterType.trust]!;

    bump(MeterType.safety, -(instability - 50) * 0.04);
    bump(MeterType.happiness, -(instability - 50) * 0.03);

    bump(MeterType.underground, (50 - trust) * 0.03);
    bump(MeterType.corruption, +0.6);

    // Budget refresh per turn, tied weakly to productivity and corruption.
    final productivity = meters[MeterType.productivity]!;
    final corruption = meters[MeterType.corruption]!;
    final income = (40 + (productivity - 50) * 0.6 - (corruption - 50) * 0.4)
        .round()
        .clamp(10, 120);

    return state.copyWith(
      turn: state.turn + 1,
      budget: income,
      meters: meters,
    );
  }
}
