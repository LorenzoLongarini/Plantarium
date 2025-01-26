import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:plantairium/models/Message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
// import 'package:plantairium/old/models/llm_item.dart';
import 'dart:convert';

final messagesAPIServiceProvider =
    Provider.autoDispose<MessagesAPIService>((ref) {
  final service = MessagesAPIService();
  return service;
});

final messageAPIServiceStreamProvider =
    StreamProvider.autoDispose<List<Message>>((ref) async* {
  final subscriptionRequest = ModelSubscriptions.onCreate(Message.classType);
  final operation = Amplify.API.subscribe(
    subscriptionRequest,
    onEstablished: () => safePrint("Subscription established"),
  );
  final provider = ref.read(messagesAPIServiceProvider);
  // yield [];
  List<Message> allMessages = await provider.getMessages();
  yield allMessages;
  await for (final GraphQLResponse graphqlMessage in operation) {
    //TODO: gestire eventuali errori
    final message = graphqlMessage.data;
    allMessages = [...allMessages, message];
    yield allMessages;
  }
});

class MessagesAPIService {
  MessagesAPIService();
  final url = 'http://10.0.2.2:8000/llm';
  late List<String> lastItem;

  Future<List<String>> addMessageFlask(String query) async {
    // if (query.isEmpty) {
    //   return;
    // }
    Map<String, dynamic> request = {
      "query": query,
    };
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(request),
    );
    Map<String, dynamic> responsePayload = json.decode(response.body);
    // final answ =
    return ['a'] ;
  //   LlmItem(
  //       id: responsePayload["id"], answer: responsePayload["answer"]);
  }

  // Future<List<LlmItem>> getLastMessageFlask() async {
  //   http.Response response;
  //   try {
  //     response = await http.get(Uri.parse(url));
  //     Map<String, dynamic> data = json.decode(response.body);
  //     LlmItem item = LlmItem(id: data['id'], answer: data['answer']);
  //     lastItem = [item];
  //     return lastItem;
  //     // lastItem = body
  //     //     .map(
  //     //       (e) => LlmItem(
  //     //         id: e['id'],
  //     //         answer: e['answer'],
  //     //       ),
  //     //     )
  //     //     .toList();
  //     // return lastItem;
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }

  Future<List<Message>> getMessages() async {
    try {
      final request = ModelQueries.list(Message.classType);
      final response = await Amplify.API.query(request: request).response;
      final messages = response.data?.items;

      if (messages == null) {
        safePrint('errors: ${response.errors}');
        return const [];
      }
      messages.sort(
        (a, b) => a!.createdAt!.compareTo(b!.createdAt!),
      );
      return messages.map((e) => e as Message).toList();
    } on Exception catch (error) {
      safePrint('fail $error');
      return const [];
    }
  }

  Future<void> addMessage(Message message) async {
    try {
      final request = ModelMutations.create(message);
      final response = await Amplify.API.mutate(request: request).response;

      final createdMessage = response.data;
      if (createdMessage == null) {
        safePrint('errors: ${response.errors}');
        return;
      }
    } on Exception catch (error) {
      safePrint('failed: $error');
    }
  }

  Future<Message> getMessage(String messageId) async {
    try {
      final request = ModelQueries.get(
        Message.classType,
        MessageModelIdentifier(id: messageId),
      );
      final response = await Amplify.API.query(request: request).response;

      final message = response.data!;
      return message;
    } on Exception catch (error) {
      safePrint('getMessage failed: $error');
      rethrow;
    }
  }

  Future<void> deleteMessage(Message message) async {
    try {
      await Amplify.API
          .mutate(
            request: ModelMutations.delete(message),
          )
          .response;
    } on Exception catch (error) {
      safePrint('deleteTrip failed: $error');
    }
  }

  Future<void> deleteAllMessages(List<Message> messages) async {
    try {
      for (final Message message in messages) {
        await Amplify.API
            .mutate(
              request: ModelMutations.delete(message),
            )
            .response;
      }
    } on Exception catch (error) {
      safePrint('deleteTrip failed: $error');
    }
  }
}
