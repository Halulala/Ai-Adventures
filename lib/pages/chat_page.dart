import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/character_model.dart';
import '../models/chat_model.dart'; // contiene MessageModel
import '../services/connectivity_service.dart';
import '../services/firestore_service.dart';
import '../widgets/chat/typing_indicator.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

const Color _backgroundImageOverlayColor = Colors.black54;

class ChatPage extends StatefulWidget {
  final CharacterModel character;
  final String chatId; // aggiunto

  const ChatPage({
    super.key,
    required this.character,
    required this.chatId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final String chatId;
  final firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<MessageModel> messages = [];
  bool _isTyping = false;

  late final GenerativeModel _model;
  late ChatSession _chat;
  late final Widget _cachedBackgroundImage;

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    chatId = widget.chatId;
    _cachedBackgroundImage = _buildImageFromBase64(widget.character.imagePath);

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyA5o1ANvM0eBZsYxzCTw7X7JogudVl4lj0',
    );

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (currentUserId == null) return;
    // Carica messaggi esistenti
    final loadedMessages = await firestoreService.getMessages(
      uid: currentUserId!,
      chatId: chatId,
    );

    // Costruisci la storia per il model
    final List<Content> history = [];
    for (final msg in loadedMessages) {
      if (msg.sender == 'Tu') {
        history.add(Content.text(msg.text));
      } else {
        history.add(Content.model([TextPart(msg.text)]));
      }
    }
    _chat = _model.startChat(history: history);

    // Se chat vuota, invia prompt iniziale del character
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
      // Usa nuovo metodo che preserva characterId
      await firestoreService.addMessagePreservingCharacter(
        uid: currentUserId!,
        chatId: chatId,
        characterId: widget.character.id,
        message: aiMessage,
      );
      loadedMessages.add(aiMessage);
    }

    if (mounted) {
      setState(() {
        messages = loadedMessages;
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devi essere autenticato per inviare')),
      );
      return;
    }
    final userMessage = MessageModel(
      sender: 'Tu',
      text: text,
      timestamp: DateTime.now(),
    );
    setState(() {
      messages.add(userMessage);
      _isTyping = true;
      _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Invia messaggio e aggiorna chat preservando characterId
    await firestoreService.addMessagePreservingCharacter(
      uid: currentUserId!,
      chatId: chatId,
      characterId: widget.character.id,
      message: userMessage,
    );
    // Chiedi al modello AI
    final geminiResponse = await _chat.sendMessage(Content.text(text));
    final aiReply = geminiResponse.text;
    final aiMessage = MessageModel(
      sender: widget.character.name,
      text: aiReply ?? "Non ho capito, puoi ripetere?",
      timestamp: DateTime.now(),
    );
    setState(() {
      messages.add(aiMessage);
      _isTyping = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    await firestoreService.addMessagePreservingCharacter(
      uid: currentUserId!,
      chatId: chatId,
      characterId: widget.character.id,
      message: aiMessage,
    );
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
    const Color fallbackBackgroundColor = Color(0xFF121212);
    if (base64String.isEmpty) {
      return Container(color: fallbackBackgroundColor);
    }
    try {
      Uint8List bytes = base64Decode(base64String);
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover),
          Container(color: _backgroundImageOverlayColor),
        ],
      );
    } catch (e) {
      debugPrint('Errore decodifica immagine Base64: $e');
      return Container(color: fallbackBackgroundColor);
    }
  }

  Widget _buildMessageBubble(MessageModel msg, bool isUser) {
    final bubbleColor = isUser
        ? Colors.blueAccent.withAlpha(230)
        : Colors.grey.shade900.withAlpha(217);
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
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
    return Material(
      child: StreamBuilder<bool>(
        stream: _connectivityService.connectionStream,
        initialData: true,
        builder: (context, snapshot) {
          final hasConnection = snapshot.data ?? true;
          return Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: Text(widget.character.name),
                  backgroundColor: Colors.black87,
                ),
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(child: _cachedBackgroundImage),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: KeyboardVisibilityBuilder(
                              builder: (context, isKeyboardVisible) {
                                return GestureDetector(
                                  onTap: () {
                                    if (isKeyboardVisible) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(10),
                                    itemCount:
                                    messages.length + (_isTyping ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index < messages.length) {
                                        final msg = messages[index];
                                        final isUser = msg.sender == 'Tu';
                                        return _buildMessageBubble(msg, isUser);
                                      } else {
                                        // typing indicator
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              CustomPaint(
                                                painter: BubbleTailPainter(
                                                  color: Colors.grey.shade900
                                                      .withAlpha(217),
                                                  isUser: false,
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 6),
                                                  padding:
                                                  const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .shade900
                                                        .withAlpha(217),
                                                    borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft:
                                                      Radius.circular(16),
                                                      topRight:
                                                      Radius.circular(16),
                                                      bottomRight:
                                                      Radius.circular(16),
                                                    ),
                                                  ),
                                                  child:
                                                  const TypingIndicator(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            color: Colors.black.withAlpha(230),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    style:
                                    const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Scrivi un messaggio...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                                IconButton(
                                  icon:
                                  const Icon(Icons.send, color: Colors.white),
                                  onPressed: _sendMessage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasConnection)
                Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: Colors.black.withOpacity(0.75),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off,
                                color: Colors.redAccent, size: 50),
                            SizedBox(height: 16),
                            Text(
                              'Connection absent.\nCheck the network and try again.',
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// CustomPainter già nel tuo codice
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
