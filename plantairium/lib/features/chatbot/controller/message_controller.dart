// lib/features/chatbot/controller/messages_controller.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/features/account/ui/account_options/faq_data.dart';
import 'package:plantairium/features/chatbot/services/copilot_service.dart';
import 'package:plantairium/features/chatbot/services/message_service.dart';

final messagesControllerProvider = StateNotifierProvider<MessagesController, AsyncValue<List<dynamic>>>((ref) {
  return MessagesController();
});

class MessagesController extends StateNotifier<AsyncValue<List<dynamic>>> {
  final MessageService _messageService = MessageService();
  final CopilotService _copilotService = CopilotService();

  final RegExp emojiRegex = RegExp(r'[\uD800-\uDBFF][\uDC00-\uDFFF]');
  final RegExp accentRegex = RegExp(r'[^\x00-\x7F]+');

  MessagesController() : super(const AsyncValue.loading()) {
    fetchMessages(1); // Carichiamo all'avvio i messaggi per un utente (hardcoded in questo esempio)
  }

  Future<void> fetchMessages(int idUtente) async {
    try {
      final messages = await _messageService.fetchMessages(idUtente);
      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> sendMessage(int idUtente, String domanda) async {
    try {
      final currentMessages = [...state.value ?? []];

      // Aggiungiamo subito il messaggio utente allo stato
      final userMessage = {
        'Id': DateTime.now().millisecondsSinceEpoch,
        'IdUtente': idUtente,
        'Tipo': 'domanda',
        'DataInvio': DateTime.now().toIso8601String(),
        'Testo': domanda
      };
      state = AsyncValue.data([...currentMessages, userMessage]);

      // -----------------------------------------------------------------
      // GESTIONE COMANDI: /faq e /plant
      // -----------------------------------------------------------------
      String faqContext = "";
      String plantContext = "";
      String actualPrompt = domanda; // testo utente eventualmente "ripulito"

      if (domanda.startsWith("/faq")) {
        // Carichiamo tutte le FAQ come contesto
        faqContext = FAQData.getAllFaqsAsText();
        // Se vuoi rimuovere la parte "/faq" dal messaggio utente:
        actualPrompt = domanda.replaceFirst("/faq", "").trim();
      }

      // Esempio: /plant 123 (o /plant 123 Qualcosa)
      if (domanda.startsWith("/plant")) {
        // estraiamo l'id dopo "/plant "
        // Formato ipotetico: "/plant 123"
        final splitted = domanda.split(" ");
        if (splitted.length >= 2) {
          final maybeId = splitted[1];
          final idPianta = int.tryParse(maybeId);
          if (idPianta != null) {
            // In realta' potresti:
            // 1) Fare una chiamata HTTP per recuperare i dettagli della pianta
            // 2) Oppure, se in Chatbot hai già la mappa pianta => details, potresti passare i suoi details
            // Esempio veloce: passiamo un contesto generico
            plantContext = "Informazioni per la pianta con ID $idPianta. (TODO: recuperare info reali)";
            // Rimuoviamo "/plant <id>" dal prompt utente
            actualPrompt = domanda.replaceFirst("/plant $maybeId", "").trim();
          }
        }
      }

      // Costruiamo un contesto extra unendo FAQ + pianta se necessario
      // in questo caso, un semplice "join" di due stringhe:
      final combinedContext = [
        if (faqContext.isNotEmpty) "FAQ:\n$faqContext",
        if (plantContext.isNotEmpty) "PIANTA:\n$plantContext",
      ].join("\n\n");

      // Ora passiamo "combinedContext" al copilotService come contesto extra
      String risposta = await _copilotService.generateResponse(actualPrompt, combinedContext);

      // Rimuoviamo emoji e caratteri speciali
      risposta = risposta.replaceAll(emojiRegex, '').replaceAll(accentRegex, '');

      // Aggiungiamo la risposta
      final aiMessage = {
        'Id': DateTime.now().millisecondsSinceEpoch + 1,
        'IdUtente': idUtente,
        'Tipo': 'risposta',
        'DataInvio': DateTime.now().toIso8601String(),
        'Testo': risposta
      };
      state = AsyncValue.data([...state.value ?? [], aiMessage]);

      // Salviamo i messaggi
      await _messageService.addMessage(idUtente, 'domanda', domanda);
      await _messageService.addMessage(idUtente, 'risposta', risposta);

    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
