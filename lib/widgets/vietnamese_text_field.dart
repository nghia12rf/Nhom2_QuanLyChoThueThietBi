import 'package:flutter/material.dart';

class VietnameseTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final int maxLines;

  const VietnameseTextField({
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.maxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      enableSuggestions: true,
      autocorrect: true,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}
