import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/purchases/models/purchase_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/purchase-entry');
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<PurchaseModel>>(
        valueListenable: Hive.box<PurchaseModel>(HiveBoxes.purchases).listenable(),
        builder: (context, box, _) {
          final purchases = box.values.where((p) => p.deletedAt == null).toList();
          return purchases.isEmpty
              ? const Center(child: Text('No purchases found.'))
              : ListView.builder(
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final purchase = purchases[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.shopping_cart)),
                      title: Text(purchase.purchaseNumber),
                      subtitle: Text(purchase.supplierName),
                      trailing: Text(
                        '₹${purchase.grandTotal}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
