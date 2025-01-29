import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/features/plants/services/plants_api_service.dart';

/// Provider che non richiede parametri e scarica TUTTE le piante
final allPlantsControllerProvider = StateNotifierProvider<AllPlantsController, AsyncValue<List<dynamic>>>((ref) {
  return AllPlantsController();
});

class AllPlantsController extends StateNotifier<AsyncValue<List<dynamic>>> {
  final PlantsService _plantsService = PlantsService();

  AllPlantsController() : super(const AsyncValue.loading()) {
    fetchAllPlants();
  }

  Future<void> fetchAllPlants() async {
    try {
      final plants = await _plantsService.fetchPlants(); 
      state = AsyncValue.data(plants);
    } catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
    }
  }
}
