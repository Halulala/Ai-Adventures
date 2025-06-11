import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/character_model.dart';
import '../models/chat_model.dart';
import '../services/firestore_service.dart';

const Color _backgroundImageOverlayColor = Colors.black54;

class ChatPage extends StatefulWidget {
  final CharacterModel character;

  const ChatPage({super.key, required this.character});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final String chatId;
  final firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> messages = [];

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    chatId = 'user123_${widget.character.id}';
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: 'AIzaSyA5o1ANvM0eBZsYxzCTw7X7JogudVl4lj0',
    );
    _chat = _model.startChat();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final loadedMessages = await firestoreService.getMessages(chatId);

    if (loadedMessages.isEmpty) {
      if (widget.character.prompt.trim().isNotEmpty) {
        final geminiResponse = await _chat.sendMessage(
          Content.text(widget.character.prompt.trim()),
        );

        final aiContent = geminiResponse.text ?? widget.character.description;

        final aiMessage = MessageModel(
          sender: widget.character.name,
          text: aiContent,
          timestamp: DateTime.now(),
        );

        await firestoreService.addMessage(chatId, aiMessage);
        loadedMessages.add(aiMessage);
      }
    }

    setState(() {
      messages = loadedMessages;
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = MessageModel(
      sender: 'Tu',
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(userMessage);
      _messageController.clear();
    });

    await firestoreService.addMessage(chatId, userMessage);

    final geminiResponse = await _chat.sendMessage(Content.text(text));

    final aiReply = geminiResponse.text;

    final aiMessage = MessageModel(
      sender: widget.character.name,
      text: aiReply ?? "Non ho capito, puoi ripetere?",
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(aiMessage);
    });

    await firestoreService.addMessage(chatId, aiMessage);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildImageFromBase64(String base64String) {
    if (base64String.isEmpty) {
      return Image.asset(
        'images/720x1280.png',
        fit: BoxFit.cover,
        color: _backgroundImageOverlayColor,
        colorBlendMode: BlendMode.darken,
      );
    }

    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        color: _backgroundImageOverlayColor,
        colorBlendMode: BlendMode.darken,
      );
    } catch (e) {
      debugPrint(
          'Error decoding base64 image on ChatPage for ${widget.character.name}: $e');
      return Image.asset(
        'images/720x1280.png',
        fit: BoxFit.cover,
        color: _backgroundImageOverlayColor,
        colorBlendMode: BlendMode.darken,
      );
    }
  }

  Widget _buildMessageBubble(MessageModel msg, bool isUser) {
    final bubbleColor = isUser
        ? Colors.blueAccent.withOpacity(0.9)
        : Colors.grey.shade900.withOpacity(0.85);

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 16),
    );

    final triangle = CustomPaint(
      painter: BubbleTailPainter(color: bubbleColor, isUser: isUser),
    );

    return Row(
      mainAxisAlignment:
      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) triangle,
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            child: Text(
              msg.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
        if (isUser) triangle,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.name),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildImageFromBase64(widget.character.imagePath),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.sender == 'Tu';
                    return _buildMessageBubble(msg, isUser);
                  },
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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

class BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isUser;

  BubbleTailPainter({required this.color, required this.isUser});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (isUser) {
      path.moveTo(0, 0);
      path.lineTo(10, 6);
      path.lineTo(0, 12);
    } else {
      path.moveTo(10, 0);
      path.lineTo(0, 6);
      path.lineTo(10, 12);
    }

    canvas.drawPath(path, paint);
  }

  @override
  Size get size => const Size(10, 12);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
