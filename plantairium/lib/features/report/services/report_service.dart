import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

// ✅ Definizione del provider
final pdfServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

class ReportService {
  Future<String> generatePDF(String plantName, String species, String reportText) async {
    // 1. Carica i font NotoSans
    final fontDataRegular = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final fontDataBold = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');

    final ttfRegular = pw.Font.ttf(fontDataRegular);
    final ttfBold = pw.Font.ttf(fontDataBold);

    // 2. Crea il documento con il tema personalizzato
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: ttfRegular,
        bold: ttfBold,
      ),
    );

    // 3. Pulizia MINIMA del testo (senza rimuovere i caratteri Unicode validi)
    reportText = _formatAndCleanText(reportText);

    // 4. Aggiunta pagina (MultiPage) con i contenuti
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Report Pianta',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Nome: $plantName', style: pw.TextStyle(fontSize: 16)),
          pw.Text('Specie: $species', style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('Analisi:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),

          // Usiamo Paragraph per gestire blocchi lunghi
          pw.Paragraph(
            text: reportText,
            style: pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );

    // 5. Salvataggio del PDF in locale
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/plant_report.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Funzione di pulizia semplificata:
  /// - Rimuove i caratteri di controllo (ASCII < 32), così evitiamo roba invisibile.
  /// - Converte eventuali sequenze errate derivate da doppia codifica (es. "Ã" -> "à").
  /// - Mantiene i caratteri accentati validi.
  String _formatAndCleanText(String text) {
    if (text.isEmpty) return text;

    // Rimuove i caratteri di controllo
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

    // Se vuoi fare altre piccole correzioni di Markdown, ecc.
    text = text
        .replaceAllMapped(RegExp(r'####?\s*'), (match) => '\n\n**')
        .replaceAllMapped(RegExp(r'\*\*\s*(.*?)\s*\*\*'), (match) => '**${match.group(1)}**')
        .replaceAll(RegExp(r'\n\s*-'), '\n-')
        .replaceAll(RegExp(r' +'), ' ')
        .trim();

    return text;
  }
}
