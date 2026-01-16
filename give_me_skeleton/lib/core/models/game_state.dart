import 'meter.dart';

class GameState {
  final int turn;
  final int budget;
  final Map<MeterType, double> meters;

  const GameState({
    required this.turn,
    required this.budget,
    required this.meters,
  });

  factory GameState.initial() {
    return GameState(
      turn: 1,
      budget: 100,
      meters: {
        for (final def in kMeterDefs) def.type: 50.0,
      },
    );
  }

  GameState copyWith({int? turn, int? budget, Map<MeterType, double>? meters}) {
    return GameState(
      turn: turn ?? this.turn,
      budget: budget ?? this.budget,
      meters: meters ?? this.meters,
    );
  }
}
