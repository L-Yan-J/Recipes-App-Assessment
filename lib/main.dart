import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_app/model/recipe_type.dart';
import 'package:recipe_app/page/listing_page.dart';
import 'package:recipe_app/page/login_or_register_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RecipeType.loadTypes();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.amber,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.030,
              color: Colors.black,
            ),
            iconTheme: IconThemeData(
              size: MediaQuery.of(context).size.height * 0.045,
              color: const Color.fromARGB(
                  255, 0, 0, 0), // Set the color for leading and action icons
            ),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[100]),
      home: const LoginOrRegister(),
    );
  }
}
