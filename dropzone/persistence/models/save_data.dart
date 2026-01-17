import 'save_metadata.dart';
import 'game_state_snapshot.dart';

/// Complete save data including metadata and game state
class SaveData {
  /// Save metadata (scenario, difficulty, timestamp, etc.)
  final SaveMetadata metadata;

  /// Snapshot of the game state
  final GameStateSnapshot gameState;

  /// Schema version (for migrations)
  final int schemaVersion;

  const SaveData({
    required this.metadata,
    required this.gameState,
    required this.schemaVersion,
  });

  /// Create from JSON
  factory SaveData.fromJson(Map<String, dynamic> json) {
    return SaveData(
      metadata: SaveMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      gameState: GameStateSnapshot.fromJson(json['gameState'] as Map<String, dynamic>),
      schemaVersion: json['schemaVersion'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'gameState': gameState.toJson(),
      'schemaVersion': schemaVersion,
    };
  }

  /// Validate save data integrity
  bool validate() {
    try {
      // Check schema versions match
      if (metadata.schemaVersion != schemaVersion) return false;

      // Validate game state
      if (!gameState.validate()) return false;

      // Ensure turn numbers match
      if (metadata.turnNumber != gameState.currentTurn) return false;

      return true;
    } catch (_) {
      return false;
    }
  }
}
