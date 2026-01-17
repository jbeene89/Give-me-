# Save/Load + Versioned Persistence - Give (Me)

## Overview

Robust persistence layer for saving and loading game state with:
- Multiple save slots (3 regular + 1 autosave)
- Schema versioning and migration system
- Data integrity validation (checksums)
- Graceful error handling and recovery
- Corrupted save detection and fallback

## Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  # For getting app documents directory
  path_provider: ^2.1.0

  # Already included in Flutter SDK:
  # - dart:io (file operations)
  # - dart:convert (JSON serialization)
```

Install:
```bash
flutter pub add path_provider
```

## Architecture

### Core Components

1. **PersistenceService** (`persistence_service.dart`)
   - High-level API for save/load operations
   - Manages autosave and regular save slots
   - Main entry point for integration

2. **SaveSlotManager** (`storage/save_slot_manager.dart`)
   - Manages multiple save slots
   - Handles metadata caching
   - Coordinates with storage provider

3. **PersistenceProvider** (`storage/persistence_provider.dart`)
   - Abstract storage interface
   - File-based implementation included
   - Extensible to other backends (cloud, SharedPreferences, etc.)

4. **Schema Versioning** (`versioning/`)
   - Version tracking (currently v1)
   - Migration manager with stubs for future versions
   - Backward compatibility support

5. **Data Integrity** (`utils/checksum_util.dart`)
   - Checksum calculation for corruption detection
   - Automatic backup/restore on corruption

## Integration Guide

### Step 1: Initialize Persistence Service

```dart
import 'package:path_provider/path_provider.dart';
import 'package:give_me/dropzone/persistence/persistence_exports.dart';

class GameManager {
  late final PersistenceService _persistenceService;

  Future<void> initialize() async {
    // Get app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${appDir.path}/saves');

    // Create and initialize service
    _persistenceService = PersistenceService.createFile(saveDir.path);
    await _persistenceService.initialize();
  }
}
```

### Step 2: Create GameStateSnapshot from GameState

You'll need to create a snapshot of your GameState. Since we can't modify core files, create a helper:

```dart
import 'package:give_me/dropzone/persistence/persistence_exports.dart';

class GameStateSerializer {
  /// Convert GameState to snapshot
  static GameStateSnapshot createSnapshot(
    GameState gameState,
    EventEngine eventEngine,
    ScenarioModifiers modifiers,
  ) {
    return GameStateSnapshot(
      meterValues: {
        'stability': gameState.getMeter('stability').value,
        'capacity': gameState.getMeter('capacity').value,
        'reserves': gameState.getMeter('reserves').value,
        'clarity': gameState.getMeter('clarity').value,
        'morale': gameState.getMeter('morale').value,
        'efficiency': gameState.getMeter('efficiency').value,
      },
      resources: {
        'budget': gameState.getResource('budget'),
        'influence': gameState.getResource('influence'),
      },
      unlockedActions: gameState.getUnlockedActions(),
      currentTurn: gameState.currentTurn,
      activeModifiers: _serializeModifiers(modifiers),
      eventLog: _serializeEventLog(eventEngine.eventLog),
      delayedEffects: _serializeDelayedEffects(eventEngine),
      eventCooldowns: eventEngine.getEventCooldowns(),
      lastTurnEventIds: eventEngine.getLastTurnEventIds(),
      randomSeed: gameState.randomSeed,
    );
  }

  /// Restore GameState from snapshot
  static void restoreFromSnapshot(
    GameState gameState,
    EventEngine eventEngine,
    GameStateSnapshot snapshot,
  ) {
    // Restore meters
    snapshot.meterValues.forEach((meterId, value) {
      gameState.getMeter(meterId).value = value;
    });

    // Restore resources
    snapshot.resources.forEach((resourceId, amount) {
      gameState.setResource(resourceId, amount);
    });

    // Restore unlocked actions
    gameState.setUnlockedActions(snapshot.unlockedActions);

    // Restore turn
    gameState.currentTurn = snapshot.currentTurn;

    // Restore event engine state
    eventEngine.restoreState(
      eventLog: _deserializeEventLog(snapshot.eventLog),
      delayedEffects: _deserializeDelayedEffects(snapshot.delayedEffects),
      eventCooldowns: snapshot.eventCooldowns,
      lastTurnEventIds: snapshot.lastTurnEventIds,
    );

    // Restore random seed if provided
    if (snapshot.randomSeed != null) {
      gameState.randomSeed = snapshot.randomSeed;
    }
  }

