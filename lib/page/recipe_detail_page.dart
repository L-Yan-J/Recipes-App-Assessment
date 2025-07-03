// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/component/dropdown_selection.dart';
import 'package:recipe_app/component/dynamic_button.dart';
import 'package:recipe_app/component/dynamic_textfield.dart';
import 'package:recipe_app/model/recipe_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recipe_app/services/delete_api.dart';
import 'package:recipe_app/services/update_api.dart';
import 'package:recipe_app/utilities/utilities.dart';

class RecipeDetailPage extends StatefulWidget {
  final RecipeModel recipeData;
  const RecipeDetailPage({super.key, required this.recipeData});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;
  bool _isEditing = false;
  late String _selectedType;
  late TextEditingController _nameTextController;
  late TextEditingController _stepTextController;
  late TextEditingController _ingredientsTextController;
  late DocumentReference recipeDoc;
  File? selectedImage;
  // ignore: prefer_typing_uninitialized_variables
  String? imageURL;

  void updateOpacity() {
    setState(() {
      _opacity = (_scrollController.offset / 100).clamp(0.0, 1.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(updateOpacity);
    recipeDoc = FirebaseFirestore.instance
        .collection("Recipe")
        .doc(widget.recipeData.id);
    _nameTextController = TextEditingController(text: widget.recipeData.name);
    _ingredientsTextController =
        TextEditingController(text: widget.recipeData.ingredients);
    _stepTextController = TextEditingController(text: widget.recipeData.step);
    _selectedType = widget.recipeData.type;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _nameTextController.dispose();
    _ingredientsTextController.dispose();
    _stepTextController.dispose();
  }

  void toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void resetOpacity() {
    setState(() {
      _opacity = 0.0;
    });
  }

  void updateContent() {
    setState(() {
      widget.recipeData.name = _nameTextController.text;
      widget.recipeData.step = _stepTextController.text;
      widget.recipeData.ingredients = _ingredientsTextController.text;
      widget.recipeData.image = imageURL ?? widget.recipeData.image;
      _isEditing = false;
    });
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
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Uploading..."),
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

    // Pop the circular progress indicator
    Navigator.of(context, rootNavigator: true).pop();
  }

  bool _hasChanges() {
    return _nameTextController.text != widget.recipeData.name ||
        _ingredientsTextController.text != widget.recipeData.ingredients ||
        _stepTextController.text != widget.recipeData.step ||
        (selectedImage != null && imageURL != null) ||
        _selectedType != widget.recipeData.type;
  }

  // Reset changes to their original state
  void _resetChanges() {
    _nameTextController.text = widget.recipeData.name;
    _ingredientsTextController.text = widget.recipeData.ingredients;
    _stepTextController.text = widget.recipeData.step;
    selectedImage = null;
    imageURL = null;
    setState(() {
      _isEditing = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    double titleFontSize = MediaQuery.of(context).size.height * 0.030;
    double subtitleFontsize = MediaQuery.of(context).size.height * 0.025;
    FontWeight fontWeight = FontWeight.w500;

    return Scaffold(
        extendBodyBehindAppBar: _isEditing ? false : true,
        appBar: AppBar(
          title:
              _isEditing ? const Text("Edit Recipe") : const SizedBox.shrink(),
          backgroundColor: _isEditing
              ? Colors.amber
              : const Color.fromARGB(255, 255, 251, 133).withOpacity(_opacity),
          leading: IconButton(
              onPressed: () {
                if (_isEditing) {
                  promptDiscardChanges(_hasChanges(), context,
                      resetChanges: _resetChanges,
                      toggleEditMode: toggleEditMode,
                      resetOpacity: resetOpacity);
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back_rounded)),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 5),
              child: PopupMenuButton(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (!_isEditing)
                    const PopupMenuItem(value: "edit", child: Text("Edit")),
                  const PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
                onSelected: (String value) {
                  if (value == "edit") {
                    toggleEditMode();
                  } else if (value == "delete") {
                    handleDelete(context, recipeDoc, "Recipe");
                  }
                },
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _isEditing
                  ? GestureDetector(
                      onTap: selectImage,
                      child: Stack(
                        children: [
                          selectedImage != null
                              ? Image.file(
                                  selectedImage!,
                                  height: 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.recipeData.image,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  height: 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle),
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.all(12),
                                child: const Icon(Icons.edit),
                              ))
                        ],
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.recipeData.image,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  width: double.infinity,
                  child: _isEditing
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name",
                                style: TextStyle(
                                  fontSize: subtitleFontsize,
                                  fontWeight: fontWeight,
                                )),
                            DynamicTextField(
                                controller: _nameTextController,
                                hintText: "Enter Recipe Name"),
                            const SizedBox(height: 20),
                            Text("Category",
                                style: TextStyle(
                                  fontSize: subtitleFontsize,
                                  fontWeight: fontWeight,
                                )),
                            DropdownSelection(
                                selectedType: _selectedType,
                                onTypeChanged: (newValue) {
                                  setState(() {
                                    _selectedType = newValue!;
                                  });
                                }),
                            const SizedBox(height: 20),
                            Text("Ingredients",
                                style: TextStyle(
                                  fontSize: subtitleFontsize,
                                  fontWeight: fontWeight,
                                )),
                            DynamicTextField(
                              controller: _ingredientsTextController,
                              hintText: "Enter Ingredients",
                              maxLines: null,
                            ),
                            const SizedBox(height: 20),
                            Text("Steps",
                                style: TextStyle(
                                  fontSize: subtitleFontsize,
                                  fontWeight: fontWeight,
                                )),
                            DynamicTextField(
                              controller: _stepTextController,
                              hintText: "Enter Steps",
                              maxLines: null,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DynamicButton(
                                    onTap: () {
                                      handleUpdate(
                                          _hasChanges(),
                                          context,
                                          recipeDoc,
                                          _nameTextController,
                                          _stepTextController,
                                          _ingredientsTextController,
                                          _selectedType,
                                          imageURL,
                                          widget.recipeData.image,
                                          updateContent,
                                          _resetChanges,
                                          resetOpacity);
                                    },
                                    text: "Update"),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        )
                      : Column(
                          children: [
                            Text(widget.recipeData.name,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: fontWeight,
                                )),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Text("Category",
                                      style: TextStyle(
                                        fontSize: subtitleFontsize,
                                        fontWeight: fontWeight,
                                      )),
                                  DropdownSelection(
                                      isEnabled: false,
                                      selectedType: _selectedType,
                                      onTypeChanged: (newValue) {
                                        setState(() {
                                          _selectedType = newValue!;
                                        });
                                      }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Ingredients",
                                          style: TextStyle(
                                            fontSize: subtitleFontsize,
                                            fontWeight: fontWeight,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(widget.recipeData.ingredients),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Steps",
                                          style: TextStyle(
                                            fontSize: subtitleFontsize,
                                            fontWeight: fontWeight,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(widget.recipeData.step),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        )),
            ],
          ),
        ));
  }
}
