import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plantairium/common/utils/env_vars.dart';

class PlantsService {
  final String apiUrl = EnvVars.lambdaApi; 

Future<List<dynamic>> fetchPlants({int? idSensore}) async {
    var url = '';
  if (idSensore == null) {
     url = '$apiUrl/pianta';
  } else {
   url = '$apiUrl/pianta?IdSensore=$idSensore';
  }
  print('📤 [DEBUG] Chiamata API: $url');

  final response = await http.get(Uri.parse(url));

  print('📥 [DEBUG] Risposta API: ${response.statusCode}');
  print('📥 [DEBUG] Corpo della risposta: ${response.body}');

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final data = decoded['piante'];
    print('✅ [DEBUG] Dati ricevuti dal server: $data');
    return data;
  } else {
    print('❌ [DEBUG] Errore API: ${response.statusCode} - ${response.body}');
    throw Exception('Errore durante il fetch delle piante');
  }
}



  Future<void> addPlant({
    required int idSensore,
    required String nome,
    required String specie,
    String? descrizione,
    required String dataPiantumazione,
  }) async {
    final body = {
      "IdSensore": idSensore,
      "Nome": nome,
      "Specie": specie,
      "Descrizione": descrizione,
      "DataPiantumazione": dataPiantumazione,
    };
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore durante l\'aggiunta della pianta');
    }
  }

  Future<void> updatePlant({
    required int id,
    required String nome,
    required String specie,
    String? descrizione,
    required String dataPiantumazione,
  }) async {
    final body = {
      "Id": id,
      "Nome": nome,
      "Specie": specie,
      "Descrizione": descrizione,
      "DataPiantumazione": dataPiantumazione,
    };
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore durante la modifica della pianta');
    }
  }

  Future<void> deletePlant(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl?Id=$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore durante l\'eliminazione della pianta');
    }
  }
}
