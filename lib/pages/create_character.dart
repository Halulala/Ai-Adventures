import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/character_model.dart';
import '../services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';


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

  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }
  void _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      String imageBase64 = '';

      if (_selectedImage != null) {
        final base64 = await imageFileToBase64(_selectedImage);
        if (base64 != null) {
          imageBase64 = base64;
        }
      }

      final newCharacter = CharacterModel(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        prompt: promptController.text,
        imagePath: imageBase64.isEmpty ? '' : imageBase64,
      );

      await _firestoreService.addCharacter(newCharacter);
      Navigator.pop(context);
    }
  }

  Future<String?> imageFileToBase64(File? imageFile) async {
    if (imageFile == null) return null;
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
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
              const SizedBox(height: 10),
              Text(
                'Immagine selezionata:',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 200, fit: BoxFit.cover)
                  : const Text('Nessuna immagine selezionata', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: Text(
                    'Inserisci immagine',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
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
