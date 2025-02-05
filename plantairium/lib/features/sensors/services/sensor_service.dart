import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/common/utils/env_vars.dart';

final sensorServiceProvider = Provider((ref) => SensorService());

class SensorService {
  final String baseUrl = EnvVars.lambdaApi;

  Future<List<dynamic>> getSensors() async {
    final response = await http.get(Uri.parse('$baseUrl/sensore'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['sensori'];
    } else {
      throw Exception('Errore nel recupero dei sensori');
    }
  }

  Future<void> addSensor(String nome, Map<String, dynamic> features) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sensore'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "IdUtente": 1,
        "Nome": nome,
        "Features": features,
        "DataInstallazione": DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore durante l\'aggiunta del sensore');
    }
  }

  Future<void> updateSensor(
      int id, String nome, Map<String, dynamic> features) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sensore/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Nome": nome,
        "Features": features,
        "UpdatedAt": DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore durante la modifica del sensore');
    }
  }

  Future<void> deleteSensor(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/sensore'), //
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Id": id}), //
    );

    print('DELETE status code: ${response.statusCode}');
    print('DELETE response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Errore durante l\'eliminazione del sensore');
    }
  }

  Future<void> requestInference(int sensorId, String featureName) async {
    final response = await http.post(
      Uri.parse('${EnvVars.inferenceApi}/inferencemodel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "IdSensore": sensorId,
        "FeatureName": featureName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore richiesta inferenza');
    }
  }
}
