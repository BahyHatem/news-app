import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final IconData? icon;
  final VoidCallback? onClear;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.focusNode,
    this.nextFocus,
    this.icon,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      focusNode: focusNode,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) => nextFocus != null
          ? FocusScope.of(context).requestFocus(nextFocus)
          : FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: onClear != null
            ? IconButton(icon: Icon(Icons.clear), onPressed: onClear)
            : null,
        border: OutlineInputBorder(),
      ),
    );
  }
}
