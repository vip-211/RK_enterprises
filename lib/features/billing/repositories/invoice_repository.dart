import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/models/sync_model.dart';
import 'package:rk_enterprises/services/notification_service.dart';

class InvoiceRepository {
  final Box<InvoiceModel> _box = Hive.box<InvoiceModel>(HiveBoxes.invoices);

  List<InvoiceModel> getInvoices() {
    return _box.values.where((i) => i.deletedAt == null).toList();
  }

  Future<void> addInvoice(InvoiceModel invoice) async {
    final newInvoice = InvoiceModel(
      id: const Uuid().v4(),
      invoiceNumber: invoice.invoiceNumber,
      invoiceDate: invoice.invoiceDate,
      customerId: invoice.customerId,
      customerName: invoice.customerName,
      items: invoice.items,
      subTotal: invoice.subTotal,
      totalDiscount: invoice.totalDiscount,
      totalGst: invoice.totalGst,
      roundOff: invoice.roundOff,
      grandTotal: invoice.grandTotal,
      paymentMethod: invoice.paymentMethod,
      amountPaid: invoice.amountPaid,
      notes: invoice.notes,
      isSynced: false,
      operation: SyncOperation.insert,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _box.put(newInvoice.id, newInvoice);
    
    // Broadcast push notification
    try {
      await NotificationService().broadcastNewInvoice(newInvoice.id, newInvoice.invoiceNumber);
    } catch (e) {
      // Ignore broadcast errors so invoice creation doesn't fail
    }
  }

  Future<void> deleteInvoice(String id) async {
    final invoice = _box.get(id);
    if (invoice != null) {
      final deletedInvoice = InvoiceModel(
        id: invoice.id,
        invoiceNumber: invoice.invoiceNumber,
        invoiceDate: invoice.invoiceDate,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        items: invoice.items,
        subTotal: invoice.subTotal,
        totalDiscount: invoice.totalDiscount,
        totalGst: invoice.totalGst,
        roundOff: invoice.roundOff,
        grandTotal: invoice.grandTotal,
        paymentMethod: invoice.paymentMethod,
        amountPaid: invoice.amountPaid,
        notes: invoice.notes,
        isSynced: false,
        operation: invoice.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.delete,
        createdAt: invoice.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      );
      await _box.put(deletedInvoice.id, deletedInvoice);
    }
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository();
});
