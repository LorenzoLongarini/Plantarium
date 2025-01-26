import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/chatbot/utils/constants/user_type.dart';

class BubbleMessage extends StatelessWidget {
  const BubbleMessage({
    super.key,
    required this.message,
    required this.userType,
    this.isTail = false,
    this.textStyle = const TextStyle(fontSize: 15, color: Colors.white),
  });
  final String message;
  final bool? isTail;
  final TextStyle? textStyle;
  final String userType;

  @override
  Widget build(BuildContext context) {
    return BubbleSpecialThree(
      isSender: userType == UserType.sender.name,
      text: message,
      tail: isTail!,
      textStyle: textStyle!,
      color: userType == UserType.sender.name
          ? Palette.primary
          : Palette.secundary,
    );
  }
}
