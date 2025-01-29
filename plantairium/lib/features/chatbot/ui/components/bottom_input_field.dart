// lib/features/chatbot/ui/components/bottom_input_field.dart

import 'package:flutter/material.dart';
import 'package:plantairium/common/utils/colors.dart';

class BottomInputField extends StatelessWidget {
  const BottomInputField({
    super.key,
    this.onPressed,
    required this.controller,
  });

  final void Function()? onPressed;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Palette.lightGreen,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: controller,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Scrivi un messaggio...',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.green),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
