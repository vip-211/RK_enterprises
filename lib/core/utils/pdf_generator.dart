import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';
import 'package:rk_enterprises/features/settings/models/print_settings_model.dart';

class PdfGenerator {
  static Future<void> generateAndPrintInvoice(InvoiceModel invoice) async {
    final box = Hive.box<PrintSettingsModel>(HiveBoxes.printSettings);
    final settings = box.get('default') ?? PrintSettingsModel();

    final pdf = pw.Document();

    // Determine Paper Size
    PdfPageFormat format = PdfPageFormat.a4;
    switch (settings.paperSize) {
      case 'A5':
        format = PdfPageFormat.a5;
        break;
      case 'Thermal58':
        format = PdfPageFormat.roll57;
        break;
      case 'Thermal80':
        format = PdfPageFormat.roll80;
        break;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: _getMargins(settings.paperSize),
        build: (pw.Context context) {
          switch (settings.templateId) {
            case 0: return _buildA4Standard(invoice, settings);
            case 1: return _buildA4Modern(invoice, settings);
            case 2: return _buildA4Detailed(invoice, settings);
            case 3: return _buildA5Compact(invoice, settings);
            case 4: return _buildA5Modern(invoice, settings);
            case 5: return _buildThermal58Basic(invoice, settings);
            case 6: return _buildThermal58Detailed(invoice, settings);
            case 7: return _buildThermal80Supermarket(invoice, settings);
            case 8: return _buildThermal80Restaurant(invoice, settings);
            case 9: return _buildCustomDragAndDrop(invoice, settings);
            default: return _buildA4Standard(invoice, settings);
          }
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNumber}.pdf'
    );
  }

  static pw.EdgeInsets _getMargins(String paperSize) {
    if (paperSize.startsWith('Thermal')) {
      return const pw.EdgeInsets.all(10);
    }
    return const pw.EdgeInsets.all(30);
  }

  // ==========================================
  // BLOCKS FOR CUSTOM DRAG & DROP
  // ==========================================
  
