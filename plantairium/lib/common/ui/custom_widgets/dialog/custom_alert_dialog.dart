import 'package:flutter/material.dart';
import 'package:plantairium/common/utils/colors.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    this.onPressed,
    this.title = '',
  });
  final void Function()? onPressed;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title!,
        style: const TextStyle(fontSize: 20),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onPressed,
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ),
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Palette.primary, fontSize: 15),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ],
    );
  }
}
