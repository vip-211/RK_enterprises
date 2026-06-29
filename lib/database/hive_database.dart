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
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(SupplierModelAdapter());
    Hive.registerAdapter(InvoiceItemModelAdapter());
    Hive.registerAdapter(InvoiceModelAdapter());
    Hive.registerAdapter(PurchaseItemModelAdapter());
    Hive.registerAdapter(PurchaseModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(StaffModelAdapter());
    
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
  }
}
