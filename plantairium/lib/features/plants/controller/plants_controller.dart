import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/features/plants/services/plants_api_service.dart';

final plantsControllerProvider =
    StateNotifierProvider.family<PlantsController, AsyncValue<List<dynamic>>, int>(
  (ref, idSensore) {
    print("📢 [DEBUG] Creazione del PlantsController per IdSensore: $idSensore");
    return PlantsController(ref, idSensore);
  },
);

class PlantsController extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Ref ref;
  final PlantsService _plantsService = PlantsService();
  final int idSensore;

  // ✅ Modifica il costruttore per ricevere l'ID del sensore
  PlantsController(this.ref, this.idSensore) : super(const AsyncValue.loading()) {
    fetchPlants(); // ⚡ Carica le piante automaticamente
  }

  Future<void> fetchPlants() async {
    try {
      print("📤 [DEBUG] Chiamata fetchPlants() per IdSensore: $idSensore...");
      final plants = await _plantsService.fetchPlants(idSensore: idSensore);
      print("✅ [DEBUG] Piante ricevute: $plants");
      state = AsyncValue.data(plants);
    } catch (e, stacktrace) {
      print("❌ [DEBUG] Errore fetchPlants(): $e");
      state = AsyncValue.error(e, stacktrace);
    }
  }

  Future<void> addPlant({
    required int idSensore,
    required String nome,
    required String specie,
    String? descrizione,
    required String dataPiantumazione,
  }) async {
    try {
      await _plantsService.addPlant(
        idSensore: idSensore,
        nome: nome,
        specie: specie,
        descrizione: descrizione,
        dataPiantumazione: dataPiantumazione,
      );
      await fetchPlants(); // Ricarica le piante
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updatePlant({
    required int id,
    required int idSensore,
    required String nome,
    required String specie,
    String? descrizione,
    required String dataPiantumazione,
  }) async {
    try {
      await _plantsService.updatePlant(
        id: id,
        nome: nome,
        specie: specie,
        descrizione: descrizione,
        dataPiantumazione: dataPiantumazione,
      );
      await fetchPlants(); // Ricarica le piante
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePlant(int id, int idSensore) async {
    try {
      await _plantsService.deletePlant(id);
      await fetchPlants(); // Ricarica le piante
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
