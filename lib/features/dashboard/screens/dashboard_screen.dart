import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/authentication/repositories/auth_repository.dart';
import 'package:rk_enterprises/features/inventory/screens/product_list_screen.dart';
import 'package:rk_enterprises/features/customers/screens/customer_list_screen.dart';
import 'package:rk_enterprises/features/suppliers/screens/supplier_list_screen.dart';
import 'package:rk_enterprises/features/billing/screens/invoice_list_screen.dart';
import 'package:rk_enterprises/features/purchases/screens/purchase_list_screen.dart';
import 'package:rk_enterprises/features/expenses/screens/expense_list_screen.dart';
import 'package:rk_enterprises/features/reports/screens/reports_screen.dart';
import 'package:rk_enterprises/features/settings/screens/settings_screen.dart';
import 'package:rk_enterprises/features/settings/screens/settings_screen.dart';
import 'package:rk_enterprises/features/dashboard/providers/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    
    final metrics = metricsAsync.value ?? DashboardMetrics();
    
    final isAdmin = user?.role == 'Admin' || user?.role == 'Super Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).state = null;
              Navigator.of(context).pushReplacementNamed('/');
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'User'),
              accountEmail: Text(user?.role ?? 'Role'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text('MANAGEMENT', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Products / Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Customers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen()));
              },
            ),
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text('Suppliers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierListScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Staff'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/staff-list');
                },
              ),
            ],
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text('TRANSACTIONS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Invoices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceListScreen()));
              },
            ),
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Purchases'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseListScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.money_off),
                title: const Text('Expenses'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen()));
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text('REPORTING', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(authStateProvider.notifier).state = null;
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user?.name ?? 'User'}!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            
            if (isAdmin) ...[
              const Text('Here is your business overview today.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildKPIWidget(context, 'Today\'s Sales', '₹ ${metrics.todaysSales.toStringAsFixed(0)}', Icons.trending_up, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildKPIWidget(context, 'Outstanding', '₹ ${metrics.outstanding.toStringAsFixed(0)}', Icons.warning_amber_rounded, Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildKPIWidget(context, 'Low Stock', '${metrics.lowStockCount} Items', Icons.inventory, Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildKPIWidget(context, 'Purchases', '₹ ${metrics.monthPurchases.toStringAsFixed(0)}', Icons.shopping_cart, Colors.blue)),
                ],
              ),
              const SizedBox(height: 32),
              Text('Revenue Trend', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              // Line Chart
              Container(
                height: 250,
                padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(color: Colors.grey, fontSize: 10);
                            switch (value.toInt()) {
                              case 1: return const Text('Mon', style: style);
                              case 3: return const Text('Wed', style: style);
                              case 5: return const Text('Fri', style: style);
                              case 7: return const Text('Sun', style: style);
                              default: return const Text('');
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(1, 1000),
                          FlSpot(2, 3500),
                          FlSpot(3, 2000),
                          FlSpot(4, 5500),
                          FlSpot(5, 4000),
                          FlSpot(6, 8000),
                          FlSpot(7, 15000),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Text('Staff Dashboard. Select an action below.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              _buildStaffActionButton(
                context, 
                title: 'New Bill (Point of Sale)', 
                icon: Icons.point_of_sale, 
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/invoice-entry'),
              ),
              const SizedBox(height: 16),
              _buildStaffActionButton(
                context, 
                title: 'View Invoices', 
                icon: Icons.receipt, 
                color: Colors.indigo,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceListScreen())),
              ),
              const SizedBox(height: 16),
              _buildStaffActionButton(
                context, 
                title: 'Check Products / Inventory', 
                icon: Icons.inventory, 
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStaffActionButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIWidget(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
