import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OptionProfile extends StatefulWidget {
  const OptionProfile({super.key});

  @override
  State<OptionProfile> createState() => _OptionProfileState();
}

class _OptionProfileState extends State<OptionProfile> {
  bool isAvatarExpanded = false;
  String nickname = "Caricamento...";
  String email = "";
  String creationDate = "";

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      // Email e data creazione da FirebaseAuth
      email = user!.email ?? "Email non disponibile";

      // Nickname da Firestore
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists && doc.data() != null && doc.data()!['nickname'] != null) {
          setState(() {
            nickname = doc.data()!['nickname'];
          });
        } else {
          setState(() {
            nickname = "Nickname non trovato";
          });
        }
      } catch (e) {
        setState(() {
          nickname = "Errore caricamento nickname";
        });
      }
    }
  }

  Future<void> _updateNickname(String newNickname) async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'nickname': newNickname,
      });
      setState(() {
        nickname = newNickname;
      });
    }
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B1B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text("Logout", style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout effettuato')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blueAccent),
                title: Text("Preferenze", style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.green),
                title: Text("Informazioni", style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF1E1B1B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Center(
                          child: Text("Informazioni",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        content: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 30, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("App: AI & Adventures", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text("Versione: 1.0.0", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text("App sviluppata con Flutter, daje Roma!", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Chiudi", style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B1B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        TextEditingController nicknameController = TextEditingController(text: nickname);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.orange),
                title: Text("Cambia immagine", style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funzione "Cambia immagine" non ancora implementata')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.lightBlue),
                title: Text("Cambia nickname", style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1B1B),
                      title: Text("Modifica nickname", style: GoogleFonts.poppins(color: Colors.white)),
                      content: TextField(
                        controller: nicknameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Inserisci nuovo nickname",
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Annulla", style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            _updateNickname(nicknameController.text);
                            Navigator.pop(context);
                          },
                          child: const Text("Salva", style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1B1B);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: _showProfileOptionsSheet,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _showOptionsBottomSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  isAvatarExpanded = !isAvatarExpanded;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isAvatarExpanded ? 150 : 100,
                height: isAvatarExpanded ? 150 : 100,
                child: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              nickname,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              email,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Informazioni", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red)),
                  const SizedBox(height: 12),
                  Text("Nickname: $nickname", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text("Email: $email", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
