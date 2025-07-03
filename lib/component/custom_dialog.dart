import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final String title;
  final String content;
  final String confirmText;
  final String closeText;
  final VoidCallback? onConfirm;

  const CustomDialog(
      {super.key,
      required this.title,
      this.content = "",
      this.confirmText = "",
      this.closeText = "",
      this.onConfirm});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    double confirmCloseText = MediaQuery.of(context).size.height * 0.018;

    List<Widget> actionButtons = [];
    if (widget.confirmText.isNotEmpty) {
      actionButtons.add(
        TextButton(
          onPressed: () {
            widget.onConfirm?.call();
          },
          child: Text(
            widget.confirmText,
            style: TextStyle(fontSize: confirmCloseText),
          ),
        ),
      );
    }

    if (widget.closeText.isNotEmpty) {
      actionButtons.add(
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            widget.closeText,
            style: TextStyle(fontSize: confirmCloseText),
          ),
        ),
      );
    }

    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.title,
        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.028),
      ),
      content: Text(
        widget.content,
        textAlign: TextAlign.justify,
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.02, height: 1.8),
      ),
      actions: actionButtons,
    );
  }
}
