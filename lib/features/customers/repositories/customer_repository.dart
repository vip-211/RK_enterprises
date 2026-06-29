import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/customers/models/customer_model.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/models/sync_model.dart';

class CustomerRepository {
  final Box<CustomerModel> _box = Hive.box<CustomerModel>(HiveBoxes.customers);

  List<CustomerModel> getCustomers() {
    return _box.values.where((c) => c.deletedAt == null).toList();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    final newCustomer = CustomerModel(
      id: const Uuid().v4(),
      name: customer.name,
      phone: customer.phone,
      whatsapp: customer.whatsapp,
      gstin: customer.gstin,
      email: customer.email,
      creditLimit: customer.creditLimit,
      outstandingBalance: customer.outstandingBalance,
      address: customer.address,
      isSynced: false,
      operation: SyncOperation.insert,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _box.put(newCustomer.id, newCustomer);
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final updatedCustomer = CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      whatsapp: customer.whatsapp,
      gstin: customer.gstin,
      email: customer.email,
      creditLimit: customer.creditLimit,
      outstandingBalance: customer.outstandingBalance,
      address: customer.address,
      isSynced: false,
      operation: customer.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.update,
      createdAt: customer.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: customer.deletedAt,
    );
    await _box.put(updatedCustomer.id, updatedCustomer);
  }

  Future<void> deleteCustomer(String id) async {
    final customer = _box.get(id);
    if (customer != null) {
      final deletedCustomer = CustomerModel(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        whatsapp: customer.whatsapp,
        gstin: customer.gstin,
        email: customer.email,
        creditLimit: customer.creditLimit,
        outstandingBalance: customer.outstandingBalance,
        address: customer.address,
        isSynced: false,
        operation: customer.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.delete,
        createdAt: customer.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      );
      await _box.put(deletedCustomer.id, deletedCustomer);
    }
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});
