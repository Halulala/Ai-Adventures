import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/connectivity_service.dart';
import '../widgets/explore_page/character_card.dart';
import '../models/character_model.dart';
import '../services/firestore_service.dart';
import '../pages/chat_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> filters = ['for you', 'today'];
  final FirestoreService _firestoreService = FirestoreService();
  final ConnectivityService _connectivityService = ConnectivityService();

  late Future<List<CharacterModel>> _charactersFuture;
  late PageController _pageController;

  List<CharacterModel> _allCharacters = [];
  List<CharacterModel> _filteredCharacters = [];

  String selectedFilter = 'for you';
  bool isSearching = false;

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _pageController = PageController(
      initialPage: filters.indexOf(selectedFilter),
    );
    _charactersFuture = _loadCharacters();
  }

  Future<List<CharacterModel>> _loadCharacters() async {
    final characters = await _firestoreService.getAllCharacters();
    _allCharacters = characters;
    _filteredCharacters = characters;
    return characters;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSwipe(int newIndex) {
    setState(() => selectedFilter = filters[newIndex]);
  }

  void _onFilterTap(String filter) {
    final index = filters.indexOf(filter);
    setState(() => selectedFilter = filter);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCharacters = _allCharacters;
      } else {
        _filteredCharacters =
            _allCharacters
                .where(
                  (character) => character.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  Future<void> _onCharacterTap(CharacterModel character) async {
    if (currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Devi essere autenticato')));
      return;
    }

    final chatId = await _getOrCreateChatId(currentUserId!, character);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(character: character, chatId: chatId),
      ),
    );
  }

  Future<String> _getOrCreateChatId(
    String uid,
    CharacterModel character,
  ) async {
    final userChatsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chats');

    final querySnap =
        await userChatsRef
            .where('characterId', isEqualTo: character.id)
            .limit(1)
            .get();

    if (querySnap.docs.isNotEmpty) return querySnap.docs.first.id;

    final newChatRef = userChatsRef.doc(character.id);
    await newChatRef.set({
      'characterId': character.id,
      'characterName': character.name,
      'lastMessage': '',
      'unread': false,
      'isFavorite': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return newChatRef.id;
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 3),
      child: Column(
        children: [
          if (isSearching)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      _searchController.clear();
                      _filteredCharacters = _allCharacters;
                    });
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double buttonWidth =
                          constraints.maxWidth / filters.length;
                      return SizedBox(
                        height: 40,
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              alignment: Alignment(
                                -1 +
                                    (2 / (filters.length - 1)) *
                                        filters.indexOf(selectedFilter),
                                0,
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Container(
                                width: buttonWidth,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            Row(
                              children:
                                  filters.map((filter) {
                                    final isSelected = filter == selectedFilter;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => _onFilterTap(filter),
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            style: TextStyle(
                                              fontSize: isSelected ? 15 : 12,
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                              color:
                                                  isSelected
                                                      ? Colors.red
                                                      : Colors.white70,
                                            ),
                                            child: Text(filter.toUpperCase()),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => setState(() => isSearching = true),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1B1B);

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
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
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
                      _buildTopBar(),
                      const SizedBox(height: 0),
                      Expanded(
                        child: FutureBuilder<List<CharacterModel>>(
                          future: _charactersFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.redAccent,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Error loading characters'),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('No characters found.'),
                              );
                            }

                            return PageView.builder(
                              controller: _pageController,
                              itemCount: filters.length,
                              onPageChanged: _onSwipe,
                              itemBuilder: (ctx, pageIndex) {
                                List<CharacterModel> pageCharacters;

                                if (filters[pageIndex] == 'today') {
                                  final now = DateTime.now();
                                  pageCharacters =
                                      _filteredCharacters.where((character) {
                                        final createdAt =
                                            character.createdAt?.toDate();
                                        return createdAt != null &&
                                            createdAt.year == now.year &&
                                            createdAt.month == now.month &&
                                            createdAt.day == now.day;
                                      }).toList();
                                } else {
                                  pageCharacters = _filteredCharacters;
                                }

                                if (pageCharacters.isEmpty) {
                                  return const Center(
                                    child: Text('No characters for today.'),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: DynamicHeightGridView(
                                    itemCount: pageCharacters.length,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 10,
                                    builder:
                                        (ctx, index) => CharacterCard(
                                          character: pageCharacters[index],
                                          onTap:
                                              () => _onCharacterTap(
                                                pageCharacters[index],
                                              ),
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (!hasConnection)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: const Color(0xBF000000),
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
