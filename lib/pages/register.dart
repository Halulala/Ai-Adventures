import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onNavigateToLogin;

  const RegisterPage({
    super.key,
    required this.onRegisterSuccess,
    required this.onNavigateToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> _handleRegister() async {
    final authService = AuthService();

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage("Passwords do not match.");
      return;
    }

    if (passwordController.text.length < 6) {
      _showMessage("The password must be at least 6 characters.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await authService.register(
        name: nameController.text,
        surname: surnameController.text,
        nickname: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (user != null) {
        widget.onRegisterSuccess();
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error during registration.";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is invalid.";
      } else if (e.code == 'weak-password') {
        message = "The password is too weak.";
      }
      _showMessage(message);
    } catch (e) {
      _showMessage("Unknown error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B1B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.person_add, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              Text(
                'Registration',
                style: GoogleFonts.pixelifySans(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              _buildTextField(nameController, "Name"),
              _buildTextField(surnameController, "Surname"),
              _buildTextField(usernameController, "Nickname"),
              _buildTextField(
                emailController,
                "Email",
                keyboardType: TextInputType.emailAddress,
                hint: "example@mail.com",
              ),
              _buildTextField(
                passwordController,
                "Password",
                obscure: true,
                hint: "At least 6 characters",
              ),
              _buildTextField(
                confirmPasswordController,
                "Confirm Password",
                obscure: true,
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleRegister,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'REGISTER',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onNavigateToLogin,
                child: const Text(
                  "Are you already registered? Sign in",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "* Enter a valid email",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Text(
                "* The password must be at least 6 characters long",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, hintText: hint),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
