import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/common/ui/custom_widgets/dialog/custom_alert_dialog.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/chatbot/controller/messages_list_controller.dart';
import 'package:plantairium/features/chatbot/services/message_service.dart';
import 'package:plantairium/features/chatbot/utils/constants/user_type.dart';
import 'package:plantairium/features/chatbot/ui/components/bottom_input_field.dart';
import 'package:plantairium/features/chatbot/ui/components/bubble_chat.dart';

class Chatbot extends ConsumerStatefulWidget {
  const Chatbot({super.key});
  @override
  ConsumerState<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends ConsumerState<Chatbot> {
  final TextEditingController _controller = TextEditingController();

  List<String> blackListId = [];
  @override
  Widget build(BuildContext context) {
    final messagesList = ref.watch(messageAPIServiceStreamProvider);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Palette.primary),
            onPressed: () => context.goNamed(AppRoute.home.name),
          ),
          // automaticallyImplyLeading: false,
          title: const Text('ChatBot'),
        ),
        body: switch (messagesList) {
          AsyncData(:final value) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        // reverse: true,
                        shrinkWrap: true,
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final message = value[index];
                          return Visibility(
                            visible: !blackListId.contains(value[index].id),
                            child: GestureDetector(
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (context) => CustomAlertDialog(
                                  title: 'Are you sure to delete this message?',
                                  onPressed: () {
                                    setState(() {
                                      blackListId.add(value[index].id);
                                    });
                                    ref
                                        .read(messagesListControllerProvider
                                            .notifier)
                                        .removeMessage(message: value[index]);
                                    Navigator.pop(context);
                                    ref.invalidate(
                                        messageAPIServiceStreamProvider);

                                    //TODO: clear list
                                    // setState(() {
                                    //   blackListId = [];
                                    // });
                                  },
                                ),
                              ),
                              child: BubbleMessage(
                                isTail: true,
                                message: message.message,
                                userType:
                                    message.userType ?? UserType.chatbot.name,
                              ),
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: BottomInputField(
                              controller: _controller,
                              onPressed: () {
                                final currMess = _controller.text;
                                setState(() {
                                  _controller.text = '';
                                });

                                ref
                                    .read(
                                        messagesListControllerProvider.notifier)
                                    .addFlaskMessage(
                                      messageContent: currMess,
                                      userId: "1",
                                      userType: UserType.chatbot.name,
                                    );
                                ref
                                    .read(
                                        messagesListControllerProvider.notifier)
                                    .addMessage(
                                      messageContent: currMess,
                                      userId: "1",
                                      userType: UserType.sender.name,
                                    );
                                // .then((value) => ref.read(
                                //         messagesListControllerProvider
                                //             .notifier)
                                // .addMessage(
                                //   userId: "1",
                                //   messageContent: currMess,
                                //   userType: UserType.chatbot.name,
                                // ),
                                // );
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => CustomAlertDialog(
                                  title: 'Are you sure to delete the chat?',
                                  onPressed: () {
                                    try {
                                      final totalMessages = value;
                                      for (final val in value) {
                                        blackListId.add(val.id);
                                      }
                                      ref
                                          .read(messagesListControllerProvider
                                              .notifier)
                                          .removeAllMessages(
                                              messages: totalMessages);

                                      ref.invalidate(
                                          messageAPIServiceStreamProvider);
                                    } on Exception catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString(),
                                          ),
                                        ),
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          AsyncError(:final error) => Text(
              error.toString(),
            ),
          _ => const Center(
              child: CircularProgressIndicator(),
            ),
        },
      ),
    );
  }
}
