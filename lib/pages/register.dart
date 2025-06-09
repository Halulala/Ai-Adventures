import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le password non coincidono.")),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La password deve essere di almeno 6 caratteri.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(usernameController.text.trim());

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'surname': surnameController.text.trim(),
          'nickname': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        await user.reload();

        widget.onRegisterSuccess(); // ✅ NAVIGAZIONE CORRETTA QUI
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Errore durante la registrazione.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Questa email è già registrata.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "L'indirizzo email non è valido.";
      } else if (e.code == 'weak-password') {
        errorMessage = "La password è troppo debole.";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore sconosciuto: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              Text('Registrazione', style: GoogleFonts.pixelifySans(fontSize: 32, color: Colors.white)),
              const SizedBox(height: 40),

              TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Nome")),
              const SizedBox(height: 10),
              TextField(controller: surnameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Cognome")),
              const SizedBox(height: 10),
              TextField(controller: usernameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Nickname")),
              const SizedBox(height: 10),
              TextField(controller: emailController, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Email", hintText: "esempio@mail.com")),
              const SizedBox(height: 10),
              TextField(controller: passwordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Password", hintText: "Almeno 6 caratteri")),
              const SizedBox(height: 10),
              TextField(controller: confirmPasswordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Conferma Password")),
              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: isLoading ? null : _handleRegister,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('REGISTRATI', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onNavigateToLogin,
                child: const Text("Sei già registrato? Accedi", style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 12),
              const Text("* Inserire una email valida", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const Text("* La password deve essere di almeno 6 caratteri", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
