class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String? imageBase64; // <-- AGGIUNTO

  UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    this.imageBase64, // <-- AGGIUNTO
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      nickname: data['nickname'] ?? 'Nickname non trovato',
      email: data['email'] ?? '',
      imageBase64: data['imageBase64'], // <-- AGGIUNTO
    );
  }
}
