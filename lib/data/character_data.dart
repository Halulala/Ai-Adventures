import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character_model.dart';

final characterCollection = FirebaseFirestore.instance.collection('characters');

Future<List<CharacterModel>> fetchCharacters() async {
  final snapshot = await characterCollection.get();
  return snapshot.docs.map((doc) {
    return CharacterModel.fromMap(doc.data(), doc.id);
  }).toList();
}
