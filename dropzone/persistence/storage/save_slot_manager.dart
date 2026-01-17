import 'dart:convert';
import '../models/save_metadata.dart';
import '../models/save_data.dart';
import '../utils/checksum_util.dart';
import '../versioning/schema_version.dart';
import '../versioning/migration_manager.dart';
import 'persistence_provider.dart';
import 'file_persistence_provider.dart';

/// Result of a save operation
class SaveResult {
  final bool success;
  final String? errorMessage;
  final List<String> warnings;

  const SaveResult({
    required this.success,
    this.errorMessage,
    this.warnings = const [],
  });

  factory SaveResult.success({List<String> warnings = const []}) {
    return SaveResult(success: true, warnings: warnings);
  }

  factory SaveResult.failure(String error) {
    return SaveResult(success: false, errorMessage: error);
  }
}

/// Result of a load operation
class LoadResult {
  final bool success;
  final SaveData? data;
  final String? errorMessage;
  final List<String> warnings;

  const LoadResult({
    required this.success,
    this.data,
    this.errorMessage,
    this.warnings = const [],
  });

  factory LoadResult.success(SaveData data, {List<String> warnings = const []}) {
    return LoadResult(success: true, data: data, warnings: warnings);
  }

  factory LoadResult.failure(String error) {
    return LoadResult(success: false, errorMessage: error);
  }
}

/// Manages save slots with metadata tracking
class SaveSlotManager {
  final PersistenceProvider _provider;

  /// Metadata cache (slot ID -> metadata)
  final Map<String, SaveMetadata> _metadataCache = {};

  /// Maximum number of regular save slots
  static const int maxSaveSlots = 3;

  /// Autosave slot ID
  static const String autosaveSlotId = 'autosave';

  SaveSlotManager(this._provider);

  /// Initialize the manager
  Future<void> initialize() async {
    await _provider.initialize();
    await _loadMetadataCache();
  }

  /// Save game data to a slot
  Future<SaveResult> save(SaveData saveData) async {
    try {
      // Validate save data
      if (!saveData.validate()) {
        return SaveResult.failure('Invalid save data');
      }

      // Check schema version
      if (saveData.schemaVersion != SchemaVersion.current) {
        return SaveResult.failure(
          'Save data schema version ${saveData.schemaVersion} does not match current ${SchemaVersion.current}',
        );
      }

      // Calculate checksum
      final dataJson = saveData.toJson();
      final checksum = ChecksumUtil.calculate(dataJson);

      // Update metadata with checksum
      final updatedMetadata = saveData.metadata.copyWith(
        checksum: checksum,
        timestamp: DateTime.now(),
      );

      final updatedSaveData = SaveData(
        metadata: updatedMetadata,
        gameState: saveData.gameState,
        schemaVersion: saveData.schemaVersion,
      );

      // Serialize to JSON
      final jsonString = json.encode(updatedSaveData.toJson());

      // Save to storage
      final saved = await _provider.save(updatedMetadata.slotId, jsonString);

      if (!saved) {
        return SaveResult.failure('Storage provider failed to save');
      }

      // Update cache
      _metadataCache[updatedMetadata.slotId] = updatedMetadata;

      return SaveResult.success();
    } on PersistenceException catch (e) {
      return SaveResult.failure(e.message);
    } catch (e) {
      return SaveResult.failure('Unexpected error during save: $e');
    }
  }

