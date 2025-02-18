import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  const CustomListTile({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.iconColor
  });
  final IconData icon;
  final String text;
  final void Function()? onTap;
  final Color? iconColor;

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(10)),
          tileColor: const Color.fromARGB(255, 244, 244, 244),
          leading: Icon(widget.icon, color: widget.iconColor,),
          trailing: const Icon(Icons.keyboard_arrow_right),
          title: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
