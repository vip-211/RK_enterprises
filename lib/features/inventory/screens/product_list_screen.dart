import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/core/widgets/empty_state_widget.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Barcodes',
            onPressed: () {
              Navigator.pushNamed(context, '/barcode-print');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/product-entry');
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<ProductModel>>(
        valueListenable: Hive.box<ProductModel>(HiveBoxes.products).listenable(),
        builder: (context, box, _) {
          final products = box.values.where((p) => p.deletedAt == null).toList();
          return products.isEmpty
              ? EmptyStateWidget(
                  title: 'No Products Yet',
                  message: 'Add your first product to start tracking inventory.',
                  icon: Icons.inventory_2_outlined,
                  actionLabel: 'Add Product',
                  onActionPressed: () => Navigator.pushNamed(context, '/product-entry'),
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: const Icon(Icons.inventory),
                      title: Text(product.name),
                      subtitle: Text('Stock: ${product.currentStock} ${product.unit} | Price: ₹${product.sellingPrice}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to EditProductScreen
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
