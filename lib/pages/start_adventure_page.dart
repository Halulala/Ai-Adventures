import 'package:flutter/material.dart';

class StartAdventurePage extends StatelessWidget {
  const StartAdventurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0A0A),
      appBar: AppBar(
        title: const Text(
          'New Adventure',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5A0E0E),
      ),
      body: const Center(
        child: Text(
          'Your adventure begins here...',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
