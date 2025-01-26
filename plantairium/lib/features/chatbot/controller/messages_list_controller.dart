import 'dart:async';

import 'package:plantairium/features/chatbot/data/messages_repository.dart';
import 'package:plantairium/models/Message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_list_controller.g.dart';

@riverpod
class MessagesListController extends _$MessagesListController {
  Future<List<Message>> _fetchMessages() async {
    final messagesRepository = ref.read(messagesRepositoryProvider);
    final messages = await messagesRepository.getMessages();
    return messages;
  }

  @override
  FutureOr<List<Message>> build() async {
    return _fetchMessages();
  }

  Future<void> addMessage({
    required String messageContent,
    required String userType,
    required String userId,
  }) async {
    final message = Message(
      message: messageContent,
      userId: userId,
      userType: userType,
    );

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final messagesRepository = ref.read(messagesRepositoryProvider);
      await messagesRepository.add(message);
      return _fetchMessages();
    });
  }

  Future<void> addFlaskMessage({
    required String messageContent,
    required String userType,
    required String userId,
  }) async {
    final message = Message(
      message: messageContent,
      userId: userId,
      userType: userType,
    );

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final messagesRepository = ref.read(messagesRepositoryProvider);
      // await messagesRepository.addFlaskMessage(message);
      return _fetchMessages();
    });
  }

  Future<void> removeMessage({
    required Message message,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final messagesRepository = ref.read(messagesRepositoryProvider);
      await messagesRepository.deleteMessage(message);
      return _fetchMessages();
    });
  }

  Future<void> removeAllMessages({
    required List<Message> messages,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final messagesRepository = ref.read(messagesRepositoryProvider);

      await messagesRepository.deleteAllMessages(messages);

      return _fetchMessages();
    });
  }

  // Stream<GraphQLResponse<Message>> getMessagesStream() {
  //   final messagesRepository = ref.read(messagesRepositoryProvider);
  //   return messagesRepository.getMessagesStreamRepo();
  // }
}
