import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/suppliers/models/supplier_model.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/models/sync_model.dart';

class SupplierRepository {
  final Box<SupplierModel> _box = Hive.box<SupplierModel>(HiveBoxes.suppliers);

  List<SupplierModel> getSuppliers() {
    return _box.values.where((s) => s.deletedAt == null).toList();
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    final newSupplier = SupplierModel(
      id: const Uuid().v4(),
      name: supplier.name,
      phone: supplier.phone,
      email: supplier.email,
      gstin: supplier.gstin,
      outstandingBalance: supplier.outstandingBalance,
      address: supplier.address,
      isSynced: false,
      operation: SyncOperation.insert,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _box.put(newSupplier.id, newSupplier);
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    final updatedSupplier = SupplierModel(
      id: supplier.id,
      name: supplier.name,
      phone: supplier.phone,
      email: supplier.email,
      gstin: supplier.gstin,
      outstandingBalance: supplier.outstandingBalance,
      address: supplier.address,
      isSynced: false,
      operation: supplier.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.update,
      createdAt: supplier.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: supplier.deletedAt,
    );
    await _box.put(updatedSupplier.id, updatedSupplier);
  }

  Future<void> deleteSupplier(String id) async {
    final supplier = _box.get(id);
    if (supplier != null) {
      final deletedSupplier = SupplierModel(
        id: supplier.id,
        name: supplier.name,
        phone: supplier.phone,
        email: supplier.email,
        gstin: supplier.gstin,
        outstandingBalance: supplier.outstandingBalance,
        address: supplier.address,
        isSynced: false,
        operation: supplier.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.delete,
        createdAt: supplier.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      );
      await _box.put(deletedSupplier.id, deletedSupplier);
    }
  }
}

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository();
});
