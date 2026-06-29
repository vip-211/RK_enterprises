import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/suppliers/repositories/supplier_repository.dart';
import 'package:rk_enterprises/features/suppliers/models/supplier_model.dart';

class SupplierListScreen extends ConsumerWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(supplierRepositoryProvider);
    final suppliers = repo.getSuppliers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add supplier screen coming soon!')));
            },
          ),
        ],
      ),
      body: suppliers.isEmpty
          ? const Center(child: Text('No suppliers found.'))
          : ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.local_shipping)),
                  title: Text(supplier.name),
                  subtitle: Text(supplier.phone),
                  trailing: Text(
                    '₹${supplier.outstandingBalance}',
                    style: TextStyle(
                      color: supplier.outstandingBalance > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Navigate to details
                  },
                );
              },
            ),
    );
  }
}
