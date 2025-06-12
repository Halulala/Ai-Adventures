import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progetto/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'wrappers/login_page_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  final prefs = await SharedPreferences.getInstance();
  final rememberLogin = prefs.getBool('remember_login') ?? false;
  final currentUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp(startLoggedIn: currentUser != null && rememberLogin));
}

class MyApp extends StatelessWidget {
  final bool startLoggedIn;

  const MyApp({super.key, required this.startLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI & Adventures',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.pixelifySansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: startLoggedIn ? const MainScreen() : const LoginPageWrapper(),
    );
  }
}
