import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/features/chatbot/services/copilot_service.dart';
import 'package:plantairium/features/report/services/report_service.dart';

final reportControllerProvider =
    StateNotifierProvider<ReportController, Map<int, String?>>((ref) {
  return ReportController(ref);
});

class ReportController extends StateNotifier<Map<int, String?>> {
  final Ref ref;

  ReportController(this.ref) : super({});

 
  Future<void> generateAndSaveReport(
    int plantId, 
    String plantName,
    String species,
    Map<String, dynamic> features,
    String prompt,
  ) async {
   
    state = {...state, plantId: null};

    try {
      
      final copilotService = ref.read(copilotServiceProvider);
      final responseText = await copilotService.generateResponse(prompt);

      
      final pdfService = ref.read(pdfServiceProvider);
      final pdfPath = await pdfService.generatePDF(plantName, species, responseText);

      print("✅ Report per $plantName salvato in: $pdfPath");

     
      state = {...state, plantId: pdfPath};
    } catch (e) {
      print("Errore nella generazione del PDF per $plantName: $e");

      state = {...state, plantId: null};
    }
  }
}
