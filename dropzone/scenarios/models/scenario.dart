import 'scenario_modifiers.dart';

/// Defines a starting scenario with initial meter values, resources, and modifiers
class Scenario {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// 2-3 line description of the scenario
  final String description;

  /// Initial meter values (meter ID -> normalized value 0.0-1.0)
  /// Expected meters: stability, capacity, reserves, clarity, morale, efficiency
  final Map<String, double> initialMeterValues;

  /// Initial meta-resources (resource ID -> amount)
  /// e.g., {'budget': 100, 'influence': 50}
  final Map<String, int> initialResources;

  /// Action IDs that are unlocked at start
  /// If null, all actions are unlocked (expert mode)
  /// If empty list, no actions unlocked (tutorial/demo mode)
  final List<String>? unlockedActions;

  /// Optional modifiers to game parameters
  final ScenarioModifiers modifiers;

  /// Recommended difficulty (for UI hints) - 1=easy, 2=medium, 3=hard
  final int recommendedDifficulty;

  /// Whether this scenario is good for beginners
  final bool beginnerFriendly;

  const Scenario({
    required this.id,
    required this.name,
    required this.description,
    required this.initialMeterValues,
    this.initialResources = const {},
    this.unlockedActions,
    this.modifiers = const ScenarioModifiers.none(),
    this.recommendedDifficulty = 2,
    this.beginnerFriendly = false,
  });

  /// Get initial value for a specific meter, or default if not specified
  double getMeterValue(String meterId, {double defaultValue = 0.5}) {
    return initialMeterValues[meterId] ?? defaultValue;
  }

  /// Get initial resource amount, or 0 if not specified
  int getResourceAmount(String resourceId) {
    return initialResources[resourceId] ?? 0;
  }

  /// Check if an action is unlocked in this scenario
  /// Returns true if unlockedActions is null (all unlocked) or contains actionId
  bool isActionUnlocked(String actionId) {
    if (unlockedActions == null) return true; // All unlocked
    return unlockedActions!.contains(actionId);
  }

  @override
  String toString() => '$name ($id)';
}
