import 'package:rk_enterprises/models/sync_model.dart';
import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 8)
class ExpenseModel implements SyncModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String category; // e.g. Rent, Electricity, Tea, Travel

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? notes;

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

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
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
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'isSynced': isSynced,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
