import 'package:workmanager/workmanager.dart';
import 'package:rk_enterprises/sync/sync_manager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackgroundWorker.syncTaskName) {
      // Required to initialize bindings for background execution
      // WidgetsFlutterBinding.ensureInitialized();
      // Initialize Hive / Firebase if needed here
      
      final syncManager = SyncManager();
      await syncManager.syncAllPendingData();
    }
    return Future.value(true);
  });
}

class BackgroundWorker {
  static const String syncTaskName = 'backgroundSyncTask';
  
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // TODO: Set to false in production
    );
  }
  
  static void schedulePeriodicSync() {
    Workmanager().registerPeriodicTask(
      "1", // unique name
      syncTaskName,
      frequency: const Duration(minutes: 15), // Minimum allowed on Android/iOS
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected to internet
      ),
    );
  }
}
