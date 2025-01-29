import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/features/chatbot/services/copilot_service.dart';
import 'package:plantairium/features/report/services/report_service.dart';

final reportControllerProvider =
    StateNotifierProvider<ReportController, String?>((ref) {
  return ReportController(ref);
});

class ReportController extends StateNotifier<String?> {
  final Ref ref;

  ReportController(this.ref) : super(null);

  Future<void> generateAndSaveReport(
    String plantName,
    String species,
    Map<String, dynamic> features,
    String prompt,
  ) async {
    state = null; // Indica che il report è in corso

    try {
      print("📢 [DEBUG] Generazione report per pianta: $plantName");

      // 1. Recupero del testo da Copilot
      final copilotService = ref.read(copilotServiceProvider);
      final responseText = await copilotService.generateResponse(prompt);

      // 2. Generazione del PDF
      final pdfService = ref.read(pdfServiceProvider);
      final pdfPath = await pdfService.generatePDF(plantName, species, responseText);

      print("✅ Report salvato in: $pdfPath");
      state = pdfPath;
    } catch (e) {
      print("❌ Errore nella generazione del PDF: $e");
      state = null;
    }
  }
}
