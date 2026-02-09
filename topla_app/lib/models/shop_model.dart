/// Do'kon modeli
class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String? slug;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final bool isVerified;
  final bool isActive;
  final DateTime? verifiedAt;
  final double commissionRate;
  final double balance;
  final double totalSales;
  final int totalOrders;
  final double rating;
  final int reviewCount;
  final int followersCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.slug,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.isVerified = false,
    this.isActive = true,
    this.verifiedAt,
    this.commissionRate = 10.0,
    this.balance = 0.0,
    this.totalSales = 0.0,
    this.totalOrders = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.followersCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'],
      description: json['description'],
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      commissionRate: (json['commission_rate'] ?? 10.0).toDouble(),
      balance: (json['balance'] ?? 0.0).toDouble(),
      totalSales: (json['total_sales'] ?? 0.0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'slug': slug,
      'description': description,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'is_verified': isVerified,
      'is_active': isActive,
      'commission_rate': commissionRate,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
    };
  }

  ShopModel copyWith({
    String? name,
    String? slug,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? phone,
    String? email,
    String? address,
    String? city,
    bool? isVerified,
    bool? isActive,
    double? commissionRate,
    double? balance,
  }) {
    return ShopModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      verifiedAt: verifiedAt,
      commissionRate: commissionRate ?? this.commissionRate,
      balance: balance ?? this.balance,
      totalSales: totalSales,
      totalOrders: totalOrders,
      rating: rating,
      reviewCount: reviewCount,
      followersCount: followersCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Formatted balance
  String get formattedBalance => '${balance.toStringAsFixed(0)} so\'m';
  String get formattedFollowers => _formatCount(followersCount);

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String get formattedTotalSales => '${totalSales.toStringAsFixed(0)} so\'m';
  String get formattedRating => rating.toStringAsFixed(1);
}
