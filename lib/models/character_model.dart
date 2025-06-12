import 'package:cloud_firestore/cloud_firestore.dart';

class CharacterModel {
  final String id;
  final String name;
  final String description;
  final String prompt;
  final String imagePath;
  final Timestamp? createdAt;
  CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.prompt,
    required this.imagePath,
    this.createdAt,
  });

  factory CharacterModel.empty() {
    return CharacterModel(
      id: '',
      name: 'Unknown Character',
      description: '',
      prompt: '',
      imagePath: 'assets/images/default.png',
    );
  }

  factory CharacterModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CharacterModel(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      prompt: data['prompt'] ?? '',
      imagePath: data['imagePath'] ?? 'assets/images/default.png',
      createdAt: data['createdAt'], // <-- important
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'prompt': prompt,
      'imagePath': imagePath,
      'createdAt': createdAt, // <-- important
    };
  }
}
