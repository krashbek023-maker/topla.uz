/// Do'kon sharhi modeli
class ShopReviewModel {
  final String id;
  final String shopId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ShopReviewModel({
    required this.id,
    required this.shopId,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ShopReviewModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return ShopReviewModel(
      id: json['id'] as String? ?? '',
      shopId: json['shop_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: profile?['full_name'] as String? ?? 'Foydalanuvchi',
      userAvatar: profile?['avatar_url'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'shop_id': shopId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      };

  /// Yulduzlar ko'rinishi
  String get stars => '★' * rating + '☆' * (5 - rating);

  /// Formatlangan sana
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} daqiqa oldin';
      }
      return '${diff.inHours} soat oldin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} kun oldin';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} hafta oldin';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} oy oldin';
    }
    return '${(diff.inDays / 365).floor()} yil oldin';
  }
}
