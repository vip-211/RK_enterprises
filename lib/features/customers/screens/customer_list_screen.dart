import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/customers/repositories/customer_repository.dart';
import 'package:rk_enterprises/features/customers/models/customer_model.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(customerRepositoryProvider);
    final customers = repo.getCustomers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add customer screen coming soon!')));
            },
          ),
        ],
      ),
      body: customers.isEmpty
          ? const Center(child: Text('No customers found.'))
          : ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(customer.name),
                  subtitle: Text(customer.phone),
                  trailing: Text(
                    '₹${customer.outstandingBalance}',
                    style: TextStyle(
                      color: customer.outstandingBalance > 0 ? Colors.red : Colors.green,
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
