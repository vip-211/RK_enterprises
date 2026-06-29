import 'package:rk_enterprises/models/sync_model.dart';
import 'package:hive/hive.dart';

part 'supplier_model.g.dart';

@HiveType(typeId: 3)
class SupplierModel implements SyncModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String? gstin;

  @HiveField(5)
  final double outstandingBalance;

  @HiveField(6)
  final String address;

  @HiveField(7)
  @override
  final bool isSynced;

  @HiveField(8)
  @override
  final String operation;

  @HiveField(9)
  @override
  final DateTime createdAt;

  @HiveField(10)
  @override
  final DateTime updatedAt;

  @HiveField(11)
  @override
  final DateTime? deletedAt;

  SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gstin,
    required this.outstandingBalance,
    required this.address,
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
      'phone': phone,
      'email': email,
      'gstin': gstin,
      'outstandingBalance': outstandingBalance,
      'address': address,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
