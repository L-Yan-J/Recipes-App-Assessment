// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/component/custom_dialog.dart';
import 'package:recipe_app/component/dropdown_selection.dart';
import 'package:recipe_app/component/dynamic_button.dart';
import 'package:recipe_app/component/dynamic_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/model/recipe_type.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recipe_app/utilities/utilities.dart';

class CreateRecipePage extends StatefulWidget {
  const CreateRecipePage({super.key});

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  String? _selectedType = RecipeType.type.first;
  final _nameTextController = TextEditingController();
  final _stepTextController = TextEditingController();
  final _ingredientsTextController = TextEditingController();
  File? selectedImage;
  // ignore: prefer_typing_uninitialized_variables
  String? imageURL;

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
  }

  Future<void> createRecipe() async {
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    if (_selectedType == "All") {
      // Pop out loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      await showDialog(
          context: context,
          builder: (context) => const CustomDialog(
                title: "Recipe Categoty",
                content: "Please select a category for the recipe",
                closeText: "OK",
              ));
      return;
    }

    if (_nameTextController.text.trim().isEmpty ||
        _stepTextController.text.isEmpty ||
        _ingredientsTextController.text.isEmpty) {
      // Pop out loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      await showDialog(
          context: context,
          builder: (context) => const CustomDialog(
                title: "Information Required",
                content: "Please enter all the information",
                closeText: "OK",
              ));
      return;
    }

    if (selectedImage == null) {
      // Pop out loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      await showDialog(
          context: context,
          builder: (context) => const CustomDialog(
                title: "Image Needed",
                content: "Please upload the food picture",
                closeText: "OK",
              ));
      return;
    }

    if (imageURL == null) {
      // Pop out loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      await showDialog(
          context: context,
          builder: (context) => const CustomDialog(
                title: "Uploading Image",
                content: "The image is still uploading",
                closeText: "OK",
              ));
      return;
    }

    if (_nameTextController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection("Recipe")
            .doc(_nameTextController.text)
            .set({
          "recipe name": _nameTextController.text,
          "recipe type": _selectedType,
          "image": imageURL,
          "recipe step": _stepTextController.text,
          "recipe ingredient": _ingredientsTextController.text
        });

        setState(() {
          _nameTextController.clear();
        });

        // Pop out loading indicator
        Navigator.of(context, rootNavigator: true).pop();

        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Recipe Created Successfully"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"))
                  ],
                ));

        // Pop out the create page
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        debugPrint("Error creating recipe: $e");
      }
    }
  }

  void closeCreatePage() {
    Navigator.of(context).pop();
  }

  void selectImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Uploading Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(), // Circular progress indicator
            SizedBox(height: 16), // Spacer
            Text("Uploading..."), // Text indicating image uploading
          ],
        ),
      ),
    );

    setState(() {
      selectedImage = File(image.path);
    });

    final ref =
        FirebaseStorage.instance.ref().child("Food Image/${image.name}");

    await ref.putFile(File(image.path));
    final url = await ref.getDownloadURL();
    imageURL = url;

    Navigator.of(context, rootNavigator: true).pop();
  }

  bool _hasChanges() {
    return _nameTextController.text.isNotEmpty ||
        _ingredientsTextController.text.isNotEmpty ||
        _stepTextController.text.isNotEmpty ||
        (selectedImage != null && imageURL != null);
  }

  @override
  Widget build(BuildContext context) {
    // double titleFontSize = MediaQuery.of(context).size.height * 0.030;
    double subtitleFontsize = MediaQuery.of(context).size.height * 0.025;
    FontWeight fontWeight = FontWeight.w500;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Create Recipe"),
          leading: IconButton(
              onPressed: () {
                // Navigator.of(context).pop();
                promptDiscardChanges(_hasChanges(), context,
                    closeCreatePage: closeCreatePage);
              },
              icon: const Icon(Icons.arrow_back_rounded)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                  onTap: selectImage,
                  child: Stack(
                    children: [
                      selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration:
                                  BoxDecoration(color: Colors.grey[300]),
                              child: Image.asset(
                                "assets/images/default.png",
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                            ),
                      const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.edit),
                          ))
                    ],
                  )),
              // const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Category",
                        style: TextStyle(
                          fontSize: subtitleFontsize,
                          fontWeight: fontWeight,
                        )),
                    DropdownSelection(
                        selectedType: _selectedType ?? "",
                        onTypeChanged: (newValue) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        }),
                    const SizedBox(height: 20),
                    Text("Name",
                        style: TextStyle(
                          fontSize: subtitleFontsize,
                          fontWeight: fontWeight,
                        )),
                    const SizedBox(height: 10),
                    DynamicTextField(
                      controller: _nameTextController,
                      hintText: 'Recipe Name',
                    ),
                    const SizedBox(height: 20),
                    Text("Ingredients",
                        style: TextStyle(
                          fontSize: subtitleFontsize,
                          fontWeight: fontWeight,
                        )),
                    const SizedBox(height: 10),
                    DynamicTextField(
                      controller: _ingredientsTextController,
                      hintText: 'Enter Ingredients',
                      maxLines: null,
                    ),
                    const SizedBox(height: 20),
                    Text("Steps",
                        style: TextStyle(
                          fontSize: subtitleFontsize,
                          fontWeight: fontWeight,
                        )),
                    const SizedBox(height: 10),
                    DynamicTextField(
                      controller: _stepTextController,
                      hintText: 'Enter Steps',
                      maxLines: null,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DynamicButton(onTap: createRecipe, text: "Create"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
