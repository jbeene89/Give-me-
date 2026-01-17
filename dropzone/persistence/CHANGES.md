# Save/Load + Versioned Persistence - Changes and Assumptions

## What Was Added

### Core Features

1. **Save/Load System**
   - Multiple save slots (3 regular + 1 autosave)
   - Complete game state serialization
   - Metadata tracking (scenario, difficulty, turn, timestamp)
   - Quick save/load functionality
   - Next available slot detection

2. **Data Integrity**
   - Checksum calculation and verification (DJB2 hash)
   - Automatic backup before overwrite
   - Corrupted save detection
   - Backup restoration on corruption
   - JSON validation

3. **Schema Versioning**
   - Version tracking (current: v1)
   - Migration manager with sequential migration path
   - Backward compatibility (minimum supported version)
   - Migration stubs for v1→v2, v2→v3
   - Version changelog tracking

4. **Error Handling**
   - Graceful failure modes
   - Detailed error messages
   - Warning system for non-fatal issues
   - Safe default fallbacks
   - Try-catch throughout

5. **Storage Abstraction**
   - `PersistenceProvider` interface
   - File-based implementation
   - Extensible to other backends (cloud, SharedPreferences)
   - Automatic backup file management

### File Structure

```
dropzone/persistence/
├── models/
│   ├── save_metadata.dart         # Metadata (scenario, turn, timestamp)
│   ├── game_state_snapshot.dart   # Serializable GameState
│   └── save_data.dart             # Complete save (metadata + state)
├── storage/
│   ├── persistence_provider.dart  # Abstract storage interface
│   ├── file_persistence_provider.dart  # File-based implementation
│   └── save_slot_manager.dart     # Manages multiple slots
├── versioning/
│   ├── schema_version.dart        # Version constants and utilities
│   └── migration_manager.dart     # Handles v1→v2, v2→v3, etc.
├── utils/
│   └── checksum_util.dart         # Data integrity validation
├── persistence_service.dart       # High-level API
├── persistence_exports.dart       # Public exports
├── README.md                      # Integration guide
└── CHANGES.md                     # This file
```

