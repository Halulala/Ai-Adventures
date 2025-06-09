import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onNavigateToLogin;

  const RegisterPage({
    super.key,
    required this.onRegisterSuccess,
    required this.onNavigateToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Future<void> _handleRegister() async {
      // Verifica che le password coincidano
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le password non coincidono.")),
        );
        return;
      }

      // Verifica lunghezza minima password
      if (passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La password deve essere di almeno 6 caratteri.")),
        );
        return;
      }

      try {
        // Prova a creare l'utente su Firebase Authentication
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Se la registrazione va a buon fine, richiama il callback
        onRegisterSuccess();
      } on FirebaseAuthException catch (e) {
        // Per debug in console
        print('FirebaseAuthException code: ${e.code}');

        String errorMessage = "Errore durante la registrazione.";
        if (e.code == 'email-already-in-use') {
          errorMessage = "Questa email è già registrata.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "L'indirizzo email non è valido.";
        } else if (e.code == 'weak-password') {
          errorMessage = "La password è troppo debole.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Errore generico
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore sconosciuto: $e")),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B1B),
      resizeToAvoidBottomInset: true,
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
                'Registrazione',
                style: GoogleFonts.pixelifySans(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(height: 40),

              // Campo Nome
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Nome"),
              ),
              const SizedBox(height: 10),

              // Campo Cognome
              TextField(
                controller: surnameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Cognome"),
              ),
              const SizedBox(height: 10),

              // Campo Username
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Username"),
              ),
              const SizedBox(height: 10),

              // Campo Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  "Email",
                  hintText: "esempio@mail.com",
                ),
              ),
              const SizedBox(height: 10),

              // Campo Password
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  "Password",
                  hintText: "Almeno 6 caratteri",
                ),
              ),
              const SizedBox(height: 10),

              // Campo Conferma Password
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Conferma Password"),
              ),
              const SizedBox(height: 30),

              // Pulsante REGISTRATI
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _handleRegister,
                  child: Text(
                    'REGISTRATI',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pulsante "Sei già registrato? Accedi"
              TextButton(
                onPressed: onNavigateToLogin,
                child: const Text(
                  "Sei già registrato? Accedi",
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 12),
              // Messaggi di nota sotto i pulsanti
              const Text(
                "* Inserire una email valida",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                "* La password deve essere di almeno 6 caratteri",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper per creare un InputDecoration con label e opzionale hintText
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
