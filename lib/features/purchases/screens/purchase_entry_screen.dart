import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/purchases/repositories/purchase_repository.dart';
import 'package:rk_enterprises/features/purchases/models/purchase_model.dart';
import 'package:rk_enterprises/features/suppliers/repositories/supplier_repository.dart';
import 'package:rk_enterprises/features/suppliers/models/supplier_model.dart';
import 'package:intl/intl.dart';

class PurchaseEntryScreen extends ConsumerStatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  ConsumerState<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends ConsumerState<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _billNoController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  SupplierModel? _selectedSupplier;
  DateTime _purchaseDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _billNoController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  void _savePurchase() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSupplier == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a supplier')));
        return;
      }
      
      setState(() => _isLoading = true);
      
      final purchase = PurchaseModel(
        id: '', 
        supplierId: _selectedSupplier!.id,
        supplierName: _selectedSupplier!.name,
        purchaseDate: _purchaseDate,
        purchaseNumber: _billNoController.text.trim(),
        items: [], // Simplified: items added later
        grandTotal: double.tryParse(_amountController.text) ?? 0,
        paymentMethod: 'Cash',
        amountPaid: 0, // Simplified: assume unpaid initially, add payment later
        isSynced: false,
        operation: 'insert',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(purchaseRepositoryProvider);
      await repo.addPurchase(purchase);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase Bill logged successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierRepositoryProvider).getSuppliers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Purchase Bill'),
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: _savePurchase,
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
              DropdownButtonFormField<SupplierModel>(
                value: _selectedSupplier,
                decoration: const InputDecoration(labelText: 'Select Supplier *', prefixIcon: Icon(Icons.business)),
                items: suppliers.map((SupplierModel supplier) {
                  return DropdownMenuItem<SupplierModel>(
                    value: supplier,
                    child: Text(supplier.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSupplier = newValue;
                  });
                },
                validator: (val) => val == null ? 'Please select a supplier' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_purchaseDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _billNoController,
                decoration: const InputDecoration(labelText: 'Reference Bill No / Invoice No', prefixIcon: Icon(Icons.receipt)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Total Amount (₹) *', prefixIcon: Icon(Icons.currency_rupee)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Item Descriptions / Notes', prefixIcon: Icon(Icons.note)),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePurchase,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Purchase', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
