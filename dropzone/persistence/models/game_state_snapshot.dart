/// Serializable snapshot of GameState
/// This mirrors the structure of GameState without depending on the actual class
class GameStateSnapshot {
  /// Current meter values (meter ID -> normalized value 0.0-1.0)
  final Map<String, double> meterValues;

  /// Current resource amounts (resource ID -> integer amount)
  final Map<String, int> resources;

  /// Currently unlocked action IDs
  final List<String> unlockedActions;

  /// Current turn number
  final int currentTurn;

  /// Active scenario modifiers (serialized as JSON-compatible map)
  final Map<String, dynamic> activeModifiers;

  /// Event log (serialized event entries)
  final List<Map<String, dynamic>> eventLog;

  /// Delayed effects queue (effects scheduled for future turns)
  final List<Map<String, dynamic>> delayedEffects;

  /// Event cooldowns (event ID -> turn number when cooldown expires)
  final Map<String, int> eventCooldowns;

  /// Events that triggered last turn (for compound event tracking)
  final List<String> lastTurnEventIds;

  /// Random seed for reproducibility
  final int? randomSeed;

  /// Additional custom data (for future extensions)
  final Map<String, dynamic> customData;

  const GameStateSnapshot({
    required this.meterValues,
    required this.resources,
    required this.unlockedActions,
    required this.currentTurn,
    required this.activeModifiers,
    required this.eventLog,
    required this.delayedEffects,
    required this.eventCooldowns,
    required this.lastTurnEventIds,
    this.randomSeed,
    this.customData = const {},
  });

  /// Create from JSON
  factory GameStateSnapshot.fromJson(Map<String, dynamic> json) {
    return GameStateSnapshot(
      meterValues: Map<String, double>.from(
        (json['meterValues'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      resources: Map<String, int>.from(json['resources'] as Map<String, dynamic>),
      unlockedActions: List<String>.from(json['unlockedActions'] as List),
      currentTurn: json['currentTurn'] as int,
      activeModifiers: Map<String, dynamic>.from(json['activeModifiers'] as Map<String, dynamic>),
      eventLog: List<Map<String, dynamic>>.from(
        (json['eventLog'] as List).map((e) => Map<String, dynamic>.from(e)),
      ),
      delayedEffects: List<Map<String, dynamic>>.from(
        (json['delayedEffects'] as List).map((e) => Map<String, dynamic>.from(e)),
      ),
      eventCooldowns: Map<String, int>.from(json['eventCooldowns'] as Map<String, dynamic>),
      lastTurnEventIds: List<String>.from(json['lastTurnEventIds'] as List),
      randomSeed: json['randomSeed'] as int?,
      customData: Map<String, dynamic>.from(json['customData'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'meterValues': meterValues,
      'resources': resources,
      'unlockedActions': unlockedActions,
      'currentTurn': currentTurn,
      'activeModifiers': activeModifiers,
      'eventLog': eventLog,
      'delayedEffects': delayedEffects,
      'eventCooldowns': eventCooldowns,
      'lastTurnEventIds': lastTurnEventIds,
      'randomSeed': randomSeed,
      'customData': customData,
    };
  }

  /// Validate snapshot has required fields and values are in valid ranges
  bool validate() {
    try {
      // Check meters are in 0.0-1.0 range
      for (final value in meterValues.values) {
        if (value < 0.0 || value > 1.0) return false;
      }

      // Check resources are non-negative
      for (final amount in resources.values) {
        if (amount < 0) return false;
      }

      // Check turn number is non-negative
      if (currentTurn < 0) return false;

      return true;
    } catch (_) {
      return false;
    }
  }
}
