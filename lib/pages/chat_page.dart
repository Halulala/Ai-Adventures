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
  late ChatSession _chat;
  late final Widget _cachedBackgroundImage;

  @override
  void initState() {
    super.initState();
    _cachedBackgroundImage = _buildImageFromBase64(widget.character.imagePath);
    chatId = '${widget.character.id}';

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyA5o1ANvM0eBZsYxzCTw7X7JogudVl4lj0',
    );

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final loadedMessages = await firestoreService.getMessages(chatId);

    final List<Content> history = [];
    for (final msg in loadedMessages) {
      if (msg.sender == 'Tu') {
        history.add(Content.text(msg.text));
      } else {
        history.add(Content.model([TextPart(msg.text)]));
      }
    }

    _chat = _model.startChat(history: history);

    if (loadedMessages.isEmpty && widget.character.prompt.trim().isNotEmpty) {
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

    if (mounted) {
      setState(() {
        messages = loadedMessages;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
    _scrollToBottom();

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
    _scrollToBottom();

    await firestoreService.addMessage(chatId, aiMessage);
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
        'assets/images/720x1280.png',
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
      debugPrint('Errore decodifica immagine Base64: $e');
      return Image.asset(
        'assets/images/720x1280.png',
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
          Positioned.fill(child: _cachedBackgroundImage),
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
                        onSubmitted: (_) => _sendMessage(),
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
      path.moveTo(0, size.height - 12);
      path.lineTo(size.width, size.height - 6);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width, size.height - 12);
      path.lineTo(0, size.height - 6);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  Size get size => const Size(10, 12);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}