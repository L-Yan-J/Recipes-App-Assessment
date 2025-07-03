// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/component/custom_dialog.dart';

void handleDelete(
    BuildContext context, DocumentReference docID, String type) async {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Delete $type"),
            content: const Text(
                "Are you sure you want to delete this recipe? This action cannot be undo."),
            actions: [
              TextButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()));
                    await docID.delete();
                    //Pop circular progress indicator
                    Navigator.of(context, rootNavigator: true).pop();

                    await showDialog(
                        context: context,
                        builder: (context) => CustomDialog(
                              title: "$type Deleted Successfully",
                              closeText: "OK",
                            ));
                    //Pop the outer alert dialog
                    Navigator.of(context, rootNavigator: true).pop();
                    //Pop the detail page (back to previou page)
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text("Delete")),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
            ],
          ));
}
