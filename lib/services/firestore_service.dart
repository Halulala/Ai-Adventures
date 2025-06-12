import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/character_model.dart';
import '../models/chat_preview_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference characterCollection = FirebaseFirestore.instance
      .collection('characters');

  Future<List<CharacterModel>> fetchCharacters() async {
    final snapshot = await characterCollection.get();
    return snapshot.docs
        .map(
          (doc) => CharacterModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
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

  Future<void> updateUserAvatar(String uid, String base64Image) async {
    await _firestore.collection('users').doc(uid).update({
      'imageBase64': base64Image,
    });
  }

  Future<String?> getUserAvatar(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return data['imageBase64'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<CharacterModel>> getAllCharacters() async {
    final snapshot = await characterCollection.get();
    return snapshot.docs
        .map(
          (doc) => CharacterModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<void> addCharacter(CharacterModel character) async {
    final data = character.toMap();
    data['createdAt'] = character.createdAt ?? Timestamp.now();
    await characterCollection.add(data);
  }

  Future<List<ChatPreviewModel>> getAllChatPreviews() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatPreviewModel(
        chatId: doc.id,
        characterId: data['characterId'] ?? '',
        characterName: data['characterName'] ?? 'Unknown',
        lastMessage: data['lastMessage'] ?? '',
        unread: data['unread'] ?? false,
        isFavorite: data['isFavorite'] ?? false,
      );
    }).toList();
  }

  Future<void> createOrUpdateChat({
    required String uid,
    required String chatId,
    required String characterId,
    required String characterName,
    required String lastMessage,
    bool unread = true,
    bool isFavorite = false,
  }) async {
    final chatRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId);

    await chatRef.set({
      'characterId': characterId,
      'characterName': characterName,
      'lastMessage': lastMessage,
      'unread': unread,
      'isFavorite': isFavorite,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addMessage({
    required String uid,
    required String chatId,
    required MessageModel message,
  }) async {
    final chatRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId);

    // 1. Recupera characterId esistente
    String existingCharacterId = '';
    try {
      final chatSnap = await chatRef.get();
      if (chatSnap.exists) {
        final data = chatSnap.data();
        if (data != null && data.containsKey('characterId')) {
          existingCharacterId = data['characterId'] as String? ?? '';
        }
      }
    } catch (_) {}

    final messagesRef = chatRef.collection('messages');
    await messagesRef.add(message.toMap());

    final updateData = <String, dynamic>{
      'lastMessage': message.text,
      'unread': message.sender != 'Tu',
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (existingCharacterId.isNotEmpty) {
      updateData['characterId'] = existingCharacterId;
    }
    if (message.sender != 'Tu') {
      updateData['characterName'] = message.sender;
    }

    await chatRef.set(updateData, SetOptions(merge: true));
  }

  Future<void> addMessagePreservingCharacter({
    required String uid,
    required String chatId,
    required String characterId,
    required MessageModel message,
  }) async {
    final chatRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId);

    // Aggiungi il messaggio
    final messagesRef = chatRef.collection('messages');
    await messagesRef.add(message.toMap());

    // Aggiorna chat con il characterId fornito
    final updateData = <String, dynamic>{
      'characterId': characterId,
      'lastMessage': message.text,
      'unread': message.sender != 'Tu',
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (message.sender != 'Tu') {
      updateData['characterName'] = message.sender;
    }
    await chatRef.set(updateData, SetOptions(merge: true));
  }

  /// Recupera tutti i messaggi di una chat specifica per un utente
  Future<List<MessageModel>> getMessages({
    required String uid,
    required String chatId,
  }) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MessageModel.fromMap(data);
    }).toList();
  }

  Future<void> deleteChat({required String uid, required String chatId}) async {
    final chatRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId);

    final messagesSnapshot = await chatRef.collection('messages').get();
    for (final doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }
    await chatRef.delete();
  }

  Future<void> setFavorite({
    required String uid,
    required String chatId,
    required bool isFavorite,
  }) async {
    final chatRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId);

    await chatRef.update({'isFavorite': isFavorite});
  }
}
