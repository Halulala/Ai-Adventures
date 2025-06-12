class ChatPreviewModel {
  final String chatId;
  final String characterId;
  final String characterName;
  final String lastMessage;
  final bool unread;
  bool isFavorite;

  ChatPreviewModel({
    required this.chatId,
    required this.characterId,
    required this.characterName,
    required this.lastMessage,
    this.unread = false,
    this.isFavorite = false,
  });
}
