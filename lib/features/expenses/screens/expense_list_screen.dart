import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/expenses/models/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/expense-entry');
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<ExpenseModel>>(
        valueListenable: Hive.box<ExpenseModel>(HiveBoxes.expenses).listenable(),
        builder: (context, box, _) {
          final expenses = box.values.where((e) => e.deletedAt == null).toList();
          return expenses.isEmpty
              ? const Center(child: Text('No expenses found.'))
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.money_off)),
                      title: Text(expense.category),
                      subtitle: Text(DateFormat('dd-MMM-yyyy').format(expense.date)),
                      trailing: Text(
                        '₹${expense.amount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        // Navigate to details
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
