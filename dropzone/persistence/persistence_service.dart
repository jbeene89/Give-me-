import 'models/save_data.dart';
import 'models/save_metadata.dart';
import 'models/game_state_snapshot.dart';
import 'storage/save_slot_manager.dart';
import 'storage/persistence_provider.dart';
import 'storage/file_persistence_provider.dart';
import 'versioning/schema_version.dart';

/// High-level persistence service
/// Main API for saving and loading game state
class PersistenceService {
  final SaveSlotManager _slotManager;
  bool _initialized = false;

  PersistenceService(this._slotManager);

  /// Create service with file-based storage
  ///
  /// Example usage:
  /// ```dart
  /// // In a real Flutter app:
  /// final appDir = await getApplicationDocumentsDirectory();
  /// final saveDir = Directory('${appDir.path}/saves');
  /// final service = PersistenceService.createFile(saveDir.path);
  /// await service.initialize();
  /// ```
  factory PersistenceService.createFile(String directoryPath) {
    final provider = FilePersistenceProvider.create(directoryPath);
    final manager = SaveSlotManager(provider);
    return PersistenceService(manager);
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;
    await _slotManager.initialize();
    _initialized = true;
  }

  /// Save current game state to a slot
  Future<SaveResult> saveGame({
    required String slotId,
    required String displayName,
    required String scenarioId,
    required String difficultyId,
    required GameStateSnapshot gameState,
    String? note,
  }) async {
    _ensureInitialized();

    try {
      // Create metadata
      final metadata = SaveMetadata(
        slotId: slotId,
        displayName: displayName,
        scenarioId: scenarioId,
        difficultyId: difficultyId,
        turnNumber: gameState.currentTurn,
        timestamp: DateTime.now(),
        schemaVersion: SchemaVersion.current,
        note: note,
        checksum: '', // Will be calculated by manager
      );

      // Create save data
      final saveData = SaveData(
        metadata: metadata,
        gameState: gameState,
        schemaVersion: SchemaVersion.current,
      );

      // Save
      return await _slotManager.save(saveData);
    } catch (e) {
      return SaveResult.failure('Failed to save game: $e');
    }
  }

  /// Quick save to autosave slot
  Future<SaveResult> quickSave({
    required String scenarioId,
    required String difficultyId,
    required GameStateSnapshot gameState,
  }) async {
    return await saveGame(
      slotId: SaveSlotManager.autosaveSlotId,
      displayName: 'Autosave',
      scenarioId: scenarioId,
      difficultyId: difficultyId,
      gameState: gameState,
      note: 'Automatic save',
    );
  }

  /// Save to next available slot
  Future<SaveResult> saveToNextSlot({
    required String scenarioId,
    required String difficultyId,
    required GameStateSnapshot gameState,
    String? displayName,
  }) async {
    _ensureInitialized();

    final slotId = await _slotManager.getNextAvailableSlot();
    final name = displayName ?? 'Save ${DateTime.now().toLocal()}';

    return await saveGame(
      slotId: slotId,
      displayName: name,
      scenarioId: scenarioId,
      difficultyId: difficultyId,
      gameState: gameState,
    );
  }

  /// Load game state from a slot
  Future<LoadResult> loadGame(String slotId) async {
    _ensureInitialized();
    return await _slotManager.load(slotId);
  }

  /// Load from autosave slot
  Future<LoadResult> loadAutosave() async {
    return await loadGame(SaveSlotManager.autosaveSlotId);
  }

  /// Delete a save slot
  Future<SaveResult> deleteSave(String slotId) async {
    _ensureInitialized();
    return await _slotManager.deleteSave(slotId);
  }

  /// Get all save metadata (for save/load UI)
  Future<List<SaveMetadata>> getAllSaves() async {
    _ensureInitialized();
    return await _slotManager.getAllMetadata();
  }

  /// Get metadata for a specific slot
  SaveMetadata? getSaveMetadata(String slotId) {
    return _slotManager.getMetadata(slotId);
  }

  /// Check if a save exists
  Future<bool> saveExists(String slotId) async {
    _ensureInitialized();
    return await _slotManager.exists(slotId);
  }

  /// Check if autosave exists
  Future<bool> hasAutosave() async {
    return await saveExists(SaveSlotManager.autosaveSlotId);
  }

  /// Get available save slots
  Future<List<String>> getAvailableSlots() async {
    _ensureInitialized();
    return await _slotManager.getAvailableSlots();
  }

  /// Clear all saves (dangerous!)
  Future<void> clearAllSaves() async {
    _ensureInitialized();
    await _slotManager.clearAll();
  }

  /// Get storage info for debugging
  String getStorageInfo() {
    return _slotManager.getStorageInfo();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }
  }
}

// Re-export for convenience
export 'storage/save_slot_manager.dart' show SaveResult, LoadResult;
