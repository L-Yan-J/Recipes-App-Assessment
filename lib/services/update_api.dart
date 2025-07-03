// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/component/custom_dialog.dart';

void handleUpdate(
    bool hasChanges,
    BuildContext context,
    DocumentReference recipeDoc,
    TextEditingController nameTextController,
    TextEditingController stepTextController,
    TextEditingController ingredientsTextController,
    String selectedType,
    String? imageURL,
    String defaultImage,
    Function onUpdateContent,
    Function resetContent,
    Function resetOpacity) async {
  if (hasChanges) {
    try {
      showDialog(
          context: context,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()));

      await recipeDoc.update({
        "recipe name": nameTextController.text,
        "recipe type": selectedType,
        "image": imageURL ?? defaultImage,
        "recipe step": stepTextController.text,
        "recipe ingredient": ingredientsTextController.text
      });

      onUpdateContent();
      resetContent();
      resetOpacity();

      // Pop the circular progress indicator
      Navigator.of(context, rootNavigator: true).pop();

      showDialog(
          context: context,
          builder: (context) => const CustomDialog(
                title: "Recipe Updated Successfully",
                closeText: "OK",
              ));
    } catch (e) {
      debugPrint("error: $e");
    }
  }

  if (!hasChanges) {
    showDialog(
        context: context,
        builder: (context) => const CustomDialog(
              title: "No Changes",
              content: "Please make some changes before update",
              closeText: "OK",
            ));
  }
}
