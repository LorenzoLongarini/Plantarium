// lib/features/chatbot/services/message_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageService {
  final String lambdaApiUrl = 'https://29iwzg968f.execute-api.eu-north-1.amazonaws.com/dev';

  // Recupera i messaggi per un utente
  Future<List<dynamic>> fetchMessages(int idUtente) async {
    final url = '$lambdaApiUrl/chat';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['messaggi'];
    } else {
      throw Exception('Errore durante il recupero dei messaggi');
    }
  }

  // Aggiunge un nuovo messaggio
  Future<void> addMessage(int idUtente, String tipo, String testo) async {
    final url = '$lambdaApiUrl/chat';
    final body = jsonEncode({
      'IdUtente': idUtente,
      'Tipo': tipo,
      'Testo': testo,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Errore durante l\'aggiunta del messaggio');
    }
  }

  // Aggiorna un messaggio esistente
  Future<void> updateMessage(int id, String testo) async {
    final url = '$lambdaApiUrl/chat';
    final body = jsonEncode({
      'Id': id,
      'Testo': testo,
    });

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Errore durante l\'aggiornamento del messaggio');
    }
  }

  // Elimina un messaggio
  Future<void> deleteMessage(int id) async {
    final url = '$lambdaApiUrl/chat?Id=$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Errore durante l\'eliminazione del messaggio');
    }
  }
}
