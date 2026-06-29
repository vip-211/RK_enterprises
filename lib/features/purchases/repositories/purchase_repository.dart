import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/purchases/models/purchase_model.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/models/sync_model.dart';

class PurchaseRepository {
  final Box<PurchaseModel> _box = Hive.box<PurchaseModel>(HiveBoxes.purchases);

  List<PurchaseModel> getPurchases() {
    return _box.values.where((p) => p.deletedAt == null).toList();
  }

  Future<void> addPurchase(PurchaseModel purchase) async {
    final newPurchase = PurchaseModel(
      id: const Uuid().v4(),
      purchaseNumber: purchase.purchaseNumber,
      purchaseDate: purchase.purchaseDate,
      supplierId: purchase.supplierId,
      supplierName: purchase.supplierName,
      items: purchase.items,
      grandTotal: purchase.grandTotal,
      paymentMethod: purchase.paymentMethod,
      amountPaid: purchase.amountPaid,
      isSynced: false,
      operation: SyncOperation.insert,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _box.put(newPurchase.id, newPurchase);
  }

  Future<void> deletePurchase(String id) async {
    final purchase = _box.get(id);
    if (purchase != null) {
      final deletedPurchase = PurchaseModel(
        id: purchase.id,
        purchaseNumber: purchase.purchaseNumber,
        purchaseDate: purchase.purchaseDate,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplierName,
        items: purchase.items,
        grandTotal: purchase.grandTotal,
        paymentMethod: purchase.paymentMethod,
        amountPaid: purchase.amountPaid,
        isSynced: false,
        operation: purchase.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.delete,
        createdAt: purchase.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      );
      await _box.put(deletedPurchase.id, deletedPurchase);
    }
  }
}

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository();
});
