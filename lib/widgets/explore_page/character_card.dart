import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../models/character_model.dart';

class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final VoidCallback onTap; // callback obbligatorio

  const CharacterCard({
    required this.character,
    required this.onTap,
    super.key,
  });

  /// Restituisce il widget per l’immagine del character.
  /// Se base64String è vuoto o non decodificabile, ritorna un Container grigio scuro.
  Widget _buildImageFromBase64(String base64String) {
    const placeholderColor = Color(0xFF333333); // grigio scuro
    const imageHeight = 200.0;

    if (base64String.isEmpty) {
      // Nessuna immagine Base64: placeholder
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
          // Se l’Image.memory, per qualche motivo, non riesce a mostrare,
          // ricadiamo sul placeholder grigio.
          return Container(
            height: imageHeight,
            width: double.infinity,
            color: placeholderColor,
          );
        },
      );
    } catch (e) {
      // Errore di decodifica: placeholder
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
    const placeholderColor = Color(0xFF333333); // grigio scuro
    const imageHeight = 200.0;

    debugPrint(
      '[CharacterCard] Building for character: ${character.name}, imagePath length: ${character.imagePath.length}',
    );

    Widget characterImage;

    if (character.imagePath.isEmpty) {
      // Se la stringa è vuota => placeholder
      characterImage = Container(
        height: imageHeight,
        width: double.infinity,
        color: placeholderColor,
      );
    }
    else if (character.imagePath.startsWith('assets/')) {
      // Proviamo a caricare da asset; se fallisce, mettiamo placeholder
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
      // Supponiamo Base64
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
              // Immagine o placeholder
              characterImage,
              // Overlay con nome/descrizione
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
