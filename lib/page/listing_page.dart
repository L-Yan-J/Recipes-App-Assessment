import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/component/dropdown_selection.dart';
import 'package:recipe_app/component/recipe_card.dart';
import 'package:recipe_app/model/recipe_model.dart';
import 'package:recipe_app/model/recipe_type.dart';
import 'package:recipe_app/page/create_recipe_page.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  String? _selectedType = RecipeType.type.first;

  @override
  void initState() {
    super.initState();
    _selectedType = "All";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.amber,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateRecipePage()));
            }),
        appBar: AppBar(
          title: const Text("Recipe"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Container(
                color: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownSelection(
                    selectedType: _selectedType ?? "",
                    onTypeChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    })),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("Recipe").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<RecipeModel> allRecipe = snapshot.data!.docs
                  .map((doc) => RecipeModel(
                        id: doc.id,
                        name: doc["recipe name"] ?? "",
                        type: doc["recipe type"] ?? "",
                        image: doc["image"] ?? "",
                        step: doc["recipe step"] ?? "",
                        ingredients: doc["recipe ingredient"] ?? "",
                      ))
                  .toList();

              List<RecipeModel> filteredRecipes;
              if (_selectedType == "All") {
                filteredRecipes = allRecipe;
              } else {
                filteredRecipes = allRecipe
                    .where((recipe) => recipe.type == _selectedType)
                    .toList();
              }

              return ListView(
                children: [
                  const SizedBox(height: 24),
                  filteredRecipes.isNotEmpty
                      ? Column(
                          children: filteredRecipes
                              .map((recipe) => RecipeCard(recipeData: recipe))
                              .toList())
                      : const Center(child: Text("No record"))
                ],
              );
            }));
  }
}
