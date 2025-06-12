import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../models/character_model.dart';

class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final VoidCallback onTap;

  const CharacterCard({
    required this.character,
    required this.onTap,
    super.key,
  });

  Widget _buildImageFromBase64(String base64String) {
    const placeholderColor = Color(0xFF333333);
    const imageHeight = 200.0;

    if (base64String.isEmpty) {
      return Container(
        height: imageHeight,
        width: double.infinity,
        color: placeholderColor,
      );
    }
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: imageHeight,
            width: double.infinity,
            color: placeholderColor,
          );
        },
      );
    } catch (e) {
      debugPrint(
        'Error decoding base64 image for ${character.name}: $e. Using placeholder.',
      );
      return Container(
        height: imageHeight,
        width: double.infinity,
        color: placeholderColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const placeholderColor = Color(0xFF333333);
    const imageHeight = 200.0;

    debugPrint(
      '[CharacterCard] Building for character: ${character.name}, imagePath length: ${character.imagePath.length}',
    );

    Widget characterImage;

    if (character.imagePath.isEmpty) {
      characterImage = Container(
        height: imageHeight,
        width: double.infinity,
        color: placeholderColor,
      );
    }
    else if (character.imagePath.startsWith('assets/')) {
      characterImage = Image.asset(
        character.imagePath,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[CharacterCard] Error loading asset image for ${character.name}: $error');
          return Container(
            height: imageHeight,
            width: double.infinity,
            color: placeholderColor,
          );
        },
      );
    } else {
      final parts = character.imagePath.split(',');
      final base64Data = parts.length > 1 ? parts.last : character.imagePath;
      characterImage = _buildImageFromBase64(base64Data);
    }

    return GestureDetector(
      onTap: onTap,
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
                        Colors.black.withAlpha(230),
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
