class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String? imageBase64;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    this.imageBase64,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      nickname: data['nickname'] ?? 'Nickname not found',
      email: data['email'] ?? '',
      imageBase64: data['imageBase64'],
    );
  }
}
