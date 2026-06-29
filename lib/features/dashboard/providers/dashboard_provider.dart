import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
import 'package:rk_enterprises/features/customers/models/customer_model.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';
import 'package:rk_enterprises/features/purchases/models/purchase_model.dart';

class DashboardMetrics {
  final double todaysSales;
  final double outstanding;
  final int lowStockCount;
  final double monthPurchases;

  DashboardMetrics({
    this.todaysSales = 0,
    this.outstanding = 0,
    this.lowStockCount = 0,
    this.monthPurchases = 0,
  });
}

final dashboardMetricsProvider = StreamProvider<DashboardMetrics>((ref) {
  final invoiceBox = Hive.box<InvoiceModel>(HiveBoxes.invoices);
  final customerBox = Hive.box<CustomerModel>(HiveBoxes.customers);
  final productBox = Hive.box<ProductModel>(HiveBoxes.products);
  final purchaseBox = Hive.box<PurchaseModel>(HiveBoxes.purchases);

  // Initial emission
  final controller = StreamController<DashboardMetrics>();

  void updateMetrics() {
    final now = DateTime.now();
    
    // Today's Sales
    final todayInvoices = invoiceBox.values.where((i) => i.deletedAt == null && i.invoiceDate.year == now.year && i.invoiceDate.month == now.month && i.invoiceDate.day == now.day);
    final sales = todayInvoices.fold<double>(0, (sum, i) => sum + i.grandTotal);

    // Outstanding
    final customers = customerBox.values.where((c) => c.deletedAt == null);
    final outstanding = customers.fold<double>(0, (sum, c) => sum + c.outstandingBalance);

    // Low Stock
    final lowStock = productBox.values.where((p) => p.deletedAt == null && p.currentStock <= p.minimumStock).length;

    // Purchases
    final monthPurchasesList = purchaseBox.values.where((p) => p.deletedAt == null && p.purchaseDate.year == now.year && p.purchaseDate.month == now.month);
    final monthPurchases = monthPurchasesList.fold<double>(0, (sum, p) => sum + p.grandTotal);

    controller.add(DashboardMetrics(
      todaysSales: sales,
      outstanding: outstanding,
      lowStockCount: lowStock,
      monthPurchases: monthPurchases,
    ));
  }

  // Initial calculation
  updateMetrics();

  // Listen to changes
  final sub1 = invoiceBox.watch().listen((_) => updateMetrics());
  final sub2 = customerBox.watch().listen((_) => updateMetrics());
  final sub3 = productBox.watch().listen((_) => updateMetrics());
  final sub4 = purchaseBox.watch().listen((_) => updateMetrics());

  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    sub3.cancel();
    sub4.cancel();
    controller.close();
  });

  return controller.stream;
});
