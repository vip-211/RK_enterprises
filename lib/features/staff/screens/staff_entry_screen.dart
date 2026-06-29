import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/staff/repositories/staff_repository.dart';
import 'package:rk_enterprises/features/staff/models/staff_model.dart';

class StaffEntryScreen extends ConsumerStatefulWidget {
  const StaffEntryScreen({super.key});

  @override
  ConsumerState<StaffEntryScreen> createState() => _StaffEntryScreenState();
}

class _StaffEntryScreenState extends ConsumerState<StaffEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();
  
  String _selectedRole = 'Sales';
  bool _isLoading = false;
  
  final List<String> _roles = ['Admin', 'Manager', 'Sales', 'Cashier', 'Delivery', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _saveStaff() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final staff = StaffModel(
        id: '', // Handled by repository
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        salary: double.tryParse(_salaryController.text) ?? 0,
        isSynced: false,
        operation: 'insert',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(staffRepositoryProvider);
      await repo.addStaff(staff);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff member saved successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Staff'),
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveStaff,
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Staff Name *', prefixIcon: Icon(Icons.person)),
                validator: (val) => val == null || val.isEmpty ? 'Please enter staff name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a phone number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Job Role', prefixIcon: Icon(Icons.work)),
                items: _roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Monthly Salary (₹)', prefixIcon: Icon(Icons.payments)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveStaff,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Staff Member', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
