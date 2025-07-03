import 'package:flutter/material.dart';

class DynamicTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  final bool passwordField;

  const DynamicTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.maxLines = 1,
      this.passwordField = false});

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.passwordField ? _obscureText : false,
      maxLines: widget.maxLines,
      controller: widget.controller,
      decoration: InputDecoration(
          suffixIcon: widget.passwordField
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: _obscureText
                      ? const Icon(Icons.visibility_outlined)
                      : const Icon(Icons.visibility_off))
              : null,
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 111, 0))),
          fillColor: Colors.amber[50],
          filled: true,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.black54)),
    );
  }
}