  static Map<String, dynamic> _serializeModifiers(ScenarioModifiers modifiers) {
    return {
      'decayRateMultiplier': modifiers.decayRateMultiplier,
      'eventProbabilityMultiplier': modifiers.eventProbabilityMultiplier,
      'noiseMagnitudeMultiplier': modifiers.noiseMagnitudeMultiplier,
      'thresholdAdjustments': modifiers.thresholdAdjustments,
      'actionCostMultiplier': modifiers.actionCostMultiplier,
      'reserveDrainMultiplier': modifiers.reserveDrainMultiplier,
    };
  }

  static List<Map<String, dynamic>> _serializeEventLog(List<EventLogEntry> log) {
    return log.map((entry) => {
      'turnNumber': entry.turnNumber,
      'eventId': entry.eventId,
      'eventName': entry.eventName,
      'cause': entry.cause,
      'actualEffects': entry.actualEffects.map((e) => {
        'meterId': e.meterId,
        'delta': e.delta,
        'delayTurns': e.delayTurns,
      }).toList(),
      'perceivedEffects': entry.perceivedEffects.map((e) => {
        'meterId': e.meterId,
        'delta': e.delta,
        'delayTurns': e.delayTurns,
      }).toList(),
      'wasObscured': entry.wasObscured,
    }).toList();
  }

  static List<Map<String, dynamic>> _serializeDelayedEffects(EventEngine engine) {
    // Get delayed effects from engine
    return engine.getUpcomingDelayedEffects().map((effect) => {
      'meterId': effect.meterId,
      'delta': effect.delta,
      'delayTurns': effect.delayTurns,
    }).toList();
  }

  // ... implement deserialize methods similarly
}
```

### Step 3: Save Game

```dart
Future<void> saveGame(String slotId, String displayName) async {
  // Create snapshot
  final snapshot = GameStateSerializer.createSnapshot(
    gameState,
    eventEngine,
    activeModifiers,
  );

  // Save
  final result = await _persistenceService.saveGame(
    slotId: slotId,
    displayName: displayName,
    scenarioId: currentScenario.id,
    difficultyId: currentDifficulty.id,
    gameState: snapshot,
    note: 'Turn ${snapshot.currentTurn}',
  );

  if (result.success) {
    print('Game saved successfully!');
    for (final warning in result.warnings) {
      print('Warning: $warning');
    }
  } else {
    print('Save failed: ${result.errorMessage}');
    // Show error to user
  }
}

// Autosave
Future<void> autoSave() async {
  final snapshot = GameStateSerializer.createSnapshot(
    gameState,
    eventEngine,
    activeModifiers,
  );

  await _persistenceService.quickSave(
    scenarioId: currentScenario.id,
    difficultyId: currentDifficulty.id,
    gameState: snapshot,
  );
}
```

### Step 4: Load Game

```dart
Future<void> loadGame(String slotId) async {
  final result = await _persistenceService.loadGame(slotId);

  if (!result.success) {
    print('Load failed: ${result.errorMessage}');
    // Show error, offer to delete corrupted save
    return;
  }

  // Check for warnings (migration, checksum issues, etc.)
  for (final warning in result.warnings) {
    print('Warning: $warning');
    // Optionally show to user
  }

  // Restore game state
  final saveData = result.data!;

  // Load scenario and difficulty
  currentScenario = ScenarioCatalog.getScenarioById(saveData.metadata.scenarioId);
  currentDifficulty = DifficultyCatalog.getProfileById(saveData.metadata.difficultyId);

  // Restore game state from snapshot
  GameStateSerializer.restoreFromSnapshot(
    gameState,
    eventEngine,
    saveData.gameState,
  );

  print('Game loaded: Turn ${saveData.metadata.turnNumber}');
}
```

### Step 5: List Saves (for UI)

```dart
Future<List<SaveMetadata>> getSaveList() async {
  return await _persistenceService.getAllSaves();
}

// Display in UI
Widget buildSaveList() {
  return FutureBuilder<List<SaveMetadata>>(
    future: getSaveList(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();

      final saves = snapshot.data!;
      return ListView(
        children: saves.map((metadata) {
          return ListTile(
            title: Text(metadata.displayName),
            subtitle: Text(
              'Turn ${metadata.turnNumber} - ${metadata.timestamp.toLocal()}',
            ),
            trailing: metadata.isValid
                ? Icon(Icons.check, color: Colors.green)
                : Icon(Icons.warning, color: Colors.red),
            onTap: () => loadGame(metadata.slotId),
          );
        }).toList(),
      );
    },
  );
}
```

### Step 6: Autosave Integration

```dart
class TurnEngine {
  final PersistenceService _persistence;

  Future<void> advanceTurn() async {
    // ... normal turn logic

    // Autosave every N turns
    if (currentTurn % 5 == 0) {
      await _autoSave();
    }
  }

