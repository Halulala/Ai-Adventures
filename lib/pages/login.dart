// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../state/login_page_state.dart'; // <-- Importa il file giusto

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToRegister;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
  });

  @override
  State<LoginPage> createState() => LoginPageState(); // <-- Funziona ora
}
