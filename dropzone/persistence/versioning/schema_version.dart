/// Schema version constants and utilities
class SchemaVersion {
  /// Current schema version
  static const int current = 1;

  /// Minimum supported schema version (for backwards compatibility)
  static const int minimumSupported = 1;

  /// Version history and changelog
  static const Map<int, String> changelog = {
    1: 'Initial schema: meters, resources, event log, modifiers',
    // Future versions:
    // 2: 'Added action history tracking',
    // 3: 'Added achievement progress',
  };

  /// Check if a version is supported
  static bool isSupported(int version) {
    return version >= minimumSupported && version <= current;
  }

  /// Check if migration is needed
  static bool needsMigration(int fromVersion) {
    return fromVersion < current;
  }

  /// Get changelog for a specific version
  static String? getChangelog(int version) {
    return changelog[version];
  }

  /// Get all versions that need migration from a given version
  static List<int> getMigrationPath(int fromVersion) {
    if (!isSupported(fromVersion)) {
      throw UnsupportedError('Version $fromVersion is not supported');
    }

    final path = <int>[];
    for (int v = fromVersion + 1; v <= current; v++) {
      path.add(v);
    }
    return path;
  }
}
