import 'meter.dart';

class GameState {
  final int turn;
  final int budget;
  final Map<MeterType, double> meters;
  final bool isCollapsed;
  final String? collapseReason;
  final double legitimacy; // Your authority to act (0-100)
  final double informationClarity; // How well you see the system (0-100)
  final double workforceCapacity; // Available labor for projects (0-100)
  final int emergencyReserves; // Saved budget for crisis response

  const GameState({
    required this.turn,
    required this.budget,
    required this.meters,
    this.isCollapsed = false,
    this.collapseReason,
    this.legitimacy = 70.0,
    this.informationClarity = 50.0,
    this.workforceCapacity = 60.0,
    this.emergencyReserves = 0,
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

  GameState copyWith({
    int? turn,
    int? budget,
    Map<MeterType, double>? meters,
    bool? isCollapsed,
    String? collapseReason,
    double? legitimacy,
    double? informationClarity,
    double? workforceCapacity,
    int? emergencyReserves,
  }) {
    return GameState(
      turn: turn ?? this.turn,
      budget: budget ?? this.budget,
      meters: meters ?? this.meters,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      collapseReason: collapseReason ?? this.collapseReason,
      legitimacy: legitimacy ?? this.legitimacy,
      informationClarity: informationClarity ?? this.informationClarity,
      workforceCapacity: workforceCapacity ?? this.workforceCapacity,
      emergencyReserves: emergencyReserves ?? this.emergencyReserves,
    );
  }
}