  /// Load game data from a slot
  Future<LoadResult> load(String slotId) async {
    try {
      // Check if slot exists
      if (!await _provider.exists(slotId)) {
        return LoadResult.failure('Save slot $slotId does not exist');
      }

      // Load raw data
      final jsonString = await _provider.load(slotId);
      if (jsonString == null) {
        return LoadResult.failure('Failed to read save data');
      }

      // Parse JSON
      Map<String, dynamic> dataJson;
      try {
        dataJson = json.decode(jsonString) as Map<String, dynamic>;
      } catch (_) {
        return LoadResult.failure('Corrupted save file (invalid JSON)');
      }

      // Check schema version
      final schemaVersion = dataJson['schemaVersion'] as int;
      if (!SchemaVersion.isSupported(schemaVersion)) {
        return LoadResult.failure(
          'Save file version $schemaVersion is not supported. '
          'Minimum: ${SchemaVersion.minimumSupported}, Current: ${SchemaVersion.current}',
        );
      }

      // Migrate if needed
      final warnings = <String>[];
      if (SchemaVersion.needsMigration(schemaVersion)) {
        final migrationResult = MigrationManager.migrate(
          dataJson,
          schemaVersion,
          SchemaVersion.current,
        );

        if (!migrationResult.success) {
          return LoadResult.failure(
            'Migration failed: ${migrationResult.errorMessage}',
          );
        }

        dataJson = migrationResult.migratedData;
        warnings.addAll(migrationResult.warnings);
        warnings.add('Save migrated from v$schemaVersion to v${SchemaVersion.current}');
      }

      // Parse save data
      final saveData = SaveData.fromJson(dataJson);

      // Verify checksum
      final expectedChecksum = saveData.metadata.checksum;
      if (expectedChecksum.isNotEmpty) {
        // Recalculate checksum (without the checksum field itself)
        final dataForChecksum = Map<String, dynamic>.from(dataJson);
        if (dataForChecksum['metadata'] is Map) {
          final metadataForChecksum = Map<String, dynamic>.from(dataForChecksum['metadata']);
          metadataForChecksum.remove('checksum');
          dataForChecksum['metadata'] = metadataForChecksum;
        }

        final calculatedChecksum = ChecksumUtil.calculate(dataForChecksum);
        if (calculatedChecksum != expectedChecksum) {
          warnings.add('Checksum mismatch - save file may be corrupted');
        }
      }

      // Validate save data
      if (!saveData.validate()) {
        return LoadResult.failure('Save data validation failed');
      }

      // Update cache
      _metadataCache[slotId] = saveData.metadata;

      return LoadResult.success(saveData, warnings: warnings);
    } on PersistenceException catch (e) {
      return LoadResult.failure(e.message);
    } catch (e) {
      return LoadResult.failure('Unexpected error during load: $e');
    }
  }

  /// Delete a save slot
  Future<SaveResult> deleteSave(String slotId) async {
    try {
      await _provider.delete(slotId);
      _metadataCache.remove(slotId);
      return SaveResult.success();
    } on PersistenceException catch (e) {
      return SaveResult.failure(e.message);
    } catch (e) {
      return SaveResult.failure('Failed to delete save: $e');
    }
  }

  /// Get metadata for all save slots
  Future<List<SaveMetadata>> getAllMetadata() async {
    await _loadMetadataCache();
    return _metadataCache.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
  }

  /// Get metadata for a specific slot
  SaveMetadata? getMetadata(String slotId) {
    return _metadataCache[slotId];
  }

  /// Check if a slot exists
  Future<bool> exists(String slotId) async {
    return await _provider.exists(slotId);
  }

  /// Get available save slot IDs (excluding autosave)
  Future<List<String>> getAvailableSlots() async {
    final allSlots = await _provider.listSlots();
    return allSlots.where((id) => id != autosaveSlotId).toList();
  }

  /// Get next available slot ID for new save
  Future<String> getNextAvailableSlot() async {
    for (int i = 1; i <= maxSaveSlots; i++) {
      final slotId = 'slot_$i';
      if (!await exists(slotId)) {
        return slotId;
      }
    }

    // All slots full, return oldest slot to overwrite
    final metadata = await getAllMetadata();
    if (metadata.isEmpty) {
      return 'slot_1';
    }

    // Find oldest non-autosave slot
    final regularSaves = metadata.where((m) => m.slotId != autosaveSlotId).toList();
    if (regularSaves.isEmpty) {
      return 'slot_1';
    }

    regularSaves.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return regularSaves.first.slotId;
  }

  /// Load metadata cache from all save files
  Future<void> _loadMetadataCache() async {
    try {
      final slotIds = await _provider.listSlots();

      for (final slotId in slotIds) {
        try {
          final jsonString = await _provider.load(slotId);
          if (jsonString == null) continue;

          final dataJson = json.decode(jsonString) as Map<String, dynamic>;
          final metadata = SaveMetadata.fromJson(dataJson['metadata'] as Map<String, dynamic>);

          _metadataCache[slotId] = metadata;
        } catch (_) {
          // Skip corrupted saves when loading metadata
          continue;
        }
      }
    } catch (_) {
      // If cache loading fails, continue with empty cache
    }
  }

  /// Clear all saves (dangerous!)
  Future<void> clearAll() async {
    await _provider.clearAll();
    _metadataCache.clear();
  }

  /// Get storage info
  String getStorageInfo() {
    return _provider.getStorageInfo();
  }
}
