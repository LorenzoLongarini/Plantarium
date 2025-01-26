import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plantairium/common/services/storage_service.dart';
import 'package:plantairium/features/chatbot/data/messages_repository.dart';
import 'package:plantairium/models/Message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_controller.g.dart';

@riverpod
class MessageController extends _$MessageController {
  Future<Message> _fetchMessage(String messageId) async {
    final messagesRepository = ref.read(messagesRepositoryProvider);
    return messagesRepository.getMessage(messageId);
  }

  @override
  FutureOr<Message> build(String messageId) async {
    return _fetchMessage(messageId);
  }

  // Future<void> updateMessage(Message message) async {
  //   state = const AsyncValue.loading();
  //   state = await AsyncValue.guard(() async {
  //     final messagesRepository = ref.read(messagesRepositoryProvider);
  //     await messagesRepository.update(message);
  //     return _fetchMessage(message.id);
  //   });
  // }

  // Future<void> uploadFile(File file, Message message) async {
  //   final fileKey = await ref.read(storageServiceProvider).uploadFile(file);
  //   if (fileKey != null) {
  //     final imageUrl =
  //         await ref.read(storageServiceProvider).getImageUrl(fileKey);
  //     final updatedMessage =
  //         message.copyWith(message: fileKey, messageImageUrl: imageUrl);
  //     await ref.read(messagesRepositoryProvider).update(updatedMessage);
  //     ref.read(storageServiceProvider).resetUploadProgress();
  //   }
  // }

  ValueNotifier<double> uploadProgress() {
    return ref.read(storageServiceProvider).getUploadProgress();
  }
}
