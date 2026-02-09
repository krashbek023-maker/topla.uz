import '../../models/shop_model.dart';
import '../../models/product_model.dart';

/// Do'konlar uchun umumiy repository interfeysi (mijozlar uchun)
abstract class IShopRepository {
  /// Do'konni ID bo'yicha olish
  Future<ShopModel?> getShopById(String shopId);

  /// Barcha faol do'konlarni olish
  Future<List<ShopModel>> getActiveShops({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? city,
    String? sortBy,
  });

  /// Top do'konlar (followers/rating bo'yicha)
  Future<List<ShopModel>> getTopShops({int limit = 10});

  /// Do'kon mahsulotlarini olish
  Future<List<ProductModel>> getShopProducts(
    String shopId, {
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? sortBy,
  });

  /// Do'konga obuna bo'lish
  Future<bool> followShop(String shopId);

  /// Obunani bekor qilish
  Future<bool> unfollowShop(String shopId);

  /// Foydalanuvchi obuna bo'lganmi?
  Future<bool> isFollowingShop(String shopId);

  /// Foydalanuvchi obuna bo'lgan do'konlar
  Future<List<ShopModel>> getFollowedShops();

  /// Do'kon statistikasi
  Future<Map<String, dynamic>> getShopStats(String shopId);

  /// Do'kon sharhlarini olish
  Future<List<Map<String, dynamic>>> getShopReviews(
    String shopId, {
    int page = 1,
    int pageSize = 20,
  });

  /// Sharh qo'shish
  Future<bool> addShopReview({
    required String shopId,
    required int rating,
    String? comment,
    List<String>? images,
    String? orderId,
  });

  /// Suhbatni boshlash/olish
  Future<Map<String, dynamic>?> getOrCreateConversation(String shopId);

  /// Xabarlarni olish
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 50,
  });

  /// Xabar yuborish
  Future<bool> sendMessage({
    required String conversationId,
    required String message,
    String messageType = 'text',
    String? attachmentUrl,
    String? productId,
    String? orderId,
  });

  /// Xabarlarni o'qilgan deb belgilash
  Future<void> markMessagesAsRead(String conversationId);

  /// Foydalanuvchi suhbatlari
  Future<List<Map<String, dynamic>>> getUserConversations();
}
