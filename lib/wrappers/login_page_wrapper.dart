import 'package:flutter/material.dart';
import 'package:progetto/pages/login.dart';
import 'package:progetto/pages/register.dart';
import 'package:progetto/screens/main_screen.dart';

class LoginPageWrapper extends StatefulWidget {
  const LoginPageWrapper({super.key});

  @override
  State<LoginPageWrapper> createState() => _LoginPageWrapperState();
}

class _LoginPageWrapperState extends State<LoginPageWrapper> {
  bool showLogin = true;

  void _showRegister() => setState(() => showLogin = false);

  void _showLogin() => setState(() => showLogin = true);

  void _completeAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(
      onLoginSuccess: _completeAuth,
      onNavigateToRegister: _showRegister,
    )
        : RegisterPage(
      onRegisterSuccess: _completeAuth,
      onNavigateToLogin: _showLogin,
    );
  }
}
