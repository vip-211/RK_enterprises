import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/inventory/models/product_model.dart';

class BarcodePrintScreen extends ConsumerStatefulWidget {
  const BarcodePrintScreen({super.key});

  @override
  ConsumerState<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends ConsumerState<BarcodePrintScreen> {
  ProductModel? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController(text: '12'); // Default to 12 labels
  
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final box = Hive.box<ProductModel>(HiveBoxes.products);
    setState(() {
      _products = box.values.where((p) => p.deletedAt == null && p.barcode != null && p.barcode!.isNotEmpty).toList();
      if (_products.isNotEmpty) {
        _selectedProduct = _products.first;
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    
    if (_selectedProduct == null) {
      // Empty PDF if nothing selected
      pdf.addPage(pw.Page(build: (context) => pw.Center(child: pw.Text('No Product Selected'))));
      return pdf.save();
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    
    // We want to draw a grid of labels. Let's say 4 columns on an A4 sheet.
    const columns = 4;
    
    final labels = List.generate(quantity, (index) {
      return pw.Container(
        width: format.availableWidth / columns - 10,
        height: 100,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('RK Enterprises', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(
              _selectedProduct!.name, 
              style: const pw.TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: pw.TextOverflow.clip,
            ),
            pw.SizedBox(height: 4),
            pw.BarcodeWidget(
              data: _selectedProduct!.barcode!,
              barcode: pw.Barcode.code128(),
              width: 100,
              height: 40,
              drawText: true,
              textStyle: const pw.TextStyle(fontSize: 8),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Price: Rs. ${_selectedProduct!.sellingPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        )
      );
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) {
          return [
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: labels,
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Barcodes'),
      ),
      body: _products.isEmpty
          ? const Center(child: Text('No products with barcodes found.\nAdd a barcode to a product first.', textAlign: TextAlign.center))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<ProductModel>(
                          value: _selectedProduct,
                          decoration: const InputDecoration(labelText: 'Select Product', prefixIcon: Icon(Icons.inventory)),
                          items: _products.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text('${p.name} (${p.barcode})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedProduct = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(labelText: 'Quantity', prefixIcon: Icon(Icons.numbers)),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setState(() {}); // Trigger rebuild to update PDF preview
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PdfPreview(
                    build: _generatePdf,
                    initialPageFormat: PdfPageFormat.a4,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                  ),
                ),
              ],
            ),
    );
  }
}
