import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/models/sync_model.dart';

class ProductRepository {
  final Box<ProductModel> _box = Hive.box<ProductModel>(HiveBoxes.products);

  List<ProductModel> getProducts() {
    return _box.values.where((p) => p.deletedAt == null).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    final newProduct = ProductModel(
      id: const Uuid().v4(),
      name: product.name,
      sku: product.sku,
      barcode: product.barcode,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      mrp: product.mrp,
      gstPercentage: product.gstPercentage,
      hsnCode: product.hsnCode,
      openingStock: product.openingStock,
      currentStock: product.currentStock,
      minimumStock: product.minimumStock,
      brand: product.brand,
      category: product.category,
      unit: product.unit,
      imageUrl: product.imageUrl,
      isSynced: false,
      operation: SyncOperation.insert,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _box.put(newProduct.id, newProduct);
  }

  Future<void> updateProduct(ProductModel product) async {
    final updatedProduct = ProductModel(
      id: product.id,
      name: product.name,
      sku: product.sku,
      barcode: product.barcode,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      mrp: product.mrp,
      gstPercentage: product.gstPercentage,
      hsnCode: product.hsnCode,
      openingStock: product.openingStock,
      currentStock: product.currentStock,
      minimumStock: product.minimumStock,
      brand: product.brand,
      category: product.category,
      unit: product.unit,
      imageUrl: product.imageUrl,
      isSynced: false,
      operation: product.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.update,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: product.deletedAt,
    );
    await _box.put(updatedProduct.id, updatedProduct);
  }

  Future<void> deleteProduct(String id) async {
    final product = _box.get(id);
    if (product != null) {
      final deletedProduct = ProductModel(
        id: product.id,
        name: product.name,
        sku: product.sku,
        barcode: product.barcode,
        purchasePrice: product.purchasePrice,
        sellingPrice: product.sellingPrice,
        mrp: product.mrp,
        gstPercentage: product.gstPercentage,
        hsnCode: product.hsnCode,
        openingStock: product.openingStock,
        currentStock: product.currentStock,
        minimumStock: product.minimumStock,
        brand: product.brand,
        category: product.category,
        unit: product.unit,
        imageUrl: product.imageUrl,
        isSynced: false,
        operation: product.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.delete, // Optimization: If it was never synced, just delete it locally entirely? We'll mark it delete.
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      );
      await _box.put(deletedProduct.id, deletedProduct);
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});
