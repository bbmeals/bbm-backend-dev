import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class AppConfig {
  static FirebaseRemoteConfig? _remoteConfig;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _remoteConfig!.fetchAndActivate();
  }

  static String get apiEndpoint {
    return _remoteConfig?.getString('api_endpoint') ?? 'http://localhost:8080/';
  }
}
