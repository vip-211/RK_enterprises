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

import 'package:rk_enterprises/features/customers/screens/customer_entry_screen.dart';
import 'package:rk_enterprises/features/inventory/screens/product_entry_screen.dart';
import 'package:rk_enterprises/features/expenses/screens/expense_entry_screen.dart';
import 'package:rk_enterprises/features/suppliers/screens/supplier_entry_screen.dart';
import 'package:rk_enterprises/features/purchases/screens/purchase_entry_screen.dart';
import 'package:rk_enterprises/features/billing/screens/invoice_entry_screen.dart';
import 'package:rk_enterprises/features/staff/screens/staff_list_screen.dart';
import 'package:rk_enterprises/features/staff/screens/staff_entry_screen.dart';
import 'package:rk_enterprises/features/splash/screens/splash_screen.dart';
import 'package:rk_enterprises/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'RK Enterprises',
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData.dark(), // Simple dark theme fallback
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/invoice-detail': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return InvoiceDetailScreen(invoiceId: id);
        },
        '/customer-entry': (context) => const CustomerEntryScreen(),
        '/product-entry': (context) => const ProductEntryScreen(),
        '/expense-entry': (context) => const ExpenseEntryScreen(),
        '/supplier-entry': (context) => const SupplierEntryScreen(),
        '/purchase-entry': (context) => const PurchaseEntryScreen(),
        '/invoice-entry': (context) => const InvoiceEntryScreen(),
        '/staff-list': (context) => const StaffListScreen(),
        '/staff-entry': (context) => const StaffEntryScreen(),
      },
    );
  }
}
