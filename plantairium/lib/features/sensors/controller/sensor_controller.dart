import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sensor_service.dart';

final sensorsControllerProvider =
    StateNotifierProvider<SensorsController, AsyncValue<List<dynamic>>>(
  (ref) => SensorsController(ref),
);

class SensorsController extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Ref ref;
  SensorsController(this.ref) : super(const AsyncLoading()) {
    _loadSensors();
  }

  Future<Map<String, dynamic>> fetchSensorData(int sensorId) async {
    try {
      final sensors = await ref.read(sensorServiceProvider).getSensors();

      final List<Map<String, dynamic>> sensorsList =
          List<Map<String, dynamic>>.from(sensors);
      final sensorData = sensorsList.firstWhere(
        (sensor) => sensor['Id'] == sensorId,
        orElse: () => <String, dynamic>{},
      );

      state = AsyncData([sensorData]);
      return sensorData;
    } catch (e) {
      print("❌ Errore in fetchSensorData: $e");
      state = AsyncError(e, StackTrace.current);
      return {};
    }
  }

  Future<void> _loadSensors() async {
    try {
      final sensors = await ref.read(sensorServiceProvider).getSensors();
      state = AsyncData(sensors);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> addSensor(String nome, Map<String, dynamic> features) async {
    try {
      await ref.read(sensorServiceProvider).addSensor(nome, features);
      _loadSensors(); // Ricarica i sensori
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateSensor(
      int id, String nome, Map<String, dynamic> features) async {
    try {
      await ref.read(sensorServiceProvider).updateSensor(id, nome, features);
      _loadSensors(); // Ricarica i sensori
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteSensor(int id) async {
    try {
      await ref.read(sensorServiceProvider).deleteSensor(id);
      _loadSensors();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> requestInference(int sensorId, String features) async {
    try {
      await ref
          .read(sensorServiceProvider)
          .requestInference(sensorId, features);
      _loadSensors(); // Ricarica i sensori
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