  static pw.Widget _buildBlockHeader(PrintSettingsModel settings, {bool isThermal = false}) {
    return pw.Column(
      crossAxisAlignment: isThermal ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(settings.shopName, style: pw.TextStyle(fontSize: isThermal ? 16 : 24, fontWeight: pw.FontWeight.bold)),
        pw.Text(settings.shopAddress, style: pw.TextStyle(fontSize: isThermal ? 8 : 12)),
        pw.Text('Phone: ${settings.shopMobile}', style: pw.TextStyle(fontSize: isThermal ? 8 : 12)),
        if (settings.gstin.isNotEmpty) pw.Text('GSTIN: ${settings.gstin}', style: pw.TextStyle(fontSize: isThermal ? 8 : 12)),
        pw.SizedBox(height: isThermal ? 10 : 20),
      ]
    );
  }

  static pw.Widget _buildBlockCustomer(InvoiceModel invoice, {bool isThermal = false}) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: isThermal ? 10 : 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Billed To:', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, color: PdfColors.grey700)),
              pw.Text(invoice.customerName ?? 'Walk-in Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: isThermal ? 10 : 12)),
            ]
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Inv: ${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10)),
              pw.Text('Date: ${invoice.invoiceDate.toString().split(' ')[0]}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10)),
            ]
          ),
        ]
      )
    );
  }

  static pw.Widget _buildBlockItems(InvoiceModel invoice, {bool isThermal = false}) {
    if (isThermal) {
      return pw.Column(
        children: invoice.items.map((item) {
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text('${item.productName} (x${item.quantity})', style: const pw.TextStyle(fontSize: 8))),
                pw.Text(item.totalAmount.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 8)),
              ]
            ),
          );
        }).toList()
      );
    }

    return pw.TableHelper.fromTextArray(
      headers: ['Item', 'Qty', 'Price', 'GST', 'Total'],
      data: invoice.items.map((item) => [
        item.productName,
        item.quantity.toString(),
        item.unitPrice.toStringAsFixed(2),
        '${item.gstPercentage}%',
        item.totalAmount.toStringAsFixed(2),
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
    );
  }

  static pw.Widget _buildBlockTotals(InvoiceModel invoice, {bool isThermal = false}) {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: isThermal ? 10 : 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Subtotal: ${invoice.subTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: isThermal ? 8 : 12)),
              if (invoice.totalDiscount > 0) pw.Text('Discount: -${invoice.totalDiscount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: isThermal ? 8 : 12)),
              pw.Text('GST: ${invoice.totalGst.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: isThermal ? 8 : 12)),
              pw.Divider(),
              pw.Text('Grand Total: Rs ${invoice.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: isThermal ? 12 : 16, fontWeight: pw.FontWeight.bold)),
            ]
          )
        ]
      )
    );
  }

  static pw.Widget _buildBlockFooter(PrintSettingsModel settings, {bool isThermal = false}) {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: isThermal ? 20 : 40),
      alignment: pw.Alignment.center,
      child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: isThermal ? 8 : 12, fontStyle: pw.FontStyle.italic))
    );
  }

  // ==========================================
  // TEMPLATES
  // ==========================================

  // 0: A4 Standard (Classic)
  static List<pw.Widget> _buildA4Standard(InvoiceModel invoice, PrintSettingsModel settings) {
    return [
      _buildBlockHeader(settings),
      pw.Divider(),
      _buildBlockCustomer(invoice),
      _buildBlockItems(invoice),
      _buildBlockTotals(invoice),
      _buildBlockFooter(settings),
    ];
  }

  // 1: A4 Modern
  static List<pw.Widget> _buildA4Modern(InvoiceModel invoice, PrintSettingsModel settings) {
    return [
      pw.Container(
        padding: const pw.EdgeInsets.all(20),
        color: PdfColors.blue800,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(settings.shopName, style: pw.TextStyle(fontSize: 28, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                pw.Text(settings.shopAddress, style: const pw.TextStyle(color: PdfColors.white)),
              ]
            ),
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
          ]
        )
      ),
      pw.SizedBox(height: 20),
      _buildBlockCustomer(invoice),
      _buildBlockItems(invoice),
      _buildBlockTotals(invoice),
      _buildBlockFooter(settings),
    ];
  }

  // 2: A4 Detailed
  static List<pw.Widget> _buildA4Detailed(InvoiceModel invoice, PrintSettingsModel settings) {
    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildBlockHeader(settings),
          pw.BarcodeWidget(data: invoice.id, barcode: pw.Barcode.qrCode(), width: 60, height: 60),
        ]
      ),
      pw.Divider(),
      _buildBlockCustomer(invoice),
      _buildBlockItems(invoice), // Note: In a real app we'd build a wider table here
      _buildBlockTotals(invoice),
      _buildBlockFooter(settings),
    ];
  }

  // 3: A5 Compact
  static List<pw.Widget> _buildA5Compact(InvoiceModel invoice, PrintSettingsModel settings) {
    return [
      pw.Center(child: pw.Text(settings.shopName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
      pw.Center(child: pw.Text(settings.shopAddress, style: const pw.TextStyle(fontSize: 10))),
      pw.SizedBox(height: 10),
      _buildBlockCustomer(invoice, isThermal: true), // reuse thermal sizing for compactness
      _buildBlockItems(invoice),
      _buildBlockTotals(invoice),
    ];
  }

  // 4: A5 Modern
  static List<pw.Widget> _buildA5Modern(InvoiceModel invoice, PrintSettingsModel settings) {
    return _buildA4Modern(invoice, settings); // Layout scales well
  }

  // 5: Thermal 58 Basic
  static List<pw.Widget> _buildThermal58Basic(InvoiceModel invoice, PrintSettingsModel settings) {
    return [
      _buildBlockHeader(settings, isThermal: true),
      _buildBlockCustomer(invoice, isThermal: true),
      _buildBlockItems(invoice, isThermal: true),
      _buildBlockTotals(invoice, isThermal: true),
      _buildBlockFooter(settings, isThermal: true),
    ];
  }

  // 6: Thermal 58 Detailed
  static List<pw.Widget> _buildThermal58Detailed(InvoiceModel invoice, PrintSettingsModel settings) {
    return [
      pw.Center(child: pw.BarcodeWidget(data: invoice.invoiceNumber, barcode: pw.Barcode.code128(), width: 100, height: 30)),
      pw.SizedBox(height: 10),
      _buildBlockHeader(settings, isThermal: true),
      pw.Divider(borderStyle: pw.BorderStyle.dashed),
      _buildBlockCustomer(invoice, isThermal: true),
      pw.Divider(borderStyle: pw.BorderStyle.dashed),
      _buildBlockItems(invoice, isThermal: true),
      pw.Divider(borderStyle: pw.BorderStyle.dashed),
      _buildBlockTotals(invoice, isThermal: true),
      _buildBlockFooter(settings, isThermal: true),
    ];
  }

  // 7: Thermal 80 Supermarket
  static List<pw.Widget> _buildThermal80Supermarket(InvoiceModel invoice, PrintSettingsModel settings) {
    return _buildThermal58Detailed(invoice, settings); // Similar layout, wider paper
  }

  // 8: Thermal 80 Restaurant
  static List<pw.Widget> _buildThermal80Restaurant(InvoiceModel invoice, PrintSettingsModel settings) {
    return [
      _buildBlockHeader(settings, isThermal: true),
      pw.Center(child: pw.Text('TABLE: 01   GUESTS: 2', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Divider(),
      _buildBlockItems(invoice, isThermal: true),
      pw.Divider(),
      pw.Center(child: pw.Text('TOTAL: Rs ${invoice.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
      pw.Divider(),
      _buildBlockFooter(settings, isThermal: true),
    ];
  }

  // 9: Custom Drag & Drop
  static List<pw.Widget> _buildCustomDragAndDrop(InvoiceModel invoice, PrintSettingsModel settings) {
    final bool isThermal = settings.paperSize.startsWith('Thermal');
    final List<pw.Widget> blocks = [];

    for (final blockName in settings.customBlocksOrder) {
      switch (blockName) {
        case 'header': blocks.add(_buildBlockHeader(settings, isThermal: isThermal)); break;
        case 'customer': blocks.add(_buildBlockCustomer(invoice, isThermal: isThermal)); break;
        case 'items': blocks.add(_buildBlockItems(invoice, isThermal: isThermal)); break;
        case 'totals': blocks.add(_buildBlockTotals(invoice, isThermal: isThermal)); break;
        case 'footer': blocks.add(_buildBlockFooter(settings, isThermal: isThermal)); break;
      }
    }

    return blocks;
  }
}
