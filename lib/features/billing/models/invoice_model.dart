import 'package:rk_enterprises/models/sync_model.dart';
import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 4)
class InvoiceItemModel {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final double unitPrice;

  @HiveField(4)
  final double discountAmount;

  @HiveField(5)
  final double gstPercentage;

  @HiveField(6)
  final double gstAmount;

  @HiveField(7)
  final double totalAmount;

  InvoiceItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.gstPercentage,
    required this.gstAmount,
    required this.totalAmount,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountAmount': discountAmount,
      'gstPercentage': gstPercentage,
      'gstAmount': gstAmount,
      'totalAmount': totalAmount,
    };
  }

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      discountAmount: map['discountAmount'],
      gstPercentage: map['gstPercentage'],
      gstAmount: map['gstAmount'],
      totalAmount: map['totalAmount'],
    );
  }
}

@HiveType(typeId: 5)
class InvoiceModel implements SyncModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String invoiceNumber;

  @HiveField(2)
  final DateTime invoiceDate;

  @HiveField(3)
  final String? customerId;

  @HiveField(4)
  final String? customerName;

  @HiveField(5)
  final List<InvoiceItemModel> items;

  @HiveField(6)
  final double subTotal;

  @HiveField(7)
  final double totalDiscount;

  @HiveField(8)
  final double totalGst;

  @HiveField(9)
  final double roundOff;

  @HiveField(10)
  final double grandTotal;

  @HiveField(11)
  final String paymentMethod; // Cash, UPI, Card, Credit, Split

  @HiveField(12)
  final double amountPaid;

  @HiveField(13)
  final String? notes;

  @HiveField(14)
  @override
  final bool isSynced;

  @HiveField(15)
  @override
  final String operation;

  @HiveField(16)
  @override
  final DateTime createdAt;

  @HiveField(17)
  @override
  final DateTime updatedAt;

  @HiveField(18)
  @override
  final DateTime? deletedAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.customerId,
    this.customerName,
    required this.items,
    required this.subTotal,
    required this.totalDiscount,
    required this.totalGst,
    required this.roundOff,
    required this.grandTotal,
    required this.paymentMethod,
    required this.amountPaid,
    this.notes,
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
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((e) => e.toMap()).toList(),
      'subTotal': subTotal,
      'totalDiscount': totalDiscount,
      'totalGst': totalGst,
      'roundOff': roundOff,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid,
      'notes': notes,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      invoiceDate: DateTime.parse(map['invoiceDate']),
      customerId: map['customerId'],
      customerName: map['customerName'],
      items: List<InvoiceItemModel>.from(map['items']?.map((x) => InvoiceItemModel.fromMap(x))),
      subTotal: map['subTotal'],
      totalDiscount: map['totalDiscount'],
      totalGst: map['totalGst'],
      roundOff: map['roundOff'],
      grandTotal: map['grandTotal'],
      paymentMethod: map['paymentMethod'],
      amountPaid: map['amountPaid'],
      notes: map['notes'],
      isSynced: true, // If it comes from Firestore, it is synced
      operation: SyncOperation.insert,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }
}
