import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  String selectedFilter = 'for you';
  bool isSearching = true;  // La ricerca è sempre attiva ora
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> characters = List.generate(6, (index) {
    return {
      'title': 'Dark Caverns',
      'description': 'A journey into shadows...',
      'image': 'images/720x1280.png',
    };
  });

  final List<String> filters = ['for you', 'today', 'random'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildFilterButton(String filter) {
    final isSelected = filter == selectedFilter;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0.8,
            end: isSelected ? 1.1 : 0.9,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: Colors.white70,
                  end: isSelected ? Colors.yellow : Colors.white70,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, color, _) {
                  return Text(
                    filter.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: color,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCharacterCard(int index) {
    final item = characters[index];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // Immagine di sfondo
            Image.asset(
              item['image']!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Sfondo sfumato dietro il testo (opzionale)
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
                  '${item['title']}\n${item['description']}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.yellow,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18,2,18,10),
      child: Column(
        children: [
          // Search bar fissa in cima
          TextField(
            controller: _searchController,
            autofocus: false,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white10,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filtri sotto la search bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...filters.map((f) =>
                _buildFilterButton(f),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundStart = Color(0xFF1E1B1B);
    const backgroundMid = Color(0xFF1E1B1B);
    const backgroundEnd = Color(0xFF1E1B1B);

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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundStart, backgroundMid, backgroundEnd],

          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DynamicHeightGridView(
                    itemCount: characters.length,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 10,
                    builder: (ctx, index) => _buildCharacterCard(index),
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
