import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/features/chatbot/services/message_service.dart';
import 'package:plantairium/models/Message.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final messagesAPIService = ref.read(messagesAPIServiceProvider);
  return MessagesRepository(messagesAPIService);
});

class MessagesRepository {
  MessagesRepository(this.messagesAPIService);

  final MessagesAPIService messagesAPIService;

  Future<List<Message>> getMessages() async {
    // final flaskMessage = await messagesAPIService.getLastMessageFlask();
    // if (flaskMessage.isNotEmpty) {
    //   Message newAnswer =
    //       Message(userId: '1', message: flaskMessage.first.answer);
    //   messagesAPIService.addMessage(newAnswer);
    // }

    return messagesAPIService.getMessages();
  }

  Future<Message> getMessage(String messageId) {
    return messagesAPIService.getMessage(messageId);
  }

  Future<void> add(Message message) async {
    return messagesAPIService.addMessage(message);
  }

  // Future<void> addFlaskMessage(Message message) async {
  //   final answer = await messagesAPIService.addMessageFlask(message.message);
  //   final Message answerMessage = Message(userId: '1', message: answer.answer);
  //   return messagesAPIService.addMessage(answerMessage);
  // }

  Future<void> deleteMessage(Message message) async {
    return messagesAPIService.deleteMessage(message);
  }

  Future<void> deleteAllMessages(List<Message> messages) async {
    return messagesAPIService.deleteAllMessages(messages);
  }

  // Stream<GraphQLResponse<Message>> getMessagesStreamRepo() {
  //   return messagesAPIService.subscribeToMessages();
  // }
}
