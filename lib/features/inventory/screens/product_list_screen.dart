import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/inventory/repositories/product_repository.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(productRepositoryProvider);
    final products = repo.getProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to AddProductScreen
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add product screen coming soon!')));
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products found.'))
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
            ),
    );
  }
}
