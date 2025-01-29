// lib/features/faq/faq_data.dart

class FAQData {
  static const List<Map<String, String>> faqs = [
    {
      'question': 'Come posso creare un account?',
      'answer': 'Per creare un account, clicca su "Registrati" nella schermata di login e segui le istruzioni.'
    },
    {
      'question': 'Come posso recuperare la mia password?',
      'answer': 'Clicca su "Password dimenticata" nella schermata di login e segui le istruzioni.'
    },
    {
      'question': 'Come posso contattare il supporto?',
      'answer': 'Puoi contattare il supporto tramite l\'email support@plantairium.com.'
    },
    {
      'question': 'Come posso inserire un sensore?',
      'answer': 'Per inserire un sensore, vai alla sezione "Sensori" e clicca su "Aggiungi Sensore". Segui le istruzioni per configurare il nuovo sensore.'
    },
    {
      'question': 'Come posso aggiungere una pianta?',
      'answer': 'Per aggiungere una pianta, vai alla sezione "Piante" e clicca su "Aggiungi Pianta". Inserisci le informazioni richieste e salva.'
    },
    {
      'question': 'Come posso aggiornare le informazioni del mio profilo?',
      'answer': 'Vai alla sezione "My Profile" e clicca su "Modifica" per aggiornare le tue informazioni.'
    },
  ];

  // Se preferisci avere le FAQ come testo singolo da passare al modello:
  static String getAllFaqsAsText() {
    final buffer = StringBuffer();
    for (var faq in faqs) {
      buffer.writeln('Domanda: ${faq['question']}');
      buffer.writeln('Risposta: ${faq['answer']}');
      buffer.writeln();
    }
    return buffer.toString();
  }
}
