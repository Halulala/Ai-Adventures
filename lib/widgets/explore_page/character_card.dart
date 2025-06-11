import 'package:flutter/material.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'dart:convert'; // Required for base64Decode

import '../../models/character_model.dart';
import '../../pages/chat_page.dart';

class CharacterCard extends StatelessWidget {
  final CharacterModel character;

  const CharacterCard({required this.character, super.key});

  // Helper method to build an image from a Base64 string
  Widget _buildImageFromBase64(String base64String) {
    debugPrint('[_buildImageFromBase64] Attempting to decode Base64 for ${character.name}. String length: ${base64String.length}');

    if (base64String.isEmpty) {
      debugPrint('[_buildImageFromBase64] Base64 string is empty. Returning default asset image.');
      return Image.asset(
        '../images/720x1280.png',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    try {
      Uint8List bytes = base64Decode(base64String);
      debugPrint('[_buildImageFromBase64] Base64 decoding successful. Image.memory will be used.');
      return Image.memory(
        bytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      // Questo debugPrint è già presente e importante!
      debugPrint('Error decoding base64 image for ${character.name}: $e. Returning default asset image.');
      return Image.asset(
        'assets/images/720x1280.png',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stampa il valore di imagePath all'inizio del build
    debugPrint('[CharacterCard] Building for character: ${character.name}, imagePath: ${character.imagePath.length > 50 ? character.imagePath.substring(0, 50) + '...' : character.imagePath}');


    Widget characterImage;

    if (character.imagePath.startsWith('assets/')) {
      debugPrint('[CharacterCard] imagePath starts with "assets/". Using Image.asset.');
      characterImage = Image.asset(
        character.imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Questo debugPrint è già presente e importante!
          debugPrint('Error loading asset image for ${character.name}: $error. Returning default asset image.');
          return Image.asset(
            'assets/images/720x1280.png',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      debugPrint('[CharacterCard] imagePath does NOT start with "assets/". Assuming Base64.');
      final parts = character.imagePath.split(',');
      final base64Data = parts.length > 1 ? parts.last : character.imagePath;
      characterImage = _buildImageFromBase64(base64Data);
    }

    // Resto identico
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(character: character)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              characterImage,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    '${character.name}\n${character.description}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}