/// Do'kon xabari modeli
class ShopMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final bool isFromShop;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  ShopMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.isFromShop,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  factory ShopMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender_profile'];

    return ShopMessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      senderName: sender?['full_name'],
      senderAvatar: sender?['avatar_url'],
      isFromShop: json['is_from_shop'] ?? false,
      content: json['content'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'is_from_shop': isFromShop,
        'content': content,
      };

  /// Formatlangan vaqt
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Oxirgi xabar bo'lsa sana ham ko'rsatiladi
  String formattedDateTime(bool showDate) {
    if (!showDate) return formattedTime;

    final now = DateTime.now();
    final diff = now.difference(createdAt);

    String date;
    if (diff.inDays == 0) {
      date = 'Bugun';
    } else if (diff.inDays == 1) {
      date = 'Kecha';
    } else {
      date =
          '${createdAt.day}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}';
    }

    return '$date, $formattedTime';
  }
}
