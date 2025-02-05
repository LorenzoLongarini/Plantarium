// lib/features/chatbot/services/copilot_service.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:plantairium/common/utils/env_vars.dart';

final copilotServiceProvider = Provider<CopilotService>((ref) {
  return CopilotService();
});

class CopilotService {
  final String copilotApiUrl =
      "https://models.inference.ai.azure.com/chat/completions";
  final String githubToken = EnvVars.copilotKey;

  Future<String> generateResponse(String prompt,
      [String faqContext = "", String plantContext = ""]) async {
    final headers = {
      'Authorization': 'Bearer $githubToken',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28',
    };
    Set<String> context;

    final body = jsonEncode({
      "model": "gpt-4o",
      "messages": [
        {
          "role": "system",
          "content": """
            Sei un assistente specializzato in piante e sensori.
            ${faqContext.isNotEmpty ? "Queste sono alcune FAQ fornite:\n$faqContext\n" : ""}
            ${plantContext.isNotEmpty ? "Queste sono alcune informazioni riguardo una pianta:\n$faqContext\n" : ""}
            Rispondi in modo chiaro e coerente alla domanda dell'utente.
            """
        },
        {"role": "user", "content": prompt}
      ],
      "temperature": 1,
      "max_tokens": 4096,
      "top_p": 1,
    });

    final response =
        await http.post(Uri.parse(copilotApiUrl), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Error: ${response.body}');
    }
  }
}
