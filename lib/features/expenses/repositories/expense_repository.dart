import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/expenses/models/expense_model.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/models/sync_model.dart';

class ExpenseRepository {
  final Box<ExpenseModel> _box = Hive.box<ExpenseModel>(HiveBoxes.expenses);

  List<ExpenseModel> getExpenses() {
    return _box.values.where((e) => e.deletedAt == null).toList();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final newExpense = ExpenseModel(
      id: const Uuid().v4(),
      category: expense.category,
      amount: expense.amount,
      date: expense.date,
      notes: expense.notes,
      isSynced: false,
      operation: SyncOperation.insert,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _box.put(newExpense.id, newExpense);
  }

  Future<void> deleteExpense(String id) async {
    final expense = _box.get(id);
    if (expense != null) {
      final deletedExpense = ExpenseModel(
        id: expense.id,
        category: expense.category,
        amount: expense.amount,
        date: expense.date,
        notes: expense.notes,
        isSynced: false,
        operation: expense.operation == SyncOperation.insert ? SyncOperation.insert : SyncOperation.delete,
        createdAt: expense.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      );
      await _box.put(deletedExpense.id, deletedExpense);
    }
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});
