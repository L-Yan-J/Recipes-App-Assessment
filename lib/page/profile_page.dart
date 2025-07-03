import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/component/dynamic_button.dart';
import 'package:recipe_app/page/login_or_register_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void logoutUser() async {
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    await FirebaseAuth.instance.signOut();

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DynamicButton(onTap: logoutUser, text: "Logout"),
        ],
      )),
    );
  }
}
