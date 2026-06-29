import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/staff/repositories/staff_repository.dart';
import 'package:rk_enterprises/features/staff/models/staff_model.dart';
import 'package:rk_enterprises/features/authentication/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/core/utils/password_utils.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'Sales';
  bool _isLoading = false;
  
  final List<String> _roles = ['Admin', 'Manager', 'Sales', 'Cashier', 'Delivery', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
      final staffId = await repo.addStaff(staff);
      
      // Auto-generate User Account for Login
      if (_passwordController.text.isNotEmpty) {
        final userBox = Hive.box<UserModel>(HiveBoxes.users);
        final user = UserModel(
          id: staffId, // Match Staff ID
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          password: PasswordUtils.hashPassword(_passwordController.text),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await userBox.put(staffId, user);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff member and login saved!')),
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
              const SizedBox(height: 24),
              const Text('App Login Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              const Divider(),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address (Optional)', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Login Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
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
