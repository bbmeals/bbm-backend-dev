class FirestoreConverter {
  /// Converts a plain Dart map into Firestore fields format.
  static Map<String, dynamic> encodeFields(Map<String, dynamic> data) {
    final encoded = <String, dynamic>{};
    data.forEach((key, value) {
      encoded[key] = _encodeValue(value);
    });
    return encoded;
  }

  /// Helper to encode a single value into the Firestore REST format.
  static Map<String, dynamic> _encodeValue(dynamic value) {
    if (value is String) {
      return {'stringValue': value};
    } else if (value is int) {
      // Firestore expects integer values as strings.
      return {'integerValue': value.toString()};
    } else if (value is double) {
      return {'doubleValue': value};
    } else if (value is bool) {
      return {'booleanValue': value};
    } else if (value is DateTime) {
      // Convert DateTime to UTC ISO8601 string format.
      return {'timestampValue': value.toUtc().toIso8601String()};
    } else if (value is Map<String, dynamic>) {
      return {'mapValue': {'fields': encodeFields(value)}};
    } else if (value is List) {
      return {
        'arrayValue': {
          'values': value.map((v) => _encodeValue(v)).toList()
        }
      };
    } else if (value == null) {
      return {'nullValue': null};
    } else {
      throw Exception('Unsupported type: ${value.runtimeType}');
    }
  }

  /// Converts Firestore fields format into a plain Dart map.
  static Map<String, dynamic> decodeFields(Map<String, dynamic> firestoreData) {
    final decoded = <String, dynamic>{};
    firestoreData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        decoded[key] = _decodeValue(value);
      }
    });
    return decoded;
  }

  /// Helper to decode a single Firestore value into a native Dart type.
  static dynamic _decodeValue(Map<String, dynamic> firestoreValue) {
    if (firestoreValue.containsKey('stringValue')) {
      return firestoreValue['stringValue'];
    } else if (firestoreValue.containsKey('integerValue')) {
      // Parse the integer stored as a string.
      return int.tryParse(firestoreValue['integerValue'] ?? '');
    } else if (firestoreValue.containsKey('doubleValue')) {
      return firestoreValue['doubleValue'];
    } else if (firestoreValue.containsKey('booleanValue')) {
      return firestoreValue['booleanValue'];
    } else if (firestoreValue.containsKey('timestampValue')) {
      // Return as an ISO8601 string directly
      return firestoreValue['timestampValue'];
  } else if (firestoreValue.containsKey('mapValue')) {
      final fields = firestoreValue['mapValue']['fields'] as Map<String, dynamic>;
      return decodeFields(fields);
    } else if (firestoreValue.containsKey('arrayValue')) {
      final values = firestoreValue['arrayValue']['values'] as List<dynamic>;
      return values
          .map((v) => _decodeValue(v as Map<String, dynamic>))
          .toList();
    } else if (firestoreValue.containsKey('nullValue')) {
      return null;
    } else {
      throw Exception("Unsupported Firestore value type");
    }
  }
}
