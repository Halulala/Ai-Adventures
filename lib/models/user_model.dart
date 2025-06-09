class UserModel {
  final String uid;
  final String nickname;
  final String email;

  UserModel({required this.uid, required this.nickname, required this.email});

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      nickname: data['nickname'] ?? 'Nickname non trovato',
      email: data['email'] ?? '',
    );
  }
}