  Future<void> _autoSave() async {
    final snapshot = GameStateSerializer.createSnapshot(
      gameState,
      eventEngine,
      activeModifiers,
    );

    await _persistence.quickSave(
      scenarioId: currentScenario.id,
      difficultyId: currentDifficulty.id,
      gameState: snapshot,
    );
  }
}
```

## Error Handling and Recovery

### Corrupted Save Detection

The system detects corruption via:
1. **JSON validation**: File must be valid JSON
2. **Checksum verification**: Data integrity check
3. **Schema validation**: Required fields present
4. **Value range validation**: Meters in 0.0-1.0, etc.

### Recovery Mechanisms

1. **Automatic Backup**
   - Before overwriting, creates `.backup` file
   - Restored automatically if main file corrupted

2. **Graceful Degradation**
   ```dart
   final result = await loadGame('slot_1');
   if (!result.success) {
     // Try autosave as fallback
     final autosaveResult = await loadAutosave();
     if (autosaveResult.success) {
       showWarning('Main save corrupted, loaded from autosave');
     } else {
       // Offer to start new game
       showError('All saves corrupted. Start new game?');
     }
   }
   ```

3. **Safe Defaults**
   ```dart
   // If load fails catastrophically, return to main menu
   try {
     await loadGame(slotId);
   } catch (e) {
     log.error('Load failed catastrophically: $e');
     navigateToMainMenu();
     showError('Failed to load save. Please try another save or start new game.');
   }
   ```

### Migration Safety

```dart
final result = await loadGame('old_save');

