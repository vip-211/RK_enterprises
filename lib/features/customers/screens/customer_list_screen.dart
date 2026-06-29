import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/customers/models/customer_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/customer-entry');
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<CustomerModel>>(
        valueListenable: Hive.box<CustomerModel>(HiveBoxes.customers).listenable(),
        builder: (context, box, _) {
          final customers = box.values.where((c) => c.deletedAt == null).toList();
          return customers.isEmpty
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
                );
        },
      ),
    );
  }
}
