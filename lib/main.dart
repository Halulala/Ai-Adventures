import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progetto/pages/explore_page.dart';
import 'package:progetto/pages/all_chats_page.dart';
import 'package:progetto/pages/option_profile.dart';
import 'package:progetto/pages/login.dart';
import 'package:progetto/pages/register.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const LoginPageWrapper(), // Qui usiamo LoginPageWrapper
    );
  }
}

class LoginPageWrapper extends StatefulWidget {
  const LoginPageWrapper({super.key});

  @override
  State<LoginPageWrapper> createState() => _LoginPageWrapperState();
}

class _LoginPageWrapperState extends State<LoginPageWrapper> {
  bool showLogin = true;

  void _showRegister() {
    setState(() {
      showLogin = false;
    });
  }

  void _showLogin() {
    setState(() {
      showLogin = true;
    });
  }

  void _completeAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(
      onLoginSuccess: _completeAuth,
      onNavigateToRegister: _showRegister, // **nome corretto del callback**
    )
        : RegisterPage(
      onRegisterSuccess: _completeAuth,
      onNavigateToLogin: _showLogin, // **nome corretto del callback**
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
    ExplorePage(),
    AllChatsPage(),
    OptionProfile(),
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
        bottomPadding: 12,
        iconSize: 32,
        backgroundColor: const Color(0xFF1E1B1B),
        waterDropColor: const Color(0xFFB22222),
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
