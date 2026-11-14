import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/table_qr_codec.dart';

const _numberStyle =
    pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold);

/// Builds an A4 sheet of table QR codes (six per page). Labels use digits
/// only, so the built-in PDF font is enough for every UI language.
Future<Uint8List> buildTableQrPdf(
  List<int> tableNumbers, {
  PdfPageFormat format = PdfPageFormat.a4,
}) {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final number in tableNumbers)
              pw.Container(
                width: 240,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: TableQrCodec.encode(number),
                      width: 180,
                      height: 180,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('$number', style: _numberStyle),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

/// Opens the platform print dialog (which also offers "save as PDF").
Future<void> printTableQrCodes(List<int> tableNumbers) async {
  await Printing.layoutPdf(
    name: 'table-qr-codes',
    onLayout: (format) => buildTableQrPdf(tableNumbers, format: format),
  );
}
