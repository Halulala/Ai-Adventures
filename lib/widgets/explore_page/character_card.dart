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
    if (base64String.isEmpty) {
      // Return a default image if the Base64 string is empty
      // and it's not a valid Base64 string.
      return Image.asset(
        'assets/images/720x1280.png', // Ensure this path is correct in pubspec.yaml
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      // Fallback to a default image in case of a decoding error (invalid Base64)
      debugPrint('Error decoding base64 image for ${character.name}: $e');
      return Image.asset(
        'assets/images/720x1280.png', // Fallback for decoding errors
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget characterImage;

    // Determine if the image path is an asset or a Base64 string.
    // We assume anything not explicitly an asset path is a Base64 string.
    if (character.imagePath.startsWith('assets/')) {
      // If it's a local asset path
      characterImage = Image.asset(
        character.imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback for asset loading errors (e.g., asset not found in pubspec.yaml)
          debugPrint('Error loading asset image for ${character.name}: $error');
          return Image.asset(
            'assets/images/720x1280.png', // Default fallback for asset errors
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // If it's not an asset path, treat it as a Base64 string.
      // We handle potential "data:image/..." prefixes.
      final parts = character.imagePath.split(',');
      final base64Data = parts.length > 1 ? parts.last : character.imagePath;

      characterImage = _buildImageFromBase64(base64Data);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(character: character),
          ),
        );

      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              characterImage, // Use the dynamically determined image widget
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