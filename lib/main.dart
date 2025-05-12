// lib/main.dart
import 'package:flutter/material.dart';
import 'package:progetto/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const HomePage(), // ✅ qui rimuovi il parametro `title`
    );
  }
}
