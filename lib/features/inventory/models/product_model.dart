import 'package:rk_enterprises/models/sync_model.dart';
import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class ProductModel implements SyncModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String sku;

  @HiveField(3)
  final String? barcode;

  @HiveField(4)
  final double purchasePrice;

  @HiveField(5)
  final double sellingPrice;

  @HiveField(6)
  final double mrp;

  @HiveField(7)
  final double gstPercentage;

  @HiveField(8)
  final String hsnCode;

  @HiveField(9)
  final double openingStock;

  @HiveField(10)
  final double currentStock;

  @HiveField(11)
  final double minimumStock;

  @HiveField(12)
  final String brand;

  @HiveField(13)
  final String category;

  @HiveField(14)
  final String unit; // e.g. PCS, KG, LTR

  @HiveField(15)
  final String? imageUrl;

  @HiveField(16)
  @override
  final bool isSynced;

  @HiveField(17)
  @override
  final String operation;

  @HiveField(18)
  @override
  final DateTime createdAt;

  @HiveField(19)
  @override
  final DateTime updatedAt;

  @HiveField(20)
  @override
  final DateTime? deletedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.mrp,
    required this.gstPercentage,
    required this.hsnCode,
    required this.openingStock,
    required this.currentStock,
    required this.minimumStock,
    required this.brand,
    required this.category,
    required this.unit,
    this.imageUrl,
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
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'mrp': mrp,
      'gstPercentage': gstPercentage,
      'hsnCode': hsnCode,
      'openingStock': openingStock,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'brand': brand,
      'category': category,
      'unit': unit,
      'imageUrl': imageUrl,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      sku: map['sku'],
      barcode: map['barcode'],
      purchasePrice: map['purchasePrice'],
      sellingPrice: map['sellingPrice'],
      mrp: map['mrp'],
      gstPercentage: map['gstPercentage'],
      hsnCode: map['hsnCode'],
      openingStock: map['openingStock'],
      currentStock: map['currentStock'],
      minimumStock: map['minimumStock'],
      brand: map['brand'],
      category: map['category'],
      unit: map['unit'],
      imageUrl: map['imageUrl'],
      isSynced: map['isSynced'] ?? true,
      operation: map['operation'] ?? SyncOperation.insert,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }
}
