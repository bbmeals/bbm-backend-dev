// lib/config/environment.dart
import 'dart:io' show Platform;

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static Map<String, dynamic> _config = {};

  static void setEnvironment(Environment env) {
    _environment = env;
    switch (env) {
      case Environment.development:
        _config = {
          'apiUrl': 'http://localhost:8080',
          'firebaseProjectId': 'bbm-db-dev',
          'firebaseConfig': {
            'apiKey': const String.fromEnvironment('FIREBASE_API_KEY',
                defaultValue: ''),
            'appId': const String.fromEnvironment('FIREBASE_APP_ID',
                defaultValue: ''),
          },
        };
        break;
      case Environment.staging:
        _config = {
          'apiUrl':
              'https://bbm-backend-dev-staging.onrender.com', // Your Render staging URL
          'firebaseProjectId': 'bbm-db-dev',
          'firebaseConfig': {
            'apiKey': const String.fromEnvironment('FIREBASE_API_KEY',
                defaultValue: ''),
            'appId': const String.fromEnvironment('FIREBASE_APP_ID',
                defaultValue: ''),
          },
        };
        break;
      case Environment.production:
        _config = {
          'apiUrl':
              'https://bbm-backend-dev.onrender.com', // Your Render production URL
          'firebaseProjectId': 'bbm-db-prod',
          'firebaseConfig': {
            'apiKey': const String.fromEnvironment('FIREBASE_API_KEY',
                defaultValue: ''),
            'appId': const String.fromEnvironment('FIREBASE_APP_ID',
                defaultValue: ''),
          },
        };
        break;
    }
  }

  // Getters
  static String get apiUrl => _config['apiUrl'] as String;
  static String get firebaseProjectId => _config['firebaseProjectId'] as String;
  static Map<String, dynamic> get firebaseConfig =>
      _config['firebaseConfig'] as Map<String, dynamic>;
  static Environment get environment => _environment;

  // Utility methods
  static bool isProduction() => _environment == Environment.production;
  static bool isDevelopment() => _environment == Environment.development;
  static bool isStaging() => _environment == Environment.staging;

  // Validate environment setup
  static bool validateConfig() {
    if (_config.isEmpty) {
      print('Environment not configured. Call setEnvironment() first.');
      return false;
    }

    final requiredKeys = ['apiUrl', 'firebaseProjectId', 'firebaseConfig'];
    final missingKeys =
        requiredKeys.where((key) => !_config.containsKey(key)).toList();

    if (missingKeys.isNotEmpty) {
      print('Missing required configuration keys: ${missingKeys.join(', ')}');
      return false;
    }

    return true;
  }
}
