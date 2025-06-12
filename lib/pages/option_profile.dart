import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache/user_cache.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/connectivity_service.dart';
import '../wrappers/login_page_wrapper.dart';
import 'create_character.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class OptionProfile extends StatefulWidget {
  const OptionProfile({super.key});

  @override
  State<OptionProfile> createState() => _OptionProfileState();
}

class _OptionProfileState extends State<OptionProfile> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isLoading = true;
  String nickname = "Loading...";
  String email = "";
  bool isAvatarExpanded = false;
  String? avatarBase64;

  User? get user => _authService.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    setState(() => _isLoading = true);

    if (UserCache.nickname != null && UserCache.email != null) {
      setState(() {
        nickname = UserCache.nickname!;
        email = UserCache.email!;
        _isLoading = false;
      });
      _loadAvatar();
      return;
    }

    final userEmail = user!.email ?? "Email not available";
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
          nickname = "Nickname not found";
          email = userEmail;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        nickname = "Error loading nickname";
        email = userEmail;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvatar() async {
    if (user == null) return;
    try {
      final profile = await _firestoreService.getUserProfile(user!.uid);
      if (profile != null && profile.imageBase64 != null) {
        setState(() {
          avatarBase64 = profile.imageBase64;
        });
      }
    } catch (_) {}
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating nickname')));
    }
  }

  Future<void> _pickAndSaveImageBase64(ImageSource source) async {
    if (user == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No image selected')));
      return;
    }

    try {
      final originalSize = await pickedFile.length();
      XFile fileToProcess = pickedFile;

      const int soglia1MB = 1 * 1024 * 1024;
      if (originalSize > soglia1MB) {
        final tempDir = await getTemporaryDirectory();
        final targetPath = path.join(
          tempDir.path,
          'compressed_${path.basename(pickedFile.path)}',
        );

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path,
          targetPath,
          quality: 40,
          format: CompressFormat.jpeg,
        );

        if (compressedFile != null) {
          fileToProcess = XFile(compressedFile.path);
        }
      }
      final bytes = await fileToProcess.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fullBase64 = 'data:image/jpeg;base64,$base64Image';

      await _firestoreService.updateUserAvatar(user!.uid, fullBase64);

      setState(() {
        avatarBase64 = fullBase64;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile image updated')));
    } catch (e) {
      print('Errore upload image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error uploading image')));
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
                  await prefs.remove('remember_login');
                  UserCache.clear();

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginPageWrapper(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.green),
                title: Text(
                  "Information",
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
                            "Information",
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
                                "Version: 1.0.0",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "This application created for a university project, aims to entertain the user with ia chat interaction, we ask you to be patient with the untrained ia that may flicker occasionally.!",
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
                              "Close",
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
    TextEditingController nicknameController = TextEditingController(
      text: nickname,
    );
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
                title: Text(
                  "Change Image",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showImageSourceSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.lightBlue),
                title: Text(
                  "Change Nickname",
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
                            "Edit Nickname",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          content: TextField(
                            controller: nicknameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Enter new nickname",
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _updateNickname(nicknameController.text);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Save",
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

  void _showImageSourceSheet() {
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
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: Text(
                  "Scatta foto",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSaveImageBase64(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  "Scegli dalla galleria",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSaveImageBase64(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: Text(
                  "Annulla",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStream,
      initialData: true,
      builder: (context, snapshot) {
        final hasConnection = snapshot.data ?? true;

        return Stack(
          children: [
            Scaffold(
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
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap:
                                  () => setState(
                                    () => isAvatarExpanded = !isAvatarExpanded,
                                  ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: isAvatarExpanded ? 150 : 100,
                                height: isAvatarExpanded ? 150 : 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white12,
                                  image:
                                      avatarBase64 != null
                                          ? (_getImageProviderFromBase64(
                                                    avatarBase64!,
                                                  ) !=
                                                  null
                                              ? DecorationImage(
                                                image:
                                                    _getImageProviderFromBase64(
                                                      avatarBase64!,
                                                    )!,
                                                fit: BoxFit.cover,
                                              )
                                              : null)
                                          : null,
                                ),
                                child:
                                    avatarBase64 == null ||
                                            _getImageProviderFromBase64(
                                                  avatarBase64!,
                                                ) ==
                                                null
                                        ? const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                        : null,
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
                                    "Information",
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
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      0,
                                      0,
                                      5,
                                    ),
                                    child: Text(
                                      "Create a new character",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "In this screen you can create your character! This character will be viewed by all players. *Tip: use an appropriate prompt, e.g., 'Behave like a dungeon master and let me face xxxxx in an epic and exciting battle!'",
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
                                        "Create Character",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                          255,
                                          82,
                                          82,
                                          0.8,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
            if (!hasConnection)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: const Color.fromRGBO(0, 0, 0, 0.75),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.redAccent,
                            size: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Connection absent.\nCheck the network and try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
