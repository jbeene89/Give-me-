/// Public API exports for Persistence system
/// Import this file to use save/load functionality
library persistence;

// Main service
export 'persistence_service.dart' show PersistenceService, SaveResult, LoadResult;

// Models
export 'models/save_metadata.dart' show SaveMetadata;
export 'models/save_data.dart' show SaveData;
export 'models/game_state_snapshot.dart' show GameStateSnapshot;

// Versioning
export 'versioning/schema_version.dart' show SchemaVersion;

// Storage
export 'storage/save_slot_manager.dart' show SaveSlotManager;
export 'storage/persistence_provider.dart' show PersistenceProvider;
export 'storage/file_persistence_provider.dart' show FilePersistenceProvider, PersistenceException;
