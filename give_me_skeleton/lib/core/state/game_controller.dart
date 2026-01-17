import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../models/policy_action.dart';
import 'turn_engine.dart';
import '../services/analytics_service.dart';
import '../events/event_engine.dart';

// Create event engine with seed for reproducibility
final eventEngineProvider = Provider<EventEngine>((ref) => EventEngine(seed: 42));

final turnEngineProvider = Provider<TurnEngine>((ref) {
  final eventEngine = ref.watch(eventEngineProvider);
  return TurnEngine(eventEngine: eventEngine);
});

final gameControllerProvider = StateNotifierProvider<GameController, GameState>((ref) {
  final engine = ref.watch(turnEngineProvider);
  final analytics = ref.watch(analyticsServiceProvider);
  return GameController(engine: engine, analytics: analytics);
});

class GameController extends StateNotifier<GameState> {
  final TurnEngine engine;
  final AnalyticsService analytics;

  GameController({required this.engine, required this.analytics}) : super(GameState.initial());

  void reset() {
    state = GameState.initial();
    analytics.logEvent('game_reset');
  }

  void applyAction(PolicyAction action) {
    final beforeBudget = state.budget;
    state = engine.applyAction(state, action);

    if (state.budget != beforeBudget) {
      analytics.logEvent('action_applied', params: {'id': action.id, 'cost': action.cost});
    }
  }

  void endTurn() {
    state = engine.endTurn(state);
    analytics.logEvent('turn_end', params: {'turn': state.turn});
  }
}
