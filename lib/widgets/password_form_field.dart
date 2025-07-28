import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;

  const PasswordFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.focusNode,
    this.nextFocus,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscure = true;

  String _getStrength(String password) {
    if (password.length < 6) return "Weak";
    if (password.length < 10) return "Medium";
    return "Strong";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          validator: widget.validator,
          focusNode: widget.focusNode,
          textInputAction: widget.nextFocus != null ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) => widget.nextFocus != null
              ? FocusScope.of(context).requestFocus(widget.nextFocus)
              : FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        if (widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Strength: ${_getStrength(widget.controller.text)}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          )
      ],
    );
  }
}
