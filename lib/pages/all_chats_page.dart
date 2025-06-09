import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../widgets/all_chats_page/chats_card.dart'; // Adatta il path al tuo progetto

class AllChatsPage extends StatefulWidget {
  const AllChatsPage({super.key});

  @override
  State<AllChatsPage> createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
  bool isChatSelected = true;
  late PageController _pageController;
  List<Map<String, String>> favoriteChats = [];

  final List<Map<String, String>> chats = [
    {'name': 'Er pupone', 'message': 'A maggggica!', 'unreadCount': '3'},
    {
      'name': 'Bomba Anarchica',
      'message': 'Sei nato sotto n cielo, sbaaaagliaaaato',
      'unreadCount': '0',
    },
    {
      'name': 'Marco',
      'message': 'Evoco Exodia il proibito!',
      'unreadCount': '2',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: isChatSelected ? 0 : 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  Widget _buildChatItem(Map<String, String> chat) {
    final bool isFavorite = favoriteChats.contains(chat);

    return ChatCard(
      chat: chat,
      isFavorite: isFavorite,
      onAddToFavorites: () {
        setState(() {
          favoriteChats.add(chat);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('È stata aggiunta ai preferiti')),
        );
      },
      onRemoveFromFavorites: () {
        setState(() {
          favoriteChats.remove(chat);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rimossa dai preferiti')));
      },
      onDelete: () {
        setState(() {
          chats.remove(chat);
          favoriteChats.remove(chat);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La chat è stata eliminata')),
        );
      },
      onLongPress: () => _showOptions(context, chat),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1B1B);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 10,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 5),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor, backgroundColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / 2;
                    final indicatorAlignment =
                        isChatSelected
                            ? Alignment.centerLeft
                            : Alignment.centerRight;

                    return SizedBox(
                      height: 40,
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            alignment: indicatorAlignment,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
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
                              SizedBox(
                                width: tabWidth,
                                child: GestureDetector(
                                  onTap: () => _switchToTab(0),
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: isChatSelected ? 15 : 12,
                                        fontWeight:
                                            isChatSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            isChatSelected
                                                ? Colors.red
                                                : Colors.white70,
                                      ),
                                      child: const Text('CHAT'),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: tabWidth,
                                child: GestureDetector(
                                  onTap: () => _switchToTab(1),
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child:
                                          isChatSelected
                                              ? const Icon(
                                                Icons.favorite_border,
                                                key: ValueKey('outlined'),
                                                color: Colors.white70,
                                                size: 20,
                                              )
                                              : const Icon(
                                                Icons.favorite,
                                                key: ValueKey('filled'),
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      isChatSelected = index == 0;
                    });
                  },
                  children: [
                    // ✅ Tab 0: tutte le chat
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: chats.length,
                      itemBuilder:
                          (context, index) => _buildChatItem(chats[index]),
                    ),

                    // ✅ Tab 1: chat preferite
                    favoriteChats.isEmpty
                        ? Center(
                          child: Text(
                            'Nessuna chat nei preferiti',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white60,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  void _showOptions(BuildContext context, Map<String, String> chat) {
    final bool isFavorite = favoriteChats.contains(chat);

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
            if (!isFavorite)
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text(
                  "Aggiungi ai preferiti",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    favoriteChats.add(chat);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('È stata aggiunta ai preferiti'),
                    ),
                  );
                },
              ),
            if (isFavorite)
              ListTile(
                leading: const Icon(
                  Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  "Rimuovi dai preferiti",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    favoriteChats.remove(chat);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rimossa dai preferiti')),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white70),
              title: const Text(
                "Elimina",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  chats.remove(chat);
                  favoriteChats.remove(chat);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La chat è stata eliminata')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
