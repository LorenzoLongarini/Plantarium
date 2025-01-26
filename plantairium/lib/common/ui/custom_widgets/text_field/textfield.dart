import 'package:flutter/material.dart';
import 'package:plantairium/common/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.obscureText = false,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.labelText = '',
    this.color = Colors.transparent,
    this.radius = 10,
    this.vertcialMargin = 5.0,
    this.horizontalMargin = 5.0,
    this.backgroundColor,
    this.height,
    this.width,
    required this.controller,
  });
  final bool obscureText;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? labelText;
  final Color color;
  final Color? backgroundColor;
  final double radius;
  final double vertcialMargin;
  final double horizontalMargin;
  final double? height;
  final double? width;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(
        width: 1.5,
        color: color,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(
        vertical: vertcialMargin,
        horizontal: horizontalMargin,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: Palette.primary),
          focusedBorder: border,
          focusColor: Palette.primary,
          enabledBorder: border,
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
