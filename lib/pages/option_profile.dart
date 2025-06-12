import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cache/user_cache.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'create_character.dart';

class OptionProfile extends StatefulWidget {
  const OptionProfile({super.key});

  @override
  State<OptionProfile> createState() => _OptionProfileState();
}

class _OptionProfileState extends State<OptionProfile> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  String nickname = "Caricamento...";
  String email = "";
  bool isAvatarExpanded = false;
  String? avatarBase64; // Base64 dell'avatar, es. "data:image/png;base64,..."

  User? get user => _authService.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carica nickname, email e avatarBase64 dal profilo Firestore o cache.
  Future<void> _loadUserData() async {
    if (user == null) return;

    setState(() => _isLoading = true);

    // Se cache nickname/email presente, usalo subito
    if (UserCache.nickname != null && UserCache.email != null) {
      setState(() {
        nickname = UserCache.nickname!;
        email = UserCache.email!;
        _isLoading = false;
      });
      // Carica avatar separatamente
      _loadAvatar();
      return;
    }

    final userEmail = user!.email ?? "Email non disponibile";
    try {
      final profile = await _firestoreService.getUserProfile(user!.uid);
      if (profile != null) {
        setState(() {
          nickname = profile.nickname;
          email = userEmail;
          avatarBase64 = profile.imageBase64;
          _isLoading = false;
        });
        UserCache.nickname = profile.nickname;
        UserCache.email = userEmail;
      } else {
        setState(() {
          nickname = "Nickname non trovato";
          email = userEmail;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        nickname = "Errore caricamento nickname";
        email = userEmail;
        _isLoading = false;
      });
    }
  }

  /// Carica solo avatar (se nickname/email erano in cache ma avatar no)
  Future<void> _loadAvatar() async {
    if (user == null) return;
    try {
      final profile = await _firestoreService.getUserProfile(user!.uid);
      if (profile != null && profile.imageBase64 != null) {
        setState(() {
          avatarBase64 = profile.imageBase64;
        });
      }
    } catch (_) {
      // Ignora errori avatar
    }
  }

  /// Aggiorna nickname in Firestore e cache
  Future<void> _updateNickname(String newNickname) async {
    if (user == null) return;

    try {
      await _firestoreService.updateNickname(user!.uid, newNickname);
      final profile = await _firestoreService.getUserProfile(user!.uid);
      if (profile != null) {
        setState(() {
          nickname = profile.nickname;
        });
        UserCache.nickname = profile.nickname;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore aggiornamento nickname')),
      );
    }
  }

  /// Seleziona immagine da galleria, converte in Base64 e salva in Firestore
  Future<void> _pickAndSaveImageBase64() async {
    if (user == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna immagine selezionata')),
      );
      return;
    }

    try {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      // Se vuoi includere il prefix MIME-type:
      final fullBase64 = 'data:image/png;base64,$base64Image';

      await _firestoreService.updateUserAvatar(user!.uid, fullBase64);

      setState(() {
        avatarBase64 = fullBase64;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Immagine profilo aggiornata')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento dell\'immagine')),
      );
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
                  await _authService.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('remember_login');
                  UserCache.clear();
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
                          child: Text("Informazioni", style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
    TextEditingController nicknameController = TextEditingController(text: nickname);
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
                leading: const Icon(Icons.image, color: Colors.orange),
                title: Text("Cambia immagine", style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSaveImageBase64();
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

  /// Helper per ottenere ImageProvider da Base64
  ImageProvider? _getImageProviderFromBase64(String imagePath) {
    if (imagePath.startsWith('data:image')) {
      try {
        final base64Str = imagePath.split(',').last;
        final bytes = base64Decode(base64Str);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    return null;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => isAvatarExpanded = !isAvatarExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isAvatarExpanded ? 150 : 100,
                height: isAvatarExpanded ? 150 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white12,
                  image: avatarBase64 != null
                      ? (_getImageProviderFromBase64(avatarBase64!) != null
                      ? DecorationImage(
                    image: _getImageProviderFromBase64(avatarBase64!)!,
                    fit: BoxFit.cover,
                  )
                      : null)
                      : null,
                ),
                child: avatarBase64 == null ||
                    _getImageProviderFromBase64(avatarBase64!) == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Informazioni", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red)),
                  const SizedBox(height: 12),
                  Text("Nickname: $nickname", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text("Email: $email", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 5),
                    child: Text("Create a new character", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "In this session you can create your own character to play against, think of a compelling story! Other players will also be able to see your created character.",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateCharacterPage()),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text("Create Character", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
