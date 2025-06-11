class CharacterModel {
  final String id;
  final String name;
  final String description;
  final String prompt;
  final String imagePath;

  CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.prompt,
    required this.imagePath,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'prompt': prompt,
      'imagePath': imagePath,
    };
  }
}
