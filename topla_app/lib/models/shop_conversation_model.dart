/// Do'kon bilan suhbat modeli
class ShopConversationModel {
  final String id;
  final String shopId;
  final String shopName;
  final String? shopLogoUrl;
  final String customerId;
  final String? customerName;
  final String? customerAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  ShopConversationModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    this.shopLogoUrl,
    required this.customerId,
    this.customerName,
    this.customerAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory ShopConversationModel.fromJson(Map<String, dynamic> json) {
    final shop = json['shops'];
    final customer = json['customer_profile'];

    return ShopConversationModel(
      id: json['id'],
      shopId: json['shop_id'],
      shopName: shop?['name'] ?? 'Do\'kon',
      shopLogoUrl: shop?['logo_url'],
      customerId: json['customer_id'],
      customerName: customer?['full_name'],
      customerAvatar: customer?['avatar_url'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Formatlangan oxirgi xabar vaqti
  String get formattedLastMessageTime {
    if (lastMessageAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inDays == 0) {
      return '${lastMessageAt!.hour.toString().padLeft(2, '0')}:${lastMessageAt!.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Kecha';
    } else if (diff.inDays < 7) {
      const days = ['Dsh', 'Ssh', 'Chr', 'Pay', 'Jum', 'Shb', 'Yak'];
      return days[lastMessageAt!.weekday - 1];
    }
    return '${lastMessageAt!.day}.${lastMessageAt!.month.toString().padLeft(2, '0')}';
  }

  bool get hasUnread => unreadCount > 0;
}
