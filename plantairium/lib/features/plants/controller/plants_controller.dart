import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/features/plants/services/plants_api_service.dart';

final plantsControllerProvider =
    StateNotifierProvider<PlantsController, AsyncValue<List<dynamic>>>((ref) {
  return PlantsController();
});

class PlantsController extends StateNotifier<AsyncValue<List<dynamic>>> {
  final PlantsService _plantsService = PlantsService();

  PlantsController() : super(const AsyncValue.loading());

  Future<void> fetchPlants(int idSensore) async {
    try {
      final plants = await _plantsService.fetchPlants(idSensore);
      state = AsyncValue.data(plants);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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
      await fetchPlants(idSensore); // Ricarica le piante
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
      await fetchPlants(idSensore); // Ricarica le piante
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePlant(int id, int idSensore) async {
    try {
      await _plantsService.deletePlant(id);
      await fetchPlants(idSensore); // Ricarica le piante
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
