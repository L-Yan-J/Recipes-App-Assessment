import 'package:flutter/material.dart';

class DynamicButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const DynamicButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 150,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 23, 31, 52),
              borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ))),
    );
  }
}
