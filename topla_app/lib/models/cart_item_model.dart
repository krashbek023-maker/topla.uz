/// Savat elementi modeli
class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final ProductInfo? product;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    this.quantity = 1,
    this.product,
  });

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    ProductInfo? product,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      product: json['products'] != null
          ? ProductInfo.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }

  double get total => (product?.price ?? 0) * quantity;
}

/// Mahsulot qisqa ma'lumoti (savat uchun)
class ProductInfo {
  final String id;
  final String nameUz;
  final String nameRu;
  final double price;
  final double? oldPrice;
  final List<String> images;
  final int stock;

  ProductInfo({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.price,
    this.oldPrice,
    this.images = const [],
    this.stock = 0,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as String? ?? '',
      nameUz: json['name_uz'] as String? ?? 'Nomsiz mahsulot',
      nameRu: json['name_ru'] as String? ?? 'Без названия',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: json['old_price'] != null
          ? (json['old_price'] as num).toDouble()
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      stock: json['stock'] as int? ?? 0,
    );
  }

  String getName(String locale) => locale == 'ru' ? nameRu : nameUz;
  String? get firstImage => images.isNotEmpty ? images.first : null;
}
