import '../../models/models.dart';

/// Vendor operatsiyalari uchun interface
abstract class IVendorRepository {
  // ==================== SHOP ====================

  /// Vendor o'z do'konini olish
  Future<ShopModel?> getMyShop();

  /// Yangi do'kon yaratish
  Future<ShopModel> createShop({
    required String name,
    String? description,
    String? logoUrl,
    String? phone,
    String? email,
    String? address,
    String? city,
  });

  /// Do'konni yangilash
  Future<ShopModel> updateShop({
    required String shopId,
    String? name,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? phone,
    String? email,
    String? address,
    String? city,
  });

  // ==================== PRODUCTS ====================

  /// Vendor mahsulotlarini olish
  Future<List<ProductModel>> getMyProducts({
    String? moderationStatus,
    int limit = 50,
    int offset = 0,
  });

  /// Yangi mahsulot qo'shish
  Future<ProductModel> createProduct({
    required String nameUz,
    required String nameRu,
    String? descriptionUz,
    String? descriptionRu,
    required double price,
    double? oldPrice,
    required String categoryId,
    List<String>? images,
    int stock = 0,
    int? cashbackPercent,
  });

  /// Mahsulotni yangilash
  Future<ProductModel> updateProduct({
    required String productId,
    String? nameUz,
    String? nameRu,
    String? descriptionUz,
    String? descriptionRu,
    double? price,
    double? oldPrice,
    String? categoryId,
    List<String>? images,
    int? stock,
    int? cashbackPercent,
  });

  /// Mahsulotni o'chirish
  Future<void> deleteProduct(String productId);

  // ==================== ORDERS ====================

  /// Vendor buyurtmalarini olish
  Future<List<OrderModel>> getMyOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  });

  /// Buyurtma statusini yangilash
  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  // ==================== PAYOUTS ====================

  /// To'lov so'rovlarini olish
  Future<List<PayoutModel>> getMyPayouts({
    PayoutStatus? status,
    int limit = 50,
    int offset = 0,
  });

  /// To'lov so'rovi yaratish
  Future<PayoutModel> requestPayout({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    String? notes,
  });

  // ==================== STATS ====================

  /// Vendor statistika
  Future<VendorStats> getMyStats();

  /// Komissiya tarixini olish
  Future<List<CommissionModel>> getCommissionHistory({
    int limit = 50,
    int offset = 0,
  });
}
