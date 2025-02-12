import 'dart:convert';
import 'dart:io';

class FirebaseConfig {
  /// Reads the configuration from google-services.json
  static Map<String, dynamic> get config {
    final file = File('firebase_services.json');
    if (!file.existsSync()) {
      throw Exception("google-services.json file not found. Make sure it is in the project root.");
    }
    return jsonDecode(file.readAsStringSync());
  }
}
