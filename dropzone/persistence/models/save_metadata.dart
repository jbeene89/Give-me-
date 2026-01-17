/// Metadata about a save slot
class SaveMetadata {
  /// Unique slot ID (e.g., "slot_1", "slot_2", "autosave")
  final String slotId;

  /// Display name for the save slot
  final String displayName;

  /// Scenario ID that was loaded
  final String scenarioId;

  /// Difficulty profile ID
  final String difficultyId;

  /// Current turn number
  final int turnNumber;

  /// Timestamp when save was created
  final DateTime timestamp;

  /// Schema version of the save data
  final int schemaVersion;

  /// Optional player note/description
  final String? note;

  /// Whether this save is valid/loadable
  final bool isValid;

  /// Checksum for data integrity validation
  final String checksum;

  const SaveMetadata({
    required this.slotId,
    required this.displayName,
    required this.scenarioId,
    required this.difficultyId,
    required this.turnNumber,
    required this.timestamp,
    required this.schemaVersion,
    this.note,
    this.isValid = true,
    required this.checksum,
  });

  /// Create from JSON
  factory SaveMetadata.fromJson(Map<String, dynamic> json) {
    return SaveMetadata(
      slotId: json['slotId'] as String,
      displayName: json['displayName'] as String,
      scenarioId: json['scenarioId'] as String,
      difficultyId: json['difficultyId'] as String,
      turnNumber: json['turnNumber'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      schemaVersion: json['schemaVersion'] as int,
      note: json['note'] as String?,
      isValid: json['isValid'] as bool? ?? true,
      checksum: json['checksum'] as String? ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'displayName': displayName,
      'scenarioId': scenarioId,
      'difficultyId': difficultyId,
      'turnNumber': turnNumber,
      'timestamp': timestamp.toIso8601String(),
      'schemaVersion': schemaVersion,
      'note': note,
      'isValid': isValid,
      'checksum': checksum,
    };
  }

  /// Create a copy with modified fields
  SaveMetadata copyWith({
    String? slotId,
    String? displayName,
    String? scenarioId,
    String? difficultyId,
    int? turnNumber,
    DateTime? timestamp,
    int? schemaVersion,
    String? note,
    bool? isValid,
    String? checksum,
  }) {
    return SaveMetadata(
      slotId: slotId ?? this.slotId,
      displayName: displayName ?? this.displayName,
      scenarioId: scenarioId ?? this.scenarioId,
      difficultyId: difficultyId ?? this.difficultyId,
      turnNumber: turnNumber ?? this.turnNumber,
      timestamp: timestamp ?? this.timestamp,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      note: note ?? this.note,
      isValid: isValid ?? this.isValid,
      checksum: checksum ?? this.checksum,
    );
  }

  @override
  String toString() {
    return 'Save: $displayName (Turn $turnNumber, ${timestamp.toLocal()})';
  }
}
