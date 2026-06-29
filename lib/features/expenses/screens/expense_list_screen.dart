import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/expenses/repositories/expense_repository.dart';
import 'package:intl/intl.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(expenseRepositoryProvider);
    final expenses = repo.getExpenses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create Expense screen coming soon!')));
            },
          ),
        ],
      ),
      body: expenses.isEmpty
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
            ),
    );
  }
}
