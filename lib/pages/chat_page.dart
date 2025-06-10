import 'package:flutter/material.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'dart:convert'; // Required for base64Decode

import '../models/character_model.dart';

class ChatPage extends StatefulWidget {
  final CharacterModel character;

  const ChatPage({super.key, required this.character});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, String>> messages = [];

  // Definiamo il colore per l'overlay dell'immagine di sfondo
  // Sostituiamo Colors.black.withOpacity(0.5) con Color.fromRGBO o Color con alpha esadecimale
  static const Color _backgroundImageOverlayColor = Color.fromRGBO(0, 0, 0, 0.5); // Nero con 50% di opacità
  static const Color _chatInputBackgroundColor = Color.fromRGBO(0, 0, 0, 0.8); // Nero con 80% di opacità
  static const Color _chatBubbleUserColor = Color.fromRGBO(66, 165, 245, 0.8); // blueAccent con 80% di opacità
  static const Color _chatBubbleCharacterColor = Color.fromRGBO(97, 97, 97, 0.7); // grey.shade800 con 70% di opacità


  @override
  void initState() {
    super.initState();
    // Add the initial message (character's description/prompt)
    messages.add({'sender': widget.character.name, 'text': widget.character.description});
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'sender': 'Tu', 'text': text});
      _messageController.clear();
    });

    // In the future, you'll send this message to your AI.
  }

  // Helper method to build an image from a Base64 string
  Widget _buildImageFromBase64(String base64String) {
    if (base64String.isEmpty) {
      // Fallback for empty Base64 string
      return Image.asset(
        'assets/images/720x1280.png', // Default image
        fit: BoxFit.cover,
        color: _backgroundImageOverlayColor, // Usiamo il colore definito come costante
        colorBlendMode: BlendMode.darken,
      );
    }

    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        color: _backgroundImageOverlayColor, // Usiamo il colore definito come costante
        colorBlendMode: BlendMode.darken,
      );
    } catch (e) {
      // Fallback for decoding errors (invalid Base64)
      debugPrint('Error decoding base64 image on ChatPage for ${widget.character.name}: $e');
      return Image.asset(
        'assets/images/720x1280.png', // Fallback for decoding errors
        fit: BoxFit.cover,
        color: _backgroundImageOverlayColor, // Usiamo il colore definito come costante
        colorBlendMode: BlendMode.darken,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which image widget to use based on the imagePath
    Widget backgroundImageWidget;

    if (widget.character.imagePath.startsWith('assets/')) {
      // If it's a local asset path
      backgroundImageWidget = Image.asset(
        widget.character.imagePath,
        fit: BoxFit.cover,
        color: _backgroundImageOverlayColor, // Usiamo il colore definito come costante
        colorBlendMode: BlendMode.darken,
        errorBuilder: (context, error, stackTrace) {
          // Fallback for asset loading errors
          debugPrint('Error loading asset background image on ChatPage for ${widget.character.name}: $error');
          return Image.asset(
            'assets/images/720x1280.png', // Default fallback image
            fit: BoxFit.cover,
            color: _backgroundImageOverlayColor, // Usiamo il colore definito come costante
            colorBlendMode: BlendMode.darken,
          );
        },
      );
    } else {
      // If it's not an asset path, assume it's a Base64 string.
      final parts = widget.character.imagePath.split(',');
      final base64Data = parts.length > 1 ? parts.last : widget.character.imagePath;
      backgroundImageWidget = _buildImageFromBase64(base64Data);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.name),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white), // Ensure back button is white
      ),
      body: Stack(
        children: [
          // Background image using the determined widget
          Positioned.fill(
            child: backgroundImageWidget,
          ),

          // Chat overlay
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg['sender'] == 'Tu';

                    return Align(
                      alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isUser
                              ? _chatBubbleUserColor // Usiamo il colore definito come costante
                              : _chatBubbleCharacterColor, // Usiamo il colore definito come costante
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Message input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: _chatInputBackgroundColor, // Usiamo il colore definito come costante
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Scrivi un messaggio...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}