import 'package:rk_enterprises/models/sync_model.dart';
import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 2)
class CustomerModel implements SyncModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? whatsapp;

  @HiveField(4)
  final String? gstin;

  @HiveField(5)
  final String? email;

  @HiveField(6)
  final double creditLimit;

  @HiveField(7)
  final double outstandingBalance;

  @HiveField(8)
  final String address;

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

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.whatsapp,
    this.gstin,
    this.email,
    required this.creditLimit,
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
      'whatsapp': whatsapp,
      'gstin': gstin,
      'email': email,
      'creditLimit': creditLimit,
      'outstandingBalance': outstandingBalance,
      'address': address,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      whatsapp: map['whatsapp'],
      gstin: map['gstin'],
      email: map['email'],
      creditLimit: map['creditLimit'],
      outstandingBalance: map['outstandingBalance'],
      address: map['address'],
      isSynced: map['isSynced'] ?? true,
      operation: map['operation'] ?? SyncOperation.insert,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }
}
