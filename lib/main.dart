import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progetto/pages/home_page.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI & Adventures',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.pixelifySansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text("Chat Page")),
    Center(child: Text("Settings Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: const Color(0xFF1E1B1B),
        waterDropColor: Colors.amberAccent,
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
          );
        },
        barItems: [
          BarItem(
            filledIcon: Icons.explore,
            outlinedIcon: Icons.explore_outlined,
          ),
          BarItem(
            filledIcon: Icons.forum,
            outlinedIcon: Icons.forum_outlined,
          ),
          BarItem(
            filledIcon: Icons.settings,
            outlinedIcon: Icons.settings_outlined,
          ),
        ],
      ),
    );
  }
}
