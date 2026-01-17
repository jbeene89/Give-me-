import 'schema_version.dart';

/// Result of a migration operation
class MigrationResult {
  final bool success;
  final Map<String, dynamic> migratedData;
  final String? errorMessage;
  final List<String> warnings;

  const MigrationResult({
    required this.success,
    required this.migratedData,
    this.errorMessage,
    this.warnings = const [],
  });

  factory MigrationResult.success(
    Map<String, dynamic> data, {
    List<String> warnings = const [],
  }) {
    return MigrationResult(
      success: true,
      migratedData: data,
      warnings: warnings,
    );
  }

  factory MigrationResult.failure(String error) {
    return MigrationResult(
      success: false,
      migratedData: const {},
      errorMessage: error,
    );
  }
}

/// Manages schema migrations between versions
class MigrationManager {
  /// Migrate save data from one version to another
  static MigrationResult migrate(
    Map<String, dynamic> data,
    int fromVersion,
    int toVersion,
  ) {
    if (!SchemaVersion.isSupported(fromVersion)) {
      return MigrationResult.failure(
        'Unsupported schema version: $fromVersion. '
        'Minimum supported: ${SchemaVersion.minimumSupported}',
      );
    }

    if (toVersion > SchemaVersion.current) {
      return MigrationResult.failure(
        'Target version $toVersion is newer than current ${SchemaVersion.current}. '
        'Please update the app.',
      );
    }

    if (fromVersion == toVersion) {
      return MigrationResult.success(data);
    }

    // Get migration path
    final migrationPath = SchemaVersion.getMigrationPath(fromVersion);
    if (migrationPath.last != toVersion) {
      return MigrationResult.failure(
        'Cannot migrate from $fromVersion to $toVersion',
      );
    }

    // Apply migrations sequentially
    var currentData = Map<String, dynamic>.from(data);
    final warnings = <String>[];

    try {
      for (final targetVersion in migrationPath) {
        final result = _applyMigration(currentData, targetVersion);
        if (!result.success) {
          return result;
        }
        currentData = result.migratedData;
        warnings.addAll(result.warnings);
      }

      return MigrationResult.success(currentData, warnings: warnings);
    } catch (e) {
      return MigrationResult.failure('Migration failed: $e');
    }
  }

  /// Apply a single migration step
  static MigrationResult _applyMigration(
    Map<String, dynamic> data,
    int toVersion,
  ) {
    switch (toVersion) {
      case 1:
        // No migration needed for v1 (initial version)
        return MigrationResult.success(data);

      // Future migrations:
      // case 2:
      //   return _migrateToV2(data);
      // case 3:
      //   return _migrateToV3(data);

      default:
        return MigrationResult.failure('No migration defined for version $toVersion');
    }
  }

  // ========== MIGRATION STUBS ==========
  // Add migration functions here as schema evolves

  /// Example migration stub for future v1 -> v2
  static MigrationResult _migrateToV2(Map<String, dynamic> data) {
    // Example: Add action history tracking
    final migrated = Map<String, dynamic>.from(data);
    final warnings = <String>[];

    try {
      // Add new field with default value
      if (migrated['gameState'] is Map<String, dynamic>) {
        final gameState = Map<String, dynamic>.from(migrated['gameState']);

        // Add action history if not present
        if (!gameState.containsKey('actionHistory')) {
          gameState['actionHistory'] = <Map<String, dynamic>>[];
          warnings.add('Added empty action history for v2 compatibility');
        }

        migrated['gameState'] = gameState;
      }

      // Update schema version
      migrated['schemaVersion'] = 2;
      if (migrated['metadata'] is Map<String, dynamic>) {
        final metadata = Map<String, dynamic>.from(migrated['metadata']);
        metadata['schemaVersion'] = 2;
        migrated['metadata'] = metadata;
      }

      return MigrationResult.success(migrated, warnings: warnings);
    } catch (e) {
      return MigrationResult.failure('v1->v2 migration failed: $e');
    }
  }

  /// Example migration stub for future v2 -> v3
  static MigrationResult _migrateToV3(Map<String, dynamic> data) {
    // Example: Add achievement tracking
    final migrated = Map<String, dynamic>.from(data);
    final warnings = <String>[];

    try {
      if (migrated['gameState'] is Map<String, dynamic>) {
        final gameState = Map<String, dynamic>.from(migrated['gameState']);

        // Add achievements if not present
        if (!gameState.containsKey('achievements')) {
          gameState['achievements'] = <String, dynamic>{
            'unlocked': <String>[],
            'progress': <String, dynamic>{},
          };
          warnings.add('Added empty achievements for v3 compatibility');
        }

        migrated['gameState'] = gameState;
      }

      // Update schema version
      migrated['schemaVersion'] = 3;
      if (migrated['metadata'] is Map<String, dynamic>) {
        final metadata = Map<String, dynamic>.from(migrated['metadata']);
        metadata['schemaVersion'] = 3;
        migrated['metadata'] = metadata;
      }

      return MigrationResult.success(migrated, warnings: warnings);
    } catch (e) {
      return MigrationResult.failure('v2->v3 migration failed: $e');
    }
  }

  /// Create a backup of data before migration
  static Map<String, dynamic> createBackup(Map<String, dynamic> data) {
    return Map<String, dynamic>.from(data);
  }
}
