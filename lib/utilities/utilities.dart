import 'package:flutter/material.dart';
import 'package:recipe_app/component/custom_dialog.dart';

void promptDiscardChanges(bool hasChanges, BuildContext context,
    {Function? resetChanges,
    Function? toggleEditMode,
    Function? resetOpacity,
    Function? closeCreatePage}) {
  if (hasChanges) {
    showDialog(
        context: context,
        builder: (context) => CustomDialog(
              title: "Discard Changes?",
              content: "You have unsaved changes. Do you want to discard them?",
              confirmText: "Discard",
              onConfirm: () {
                toggleEditMode?.call();
                resetOpacity?.call();
                resetChanges?.call();
                Navigator.pop(context); // Close the dialog
                closeCreatePage?.call();
              },
              closeText: "Close",
            ));
  } else {
    toggleEditMode?.call();
    resetOpacity?.call();
    closeCreatePage?.call();
  }
}
