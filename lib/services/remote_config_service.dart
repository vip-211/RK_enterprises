import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService(this._remoteConfig);

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // Use 0 for dev
      ));

      // Define default values
      await _remoteConfig.setDefaults(const {
        'maintenance_mode': false,
        'latest_app_version': '1.0.0',
        'show_promotions': true,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Failed to initialize Remote Config: $e');
    }
  }

  bool get isMaintenanceMode => _remoteConfig.getBool('maintenance_mode');
  String get latestAppVersion => _remoteConfig.getString('latest_app_version');
  bool get showPromotions => _remoteConfig.getBool('show_promotions');
}

final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(FirebaseRemoteConfig.instance);
});
