import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/models/sync_model.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/authentication/models/user_model.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
import 'package:rk_enterprises/features/customers/models/customer_model.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';
import 'package:rk_enterprises/features/purchases/models/purchase_model.dart';
import 'package:rk_enterprises/features/expenses/models/expense_model.dart';
import 'package:rk_enterprises/features/staff/models/staff_model.dart';
import 'package:rk_enterprises/features/suppliers/models/supplier_model.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Logger _logger = Logger();
  bool _isSyncing = false;
  StreamSubscription? _internetSubscription;
  final List<StreamSubscription> _snapshotSubscriptions = [];

  void init() {
    _internetSubscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.connected) {
        _logger.i('Internet connected. Starting sync and listeners...');
        syncAllPendingData();
        _startRealTimeListeners();
      } else {
        _logger.i('Internet disconnected. Stopping listeners...');
        _stopRealTimeListeners();
      }
    });
  }

  void dispose() {
    _internetSubscription?.cancel();
    _stopRealTimeListeners();
  }
  
  void _stopRealTimeListeners() {
    for (var sub in _snapshotSubscriptions) {
      sub.cancel();
    }
    _snapshotSubscriptions.clear();
  }

  void _startRealTimeListeners() {
    if (_snapshotSubscriptions.isNotEmpty) return; // already listening

    _listenToCollection<UserModel>('users', HiveBoxes.users, UserModel.fromMap);
    _listenToCollection<ProductModel>('products', HiveBoxes.products, ProductModel.fromMap);
    _listenToCollection<CustomerModel>('customers', HiveBoxes.customers, CustomerModel.fromMap);
    _listenToCollection<SupplierModel>('suppliers', HiveBoxes.suppliers, SupplierModel.fromMap);
    _listenToCollection<InvoiceModel>('invoices', HiveBoxes.invoices, InvoiceModel.fromMap);
    _listenToCollection<PurchaseModel>('purchases', HiveBoxes.purchases, PurchaseModel.fromMap);
    _listenToCollection<ExpenseModel>('expenses', HiveBoxes.expenses, ExpenseModel.fromMap);
    _listenToCollection<StaffModel>('staff', HiveBoxes.staff, StaffModel.fromMap);
  }

  void _listenToCollection<T extends SyncModel>(String collectionName, String boxName, T Function(Map<String, dynamic>) fromMap) {
    try {
      final box = Hive.box<T>(boxName);
      final sub = FirebaseFirestore.instance.collection(collectionName).snapshots().listen((snapshot) async {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
             if (change.doc.data() != null) {
                final pulledItem = fromMap(change.doc.data()!);
                final localItem = box.get(pulledItem.id);
                // Only overwrite if it's newer, to prevent overwriting local pending changes with old cloud state
                if (localItem == null || pulledItem.updatedAt.isAfter(localItem.updatedAt)) {
                  await box.put(pulledItem.id, pulledItem);
                }
             }
          } else if (change.type == DocumentChangeType.removed) {
             await box.delete(change.doc.id);
          }
        }
      });
      _snapshotSubscriptions.add(sub);
    } catch (e) {
      _logger.e('Failed to start listener for $collectionName: $e');
    }
  }

  Future<void> syncAllPendingData() async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      _logger.i('--- GLOBAL SYNC STARTED ---');
      
      bool hasInternet = await InternetConnection().hasInternetAccess;
      if (!hasInternet) {
        _logger.w('No internet connection. Sync aborted.');
        return;
      }
      
      await _syncCollection<UserModel>('users', HiveBoxes.users, UserModel.fromMap);
      await _syncCollection<ProductModel>('products', HiveBoxes.products, ProductModel.fromMap);
      await _syncCollection<CustomerModel>('customers', HiveBoxes.customers, CustomerModel.fromMap);
      await _syncCollection<SupplierModel>('suppliers', HiveBoxes.suppliers, SupplierModel.fromMap);
      await _syncCollection<InvoiceModel>('invoices', HiveBoxes.invoices, InvoiceModel.fromMap);
      await _syncCollection<PurchaseModel>('purchases', HiveBoxes.purchases, PurchaseModel.fromMap);
      await _syncCollection<ExpenseModel>('expenses', HiveBoxes.expenses, ExpenseModel.fromMap);
      await _syncCollection<StaffModel>('staff', HiveBoxes.staff, StaffModel.fromMap);

      _logger.i('--- GLOBAL SYNC COMPLETED SUCCESSFULLY ---');
    } catch (e) {
      _logger.e('Sync Failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncCollection<T extends SyncModel>(String collectionName, String boxName, T Function(Map<String, dynamic>) fromMap) async {
    try {
      final box = Hive.box<T>(boxName);
      final pendingItems = box.values.where((item) => !item.isSynced).toList();

      for (var item in pendingItems) {
        try {
          if (item.operation == SyncOperation.insert || item.operation == SyncOperation.update) {
            await FirebaseFirestore.instance.collection(collectionName).doc(item.id).set(item.toMap());
          } else if (item.operation == SyncOperation.delete) {
            await FirebaseFirestore.instance.collection(collectionName).doc(item.id).delete();
          }
          
          // Mark as synced locally
          final map = item.toMap();
          map['isSynced'] = true;
          final syncedItem = fromMap(map);
          await box.put(item.id, syncedItem);
        } catch (e) {
          _logger.e('Failed to sync $collectionName item ${item.id}: $e');
        }
      }
    } catch (e) {
      _logger.e('Failed to process collection $collectionName: $e');
    }
  }
}
