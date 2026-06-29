import 'package:rk_enterprises/models/sync_model.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel implements SyncModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String role; // 'Super Admin', 'Admin', 'Manager', 'Employee', 'Cashier'

  @HiveField(5)
  @override
  final bool isSynced;

  @HiveField(6)
  @override
  final String operation;

  @HiveField(7)
  @override
  final DateTime createdAt;

  @HiveField(8)
  @override
  final DateTime updatedAt;

  @HiveField(9)
  @override
  final DateTime? deletedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
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
      'email': email,
      'phone': phone,
      'role': role,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
      isSynced: map['isSynced'] ?? true,
      operation: map['operation'] ?? SyncOperation.insert,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }
}
