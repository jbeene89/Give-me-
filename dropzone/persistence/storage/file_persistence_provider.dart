import 'dart:io';
import 'dart:convert';
import 'persistence_provider.dart';

/// File-based persistence provider
/// Requires path_provider package to get app documents directory
class FilePersistenceProvider implements PersistenceProvider {
  final Directory _saveDirectory;
  static const String _fileExtension = '.json';
  static const String _savePrefix = 'save_';

  FilePersistenceProvider(this._saveDirectory);

  /// Create provider with a specific directory
  /// In a real app, use path_provider to get app documents directory:
  ///
  /// ```dart
  /// final appDir = await getApplicationDocumentsDirectory();
  /// final saveDir = Directory('${appDir.path}/saves');
  /// final provider = FilePersistenceProvider(saveDir);
  /// await provider.initialize();
  /// ```
  factory FilePersistenceProvider.create(String directoryPath) {
    return FilePersistenceProvider(Directory(directoryPath));
  }

  @override
  Future<void> initialize() async {
    try {
      if (!await _saveDirectory.exists()) {
        await _saveDirectory.create(recursive: true);
      }
    } catch (e) {
      throw PersistenceException('Failed to initialize save directory: $e');
    }
  }

  @override
  Future<bool> save(String slotId, String data) async {
    try {
      final file = _getFileForSlot(slotId);

      // Create backup of existing file if it exists
      if (await file.exists()) {
        final backupFile = File('${file.path}.backup');
        await file.copy(backupFile.path);
      }

      // Write new data
      await file.writeAsString(data, flush: true);

      // Verify write was successful
      final written = await file.readAsString();
      if (written != data) {
        throw PersistenceException('Data verification failed after write');
      }

      return true;
    } catch (e) {
      throw PersistenceException('Failed to save to slot $slotId: $e');
    }
  }

  @override
  Future<String?> load(String slotId) async {
    try {
      final file = _getFileForSlot(slotId);

      if (!await file.exists()) {
        return null;
      }

      final data = await file.readAsString();

      // Validate it's valid JSON
      try {
        json.decode(data);
      } catch (_) {
        // Corrupted, try backup
        return await _loadFromBackup(slotId);
      }

      return data;
    } catch (e) {
      throw PersistenceException('Failed to load from slot $slotId: $e');
    }
  }

  @override
  Future<bool> delete(String slotId) async {
    try {
      final file = _getFileForSlot(slotId);

      if (await file.exists()) {
        await file.delete();
      }

      // Also delete backup if exists
      final backupFile = File('${file.path}.backup');
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      return true;
    } catch (e) {
      throw PersistenceException('Failed to delete slot $slotId: $e');
    }
  }

  @override
  Future<bool> exists(String slotId) async {
    final file = _getFileForSlot(slotId);
    return await file.exists();
  }

  @override
  Future<List<String>> listSlots() async {
    try {
      if (!await _saveDirectory.exists()) {
        return [];
      }

      final files = await _saveDirectory.list().toList();
      final slotIds = <String>[];

      for (final entity in files) {
        if (entity is File) {
          final name = entity.uri.pathSegments.last;
          if (name.startsWith(_savePrefix) && name.endsWith(_fileExtension)) {
            // Extract slot ID from filename
            final slotId = name
                .substring(_savePrefix.length)
                .replaceAll(_fileExtension, '');
            slotIds.add(slotId);
          }
        }
      }

      return slotIds;
    } catch (e) {
      throw PersistenceException('Failed to list save slots: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      if (await _saveDirectory.exists()) {
        await _saveDirectory.delete(recursive: true);
        await initialize(); // Recreate empty directory
      }
    } catch (e) {
      throw PersistenceException('Failed to clear all saves: $e');
    }
  }

  @override
  String getStorageInfo() {
    return 'File storage: ${_saveDirectory.path}';
  }

  /// Get file for a specific slot
  File _getFileForSlot(String slotId) {
    final filename = '$_savePrefix$slotId$_fileExtension';
    return File('${_saveDirectory.path}/$filename');
  }

  /// Try to load from backup file
  Future<String?> _loadFromBackup(String slotId) async {
    try {
      final file = _getFileForSlot(slotId);
      final backupFile = File('${file.path}.backup');

      if (!await backupFile.exists()) {
        return null;
      }

      final data = await backupFile.readAsString();

      // Validate backup JSON
      json.decode(data);

      // Restore from backup
      await backupFile.copy(file.path);

      return data;
    } catch (_) {
      return null;
    }
  }
}

/// Exception thrown by persistence operations
class PersistenceException implements Exception {
  final String message;

  PersistenceException(this.message);

  @override
  String toString() => 'PersistenceException: $message';
}
