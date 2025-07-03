import 'package:flutter/material.dart';
import 'package:recipe_app/model/recipe_type.dart';

// ignore: must_be_immutable
class DropdownSelection extends StatefulWidget {
  String selectedType;
  final ValueChanged<String?> onTypeChanged;
  bool isEnabled;

  DropdownSelection(
      {super.key,
      required this.selectedType,
      required this.onTypeChanged,
      this.isEnabled = true});

  @override
  State<DropdownSelection> createState() => _DropdownSelectionState();
}

class _DropdownSelectionState extends State<DropdownSelection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            isExpanded: true,
            value: widget.selectedType,
            icon: widget.isEnabled == true
                ? const Icon(Icons.arrow_drop_down,
                    color: Color.fromARGB(255, 0, 0, 0))
                : const SizedBox.shrink(),
            dropdownColor: Colors.amber[100],
            items:
                RecipeType.type.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: widget.isEnabled == true
                ? (String? newValue) {
                    setState(() {
                      widget.onTypeChanged(newValue);
                    });
                  }
                : null),
      ),
    );
  }
}
