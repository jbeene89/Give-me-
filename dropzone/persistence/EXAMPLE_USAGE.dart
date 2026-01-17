/// Example usage of the Persistence system
/// Demonstrates save/load operations, error handling, and migration

import 'dart:io';
import 'persistence_exports.dart';

void main() async {
  print('=== Persistence System Examples ===\n');

  // Setup temporary directory for examples
  final tempDir = Directory.systemTemp.createTempSync('give_me_saves');

  try {
    await exampleBasicSaveLoad(tempDir);
    print('\n---\n');

    await exampleMultipleSaveSlots(tempDir);
    print('\n---\n');

    await exampleAutosave(tempDir);
    print('\n---\n');

    await exampleCorruptionRecovery(tempDir);
    print('\n---\n');

    await exampleMigration(tempDir);
    print('\n---\n');

    exampleMetadataListing(tempDir);
  } finally {
    // Cleanup
    tempDir.deleteSync(recursive: true);
  }
}

/// Example 1: Basic save and load
Future<void> exampleBasicSaveLoad(Directory tempDir) async {
  print('Example 1: Basic Save and Load\n');

  // Create service
  final service = PersistenceService.createFile(tempDir.path);
  await service.initialize();

  // Create a game state snapshot
  final snapshot = GameStateSnapshot(
    meterValues: {
      'stability': 0.45,
      'capacity': 0.60,
      'reserves': 0.30,
      'clarity': 0.50,
      'morale': 0.55,
      'efficiency': 0.40,
    },
    resources: {
      'budget': 85,
      'influence': 42,
    },
    unlockedActions: ['stabilize', 'allocate_reserves', 'improve_clarity'],
    currentTurn: 42,
    activeModifiers: {
      'decayRateMultiplier': 1.0,
      'eventProbabilityMultiplier': 1.0,
    },
    eventLog: [],
    delayedEffects: [],
    eventCooldowns: {},
    lastTurnEventIds: [],
    randomSeed: 12345,
  );

  // Save game
  final saveResult = await service.saveGame(
    slotId: 'slot_1',
    displayName: 'My First Save',
    scenarioId: 'baseline',
    difficultyId: 'standard',
    gameState: snapshot,
    note: 'Turn 42 - looking good!',
  );

  if (saveResult.success) {
    print('✓ Game saved successfully to slot_1');
  } else {
    print('✗ Save failed: ${saveResult.errorMessage}');
    return;
  }

  // Load game
  final loadResult = await service.loadGame('slot_1');

  if (loadResult.success) {
    print('✓ Game loaded successfully from slot_1');
    final loaded = loadResult.data!;
    print('  Scenario: ${loaded.metadata.scenarioId}');
    print('  Difficulty: ${loaded.metadata.difficultyId}');
    print('  Turn: ${loaded.metadata.turnNumber}');
    print('  Timestamp: ${loaded.metadata.timestamp.toLocal()}');
    print('  Stability: ${(loaded.gameState.meterValues['stability']! * 100).toStringAsFixed(0)}%');
    print('  Budget: ${loaded.gameState.resources['budget']}');
  } else {
    print('✗ Load failed: ${loadResult.errorMessage}');
  }
}

/// Example 2: Multiple save slots
Future<void> exampleMultipleSaveSlots(Directory tempDir) async {
  print('Example 2: Multiple Save Slots\n');

  final service = PersistenceService.createFile(tempDir.path);
  await service.initialize();

  // Create 3 different saves
  for (int i = 1; i <= 3; i++) {
    final snapshot = GameStateSnapshot(
      meterValues: {
        'stability': 0.5 + (i * 0.1),
        'capacity': 0.5,
        'reserves': 0.5,
        'clarity': 0.5,
        'morale': 0.5,
        'efficiency': 0.5,
      },
      resources: {'budget': 100, 'influence': 50},
      unlockedActions: [],
      currentTurn: i * 10,
      activeModifiers: {},
      eventLog: [],
      delayedEffects: [],
      eventCooldowns: {},
      lastTurnEventIds: [],
    );

    await service.saveGame(
      slotId: 'slot_$i',
      displayName: 'Save $i',
      scenarioId: 'baseline',
      difficultyId: 'standard',
      gameState: snapshot,
    );

    print('✓ Saved to slot_$i (Turn ${i * 10})');
  }

  // List all saves
  final saves = await service.getAllSaves();
  print('\nAll saves (${saves.length} total):');
  for (final save in saves) {
    print('  ${save.slotId}: ${save.displayName} - Turn ${save.turnNumber}');
  }

  // Load specific save
  final loadResult = await service.loadGame('slot_2');
  if (loadResult.success) {
    print('\nLoaded slot_2:');
    print('  Turn: ${loadResult.data!.metadata.turnNumber}');
  }
}

