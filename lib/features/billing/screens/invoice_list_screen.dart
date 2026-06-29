import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/billing/repositories/invoice_repository.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(invoiceRepositoryProvider);
    final invoices = repo.getInvoices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/invoice-entry');
            },
          ),
        ],
      ),
      body: invoices.isEmpty
          ? const Center(child: Text('No invoices found.'))
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.receipt)),
                  title: Text(invoice.invoiceNumber),
                  subtitle: Text(invoice.customerName ?? 'Walk-in Customer'),
                  trailing: Text(
                    '₹${invoice.grandTotal}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () {
                    // Navigate to details / print
                  },
                );
              },
            ),
    );
  }
}
