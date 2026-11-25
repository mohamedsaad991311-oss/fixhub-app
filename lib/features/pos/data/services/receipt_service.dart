// lib/features/pos/data/services/receipt_service.dart

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptService {
  static Future<void> printReceipt({
    required String shopName,
    required String shopPhone,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    String? customerName,
    String? address,
    required double paidAmount,
    String? invoiceId,
  }) async {
    final doc = pw.Document();

    final fontData = await rootBundle.load('assets/fonts/cairo.ttf');
    final ttf = pw.Font.ttf(fontData);

    final height = 350.0 + (items.length * 25.0);

    final pageFormat = PdfPageFormat(
      80 * PdfPageFormat.mm,
      height,
      marginAll: 1 * PdfPageFormat.mm,
    );

    final now = DateTime.now();
    final dateStr = "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final invoiceNum = "INV-${now.millisecondsSinceEpoch.toString().substring(7)}";
    final remaining = totalAmount - paidAmount;

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 1. Ø±Ø£Ø³ Ø§Ù„ÙØ§ØªÙˆØ±Ø©
                pw.Center(
                  child: pw.Text(
                    shopName,
                    style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text('ÙØ§ØªÙˆØ±Ø© Ø¨ÙŠØ¹', style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 6),
                
                // 2. Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„ÙØ§ØªÙˆØ±Ø©
                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Ø±Ù‚Ù… Ø§Ù„ÙØ§ØªÙˆØ±Ø©: $invoiceNum', style: pw.TextStyle(font: ttf, fontSize: 7)),
                          pw.Text('Ù†ÙˆØ¹ Ø§Ù„Ø¯ÙØ¹: $paymentMethod', style: pw.TextStyle(font: ttf, fontSize: 7)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Ø§Ù„ØªØ§Ø±ÙŠØ®: $dateStr', style: pw.TextStyle(font: ttf, fontSize: 7)),
                          pw.Text('Ø§Ù„ÙˆÙ‚Øª: $timeStr', style: pw.TextStyle(font: ttf, fontSize: 7)),
                        ],
                      ),
                      if (customerName != null && customerName.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Row(
                          children: [
                            pw.Text('Ø§Ù„Ø¹Ù…ÙŠÙ„: $customerName', style: pw.TextStyle(font: ttf, fontSize: 7)),
                          ],
                        ),
                      ],
                      if (address != null && address.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Row(
                          children: [
                            pw.Text('Ø§Ù„Ø¹Ù†ÙˆØ§Ù†: $address', style: pw.TextStyle(font: ttf, fontSize: 7)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),

                // 3. Ø¬Ø¯ÙˆÙ„ Ø§Ù„Ø£ØµÙ†Ø§Ù
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4.5), // Ù…Ø³Ø§Ø­Ø© Ø£ÙƒØ¨Ø± Ù„Ù„Ø§Ø³Ù…
                    1: const pw.FlexColumnWidth(1),   // ÙƒÙ…ÙŠØ©
                    2: const pw.FlexColumnWidth(1.5), // Ø³Ø¹Ø± (Ø£Ù‚Ù„)
                    3: const pw.FlexColumnWidth(1.5), // Ø¥Ø¬Ù…Ø§Ù„ÙŠ (Ø£Ù‚Ù„)
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 0.5),
                          child: pw.Text('Ø§Ù„ØµÙ†Ù', style: pw.TextStyle(font: ttf, fontSize: 7, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 0.5),
                          child: pw.Text('ÙƒÙ…ÙŠØ©', style: pw.TextStyle(font: ttf, fontSize: 7, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 0.5),
                          child: pw.Text('Ø³Ø¹Ø±', style: pw.TextStyle(font: ttf, fontSize: 7, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 0.5),
                          child: pw.Text('Ø¥Ø¬Ù…Ø§Ù„ÙŠ', style: pw.TextStyle(font: ttf, fontSize: 7, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        ),
                      ],
                    ),
                    ...items.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Text(item['name'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 7)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Text('${item['qty']}', style: pw.TextStyle(font: ttf, fontSize: 7), textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Text('${item['price']}', style: pw.TextStyle(font: ttf, fontSize: 7), textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Text('${item['total']}', style: pw.TextStyle(font: ttf, fontSize: 7), textAlign: pw.TextAlign.center),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 6),

                // 4. Ø§Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠØ§Øª
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Text('Ø§Ù„Ù…Ø·Ù„ÙˆØ¨ (Ø¶Ø±ÙŠØ¨Ø© 0%):', style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Text('${totalAmount.toStringAsFixed(2)} Ø¬.Ù…', style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Text('Ø§Ù„Ù…Ø¯ÙÙˆØ¹:', style: pw.TextStyle(font: ttf, fontSize: 7)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Text('${paidAmount.toStringAsFixed(2)} Ø¬.Ù…', style: pw.TextStyle(font: ttf, fontSize: 7), textAlign: pw.TextAlign.center),
                        ),
                      ],
                    ),
                    if (remaining > 0)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Text('Ø§Ù„Ø±ØµÙŠØ¯ Ø§Ù„Ø­Ø§Ù„ÙŠ (Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ):', style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Text('${remaining.toStringAsFixed(2)} Ø¬.Ù…', style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red), textAlign: pw.TextAlign.center),
                          ),
                        ],
                      ),
                  ],
                ),

                pw.SizedBox(height: 8),
                
                // 5. Ø§Ù„ØªØ°ÙŠÙŠÙ„
                pw.Center(
                  child: pw.Text('Ø´ÙƒØ±Ø§Ù‹ Ù„Ø²ÙŠØ§Ø±ØªÙƒÙ…!', style: pw.TextStyle(font: ttf, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text('Ø±Ù‚Ù… Ø§Ù„Ù…Ø­Ù„: $shopPhone', style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Ø´Ø±ÙˆØ· Ø§Ù„Ø§Ø³ØªØ±Ø¬Ø§Ø¹:', style: pw.TextStyle(font: ttf, fontSize: 6, fontWeight: pw.FontWeight.bold)),
                pw.Text('â€¢ ÙŠØ¬Ø¨ Ø£Ù† ØªÙƒÙˆÙ† Ø§Ù„Ù‚Ø·Ø¹Ø© Ø¨Ù†ÙØ³ Ø­Ø§Ù„ØªÙ‡Ø§ Ø§Ù„ØªÙŠ Ø§Ø³ØªÙ„Ù…ØªÙ‡Ø§ Ø¨Ù‡Ø§.', style: pw.TextStyle(font: ttf, fontSize: 6)),
                pw.Text('â€¢ Ø¹Ø¯Ù… ÙˆØ¬ÙˆØ¯ Ø£ÙŠ ØªÙ„Ù Ø¯Ø§Ø®Ù„ÙŠ Ø£Ùˆ Ø®Ø§Ø±Ø¬ÙŠ ÙÙŠ Ø§Ù„Ù‚Ø·Ø¹Ø©.', style: pw.TextStyle(font: ttf, fontSize: 6)),
              ],
            ),
          );
        },
      ),
    );

    // ÙØªØ­ ÙˆØ§Ø¬Ù‡Ø© Ø§Ù„Ø·Ø¨Ø§Ø¹Ø©
    final pdfBytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Receipt_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
