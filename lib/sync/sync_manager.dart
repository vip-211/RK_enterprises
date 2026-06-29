import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:rk_enterprises/models/sync_model.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Logger _logger = Logger();
  bool _isSyncing = false;
  StreamSubscription? _internetSubscription;

  void init() {
    _internetSubscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.connected) {
        _logger.i('Internet connected. Starting sync...');
        syncAllPendingData();
      }
    });
  }

  void dispose() {
    _internetSubscription?.cancel();
  }

  Future<void> syncAllPendingData() async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      _logger.i('--- SYNC STARTED ---');
      
      bool hasInternet = await InternetConnection().hasInternetAccess;
      if (!hasInternet) {
        _logger.w('No internet connection. Sync aborted.');
        return;
      }
      
      // Fetch pending data
      final invoiceBox = await Hive.openBox<InvoiceModel>('invoices');
      final pendingInvoices = invoiceBox.values.where((inv) => !inv.isSynced).toList();

      for (var invoice in pendingInvoices) {
        try {
          if (invoice.operation == SyncOperation.insert || invoice.operation == SyncOperation.update) {
            await FirebaseFirestore.instance.collection('invoices').doc(invoice.id).set(invoice.toMap());
          } else if (invoice.operation == SyncOperation.delete) {
            await FirebaseFirestore.instance.collection('invoices').doc(invoice.id).delete();
          }
          
          // Mark as synced locally
          final syncedInvoice = InvoiceModel(
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
            isSynced: true, // Marked true!
            operation: SyncOperation.insert,
            createdAt: invoice.createdAt,
            updatedAt: DateTime.now(),
            deletedAt: invoice.deletedAt,
          );
          await invoiceBox.put(invoice.id, syncedInvoice);
        } catch (e) {
          _logger.e('Failed to sync invoice ${invoice.id}: $e');
        }
      }
      
      // Pull new data from Firestore
      final snapshot = await FirebaseFirestore.instance.collection('invoices').get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final pulledInvoice = InvoiceModel.fromMap(data);
        // Only put if we don't have it, or ours is older (simplistic conflict resolution)
        final localInvoice = invoiceBox.get(pulledInvoice.id);
        if (localInvoice == null || pulledInvoice.updatedAt.isAfter(localInvoice.updatedAt)) {
          await invoiceBox.put(pulledInvoice.id, pulledInvoice);
        }
      }

      _logger.i('--- SYNC COMPLETED SUCCESSFULLY ---');
    } catch (e) {
      _logger.e('Sync Failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
