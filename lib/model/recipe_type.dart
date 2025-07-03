import 'dart:convert';
import 'package:flutter/services.dart';

class RecipeType {
  static List<String> type = [];

  static Future<void> loadTypes() async {
    final String response =
        await rootBundle.loadString('assets/data/recipe_types.json');
    final data = jsonDecode(response);
    type = List<String>.from(data['types']);
  }
}
