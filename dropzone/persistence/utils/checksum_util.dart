import 'dart:convert';
import 'dart:typed_data';

/// Simple checksum utility for data integrity validation
/// Uses a basic hash to detect corruption (not cryptographic)
class ChecksumUtil {
  /// Calculate checksum for JSON data
  static String calculate(Map<String, dynamic> data) {
    try {
      // Convert to canonical JSON string (sorted keys for consistency)
      final jsonString = _canonicalJsonEncode(data);

      // Calculate simple hash
      return _simpleHash(jsonString);
    } catch (_) {
      return '';
    }
  }

  /// Verify checksum matches data
  static bool verify(Map<String, dynamic> data, String checksum) {
    if (checksum.isEmpty) return false;
    final calculated = calculate(data);
    return calculated == checksum;
  }

  /// Convert JSON to canonical string (deterministic)
  static String _canonicalJsonEncode(dynamic obj) {
    if (obj is Map) {
      // Sort keys for deterministic output
      final sortedKeys = obj.keys.toList()..sort();
      final entries = sortedKeys.map((key) {
        final value = _canonicalJsonEncode(obj[key]);
        final keyStr = _canonicalJsonEncode(key);
        return '$keyStr:$value';
      });
      return '{${entries.join(',')}}';
    } else if (obj is List) {
      final items = obj.map(_canonicalJsonEncode);
      return '[${items.join(',')]';
    } else if (obj is String) {
      return '"$obj"';
    } else if (obj is num) {
      return obj.toString();
    } else if (obj is bool) {
      return obj.toString();
    } else if (obj == null) {
      return 'null';
    } else {
      return obj.toString();
    }
  }

  /// Simple hash function (DJB2 variant)
  /// Not cryptographically secure, but good enough for corruption detection
  static String _simpleHash(String input) {
    int hash = 5381;
    final bytes = utf8.encode(input);

    for (final byte in bytes) {
      hash = ((hash << 5) + hash) + byte; // hash * 33 + byte
      hash = hash & 0xFFFFFFFF; // Keep it 32-bit
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// Calculate checksum for a file's bytes
  static String calculateForBytes(Uint8List bytes) {
    int hash = 5381;

    for (final byte in bytes) {
      hash = ((hash << 5) + hash) + byte;
      hash = hash & 0xFFFFFFFF;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }
}
