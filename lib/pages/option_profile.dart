import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progetto/pages/create_character.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cache/user_cache.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class OptionProfile extends StatefulWidget {
  const OptionProfile({super.key});

  @override
  State<OptionProfile> createState() => _OptionProfileState();
}

class _OptionProfileState extends State<OptionProfile> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true; // << aggiunto

  User? get user => _authService.currentUser;

  String nickname = "Caricamento...";
  String email = "";
  bool isAvatarExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    setState(() => _isLoading = true); // << loading start

    if (UserCache.nickname != null && UserCache.email != null) {
      setState(() {
        nickname = UserCache.nickname!;
        email = UserCache.email!;
        _isLoading = false; // << loading end
      });
      return;
    }

    setState(() {
      email = user!.email ?? "Email non disponibile";
    });

    try {
      final profile = await _firestoreService.getUserProfile(user!.uid);
      if (profile != null) {
        setState(() {
          nickname = profile.nickname;
          _isLoading = false; // << loading end
        });

        UserCache.nickname = profile.nickname;
        UserCache.email = user!.email;
      } else {
        setState(() {
          nickname = "Nickname non trovato";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        nickname = "Errore caricamento nickname";
        _isLoading = false;
      });
    }

    setState(() {
      email = user!.email ?? "Email non disponibile";
    });

    try {
      final profile = await _firestoreService.getUserProfile(user!.uid);
      if (profile != null) {
        setState(() {
          nickname = profile.nickname;
        });

        // Salva in cache
        UserCache.nickname = profile.nickname;
        UserCache.email = user!.email;
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

  Future<void> _updateNickname(String newNickname) async {
    if (user == null) return;

    try {
      await _firestoreService.updateNickname(user!.uid, newNickname);
      setState(() {
        nickname = newNickname;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore aggiornamento nickname')),
      );
    }

    setState(() {
      email = user!.email ?? "Email non disponibile";
    });

    try {
      final profile = await _firestoreService.getUserProfile(user!.uid);
      if (profile != null) {
        setState(() {
          nickname = profile.nickname;
          _isLoading = false; // << loading end
        });

        UserCache.nickname = profile.nickname;
        UserCache.email = user!.email;
      } else {
        setState(() {
          nickname = "Nickname non trovato";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        nickname = "Errore caricamento nickname";
        _isLoading = false;
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
                title: Text(
                  "Logout",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _authService.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('remember_login'); // AGGIUNTO
                  UserCache.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout effettuato')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blueAccent),
                title: Text(
                  "Preferenze",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.green),
                title: Text(
                  "Informazioni",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF1E1B1B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Center(
                          child: Text(
                            "Informazioni",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        content: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 30, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "App: AI & Adventures",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Versione: 1.0.0",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "App sviluppata con Flutter, daje Roma!",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Chiudi",
                              style: TextStyle(color: Colors.redAccent),
                            ),
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
        TextEditingController nicknameController = TextEditingController(
          text: nickname,
        );
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.orange),
                title: Text(
                  "Cambia immagine",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Funzione "Cambia immagine" non ancora implementata',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.lightBlue),
                title: Text(
                  "Cambia nickname",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1B1B),
                          title: Text(
                            "Modifica nickname",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
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
                              child: const Text(
                                "Annulla",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _updateNickname(nicknameController.text);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Salva",
                                style: TextStyle(color: Colors.green),
                              ),
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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
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
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        nickname,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Primo box - info utente (testo centrato)
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
                            Text(
                              "Informazioni",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Nickname: $nickname",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Email: $email",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Secondo box - crea personaggio (testo centrato)
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
                              child: Text(
                                "Crea un nuovo personaggio",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "In questa sessione puoi creare il tuo personaggio contro la quale giocare, pensa ad una storia avvincente! Anche gli altri giocatori potranno vedere il tuo personaggio creato.",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const CreateCharacterPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Crea Personaggio",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(
                                    0.8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
