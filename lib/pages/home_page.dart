import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  String selectedFilter = 'for you';

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

  @override
  Widget build(BuildContext context) {
    const backgroundStart = Color(0xFF332E2E);
    const backgroundMid = Color(0xFF2D2424);
    const backgroundEnd = Color(0xFF1E1B1B);
    const titleYellow = Color(0xFFFFEB3B);
    const borderWhite = Color(0xFFEFEFEF);
    const borderGrey = Color(0xFFB0B0B0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'AI & ADVENTURES',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: titleYellow,
            letterSpacing: 1.5,
            shadows: [
              Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundStart, backgroundMid, backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 48.0, left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: filters.map((filter) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          filter.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Characters grid in staggered layout
                Expanded(
                  child: ListView.builder(
                    itemCount: (characters.length / 2).ceil(),
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, rowIndex) {
                      final isOffset = rowIndex % 2 == 1;
                      final items = characters.skip(rowIndex * 2).take(2).toList();

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 16.0,
                          left: isOffset ? 32.0 : 0,
                          right: isOffset ? 0 : 32.0,
                        ),
                        child: Row(
                          children: items.map((item) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: borderWhite, width: 2),
                                    left: BorderSide(color: borderGrey, width: 2),
                                    right: BorderSide(color: borderWhite, width: 2),
                                    bottom: BorderSide(color: borderGrey, width: 2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      child: Image.asset(
                                        item['image']!,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(
                                        '${item['title']}\n${item['description']}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          height: 1.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundEnd,
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Options',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Party',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
        ],
      ),
    );
  }
}
