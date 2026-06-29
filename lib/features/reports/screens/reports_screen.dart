import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            context,
            'Daily Sales Report',
            'Generate a detailed PDF/Excel report of all sales today.',
            Icons.receipt_long,
            Colors.blue,
          ),
          _buildReportCard(
            context,
            'Expense Report',
            'View all expenses grouped by category for this month.',
            Icons.money_off,
            Colors.red,
          ),
          _buildReportCard(
            context,
            'Stock Valuation Report',
            'Get current inventory valuation and low stock alerts.',
            Icons.inventory,
            Colors.green,
          ),
          _buildReportCard(
            context,
            'Tax Report (GST)',
            'GSTR-1, GSTR-2, and GSTR-3B summary reports.',
            Icons.account_balance,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generating $title...')));
        },
      ),
    );
  }
}