/// Example 3: Autosave functionality
Future<void> exampleAutosave(Directory tempDir) async {
  print('Example 3: Autosave\n');

  final service = PersistenceService.createFile(tempDir.path);
  await service.initialize();

  // Simulate game progression with autosaves
  for (int turn = 1; turn <= 15; turn++) {
    // Every 5 turns, autosave
    if (turn % 5 == 0) {
      final snapshot = GameStateSnapshot(
        meterValues: {
          'stability': 0.5 - (turn * 0.01),
          'capacity': 0.5,
          'reserves': 0.5,
          'clarity': 0.5,
          'morale': 0.5,
          'efficiency': 0.5,
        },
        resources: {'budget': 100 - turn, 'influence': 50},
        unlockedActions: [],
        currentTurn: turn,
        activeModifiers: {},
        eventLog: [],
        delayedEffects: [],
        eventCooldowns: {},
        lastTurnEventIds: [],
      );

      await service.quickSave(
        scenarioId: 'baseline',
        difficultyId: 'standard',
        gameState: snapshot,
      );

      print('Turn $turn: Autosaved');
    }
  }

  // Check if autosave exists
  final hasAutosave = await service.hasAutosave();
  print('\nHas autosave: $hasAutosave');

  // Load autosave
  if (hasAutosave) {
    final loadResult = await service.loadAutosave();
    if (loadResult.success) {
      print('Loaded autosave from turn ${loadResult.data!.metadata.turnNumber}');
    }
  }
}

/// Example 4: Corruption recovery
Future<void> exampleCorruptionRecovery(Directory tempDir) async {
  print('Example 4: Corruption Recovery\n');

  final service = PersistenceService.createFile(tempDir.path);
  await service.initialize();

  // Create a valid save
  final snapshot = GameStateSnapshot(
    meterValues: {'stability': 0.5, 'capacity': 0.5, 'reserves': 0.5,
                  'clarity': 0.5, 'morale': 0.5, 'efficiency': 0.5},
    resources: {'budget': 100, 'influence': 50},
    unlockedActions: [],
    currentTurn: 10,
    activeModifiers: {},
    eventLog: [],
    delayedEffects: [],
    eventCooldowns: {},
    lastTurnEventIds: [],
  );

  await service.saveGame(
    slotId: 'test_corruption',
    displayName: 'Corruption Test',
    scenarioId: 'baseline',
    difficultyId: 'standard',
    gameState: snapshot,
  );

  print('✓ Created valid save');

  // Corrupt the file
  final saveFile = File('${tempDir.path}/save_test_corruption.json');
  await saveFile.writeAsString('{ invalid json !!!');
  print('✗ Corrupted save file');

  // Try to load (should recover from backup)
  final loadResult = await service.loadGame('test_corruption');

  if (loadResult.success) {
    print('✓ Recovered from backup!');
    if (loadResult.warnings.isNotEmpty) {
      print('  Warnings:');
      for (final warning in loadResult.warnings) {
        print('    - $warning');
      }
    }
  } else {
    print('✗ Recovery failed: ${loadResult.errorMessage}');
  }
}

/// Example 5: Schema migration
Future<void> exampleMigration(Directory tempDir) async {
  print('Example 5: Schema Migration (Simulated)\n');

  print('Current schema version: ${SchemaVersion.current}');
  print('Minimum supported: ${SchemaVersion.minimumSupported}');
  print('');

  // Check if migration would be needed
  final oldVersion = 1;
  if (SchemaVersion.needsMigration(oldVersion)) {
    final path = SchemaVersion.getMigrationPath(oldVersion);
    print('Migration path from v$oldVersion: ${path.join(" → ")}');
    print('');
  }

  // Simulate loading an old save
  print('Simulating load of v1 save...');
  print('(In real usage, this would automatically migrate to v${SchemaVersion.current})');
  print('');

  // Show changelog
  print('Version changelog:');
  SchemaVersion.changelog.forEach((version, changes) {
    print('  v$version: $changes');
  });
}

