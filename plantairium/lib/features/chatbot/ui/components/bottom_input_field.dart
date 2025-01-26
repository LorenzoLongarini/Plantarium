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
        margin: const EdgeInsets.only(top: 20),
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Palette.lightGreen,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            TextFormField(
              controller: controller,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  right: 42,
                  left: 16,
                  top: 18,
                ),
                hintText: 'message',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            // custom suffix btn
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