if (result.warnings.isNotEmpty) {
  // Warn user about migration
  showDialog(
    title: 'Save File Updated',
    content: 'This save was from an older version and has been updated:\n' +
        result.warnings.join('\n'),
    actions: [
      'Continue' -> proceedWithLoad(),
      'Cancel' -> return,
    ],
  );
}
```

## Schema Versioning

### Current Version: 1

```dart
SchemaVersion.current // = 1
```

### Adding New Version

When game state structure changes:

1. **Increment version** in `schema_version.dart`:
   ```dart
   static const int current = 2;
   ```

2. **Add changelog**:
   ```dart
   static const Map<int, String> changelog = {
     1: 'Initial schema',
     2: 'Added action history tracking',
   };
   ```

3. **Implement migration** in `migration_manager.dart`:
   ```dart
   static MigrationResult _migrateToV2(Map<String, dynamic> data) {
     final migrated = Map<String, dynamic>.from(data);

     // Add new field with default value
     if (migrated['gameState'] is Map) {
       final gameState = Map.from(migrated['gameState']);
       gameState['actionHistory'] = [];
       migrated['gameState'] = gameState;
     }

     // Update version
     migrated['schemaVersion'] = 2;

     return MigrationResult.success(migrated);
   }
   ```

4. **Update switch statement**:
   ```dart
   static MigrationResult _applyMigration(data, toVersion) {
     switch (toVersion) {
       case 1: return MigrationResult.success(data);
       case 2: return _migrateToV2(data);
       default: return MigrationResult.failure('...');
     }
   }
   ```

### Migration Flow

```
Load v1 save → Detect old version → Create backup →
Apply v1→v2 migration → Apply v2→v3 migration (if needed) →
Validate → Return with warnings
```

## Storage Details

### File Structure

```
<app_documents>/saves/
├── save_slot_1.json          # Regular save slot 1
├── save_slot_1.json.backup   # Automatic backup
├── save_slot_2.json          # Regular save slot 2
├── save_slot_2.json.backup
├── save_slot_3.json          # Regular save slot 3
├── save_slot_3.json.backup
├── save_autosave.json        # Autosave
└── save_autosave.json.backup
```

### Save File Format (v1)

```json
{
  "schemaVersion": 1,
  "metadata": {
    "slotId": "slot_1",
    "displayName": "My Save",
    "scenarioId": "baseline",
    "difficultyId": "standard",
    "turnNumber": 42,
    "timestamp": "2026-01-17T12:34:56.789Z",
    "schemaVersion": 1,
    "note": "Turn 42",
    "isValid": true,
    "checksum": "a1b2c3d4"
  },
  "gameState": {
    "meterValues": {
      "stability": 0.45,
      "capacity": 0.60,
      "reserves": 0.30,
      "clarity": 0.50,
      "morale": 0.55,
      "efficiency": 0.40
    },
    "resources": {
      "budget": 85,
      "influence": 42
    },
    "unlockedActions": ["stabilize", "allocate_reserves", ...],
    "currentTurn": 42,
    "activeModifiers": { ... },
    "eventLog": [ ... ],
    "delayedEffects": [ ... ],
    "eventCooldowns": { ... },
    "lastTurnEventIds": [ ... ],
    "randomSeed": 12345,
    "customData": {}
  }
}
```

## Best Practices

### When to Save

1. **Manual save**: When player explicitly saves
2. **Autosave**:
   - Every N turns (e.g., 5 turns)
   - Before major decisions
   - After significant events
3. **On quit**: Save to autosave slot when app closes

### When to Load

1. **Continue**: Load autosave at app start
2. **Load game**: Player selects from save list
3. **Recovery**: Load autosave if main save corrupted

### Validation

Always validate after load:
```dart
final result = await loadGame(slotId);
if (result.success && result.data!.validate()) {
  // Safe to use
} else {
  // Handle error
}
```

### User Feedback

```dart
// Show save result to user
final result = await saveGame(...);
if (result.success) {
  showSnackbar('Game saved!');
  if (result.warnings.isNotEmpty) {
    log.warning(result.warnings.join(', '));
  }
} else {
  showError('Save failed: ${result.errorMessage}');
}
```

## Testing

### Test Save/Load Cycle

```dart
test('Save and load preserves game state', () async {
  final service = PersistenceService.createFile(tempDir.path);
  await service.initialize();

  // Create test snapshot
  final snapshot = GameStateSnapshot(
    meterValues: {'stability': 0.5, ...},
    resources: {'budget': 100},
    currentTurn: 10,
    // ... other fields
  );

  // Save
  final saveResult = await service.saveGame(
    slotId: 'test',
    displayName: 'Test',
    scenarioId: 'baseline',
    difficultyId: 'standard',
    gameState: snapshot,
  );

  expect(saveResult.success, true);

  // Load
  final loadResult = await service.loadGame('test');

  expect(loadResult.success, true);
  expect(loadResult.data!.gameState.currentTurn, 10);
  expect(loadResult.data!.gameState.meterValues['stability'], 0.5);
});
```

### Test Corruption Recovery

```dart
test('Recovers from corrupted save', () async {
  // Create valid save
  await service.saveGame(...);

  // Corrupt the file
  final file = File('$saveDir/save_test.json');
  await file.writeAsString('invalid json{{{');

  // Load should recover from backup
  final result = await service.loadGame('test');

  expect(result.success, true);
  expect(result.warnings, contains('Restored from backup'));
});
```

### Test Migration

```dart
test('Migrates v1 to v2', () async {
  // Create v1 save file manually
  final v1Data = {
    'schemaVersion': 1,
    'metadata': {...},
    'gameState': {...},
  };

  // Write to file
  final file = File('$saveDir/save_test.json');
  await file.writeAsString(json.encode(v1Data));

  // Load (should trigger migration)
  final result = await service.loadGame('test');

  expect(result.success, true);
  expect(result.data!.schemaVersion, SchemaVersion.current);
  expect(result.warnings, contains('migrated'));
});
```

## Troubleshooting

### "PersistenceService not initialized"
- Call `await service.initialize()` before use

### "Save file corrupted"
- Check if backup exists (`.backup` file)
- Try loading autosave
- Offer to delete corrupted save

### "Version not supported"
- Save is too old (< minimum supported)
- Save is too new (app needs update)
- Display clear message to user

### "Storage permission denied" (mobile)
- Ensure app has storage permissions
- `path_provider` should handle this automatically for app documents

## Advanced Usage

### Custom Storage Backend

```dart
class CloudPersistenceProvider implements PersistenceProvider {
  @override
  Future<bool> save(String slotId, String data) async {
    // Upload to cloud storage
  }

  // ... implement other methods
}

final service = PersistenceService(
  SaveSlotManager(CloudPersistenceProvider())
);
```

### Compression

For large save files:
```dart
import 'dart:io';

Future<bool> saveCompressed(String slotId, String data) async {
  final compressed = gzip.encode(utf8.encode(data));
  // Write compressed bytes
}
```

### Encryption

For sensitive data:
```dart
import 'package:encrypt/encrypt.dart';

Future<bool> saveEncrypted(String slotId, String data) async {
  final encrypted = encrypter.encrypt(data);
  // Write encrypted string
}
```

## Summary

- **3 save slots + autosave**: Ample storage for player saves
- **Checksum validation**: Detects corruption automatically
- **Automatic backup**: Transparent recovery mechanism
- **Schema versioning**: Future-proof for game updates
- **Graceful errors**: Never loses player progress silently
- **Migration stubs**: Easy to add new versions

This persistence layer provides robust, production-ready save/load functionality while maintaining separation from core game files.
