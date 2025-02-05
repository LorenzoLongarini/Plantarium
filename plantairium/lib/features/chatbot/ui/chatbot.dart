import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/features/chatbot/controller/chat_plant_controller.dart';
import 'package:plantairium/features/chatbot/controller/message_controller.dart';
import 'package:plantairium/features/chatbot/ui/components/bubble_chat.dart';
import 'package:plantairium/features/chatbot/ui/components/bottom_input_field.dart';

class Chatbot extends ConsumerStatefulWidget {
  final int userId;

  const Chatbot({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends ConsumerState<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isWaitingForResponse = false;
  bool _showSlashSuggestions =
      false; // per mostrare suggerimenti quando si digita "/"

  // Quick Questions fisse (le FAQ e altre domande)
  final List<String> quickQuestions = [
    "Come innaffiare al meglio il basilico?",
    "Che tipo di sensori servono per misurare l'umidità del terreno?",
    "Come gestire la temperatura per piante da interno?",
  ];

  @override
  void initState() {
    super.initState();
    // Listener sul text controller per catturare quando l’utente digita "/"
    _controller.addListener(_onTextChanged);

    // All'avvio, facciamo fetch di TUTTE le piante
    // Il provider fetcha automaticamente nel suo costruttore, ma se vuoi forzare puoi fare:
    // ref.read(allPlantsControllerProvider.notifier).fetchAllPlants();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    // Se il testo finisce con "/", mostriamo i suggerimenti
    if (text.endsWith('/')) {
      setState(() {
        _showSlashSuggestions = true;
      });
    } else {
      setState(() {
        _showSlashSuggestions = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      isWaitingForResponse = true;
    });

    await ref
        .read(messagesControllerProvider.notifier)
        .sendMessage(widget.userId, text);

    _controller.clear();
    setState(() {
      isWaitingForResponse = false;
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesControllerProvider);

    // Osserviamo la lista di tutte le piante
    final allPlantsState = ref.watch(allPlantsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(AppRoute.home.name);
          },
        ),
      ),
      body: Column(
        children: [
          // Quick Questions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: quickQuestions.map((question) {
                return ActionChip(
                  backgroundColor: Colors.grey.shade200,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.grey.shade400, // Colore del bordo grigio
                      width: 1.0,
                    ),
                  ),
                  label: Text(question),
                  onPressed: () {
                    // Inseriamo la domanda nel campo di input (non inviamo subito)
                    _controller.text = question;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Lista messaggi
          Expanded(
            child: messagesState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                      child: Text('Nessun messaggio ancora inviato.'));
                }
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length + (isWaitingForResponse ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isWaitingForResponse) {
                      return const BubbleMessage(
                        message: "...",
                        userType: "ai",
                        isLoading: true,
                      );
                    }
                    final message = messages[index];
                    return BubbleMessage(
                      message: message['Testo'],
                      userType: message['Tipo'] == 'domanda' ? "user" : "ai",
                      timestamp: message['DataInvio'],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Errore: $error')),
            ),
          ),

          // Se l'utente ha digitato "/", mostriamo i suggerimenti (FAQ + piante)
          if (_showSlashSuggestions) _buildSlashSuggestions(allPlantsState),

          // Barra di input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: BottomInputField(
              controller: _controller,
              onPressed: () {
                final domanda = _controller.text.trim();
                _handleSendMessage(domanda);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Costruisce la sezione dei suggerimenti dopo aver digitato "/"
  Widget _buildSlashSuggestions(AsyncValue<List<dynamic>> allPlantsState) {
    if (allPlantsState is AsyncLoading) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: const Text("Caricamento piante..."),
      );
    }
    if (allPlantsState is AsyncError) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: const Text("Errore nel caricamento delle piante."),
      );
    }

    final plants = allPlantsState.value ?? [];

    return SizedBox(
      height: 50, // 🔹 Altezza fissa per evitare overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // ✅ Scroll orizzontale
        itemCount: plants.length + 1, // +1 per il suggerimento "/faq"
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ActionChip(
                backgroundColor: Colors.grey.shade200,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: Colors.grey.shade400, // Colore del bordo grigio
                    width: 1.0,
                  ),
                ),
                label: const Text("/faq"),
                onPressed: () {
                  _replaceLastSlashWith("/faq ");
                },
              ),
            );
          }

          final plant = plants[index - 1]; // 🔹 Perché il primo è "/faq"
          final nome = plant['Nome'] ?? 'Sconosciuto';
          final id = plant['Id'] ?? '-';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              backgroundColor: Colors.grey.shade200,
              shape: StadiumBorder(
                side: BorderSide(
                  color: Colors.grey.shade400, // Colore del bordo grigio
                  width: 1.0,
                ),
              ),
              label: Text("/plant $id $nome"),
              onPressed: () {
                _replaceLastSlashWith("/plant $nome",
                    name: plant['Nome'], description: plant['Descrizione']);
              },
            ),
          );
        },
      ),
    );
  }

  /// Rimpiazza l'ultimo "/" con la stringa [replacement] (es. "/faq " o "/plant 1 ")
  void _replaceLastSlashWith(String replacement,
      {String? description, String? name}) {
    final currentText = _controller.text;
    if (currentText.endsWith('/')) {
      final textWithoutSlash = currentText.substring(0, currentText.length - 1);
      final newText = '$textWithoutSlash$replacement';
      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
      setState(() {
        _showSlashSuggestions = false;
      });
    }
    if (replacement.startsWith("/plant")) {
      if (name != null && description != null) {
        _handleSendMessage(name + description);
      }
    }
  }
}
