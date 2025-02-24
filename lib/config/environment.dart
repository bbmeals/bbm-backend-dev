// lib/config/environment.dart
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
        };
        break;
      case Environment.staging:
        _config = {
          'apiUrl': 'https://bbm-backend-api-staging-abcdef.run.app',
          'firebaseProjectId': 'bbm-db-dev',
        };
        break;
      case Environment.production:
        _config = {
          'apiUrl': 'https://bbm-backend-api-abcdef.run.app',
          'firebaseProjectId':
              'bbm-db-prod', // If you have a separate prod project
        };
        break;
    }
  }

  static String get apiUrl => _config['apiUrl'];
  static String get firebaseProjectId => _config['firebaseProjectId'];
}
