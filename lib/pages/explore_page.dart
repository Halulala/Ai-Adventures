import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import '../widgets/explore_page/character_card.dart';
import '../models/character_model.dart';
import '../services/firestore_service.dart'; // Assicurati che il path sia corretto

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> filters = ['for you', 'today', 'random'];
  final FirestoreService _firestoreService = FirestoreService();

  late Future<List<CharacterModel>> _charactersFuture;
  late PageController _pageController;

  String selectedFilter = 'for you';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: filters.indexOf(selectedFilter),
    );
    _charactersFuture = _firestoreService.getAllCharacters(); // Firestore data
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSwipe(int newIndex) {
    setState(() {
      selectedFilter = filters[newIndex];
    });
  }

  void _onFilterTap(String filter) {
    final index = filters.indexOf(filter);
    setState(() {
      selectedFilter = filter;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                    onPressed: () {
                      setState(() {
                        isSearching = true;
                      });
                    },
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
    return Scaffold(
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No characters found.'));
                    }

                    final characters = snapshot.data!;

                    return PageView.builder(
                      controller: _pageController,
                      itemCount: filters.length,
                      onPageChanged: _onSwipe,
                      itemBuilder: (ctx, pageIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: DynamicHeightGridView(
                            itemCount: characters.length,
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 10,
                            builder:
                                (ctx, index) =>
                                    CharacterCard(character: characters[index]),
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
    );
  }
}
