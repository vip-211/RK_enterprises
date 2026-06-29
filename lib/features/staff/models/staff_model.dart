import 'package:hive/hive.dart';
import 'package:rk_enterprises/models/sync_model.dart';

part 'staff_model.g.dart';

@HiveType(typeId: 9)
class StaffModel extends HiveObject implements SyncModel {
  @override
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final double salary;

  @override
  @HiveField(5)
  final bool isSynced;

  @override
  @HiveField(6)
  final String operation;

  @override
  @HiveField(7)
  final DateTime createdAt;

  @override
  @HiveField(8)
  final DateTime updatedAt;

  @override
  @HiveField(9)
  final DateTime? deletedAt;

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.salary,
    this.isSynced = false,
    this.operation = SyncOperation.insert,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'salary': salary,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      role: map['role'],
      salary: map['salary'],
      isSynced: map['isSynced'],
      operation: map['operation'] ?? SyncOperation.insert,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }
}
