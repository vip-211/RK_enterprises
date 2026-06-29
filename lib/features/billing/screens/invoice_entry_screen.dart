import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/billing/repositories/invoice_repository.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
import 'package:rk_enterprises/features/customers/repositories/customer_repository.dart';
import 'package:rk_enterprises/features/customers/models/customer_model.dart';
import 'package:rk_enterprises/features/inventory/repositories/product_repository.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class InvoiceEntryScreen extends ConsumerStatefulWidget {
  const InvoiceEntryScreen({super.key});

  @override
  ConsumerState<InvoiceEntryScreen> createState() => _InvoiceEntryScreenState();
}

class _InvoiceEntryScreenState extends ConsumerState<InvoiceEntryScreen> {
  CustomerModel? _selectedCustomer;
  final List<InvoiceItemModel> _items = [];
  
  double _discount = 0;
  bool _isLoading = false;

  void _addProduct() {
    final products = ref.read(productRepositoryProvider).getProducts();
    
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add products to inventory first.')));
      return;
    }

    ProductModel? selectedProduct;
    final qtyController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ProductModel>(
                    value: selectedProduct,
                    decoration: const InputDecoration(labelText: 'Select Product'),
                    items: products.map((ProductModel prod) {
                      return DropdownMenuItem<ProductModel>(
                        value: prod,
                        child: Text('${prod.name} (₹${prod.sellingPrice})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedProduct = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final p = selectedProduct;
                    if (p != null) {
                      final qty = double.tryParse(qtyController.text) ?? 1;
                      
                      // Calculate item totals
                      final basePrice = p.sellingPrice * qty;
                      final tax = basePrice * (p.gstPercentage / 100);
                      final total = basePrice + tax;

                      setState(() {
                        _items.add(InvoiceItemModel(
                          productId: p.id,
                          productName: p.name,
                          quantity: qty,
                          unitPrice: p.sellingPrice,
                          discountAmount: 0,
                          gstPercentage: p.gstPercentage,
                          gstAmount: tax,
                          totalAmount: total,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      }
    );
  }

  void _scanProduct() async {
    final products = ref.read(productRepositoryProvider).getProducts();
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add products to inventory first.')));
      return;
    }

    bool keepScanning = true;
    while (keepScanning) {
      if (!mounted) break;
      String? res = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Scan Product Barcode',
          centerTitle: false,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        delayMillis: 500,
        cameraFace: CameraFace.back,
      );

      if (res != null && res != '-1') {
        final match = products.where((p) => p.barcode == res || p.sku == res).toList();
        if (!mounted) return;
        if (match.isNotEmpty) {
          final p = match.first;
          final existingIndex = _items.indexWhere((item) => item.productId == p.id);
          
          setState(() {
            if (existingIndex >= 0) {
              final existing = _items[existingIndex];
              final newQty = existing.quantity + 1;
              final basePrice = p.sellingPrice * newQty;
              final tax = basePrice * (p.gstPercentage / 100);
              final total = basePrice + tax;
              
              _items[existingIndex] = InvoiceItemModel(
                productId: existing.productId,
                productName: existing.productName,
                quantity: newQty,
                unitPrice: existing.unitPrice,
                discountAmount: existing.discountAmount,
                gstPercentage: existing.gstPercentage,
                gstAmount: tax,
                totalAmount: total,
              );
            } else {
              final qty = 1.0;
              final basePrice = p.sellingPrice * qty;
              final tax = basePrice * (p.gstPercentage / 100);
              final total = basePrice + tax;
              
              _items.add(InvoiceItemModel(
                productId: p.id,
                productName: p.name,
                quantity: qty,
                unitPrice: p.sellingPrice,
                discountAmount: 0,
                gstPercentage: p.gstPercentage,
                gstAmount: tax,
                totalAmount: total,
              ));
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${p.name}')));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product not found for barcode: $res')));
          }
          keepScanning = false;
        }
      } else {
        keepScanning = false; // User cancelled or closed scanner
      }
    }
  }

  void _saveInvoice() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item.')));
      return;
    }

    setState(() => _isLoading = true);

    // Generate Invoice Number
    final invoices = ref.read(invoiceRepositoryProvider).getInvoices();
    final invoiceNo = 'INV-${(invoices.length + 1).toString().padLeft(4, '0')}';

    // Calculate totals
    double subTotal = 0;
    double totalGst = 0;
    for (var item in _items) {
      subTotal += (item.unitPrice * item.quantity);
      totalGst += item.gstAmount;
    }
    
    final amountBeforeRound = (subTotal - _discount) + totalGst;
    final grandTotal = amountBeforeRound.roundToDouble();
    final roundOff = grandTotal - amountBeforeRound;

    final invoice = InvoiceModel(
      id: '',
      invoiceNumber: invoiceNo,
      invoiceDate: DateTime.now(),
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
      items: _items,
      subTotal: subTotal,
      totalDiscount: _discount,
      totalGst: totalGst,
      roundOff: roundOff,
      grandTotal: grandTotal,
      paymentMethod: 'Cash',
      amountPaid: grandTotal, 
      notes: '',
      isSynced: false,
      operation: 'insert',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(invoiceRepositoryProvider).addInvoice(invoice);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice generated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerRepositoryProvider).getCustomers();

    // Live Totals
    double liveSubTotal = 0;
    double liveGst = 0;
    for (var item in _items) {
      liveSubTotal += (item.unitPrice * item.quantity);
      liveGst += item.gstAmount;
    }
    final liveGrandTotal = (liveSubTotal - _discount) + liveGst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveInvoice,
              ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<CustomerModel>(
              value: _selectedCustomer,
              decoration: const InputDecoration(labelText: 'Customer (Optional - Walk-in)'),
              items: customers.map((CustomerModel c) {
                return DropdownMenuItem<CustomerModel>(
                  value: c,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCustomer = val;
                });
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No items added. Tap + to add items.'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.productName),
                        subtitle: Text('${item.quantity} x ₹${item.unitPrice} (+${item.gstPercentage}% GST)'),
                        trailing: Text('₹${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        onLongPress: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('₹${liveSubTotal.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total GST:'),
                    Text('₹${liveGst.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('₹${liveGrandTotal.roundToDouble().toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btn_scan',
            onPressed: _scanProduct,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Item'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'btn_add',
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add Item Manually'),
          ),
        ],
      ),
    );
  }
}
