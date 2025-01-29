import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class PdfService {
  Future<String> generatePdfReport(String reportText) async {
    // 1. Carico i font NotoSans
    final fontDataRegular = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final fontDataBold = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
    final ttfRegular = pw.Font.ttf(fontDataRegular);
    final ttfBold = pw.Font.ttf(fontDataBold);

    // 2. Crea il PDF con tema personalizzato
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: ttfRegular,
        bold: ttfBold,
      ),
    );

    // 3. Pulizia testo
    final cleanedText = _formatAndCleanText(reportText);

    // 4. Aggiunge il contenuto
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Titolo di Esempio',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Paragraph(text: cleanedText, style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );

    // 5. Salvataggio
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/my_document.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print("✅ PDF salvato in: $filePath");
    return filePath;
  }

  String _formatAndCleanText(String text) {
    if (text.isEmpty) return text;
    text = text.replaceAll(RegExp(r'[\x00-\x08\x0B-\x1F\x7F]+'), ' ');

    final replacements = {
      'Â': '',
      'Ã ': 'à',
      'Ã¨': 'è',
      'Ã©': 'é',
      'Ã¬': 'ì',
      'Ã²': 'ò',
      'Ã¹': 'ù',
      'â€™': "'",
      'â€œ': '"',
      'â€': '"',
      'â€¢': '- ',
      'â€“': '-',
      'â€”': '-',
    };
    replacements.forEach((key, value) {
      text = text.replaceAll(key, value);
    });

    return text.trim();
  }
}
