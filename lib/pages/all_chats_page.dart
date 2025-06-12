import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/character_model.dart';
import '../models/chat_preview_model.dart';
import '../services/connectivity_service.dart';
import '../services/firestore_service.dart';
import '../widgets/all_chats_page/chats_card.dart';
import 'chat_page.dart';

class AllChatsPage extends StatefulWidget {
  const AllChatsPage({super.key});

  @override
  State<AllChatsPage> createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
  bool isChatSelected = true;
  late PageController _pageController;

  List<ChatPreviewModel> allChats = [];
  List<CharacterModel> allCompleteChats = [];
  List<ChatPreviewModel> favoriteChats = [];
  bool _isLoading = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  final FirestoreService firestoreService = FirestoreService();

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    loadChats();
  }

  Future<void> loadChats() async {
    if (currentUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // 1. Carica le preview delle chat per questo utente
    final chatPreviews = await firestoreService.getAllChatPreviews();
    // 2. Carica tutti i personaggi globali
    final characters = await firestoreService.getAllCharacters();

    // Opzionale: verifica integrità dati
    for (var cp in chatPreviews) {
      final exists = characters.any((c) => c.id == cp.characterId);
      if (!exists) {
        // debug: manca personaggio
        // print('Warning: characterId ${cp.characterId} non trovato tra i characters globali');
      }
    }

    setState(() {
      allChats = chatPreviews;
      allCompleteChats = characters;
      favoriteChats = chatPreviews.where((c) => c.isFavorite).toList();
      _isLoading = false;
    });
  }

  void _switchToTab(int index) {
    setState(() {
      isChatSelected = index == 0;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _addToFavorites(ChatPreviewModel chat) async {
    if (currentUserId == null) return;
    await firestoreService.setFavorite(
      uid: currentUserId!,
      chatId: chat.chatId,
      isFavorite: true,
    );
    await loadChats();
  }

  Future<void> _removeFromFavorites(ChatPreviewModel chat) async {
    if (currentUserId == null) return;
    await firestoreService.setFavorite(
      uid: currentUserId!,
      chatId: chat.chatId,
      isFavorite: false,
    );
    await loadChats();
  }

  Future<void> _deleteChat(ChatPreviewModel chat) async {
    if (currentUserId == null) return;
    await firestoreService.deleteChat(uid: currentUserId!, chatId: chat.chatId);
    await loadChats();
  }

  Widget _buildChatItem(ChatPreviewModel chat) {
    // Trova il personaggio corrispondente tramite characterId
    CharacterModel character = allCompleteChats.firstWhere(
      (c) => c.id == chat.characterId,
      orElse: () => CharacterModel.empty(),
    );

    // Handler tap: apre ChatPage con chatId e character
    void handleTap() {
      if (character.id.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(character: character, chatId: chat.chatId),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Character non trovato')));
      }
    }

    return ChatCard(
      chat: {
        'chatId': chat.chatId,
        'characterId': chat.characterId,
        'name': chat.characterName,
        'message': chat.lastMessage,
        'unreadCount': chat.unread ? '1' : '0',
        'imagePath': character.imagePath,
      },
      isFavorite: chat.isFavorite,
      onTap: handleTap,
      onLongPress: () => _showOptions(context, chat),
      onAddToFavorites: () async {
        await _addToFavorites(chat);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aggiunta ai preferiti')));
      },
      onRemoveFromFavorites: () async {
        await _removeFromFavorites(chat);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rimossa dai preferiti')));
      },
      onDelete: () async {
        await _deleteChat(chat);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chat eliminata')));
      },
    );
  }

  void _showOptions(BuildContext context, ChatPreviewModel chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            chat.isFavorite
                ? ListTile(
                  leading: const Icon(
                    Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    "Rimuovi dai preferiti",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removeFromFavorites(chat);
                  },
                )
                : ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text(
                    "Aggiungi ai preferiti",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _addToFavorites(chat);
                  },
                ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white70),
              title: const Text(
                "Elimina",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _deleteChat(chat);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStream,
      initialData: true,
      builder: (context, snapshot) {
        final hasConnection = snapshot.data ?? true;
        return Stack(
          children: [
            Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                toolbarHeight: 10,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Container(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 5),
                decoration: const BoxDecoration(color: Color(0xFF1E1B1B)),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final tabWidth = constraints.maxWidth / 2;
                            return Stack(
                              children: [
                                AnimatedAlign(
                                  alignment:
                                      isChatSelected
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    width: tabWidth,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _switchToTab(0),
                                      child: SizedBox(
                                        width: tabWidth,
                                        child: Center(
                                          child: Text(
                                            'CHAT',
                                            style: GoogleFonts.poppins(
                                              fontSize:
                                                  isChatSelected ? 15 : 12,
                                              fontWeight:
                                                  isChatSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                              color:
                                                  isChatSelected
                                                      ? Colors.red
                                                      : Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _switchToTab(1),
                                      child: SizedBox(
                                        width: tabWidth,
                                        child: Center(
                                          child:
                                              isChatSelected
                                                  ? const Icon(
                                                    Icons.favorite_border,
                                                    color: Colors.white70,
                                                  )
                                                  : const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Page content
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => isChatSelected = index == 0);
                          },
                          children: [
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  ),
                                )
                                : allChats.isEmpty
                                ? const Center(
                                  child: Text(
                                    'Nessuna chat',
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: allChats.length,
                                  itemBuilder:
                                      (context, index) =>
                                          _buildChatItem(allChats[index]),
                                ),
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  ),
                                )
                                : favoriteChats.isEmpty
                                ? const Center(
                                  child: Text(
                                    'Nessun preferito',
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: favoriteChats.length,
                                  itemBuilder:
                                      (context, index) =>
                                          _buildChatItem(favoriteChats[index]),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Overlay di connessione assente
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
                          Icon(
                            Icons.wifi_off,
                            color: Colors.redAccent,
                            size: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Connection absent.\nCheck the network and try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
    );
  }
}
