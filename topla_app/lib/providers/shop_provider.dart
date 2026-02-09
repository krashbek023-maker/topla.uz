import 'package:flutter/foundation.dart';
import '../core/repositories/i_shop_repository.dart';
import '../models/shop_model.dart';
import '../models/shop_review_model.dart';
import '../models/shop_conversation_model.dart';
import '../models/shop_message_model.dart';
import '../models/product_model.dart';

/// Do'konlar uchun Provider - obuna, sharh, chat
class ShopProvider extends ChangeNotifier {
  final IShopRepository _shopRepo;

  ShopProvider(this._shopRepo);

  // Estado
  ShopModel? _currentShop;
  List<ShopModel> _shops = [];
  List<ShopModel> _followedShops = [];
  List<ShopModel> _topShops = [];
  List<ProductModel> _shopProducts = [];
  List<ShopReviewModel> _currentShopReviews = [];
  List<ShopConversationModel> _conversations = [];
  List<ShopMessageModel> _currentMessages = [];

  bool _isLoading = false;
  bool _isLoadingProducts = false;
  bool _isLoadingReviews = false;
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  bool _isFollowing = false;
  String? _error;

  // Getters
  ShopModel? get currentShop => _currentShop;
  List<ShopModel> get shops => _shops;
  List<ShopModel> get followedShops => _followedShops;
  List<ShopModel> get topShops => _topShops;
  List<ProductModel> get shopProducts => _shopProducts;
  List<ShopReviewModel> get currentShopReviews => _currentShopReviews;
  List<ShopConversationModel> get conversations => _conversations;
  List<ShopMessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingReviews => _isLoadingReviews;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  bool get isFollowingLoading => _isFollowing;
  String? get error => _error;

  /// Do'konni ID bo'yicha olish
  Future<void> loadShop(String shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentShop = await _shopRepo.getShopById(shopId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Barcha do'konlarni yuklash
  Future<void> loadShops({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? city,
    String? sortBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shops = await _shopRepo.getActiveShops(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        city: city,
        sortBy: sortBy,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Do'konlarni qidirish
  Future<void> searchShops(String query) async {
    await loadShops(searchQuery: query);
  }

  /// Top do'konlarni yuklash
  Future<void> loadTopShops({int limit = 10}) async {
    try {
      _topShops = await _shopRepo.getTopShops(limit: limit);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Do'kon mahsulotlarini yuklash
  Future<void> loadShopProducts(
    String shopId, {
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? sortBy,
  }) async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      _shopProducts = await _shopRepo.getShopProducts(
        shopId,
        page: page,
        pageSize: pageSize,
        categoryId: categoryId,
        sortBy: sortBy,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Obuna bo'lgan do'konlarni yuklash
  Future<void> loadFollowedShops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _followedShops = await _shopRepo.getFollowedShops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Do'konga obuna bo'lish
  Future<bool> followShop(String shopId) async {
    _isFollowing = true;
    notifyListeners();

    try {
      final success = await _shopRepo.followShop(shopId);
      if (success && _currentShop != null && _currentShop!.id == shopId) {
        await loadShop(shopId);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isFollowing = false;
      notifyListeners();
    }
  }

  /// Obunani bekor qilish
  Future<bool> unfollowShop(String shopId) async {
    _isFollowing = true;
    notifyListeners();

    try {
      final success = await _shopRepo.unfollowShop(shopId);
      if (success && _currentShop != null && _currentShop!.id == shopId) {
        await loadShop(shopId);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isFollowing = false;
      notifyListeners();
    }
  }

  /// Obuna holatini tekshirish
  Future<bool> checkIsFollowing(String shopId) async {
    try {
      return await _shopRepo.isFollowingShop(shopId);
    } catch (e) {
      return false;
    }
  }

  // ========== REVIEWS ==========

  /// Do'kon sharhlarini yuklash
  Future<void> loadShopReviews(String shopId,
      {int page = 1, int pageSize = 20}) async {
    _isLoadingReviews = true;
    notifyListeners();

    try {
      final reviews = await _shopRepo.getShopReviews(shopId,
          page: page, pageSize: pageSize);
      _currentShopReviews =
          reviews.map((e) => ShopReviewModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  /// Sharh qoldirish
  Future<bool> addReview({
    required String shopId,
    required int rating,
    String? comment,
    List<String>? images,
    String? orderId,
  }) async {
    try {
      final success = await _shopRepo.addShopReview(
        shopId: shopId,
        rating: rating,
        comment: comment,
        images: images,
        orderId: orderId,
      );
      if (success) {
        await loadShopReviews(shopId);
        await loadShop(shopId);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ========== CHAT ==========

  /// Barcha suhbatlarni yuklash
  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    notifyListeners();

    try {
      final convs = await _shopRepo.getUserConversations();
      _conversations =
          convs.map((e) => ShopConversationModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// Suhbat xabarlarini yuklash
  Future<void> loadMessages(String conversationId,
      {int page = 1, int pageSize = 50}) async {
    _isLoadingMessages = true;
    notifyListeners();

    try {
      final msgs = await _shopRepo.getMessages(conversationId,
          page: page, pageSize: pageSize);
      _currentMessages = msgs.map((e) => ShopMessageModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Xabar jo'natish
  Future<bool> sendMessage({
    required String conversationId,
    required String message,
    String messageType = 'text',
    String? attachmentUrl,
    String? productId,
    String? orderId,
  }) async {
    _isSendingMessage = true;
    notifyListeners();

    try {
      final success = await _shopRepo.sendMessage(
        conversationId: conversationId,
        message: message,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        productId: productId,
        orderId: orderId,
      );
      if (success) {
        await loadMessages(conversationId);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  /// Yangi suhbat boshlash yoki mavjud suhbatni olish
  Future<String?> getOrCreateConversation(String shopId) async {
    try {
      final result = await _shopRepo.getOrCreateConversation(shopId);
      return result?['id'];
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  /// Xabarlarni o'qilgan deb belgilash
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _shopRepo.markMessagesAsRead(conversationId);
    } catch (e) {
      // Silent fail
    }
  }

  /// Holatni tozalash
  void clearCurrentShop() {
    _currentShop = null;
    _currentShopReviews = [];
    _shopProducts = [];
    notifyListeners();
  }

  void clearMessages() {
    _currentMessages = [];
    notifyListeners();
  }
}
