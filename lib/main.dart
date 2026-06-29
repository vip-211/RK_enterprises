import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:rk_enterprises/firebase_options.dart';
import 'package:rk_enterprises/theme/app_theme.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/services/background_worker.dart';
import 'package:rk_enterprises/sync/sync_manager.dart';

import 'package:rk_enterprises/features/authentication/screens/login_screen.dart';
import 'package:rk_enterprises/services/remote_config_service.dart';

import 'package:rk_enterprises/services/notification_service.dart';
import 'package:rk_enterprises/features/billing/screens/invoice_detail_screen.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive
  await HiveDatabase.init();
  
  // Init Notifications
  await NotificationService().init();
  
  // Init Remote Config
  final remoteConfig = RemoteConfigService(FirebaseRemoteConfig.instance);
  await remoteConfig.init();
  
  if (!kIsWeb) {
    // Initialize Background Sync
    await BackgroundWorker.init();
    BackgroundWorker.schedulePeriodicSync();
  }
  
  // Initialize SyncManager listener
  SyncManager().init();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RK Enterprises',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/invoice-detail': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return InvoiceDetailScreen(invoiceId: id);
        },
      },
    );
  }
}