/// Example 6: Metadata listing
void exampleMetadataListing(Directory tempDir) {
  print('Example 6: Save Metadata\n');

  // Create sample metadata
  final metadata = SaveMetadata(
    slotId: 'slot_1',
    displayName: 'Epic Run',
    scenarioId: 'hardline_city',
    difficultyId: 'unforgiving',
    turnNumber: 73,
    timestamp: DateTime.now(),
    schemaVersion: 1,
    note: 'Barely surviving!',
    isValid: true,
    checksum: 'a1b2c3d4',
  );

  print('Save Metadata:');
  print('  Slot: ${metadata.slotId}');
  print('  Name: ${metadata.displayName}');
  print('  Scenario: ${metadata.scenarioId}');
  print('  Difficulty: ${metadata.difficultyId}');
  print('  Turn: ${metadata.turnNumber}');
  print('  Saved: ${metadata.timestamp.toLocal()}');
  print('  Note: ${metadata.note}');
  print('  Valid: ${metadata.isValid ? "Yes" : "No"}');
  print('  Checksum: ${metadata.checksum}');
}

/// Example 7: Error handling patterns
void exampleErrorHandling() {
  print('Example 7: Error Handling Patterns\n');

  print('''
// Pattern 1: Try main save, fallback to autosave
final result = await service.loadGame('slot_1');
if (!result.success) {
  final autosave = await service.loadAutosave();
  if (autosave.success) {
    showWarning('Main save corrupted, loaded autosave');
    return autosave.data;
  }
  throw Exception('All saves corrupted');
}

// Pattern 2: Save with validation
final saveResult = await service.saveGame(...);
if (!saveResult.success) {
  showError('Failed to save: \${saveResult.errorMessage}');
  return;
}
if (saveResult.warnings.isNotEmpty) {
  log.warning(saveResult.warnings.join(', '));
}

// Pattern 3: Load with migration warnings
final loadResult = await service.loadGame(slotId);
if (loadResult.warnings.isNotEmpty) {
  showDialog(
    'Save Updated',
    'This save was migrated from an older version.',
  );
}

// Pattern 4: Delete with confirmation
if (await confirmDelete()) {
  final deleteResult = await service.deleteSave(slotId);
  if (deleteResult.success) {
    showSuccess('Save deleted');
  }
}
''');
}

/// Example 8: Integration with game loop
void exampleGameLoopIntegration() {
  print('Example 8: Game Loop Integration\n');

  print('''
class GameManager {
  late final PersistenceService _persistence;

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('\${appDir.path}/saves');

    _persistence = PersistenceService.createFile(saveDir.path);
    await _persistence.initialize();
  }

  // Called every turn
  Future<void> onTurnEnd() async {
    currentTurn++;

    // Autosave every 5 turns
    if (currentTurn % 5 == 0) {
      await _autoSave();
    }
  }

  Future<void> _autoSave() async {
    final snapshot = _createSnapshot();
    await _persistence.quickSave(
      scenarioId: currentScenario.id,
      difficultyId: currentDifficulty.id,
      gameState: snapshot,
    );
  }

  Future<void> saveGame(String displayName) async {
    final snapshot = _createSnapshot();
    final result = await _persistence.saveToNextSlot(
      scenarioId: currentScenario.id,
      difficultyId: currentDifficulty.id,
      gameState: snapshot,
      displayName: displayName,
    );

    if (result.success) {
      showNotification('Game saved!');
    } else {
      showError('Save failed: \${result.errorMessage}');
    }
  }

  Future<void> loadGame(String slotId) async {
    final result = await _persistence.loadGame(slotId);

    if (!result.success) {
      showError('Load failed: \${result.errorMessage}');
      return;
    }

    _restoreFromSnapshot(result.data!);

    if (result.warnings.isNotEmpty) {
      log.warning('Load warnings: \${result.warnings.join(", ")}');
    }
  }

  GameStateSnapshot _createSnapshot() {
    return GameStateSnapshot(
      meterValues: _collectMeterValues(),
      resources: _collectResources(),
      unlockedActions: _getUnlockedActions(),
      currentTurn: currentTurn,
      activeModifiers: _serializeModifiers(),
      eventLog: _serializeEventLog(),
      delayedEffects: _serializeDelayedEffects(),
      eventCooldowns: _getEventCooldowns(),
      lastTurnEventIds: _getLastTurnEventIds(),
      randomSeed: randomSeed,
    );
  }

  void _restoreFromSnapshot(SaveData saveData) {
    final snapshot = saveData.gameState;

    // Restore meters
    snapshot.meterValues.forEach((id, value) {
      gameState.getMeter(id).value = value;
    });

    // Restore resources
    snapshot.resources.forEach((id, amount) {
      gameState.setResource(id, amount);
    });

    // Restore other state...
    currentTurn = snapshot.currentTurn;
    randomSeed = snapshot.randomSeed;

    // Restore event engine state
    eventEngine.restore(
      eventLog: snapshot.eventLog,
      delayedEffects: snapshot.delayedEffects,
      eventCooldowns: snapshot.eventCooldowns,
      lastTurnEventIds: snapshot.lastTurnEventIds,
    );
  }
}
''');
}
