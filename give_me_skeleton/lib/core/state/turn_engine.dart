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
    double legitimacyDelta = 0;
    double clarityDelta = 0;

    void bump(MeterType m, double delta) {
      meters[m] = (meters[m]! + delta).clamp(0.0, 100.0);
    }

    // Immediate effects
    switch (action.id) {
      case 'social':
        bump(MeterType.happiness, +8);
        bump(MeterType.instability, -2);
        bump(MeterType.productivity, -1);
        legitimacyDelta = +2; // Popular action
        break;
      case 'enforce':
        bump(MeterType.instability, -7);
        bump(MeterType.trust, -4);
        bump(MeterType.underground, +3);
        legitimacyDelta = -3; // Unpopular authoritarian action
        break;
      case 'infra':
        bump(MeterType.productivity, +5);
        bump(MeterType.happiness, +2);
        bump(MeterType.corruption, +1);
        legitimacyDelta = +1; // Moderately popular
        break;
      case 'intel':
        bump(MeterType.underground, -2);
        bump(MeterType.trust, +1);
        clarityDelta = +4; // Improves information clarity
        legitimacyDelta = -1; // Slight legitimacy cost (surveillance concerns)
        break;
    }

    final next = state.copyWith(
      budget: state.budget - action.cost,
      meters: meters,
      legitimacy: (state.legitimacy + legitimacyDelta).clamp(0.0, 100.0),
      informationClarity: (state.informationClarity + clarityDelta).clamp(0.0, 100.0),
    );

    return next;
  }

  /// Check for collapse conditions. Returns null if stable, or collapse reason if failed.
  String? checkCollapse(Map<MeterType, double> meters, double legitimacy) {
    // Soft collapse thresholds - no perfect win, only survival
    if (legitimacy <= 5) {
      return 'Authority collapse: no one recognizes your right to allocate';
    }
    if (meters[MeterType.instability]! >= 95) {
      return 'Total disorder: systems unable to maintain control';
    }
    if (meters[MeterType.happiness]! <= 5) {
      return 'Mass despair: population lost faith in the system';
    }
    if (meters[MeterType.corruption]! >= 95) {
      return 'Systemic rot: the allocator became part of the problem';
    }
    if (meters[MeterType.trust]! <= 5) {
      return 'Legitimacy failure: no one believes in the system anymore';
    }
    if (meters[MeterType.underground]! >= 95) {
      return 'Shadow takeover: alternative structures replaced official ones';
    }
    if (meters[MeterType.productivity]! <= 5) {
      return 'Economic collapse: output ceased, nothing left to allocate';
    }

    return null;
  }

  /// End-of-turn drift. This is where you can add events, thresholds, etc.
  GameState endTurn(GameState state) {
    // Don't process turns if already collapsed
    if (state.isCollapsed) return state;

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

    // Legitimacy naturally erodes (you must earn it continuously)
    final happiness = meters[MeterType.happiness]!;
    final legitimacyDrift = (happiness - 50) * 0.05 - 0.8; // Net negative drift
    final newLegitimacy = (state.legitimacy + legitimacyDrift).clamp(0.0, 100.0);

    // Information clarity decays without active intelligence work
    final newClarity = (state.informationClarity - 1.2).clamp(0.0, 100.0);

    // Budget refresh per turn, tied weakly to productivity and corruption.
    final productivity = meters[MeterType.productivity]!;
    final corruption = meters[MeterType.corruption]!;
    final income = (40 + (productivity - 50) * 0.6 - (corruption - 50) * 0.4)
        .round()
        .clamp(10, 120);

    // Check for collapse after drift
    final collapseReason = checkCollapse(meters, newLegitimacy);

    return state.copyWith(
      turn: state.turn + 1,
      budget: income,
      meters: meters,
      legitimacy: newLegitimacy,
      informationClarity: newClarity,
      isCollapsed: collapseReason != null,
      collapseReason: collapseReason,
    );
  }
}
