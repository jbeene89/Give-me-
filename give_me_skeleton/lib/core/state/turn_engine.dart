import '../models/game_state.dart';
import '../models/meter.dart';
import '../models/policy_action.dart';
import '../events/event_engine.dart';

/// A deliberately simple "toy" simulation.
///
/// The goal is to give you something that runs, is easy to tune,
/// and is clearly separable from UI.
class TurnEngine {
  final EventEngine? eventEngine;

  const TurnEngine({this.eventEngine});

  GameState applyAction(GameState state, PolicyAction action) {
    if (state.budget < action.cost) return state;

    final meters = Map<MeterType, double>.from(state.meters);
    double legitimacyDelta = 0;
    double clarityDelta = 0;
    double workforceDelta = 0;

    void bump(MeterType m, double delta) {
      meters[m] = (meters[m]! + delta).clamp(0.0, 100.0);
    }

    // Immediate effects, scaled by workforce capacity
    final workforceMultiplier = (state.workforceCapacity / 100) * 0.5 + 0.75; // 0.75x to 1.25x

    switch (action.id) {
      case 'social':
        bump(MeterType.happiness, +8 * workforceMultiplier);
        bump(MeterType.instability, -2 * workforceMultiplier);
        bump(MeterType.productivity, -1);
        legitimacyDelta = +2; // Popular action
        break;
      case 'enforce':
        bump(MeterType.instability, -7 * workforceMultiplier);
        bump(MeterType.trust, -4);
        bump(MeterType.underground, +3);
        legitimacyDelta = -3; // Unpopular authoritarian action
        workforceDelta = -2; // Enforcement diverts labor
        break;
      case 'infra':
        bump(MeterType.productivity, +5 * workforceMultiplier);
        bump(MeterType.happiness, +2);
        bump(MeterType.corruption, +1);
        legitimacyDelta = +1; // Moderately popular
        workforceDelta = +3; // Infrastructure builds capacity
        break;
      case 'intel':
        bump(MeterType.underground, -2);
        bump(MeterType.trust, +1);
        clarityDelta = +4; // Improves information clarity
        legitimacyDelta = -1; // Slight legitimacy cost (surveillance concerns)
        break;
      case 'emergency':
        // Emergency response uses reserves to stabilize dangerous meters
        bump(MeterType.instability, -10 * workforceMultiplier);
        bump(MeterType.safety, +8);
        bump(MeterType.happiness, +5);
        legitimacyDelta = +3; // Shows you care in crisis
        // Cost will be paid from reserves in next section
        break;
      case 'stimulus':
        // Economic stimulus: immediate productivity, delayed corruption
        bump(MeterType.productivity, +12 * workforceMultiplier);
        bump(MeterType.happiness, +4);
        bump(MeterType.corruption, +3); // Immediate corruption from rushed spending
        legitimacyDelta = +2;
        break;
      case 'surveillance':
        // Surveillance: reduces underground, improves clarity, kills trust
        bump(MeterType.underground, -8);
        bump(MeterType.trust, -6);
        bump(MeterType.instability, +2);
        clarityDelta = +6; // Better than intel for visibility
        legitimacyDelta = -4; // Very unpopular
        break;
    }

    // Emergency response draws from reserves if available
    int budgetCost = action.cost;
    int reservesUsed = 0;
    if (action.id == 'emergency' && state.emergencyReserves > 0) {
      reservesUsed = state.emergencyReserves.clamp(0, action.cost);
      budgetCost = action.cost - reservesUsed;
    }

    final next = state.copyWith(
      budget: state.budget - budgetCost,
      emergencyReserves: state.emergencyReserves - reservesUsed,
      meters: meters,
      legitimacy: (state.legitimacy + legitimacyDelta).clamp(0.0, 100.0),
      informationClarity: (state.informationClarity + clarityDelta).clamp(0.0, 100.0),
      workforceCapacity: (state.workforceCapacity + workforceDelta).clamp(0.0, 100.0),
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
    if (meters[MeterType.migration]! >= 95) {
      return 'Mass exodus: population abandoned the system entirely';
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

    // Get meter values for drift calculations
    final safety = meters[MeterType.safety]!;
    final happiness = meters[MeterType.happiness]!;

    // Migration pressure increases with instability and low happiness/safety
    final migrationDrift = (instability - 50) * 0.05 + (50 - happiness) * 0.03 + (50 - safety) * 0.02;
    bump(MeterType.migration, migrationDrift);

    // TRADEOFF MECHANICS (Items 26-30)

    // 26. Over-enforcement backlash: too much safety causes instability spike
    if (safety > 80) {
      bump(MeterType.instability, +(safety - 80) * 0.15); // Oppression breeds resistance
      bump(MeterType.underground, +(safety - 80) * 0.1); // Pushes activity underground
    }

    // 27. Under-enforcement metastasis: too little safety lets problems compound
    if (safety < 30) {
      bump(MeterType.instability, +(30 - safety) * 0.12); // Chaos accelerates
      bump(MeterType.productivity, -(30 - safety) * 0.08); // Can't work in chaos
    }

    // 28. Welfare dependency: too much happiness from support reduces productivity
    if (happiness > 75 && meters[MeterType.productivity]! < 50) {
      bump(MeterType.productivity, -(happiness - 75) * 0.1); // Complacency
    }

    // 29. Surveillance vs trust decay: already implemented in action effects

    // 30. Short-term vs long-term: already implemented via delayed effects

    // Legitimacy naturally erodes (you must earn it continuously)
    final legitimacyDrift = (happiness - 50) * 0.05 - 0.8; // Net negative drift
    final newLegitimacy = (state.legitimacy + legitimacyDrift).clamp(0.0, 100.0);

    // Information clarity decays without active intelligence work
    final newClarity = (state.informationClarity - 1.2).clamp(0.0, 100.0);

    // Workforce capacity drifts based on safety and happiness
    final workforceDrift = (happiness - 50) * 0.04 + (safety - 50) * 0.03 - 0.5;
    final newWorkforce = (state.workforceCapacity + workforceDrift).clamp(0.0, 100.0);

    // Budget refresh per turn, tied weakly to productivity and corruption.
    final productivity = meters[MeterType.productivity]!;
    final corruption = meters[MeterType.corruption]!;
    final income = (40 + (productivity - 50) * 0.6 - (corruption - 50) * 0.4)
        .round()
        .clamp(10, 120);

    // Emergency reserves can be auto-saved (5% of income)
    final reserveAddition = (income * 0.05).round().clamp(0, 10);
    final newReserves = (state.emergencyReserves + reserveAddition).clamp(0, 200);

    // Check for collapse after drift
    final collapseReason = checkCollapse(meters, newLegitimacy);

    // Create intermediate state before events
    var nextState = state.copyWith(
      turn: state.turn + 1,
      budget: income,
      meters: meters,
      legitimacy: newLegitimacy,
      informationClarity: newClarity,
      workforceCapacity: newWorkforce,
      emergencyReserves: newReserves,
      isCollapsed: collapseReason != null,
      collapseReason: collapseReason,
    );

    // Apply event engine if available (uses internal deterministic seeding)
    if (eventEngine != null && !nextState.isCollapsed) {
      final eventResult = eventEngine!.applyTurnEvents(
        nextState,
        nextState.turn,
      );
      nextState = eventResult.updatedState;
      // Event log is tracked internally by EventEngine

      // Check collapse again after events (events can cause immediate collapse)
      final postEventCollapseReason = checkCollapse(nextState.meters, nextState.legitimacy);
      if (postEventCollapseReason != null) {
        nextState = nextState.copyWith(
          isCollapsed: true,
          collapseReason: postEventCollapseReason,
        );
      }
    }

    return nextState;
  }
}
