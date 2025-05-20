import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> filters = ['for you', 'today', 'random'];
  final List<Map<String, String>> characters = List.generate(14, (index) {
    return {
      'title': 'Dark Caverns',
      'description': 'A journey into shadows...',
      'image': 'images/720x1280.png',
    };
  });

  late PageController _pageController;
  String selectedFilter = 'for you';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: filters.indexOf(selectedFilter));
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  Widget _buildCharacterCard(int index) {
    final item = characters[index];
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.asset(
              item['image']!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
                    color: Colors.white,
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                      final double buttonWidth = constraints.maxWidth / filters.length;
                      return SizedBox(
                        height: 40,
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              alignment: Alignment(
                                -1 + (2 / (filters.length - 1)) * filters.indexOf(selectedFilter),
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
                              children: filters.map((filter) {
                                final isSelected = filter == selectedFilter;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _onFilterTap(filter),
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          fontSize: isSelected ? 15 : 12,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected ? Colors.red : Colors.white70,
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
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
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
                child: PageView.builder(
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
                        builder: (ctx, index) => _buildCharacterCard(index),
                      ),
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
