import 'package:flutter/material.dart';
import 'package:plantairium/common/utils/colors.dart';

class CustomMaterialButton extends StatelessWidget {
  const CustomMaterialButton({
    super.key,
    this.onPressed,
    this.title = '',
  });
  final void Function()? onPressed;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      shadowColor: Palette.primary,
      elevation: 4,
      color: Palette.primary,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title!,
          style: TextStyle(
            color: Palette.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
