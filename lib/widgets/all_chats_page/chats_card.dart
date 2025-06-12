import 'dart:convert';

import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final Map<String, String> chat;
  final bool isFavorite;
  final VoidCallback onAddToFavorites;
  final VoidCallback onRemoveFromFavorites;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.chat,
    required this.isFavorite,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
    required this.onDelete,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: (chat['imagePath'] != null &&
                    chat['imagePath']!.isNotEmpty)
                    ? _getImageProvider(chat['imagePath']!)
                    : null,
                child: (chat['imagePath'] != null &&
                    chat['imagePath']!.isNotEmpty &&
                    _getImageProvider(chat['imagePath']!) != null)
                    ? null
                    : const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat['message'] ?? '',
                      style:
                      const TextStyle(fontSize: 14, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (chat['unreadCount'] != null && chat['unreadCount'] != '0')
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "!!",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }
    try {
      final parts = imagePath.split(',');
      final base64Data = parts.length > 1 ? parts.last : imagePath;
      final bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
}
