import 'package:rk_enterprises/models/sync_model.dart';
import 'package:hive/hive.dart';

part 'purchase_model.g.dart';

@HiveType(typeId: 6)
class PurchaseItemModel {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final double purchasePrice;

  @HiveField(4)
  final double totalAmount;

  PurchaseItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.totalAmount,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'totalAmount': totalAmount,
    };
  }
}

@HiveType(typeId: 7)
class PurchaseModel implements SyncModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String purchaseNumber;

  @HiveField(2)
  final DateTime purchaseDate;

  @HiveField(3)
  final String supplierId;

  @HiveField(4)
  final String supplierName;

  @HiveField(5)
  final List<PurchaseItemModel> items;

  @HiveField(6)
  final double grandTotal;

  @HiveField(7)
  final String paymentMethod; 

  @HiveField(8)
  final double amountPaid;

  @HiveField(9)
  @override
  final bool isSynced;

  @HiveField(10)
  @override
  final String operation;

  @HiveField(11)
  @override
  final DateTime createdAt;

  @HiveField(12)
  @override
  final DateTime updatedAt;

  @HiveField(13)
  @override
  final DateTime? deletedAt;

  PurchaseModel({
    required this.id,
    required this.purchaseNumber,
    required this.purchaseDate,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.grandTotal,
    required this.paymentMethod,
    required this.amountPaid,
    this.isSynced = false,
    this.operation = SyncOperation.insert,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchaseNumber': purchaseNumber,
      'purchaseDate': purchaseDate.toIso8601String(),
      'supplierId': supplierId,
      'supplierName': supplierName,
      'items': items.map((e) => e.toMap()).toList(),
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
