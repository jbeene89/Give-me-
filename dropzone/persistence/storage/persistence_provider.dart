/// Abstract interface for persistence storage
/// Allows swapping implementations (file, shared_preferences, cloud, etc.)
abstract class PersistenceProvider {
  /// Initialize the provider
  Future<void> initialize();

  /// Save data to a slot
  Future<bool> save(String slotId, String data);

  /// Load data from a slot
  Future<String?> load(String slotId);

  /// Delete a save slot
  Future<bool> delete(String slotId);

  /// Check if a slot exists
  Future<bool> exists(String slotId);

  /// List all save slot IDs
  Future<List<String>> listSlots();

  /// Clear all saves (use with caution)
  Future<void> clearAll();

  /// Get storage path/info (for debugging)
  String getStorageInfo();
}
