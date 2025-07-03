import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/component/bottom_navigation.dart';
import 'package:recipe_app/component/dynamic_textfield.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool isSignUpSelected = false;
  bool isRememberMeChecked = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmedPasswordController =
      TextEditingController();

  // Sign Up User Function
  Future<void> signUpUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmedPassword = _confirmedPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmedPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please ensure all the required information is entered")),
      );
      return;
    }

    if (password != confirmedPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Show loading dialog
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'email': email});

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Sign Up failed";
      if (e.code == 'weak-password') {
        message = "Password should be at least 6 characters";
      } else {
        debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
      }
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  //Sign In User
  Future<void> signInUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Ensure all the required credential is entered")),
      );
      return;
    }

    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      Navigator.of(context, rootNavigator: true).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'invalid-email') {
        message = "Invalid Email";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid Credential.";
      } else {
        debugPrint("FirebaseAuthException 00000000: ${e.code} - ${e.message}");
      }
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Image.asset('assets/icons/app_icon.png', height: 120),
                    const Text(
                      "Get Started Now",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Create an account or log in to explore about our app",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),

                    // Sign Up and Login Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 6),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8)),
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Sign Up Button
                          Expanded(
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    isSignUpSelected = true;
                                  });
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: isSignUpSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: const Text("Sign Up")),
                          ),

                          //Login Button
                          Expanded(
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    isSignUpSelected = false;
                                  });
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: isSignUpSelected
                                        ? Colors.transparent
                                        : Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: const Text("Login")),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    //Sign Up Text Field
                    isSignUpSelected
                        ? SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Field
                                const Text("Email Address"),
                                const SizedBox(height: 4),

                                DynamicTextField(
                                  controller: _emailController,
                                  hintText: "Enter your email",
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                const Text("Password"),
                                const SizedBox(height: 4),

                                DynamicTextField(
                                    controller: _passwordController,
                                    hintText: "Password",
                                    passwordField: true),

                                const SizedBox(height: 20),

                                // Confirmed Password Field
                                const Text("Confirmed Password"),
                                const SizedBox(height: 4),

                                DynamicTextField(
                                    controller: _confirmedPasswordController,
                                    hintText: "Confirmed Password",
                                    passwordField: true),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Field
                                const Text("Email Address"),
                                const SizedBox(height: 4),

                                DynamicTextField(
                                  controller: _emailController,
                                  hintText: "Enter your email",
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                const Text("Password"),
                                const SizedBox(height: 4),

                                DynamicTextField(
                                    controller: _passwordController,
                                    hintText: "Password",
                                    passwordField: true),
                              ],
                            ),
                          ),
                    const SizedBox(
                      height: 40,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            if (!isSignUpSelected) {
                              signInUser();
                            } else {
                              signUpUser();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 213, 175, 50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: Text(isSignUpSelected ? "Sign Up" : "Log In")),
                    ),
                  ],
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'By continuing, you agree to our ',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                children: [
                  TextSpan(
                      text: 'Term of Service',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 213, 175, 50),
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                  const TextSpan(
                    text: ' and ',
                  ),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 213, 175, 50),
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      )),
    );
  }
}
