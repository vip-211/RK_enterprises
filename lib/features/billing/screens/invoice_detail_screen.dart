import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/billing/repositories/invoice_repository.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
import 'package:intl/intl.dart';
import 'package:rk_enterprises/core/widgets/skeleton.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real application, you'd fetch this from the repository
    // using a FutureProvider or similar. For simplicity, we assume
    // the repository fetches it from Hive.
    return FutureBuilder<InvoiceModel?>(
      future: _getInvoice(ref, invoiceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 200, height: 24),
                    SizedBox(height: 32),
                    SkeletonList(itemCount: 3),
                    Divider(height: 32),
                    Skeleton(width: double.infinity, height: 100),
                  ],
                ),
              ),
            ),
          );
        }
        
        final invoice = snapshot.data;
        if (invoice == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invoice Not Found')),
            body: const Center(child: Text('This invoice could not be found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Invoice ${invoice.invoiceNumber}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () {
                  // In a real app, call PdfGenerator.generateAndPrintInvoice(invoice);
                },
              ),
            ]
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(invoice),
                const Divider(height: 32),
                _buildItemsList(invoice),
                const Divider(height: 32),
                _buildTotals(invoice),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<InvoiceModel?> _getInvoice(WidgetRef ref, String id) async {
    final repo = ref.read(invoiceRepositoryProvider);
    final invoices = await repo.getInvoices();
    try {
      return invoices.firstWhere((inv) => inv.id == id);
    } catch (e) {
      return null;
    }
  }

  Widget _buildHeader(InvoiceModel invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(invoice.customerName ?? 'Walk-in Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(DateFormat('dd MMM yyyy').format(invoice.invoiceDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        )
      ],
    );
  }

  Widget _buildItemsList(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...invoice.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.quantity} x ${item.productName}'),
              Text('₹${item.totalAmount.toStringAsFixed(2)}'),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTotals(InvoiceModel invoice) {
    return Column(
      children: [
        _buildTotalRow('Subtotal', invoice.subTotal),
        _buildTotalRow('Discount', -invoice.totalDiscount, color: Colors.green),
        _buildTotalRow('GST', invoice.totalGst),
        const Divider(),
        _buildTotalRow('Grand Total', invoice.grandTotal, isBold: true, fontSize: 18),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {Color? color, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
          Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
        ],
      ),
    );
  }
}
