import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';
import 'package:rk_enterprises/features/customers/models/customer_model.dart';
import 'package:rk_enterprises/features/suppliers/models/supplier_model.dart';
import 'package:rk_enterprises/features/authentication/models/user_model.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
import 'package:rk_enterprises/features/purchases/models/purchase_model.dart';
import 'package:rk_enterprises/features/expenses/models/expense_model.dart';
import 'package:rk_enterprises/features/staff/models/staff_model.dart';

class HiveBoxes {
  static const String users = 'usersBox';
  static const String products = 'productsBox';
  static const String customers = 'customersBox';
  static const String suppliers = 'suppliersBox';
  static const String invoices = 'invoicesBox';
  static const String purchases = 'purchasesBox';
  static const String expenses = 'expensesBox';
  static const String staff = 'staffBox';
  // Add other boxes as we go
}

class HiveDatabase {
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ProductModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CustomerModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SupplierModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(InvoiceItemModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(InvoiceModelAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(PurchaseItemModelAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(PurchaseModelAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(ExpenseModelAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(StaffModelAdapter());
    
    await Future.wait([
      Hive.openBox<UserModel>(HiveBoxes.users),
      Hive.openBox<ProductModel>(HiveBoxes.products),
      Hive.openBox<CustomerModel>(HiveBoxes.customers),
      Hive.openBox<SupplierModel>(HiveBoxes.suppliers),
      Hive.openBox<InvoiceModel>(HiveBoxes.invoices),
      Hive.openBox<PurchaseModel>(HiveBoxes.purchases),
      Hive.openBox<ExpenseModel>(HiveBoxes.expenses),
      Hive.openBox<StaffModel>(HiveBoxes.staff),
    ]);
    
    _initialized = true;
  }
}
