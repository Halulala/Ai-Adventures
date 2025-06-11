import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final characterCollection = FirebaseFirestore.instance.collection('characters');


  Future<List<CharacterModel>> fetchCharacters() async {
    final snapshot = await characterCollection.get();
    return snapshot.docs.map((doc) {
      return CharacterModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNickname(String uid, String newNickname) async {
    await _firestore.collection('users').doc(uid).update({
      'nickname': newNickname,
    });
  }

  Future<List<CharacterModel>> getAllCharacters() async {
    final snapshot = await FirebaseFirestore.instance.collection('characters').get();
    return snapshot.docs
        .map((doc) => CharacterModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addCharacter(CharacterModel character) async {
    await FirebaseFirestore.instance.collection('characters').add(character.toMap());
  }

  Future<void> addMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  Future<List<MessageModel>> getMessages(String chatId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data()))
        .toList();
  }



}
