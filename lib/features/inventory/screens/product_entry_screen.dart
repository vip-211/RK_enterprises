import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/inventory/repositories/product_repository.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';

class ProductEntryScreen extends ConsumerStatefulWidget {
  const ProductEntryScreen({super.key});

  @override
  ConsumerState<ProductEntryScreen> createState() => _ProductEntryScreenState();
}

class _ProductEntryScreenState extends ConsumerState<ProductEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _taxRateController = TextEditingController(text: '18');
  final _stockQuantityController = TextEditingController(text: '0');
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _taxRateController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final product = ProductModel(
        id: '', // Handled by repository
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        description: '',
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0,
        taxRate: double.tryParse(_taxRateController.text) ?? 18,
        stockQuantity: double.tryParse(_stockQuantityController.text) ?? 0,
        minStockLevel: 5,
        isSynced: false,
        operation: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(productRepositoryProvider);
      await repo.addProduct(product);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveProduct,
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name *', prefixIcon: Icon(Icons.inventory)),
                validator: (val) => val == null || val.isEmpty ? 'Please enter item name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'Item Code / SKU', prefixIcon: Icon(Icons.qr_code)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration: const InputDecoration(labelText: 'Sale Price (₹) *', prefixIcon: Icon(Icons.sell)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(labelText: 'Purchase Price (₹)', prefixIcon: Icon(Icons.shopping_cart)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _taxRateController,
                      decoration: const InputDecoration(labelText: 'Tax Rate (GST %)', prefixIcon: Icon(Icons.percent)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockQuantityController,
                      decoration: const InputDecoration(labelText: 'Opening Stock', prefixIcon: Icon(Icons.layers)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Product', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
