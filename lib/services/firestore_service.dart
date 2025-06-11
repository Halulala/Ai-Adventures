import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character_model.dart';
import '../models/chat_model.dart';
import '../models/chat_preview_model.dart';
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

  Future<List<ChatPreviewModel>> getAllChatPreviews() async {
    final snapshot = await _firestore.collection('chats').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatPreviewModel(
        chatId: doc.id,
        characterName: data['characterName'] ?? 'Sconosciuto',
        lastMessage: data['lastMessage'] ?? '',
        unread: data['unread'] ?? false,
        isFavorite: data['isFavorite'] ?? false,
      );
    }).toList();
  }

  Future<void> setFavorite(String chatId, bool isFavorite) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isFavorite': isFavorite,
    });
  }

  Future<void> deleteChat(String chatId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    // Elimina i messaggi prima
    final messagesSnapshot = await chatRef.collection('messages').get();
    for (final doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    await chatRef.delete();
  }

  Future<void> addMessage(String chatId, MessageModel message) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    await chatRef.collection('messages').add(message.toMap());

    await chatRef.set({
      'lastMessage': message.text,
      'characterName': message.sender != 'Tu' ? message.sender : null,
      'unread': message.sender != 'Tu',
      'isFavorite': false, // default
    }, SetOptions(merge: true));
  }

  Future<List<MessageModel>> getMessages(String chatId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MessageModel(
        sender: data['sender'] ?? '???',
        text: data['text'] ?? '',
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
  }
}
