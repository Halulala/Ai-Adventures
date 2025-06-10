import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/character_model.dart';
import '../services/firestore_service.dart';

class CreateCharacterPage extends StatefulWidget {
  const CreateCharacterPage({super.key});

  @override
  State<CreateCharacterPage> createState() => _CreateCharacterPageState();
}

class _CreateCharacterPageState extends State<CreateCharacterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final promptController = TextEditingController();
  final imagePathController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  void _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      final newCharacter = CharacterModel(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        prompt: promptController.text,
        imagePath: imagePathController.text.isEmpty
            ? 'images/720x1280.png'
            : imagePathController.text,
      );
      await _firestoreService.addCharacter(newCharacter);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1B1B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Crea Personaggio",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nameController, 'Nome', 'Inserisci un nome'),
              _buildTextField(descriptionController, 'Descrizione', 'Inserisci una descrizione'),
              _buildTextField(promptController, 'Prompt per l\'IA', null),
              _buildTextField(imagePathController, 'Path immagine (opzionale)', null),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveCharacter,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    'Salva',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? validatorText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        validator: validatorText != null
            ? (value) => value!.isEmpty ? validatorText : null
            : null,
      ),
    );
  }
}
