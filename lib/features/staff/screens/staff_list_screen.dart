import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/staff/repositories/staff_repository.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(staffRepositoryProvider);
    final staffList = repo.getStaff();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/staff-entry');
            },
          ),
        ],
      ),
      body: staffList.isEmpty
          ? const Center(child: Text('No staff members found. Tap + to add.'))
          : ListView.builder(
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(staff.name[0].toUpperCase())),
                  title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${staff.role} • ${staff.phone}'),
                  trailing: Text('₹${staff.salary.toStringAsFixed(0)} / mo', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Staff?'),
                        content: Text('Are you sure you want to remove ${staff.name}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              repo.deleteStaff(staff.id);
                              Navigator.pop(c);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff deleted')));
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
