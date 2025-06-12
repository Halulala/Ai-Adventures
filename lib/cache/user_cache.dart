class UserCache {
  static String? nickname;
  static String? email;

  static void clear() {
    nickname = null;
    email = null;
  }
}