## Implementation Details

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
    "note": "Optional note",
    "isValid": true,
    "checksum": "a1b2c3d4"
  },
  "gameState": {
    "meterValues": { "stability": 0.45, ... },
    "resources": { "budget": 100, ... },
    "unlockedActions": ["action1", "action2"],
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

### Checksum Algorithm

Uses DJB2 hash variant:
- Simple, fast, non-cryptographic
- Good distribution for corruption detection
- Deterministic (same data = same checksum)
- 32-bit hash for reasonable collision resistance

Not secure against malicious tampering, but detects accidental corruption.

### Storage Strategy

**File-based storage:**
- Each save slot = separate JSON file
- Filename: `save_<slotId>.json`
- Backup: `save_<slotId>.json.backup`
- Location: `<app_documents>/saves/`

**Advantages:**
- Simple to implement
- Human-readable (JSON)
- Easy to debug
- Works offline
- No external dependencies

**Limitations:**
- No cloud sync (but extensible)
- Larger file size than binary
- File I/O overhead

### Migration Strategy

**Sequential migrations:**
```
v1 → v2 → v3 → ... → current
```

Each migration step:
1. Create backup
2. Apply transformation
3. Update version number
4. Validate result
5. Return with warnings

**Migration stubs included for:**
- v1 → v2: Add action history tracking (example)
- v2 → v3: Add achievements (example)

### Error Recovery Hierarchy

```
1. Try to load main save file
   ↓ (corruption detected)
2. Try to load .backup file
   ↓ (backup also corrupted)
3. Return LoadResult.failure with error
   ↓ (caller handles)
4. Try autosave as fallback
   ↓ (autosave also corrupted)
5. Offer to start new game
```

## Assumptions Made

### GameState Assumptions

- **Meters exist:**
  - `stability`, `capacity`, `reserves`, `clarity`, `morale`, `efficiency`
  - All normalized 0.0-1.0

- **Resources exist:**
  - `budget` and `influence` (minimum)
  - Integer values
  - Non-negative

- **Actions:**
  - Have string IDs
  - Can be locked/unlocked
  - List of unlocked actions can be stored

- **Turn tracking:**
  - Integer turn counter
  - Can be saved and restored

- **Random seed:**
  - Optional integer seed for reproducibility
  - Can be null

### EventEngine Assumptions

- **Event log:**
  - List of `EventLogEntry` objects
  - Can be serialized to JSON
  - Contains: turn, event ID, name, cause, effects

- **Delayed effects:**
  - Queue of future effects
  - Can be serialized and restored
  - Contains: meter ID, delta, delay turns

- **Event cooldowns:**
  - Map of event ID → turn number
  - Tracks when events can retrigger

- **Last turn events:**
  - List of event IDs from previous turn
  - For compound event tracking

### Scenario System Assumptions

- **Scenario IDs:**
  - String identifiers (e.g., "baseline", "hardline_city")
  - Can be looked up from catalog

- **Difficulty IDs:**
  - String identifiers (e.g., "standard", "unforgiving")
  - Can be looked up from catalog

- **Modifiers:**
  - Can be serialized as JSON
  - Contains multipliers and adjustments
  - Can be restored from JSON

### Storage Assumptions

- **File system access:**
  - App has permission to write to documents directory
  - `path_provider` package available
  - Sufficient storage space

- **File operations:**
  - Atomic writes (or close enough)
  - File.copy() creates backup reliably
  - Flush ensures data written to disk

### Integration Assumptions

- **Core files not modified:**
  - Did not edit `game_state.dart`, `meter.dart`, `turn_engine.dart`
  - Integration happens via helper class (`GameStateSerializer`)

- **TurnEngine integration:**
  - TurnEngine will create snapshots
  - TurnEngine will restore from snapshots
  - TurnEngine owns GameState and EventEngine

- **UI integration:**
  - UI will call PersistenceService methods
  - UI will display SaveMetadata in save/load screens
  - UI will handle error messages and warnings

## What Was Intentionally NOT Implemented

### Out of Scope

1. **UI Components**
   - No Flutter widgets for save/load screens
   - No save slot selection UI
   - No confirmation dialogs
   - Integration examples only

2. **Cloud Sync**
   - No cloud storage backend
   - No multi-device sync
   - No conflict resolution
   - File-based only (but extensible via `PersistenceProvider`)

3. **Compression**
   - No GZIP or other compression
   - Saves are plain JSON
   - Could add compression layer in provider

4. **Encryption**
   - No data encryption
   - Saves are plain text
   - Could add encryption layer if needed

5. **Automatic Backup Management**
   - No cleanup of old backups
   - No multiple backup versions (only .backup)
   - Manual cleanup required

6. **Save Thumbnails**
   - No screenshot or preview images
   - Metadata only
   - Could add as custom data

7. **Save Sharing**
   - No export/import functionality
   - No save file sharing between users
   - Local saves only

8. **Undo/Redo**
   - No turn-by-turn history
   - No undo to previous turn
   - Would require separate system

9. **Save Validation UI**
   - No visual corruption indicators
   - No "repair save" tool
   - Warnings in console only

10. **Custom Serializers**
    - No binary serialization
    - No protocol buffers
    - JSON only (human-readable)

## Design Choices & Rationale

### Why JSON Over Binary?

**Advantages:**
- Human-readable for debugging
- Easy to modify manually if needed
- Standard library support
- Cross-platform compatible

**Disadvantages:**
- Larger file size
- Slower parsing
- No schema enforcement

**Decision:** Simplicity and debuggability outweigh performance. Save files are small enough (~10-50 KB) that JSON overhead is negligible.

### Why File-Based Storage?

**Alternatives considered:**
- SharedPreferences: Size limits, not meant for large data
- SQLite: Overkill for simple save/load
- Cloud storage: Requires network, complex

**Decision:** Files provide good balance of simplicity, reliability, and flexibility.

### Why DJB2 Hash for Checksums?

**Alternatives considered:**
- MD5/SHA: Cryptographically secure but overkill
- CRC32: Standard but requires library
- Custom: Simple but less proven

**Decision:** DJB2 is simple, fast, and good enough for corruption detection (not security).

### Why 3 Save Slots?

**Rationale:**
- Common in games (RPGs, strategy games)
- Allows experimentation without overwriting
- Not so many that UI becomes cluttered
- Plus autosave = 4 total saves

### Why Sequential Migrations?

**Alternatives considered:**
- Direct jump (v1 → v3): Complex, error-prone
- Schema evolution library: External dependency

**Decision:** Sequential migrations are simple, predictable, and testable. Each migration step is small and focused.

### Why Separate Metadata and GameState?

**Rationale:**
- Fast loading of save list without parsing full state
- Metadata can be cached in memory
- GameState only loaded when actually loading save
- Cleaner separation of concerns

### Why Backup Before Overwrite?

**Rationale:**
- Protects against crashes during save
- Allows recovery from corrupted writes
- Simple automatic fallback
- Minimal storage overhead (1 backup per slot)

**Tradeoff:** Uses 2x storage, but safety is worth it.

## Known Limitations

1. **No Multi-Version Support**
   - Can't load saves from newer app versions
   - Forward compatibility not guaranteed
   - Would need more complex versioning

2. **No Concurrent Access**
   - No file locking
   - Assumes single instance of app
   - Multiple instances could corrupt saves

3. **No Save Compression**
   - Large event logs could make saves big
   - No automatic compression
   - Could add transparent compression layer

4. **Limited Corruption Detection**
   - Checksum detects bit flips
   - Doesn't detect semantic errors
   - Doesn't validate game logic consistency

5. **No Save File Size Limits**
   - No upper bound on save size
   - Could grow indefinitely with event log
   - May want to truncate old events

6. **Metadata Cache Not Persistent**
   - Rebuilt on each app launch
   - Could cache to separate file for faster startup
   - Not a problem for small number of saves

7. **No Progress Tracking**
   - No achievements or statistics
   - No global progress across saves
   - Could add as extension

8. **Platform-Specific Paths**
   - Depends on `path_provider`
   - Different paths on iOS/Android/desktop
   - Not a limitation, just awareness

## Testing Recommendations

### Unit Tests

```dart
test('Save and load cycle preserves data', () { ... });
test('Corrupted save falls back to backup', () { ... });
test('Migration from v1 to v2', () { ... });
test('Checksum detects corruption', () { ... });
test('Invalid JSON fails gracefully', () { ... });
```

### Integration Tests

```dart
test('Full game save/load/restore cycle', () { ... });
test('Autosave every 5 turns', () { ... });
test('Load old save after schema change', () { ... });
```

### Manual Tests

- Fill all 3 slots, verify oldest overwritten
- Corrupt save file manually, verify recovery
- Delete .backup, verify error handling
- Save on turn 100, load, verify state identical

## Migration Examples

### Future v1 → v2 Migration

**Scenario:** Adding action history tracking

```dart
static MigrationResult _migrateToV2(Map<String, dynamic> data) {
  final migrated = Map<String, dynamic>.from(data);

  if (migrated['gameState'] is Map) {
    final gameState = Map<String, dynamic>.from(migrated['gameState']);

    // Add empty action history
    gameState['actionHistory'] = <Map<String, dynamic>>[];

    migrated['gameState'] = gameState;
  }

  migrated['schemaVersion'] = 2;
  migrated['metadata']['schemaVersion'] = 2;

  return MigrationResult.success(
    migrated,
    warnings: ['Added action history for v2'],
  );
}
```

### Future v2 → v3 Migration

**Scenario:** Adding achievement tracking

```dart
static MigrationResult _migrateToV3(Map<String, dynamic> data) {
  final migrated = Map<String, dynamic>.from(data);

  if (migrated['gameState'] is Map) {
    final gameState = Map<String, dynamic>.from(migrated['gameState']);

    // Add achievement data
    gameState['achievements'] = {
      'unlocked': <String>[],
      'progress': <String, int>{},
    };

    migrated['gameState'] = gameState;
  }

  migrated['schemaVersion'] = 3;
  migrated['metadata']['schemaVersion'] = 3;

  return MigrationResult.success(
    migrated,
    warnings: ['Added achievements for v3'],
  );
}
```

## Best Practices for Integration

### DO:

- Always validate after load
- Show warnings to user (migrations, checksums)
- Catch exceptions at UI boundary
- Autosave regularly (every N turns)
- Test save/load cycle thoroughly
- Version bumps only when schema changes

### DON'T:

- Don't ignore load warnings
- Don't save on every turn (performance)
- Don't assume saves always succeed
- Don't modify core files (use snapshots)
- Don't skip initialization
- Don't expose raw file paths to user

### Error Handling Pattern:

```dart
final result = await loadGame(slotId);

if (!result.success) {
  // Try autosave
  final autosave = await loadAutosave();
  if (autosave.success) {
    showWarning('Main save corrupted, loaded autosave');
    return;
  }

  // All failed, safe default
  showError('Cannot load save: ${result.errorMessage}');
  navigateToMainMenu();
  return;
}

// Success, check warnings
if (result.warnings.isNotEmpty) {
  log.warning(result.warnings.join('; '));
}

// Restore game state
restoreFromSnapshot(result.data!);
```

## Future Enhancements (Not Implemented)

- Cloud sync (Google Drive, iCloud)
- Save file compression
- Save file encryption
- Multiple backup versions
- Save file export/import
- Save thumbnails/screenshots
- Incremental saves (diff-based)
- Save file repair tool
- Global statistics across saves
- Achievement system integration
- Replay/timeline viewer
- Save file browser/editor

## Dependencies

### Required:

- `path_provider: ^2.1.0` (get app documents directory)

### Included in Flutter SDK:

- `dart:io` (file operations)
- `dart:convert` (JSON serialization)

### Optional (for extensions):

- `encrypt` (save encryption)
- `archive` (compression)
- `firebase_storage` (cloud sync)

## Version

- **Version**: 1.0
- **Schema Version**: 1
- **Date**: 2026-01-17
- **Status**: Complete, ready for integration
- **Dependencies**: Event Engine, Scenario System
