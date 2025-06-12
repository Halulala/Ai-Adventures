import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 800,
        minWidth: 800,
        quality: 40,
        format: CompressFormat.jpeg,
      );

      final tempDir = await Directory.systemTemp.createTemp();
      final file = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      )..writeAsBytesSync(compressedBytes);

      if (!mounted) return;
      setState(() => _selectedImage = file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading the \'image')),
      );
    }
  }

  Future<void> _saveCharacter() async {
    if (!_formKey.currentState!.validate()) return;

    String imageBase64 = '';
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    final newCharacter = CharacterModel(
      id: '',
      name: nameController.text,
      description: descriptionController.text,
      prompt: promptController.text,
      imagePath: imageBase64,
    );

    await _firestoreService.addCharacter(newCharacter);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Character created')));
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Create Character",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nameController, 'Name', 'Enter a name'),
              _buildTextField(
                descriptionController,
                'Description',
                'Enter a description',
              ),
              _buildTextField(promptController, 'Prompt per l\'IA', null),
              const SizedBox(height: 16),
              Text(
                'Selected image:',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 200, fit: BoxFit.cover)
                  : const Text(
                    'No image selected',
                    style: TextStyle(color: Colors.white54),
                  ),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: Text(
                    'Insert image',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: FilledButton.icon(
                  onPressed: _saveCharacter,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? validatorText,
  ) {
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        validator:
            validatorText != null
                ? (value) => value!.isEmpty ? validatorText : null
                : null,
      ),
    );
  }
}
