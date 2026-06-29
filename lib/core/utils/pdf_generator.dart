import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rk_enterprises/features/billing/models/invoice_model.dart';

class PdfGenerator {
  static Future<void> generateAndPrintInvoice(InvoiceModel invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('RK ENTERPRISES', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 20, color: PdfColors.grey700)),
                  ]
                )
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed To:'),
                      pw.Text(invoice.customerName ?? 'Walk-in Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No: ${invoice.invoiceNumber}'),
                      pw.Text('Date: ${invoice.invoiceDate.toString().split(' ')[0]}'),
                    ]
                  ),
                ]
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                headers: ['Item', 'Qty', 'Price', 'GST', 'Total'],
                data: invoice.items.map((item) => [
                  item.productName,
                  item.quantity.toString(),
                  'Rs ${item.unitPrice}',
                  '${item.gstPercentage}%',
                  'Rs ${item.totalAmount}',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerRight,
                }
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: Rs ${invoice.subTotal}'),
                      if (invoice.totalDiscount > 0) pw.Text('Discount: -Rs ${invoice.totalDiscount}'),
                      pw.Text('GST: Rs ${invoice.totalGst}'),
                      pw.Divider(),
                      pw.Text('Grand Total: Rs ${invoice.grandTotal}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ]
                  )
                ]
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNumber}.pdf'
    );
  }
}
