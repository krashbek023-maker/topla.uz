/// Mahsulot modeli
class ProductModel {
  final String id;
  final String nameUz;
  final String nameRu;
  final String? descriptionUz;
  final String? descriptionRu;
  final double price;
  final double? oldPrice;
  final String? categoryId;
  final String? subcategoryId;
  final String? shopId;
  final List<String> images;
  final int stock;
  final int soldCount;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final bool isFeatured;
  final bool isFlashSale;
  final DateTime? flashSaleEnd;
  final int? cashbackPercent;
  final DateTime? createdAt;
  // Moderatsiya uchun
  final String? moderationStatus;
  final String? rejectionReason;

  ProductModel({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    this.descriptionUz,
    this.descriptionRu,
    required this.price,
    this.oldPrice,
    this.categoryId,
    this.subcategoryId,
    this.shopId,
    this.images = const [],
    this.stock = 0,
    this.soldCount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isFlashSale = false,
    this.flashSaleEnd,
    this.cashbackPercent = 0,
    this.createdAt,
    this.moderationStatus,
    this.rejectionReason,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      nameUz: (json['name_uz'] ?? json['name'] ?? '') as String,
      nameRu: (json['name_ru'] ?? json['name'] ?? '') as String,
      descriptionUz: (json['description_uz'] ?? json['description']) as String?,
      descriptionRu: (json['description_ru'] ?? json['description']) as String?,
      price: (json['price'] as num).toDouble(),
      oldPrice: (json['old_price'] ?? json['originalPrice']) != null
          ? ((json['old_price'] ?? json['originalPrice']) as num).toDouble()
          : null,
      categoryId: (json['category_id'] ?? json['categoryId']) as String?,
      subcategoryId:
          (json['subcategory_id'] ?? json['subcategoryId']) as String?,
      shopId: (json['shop_id'] ?? json['shopId']) as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      stock: json['stock'] as int? ?? 0,
      soldCount: (json['sold_count'] ?? json['salesCount']) as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] ?? json['reviewCount']) as int? ?? 0,
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      isFeatured: (json['is_featured'] ?? json['isFeatured']) as bool? ?? false,
      isFlashSale: json['is_flash_sale'] as bool? ?? false,
      flashSaleEnd: json['flash_sale_end'] != null
          ? DateTime.parse(json['flash_sale_end'])
          : null,
      cashbackPercent:
          (json['cashback_percent'] ?? json['discountPercent']) as int? ?? 0,
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse((json['created_at'] ?? json['createdAt']))
          : null,
      moderationStatus: json['moderation_status'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nameUz,
      'description': descriptionUz,
      'price': price,
      'originalPrice': oldPrice,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'shopId': shopId,
      'images': images,
      'stock': stock,
      'isActive': isActive,
      'isFeatured': isFeatured,
    };
  }

  /// Til bo'yicha nom olish
  String getName(String locale) {
    if (locale == 'ru' && nameRu.isNotEmpty) return nameRu;
    return nameUz;
  }

  /// Til bo'yicha tavsif olish
  String? getDescription(String locale) {
    return locale == 'ru' ? descriptionRu : descriptionUz;
  }

  /// Chegirma foizi
  int get discountPercent {
    if (oldPrice == null || oldPrice! <= price) return 0;
    return ((oldPrice! - price) / oldPrice! * 100).round();
  }

  /// Birinchi rasm
  String? get firstImage => images.isNotEmpty ? images.first : null;

  /// Omborda bormi
  bool get inStock => stock > 0;

  /// Tilga mos nom (default Uzbek)
  String get name => nameUz;

  /// Birinchi rasm URL
  String? get imageUrl => firstImage;

  /// Asl narx (oldPrice)
  double? get originalPrice => oldPrice;

  /// Map formatiga aylantirish (ProductDetailScreen uchun)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': nameUz,
      'name_uz': nameUz,
      'name_ru': nameRu,
      'description': descriptionUz,
      'description_uz': descriptionUz,
      'description_ru': descriptionRu,
      'price': price.toInt(),
      'oldPrice': oldPrice?.toInt(),
      'discount': discountPercent,
      'image': firstImage ?? '',
      'images': images,
      'rating': rating,
      'sold': soldCount,
      'cashback': cashbackPercent,
      'stock': stock,
      'category_id': categoryId,
      'shop_id': shopId,
    };
  }
}
