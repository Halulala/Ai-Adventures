import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> register({
    required String name,
    required String surname,
    required String nickname,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(nickname);

      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'surname': surname.trim(),
        'nickname': nickname.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await user.reload();
    }

    return user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return credential.user;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
