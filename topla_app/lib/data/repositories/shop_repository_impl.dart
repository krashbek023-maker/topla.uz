import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/repositories/i_shop_repository.dart';
import '../../core/utils/app_logger.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';

class ShopRepositoryImpl implements IShopRepository {
  static const _tag = 'ShopRepo';
  final SupabaseClient _supabase;

  ShopRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      final response = await _supabase
          .from('shops')
          .select()
          .eq('id', shopId)
          .eq('is_active', true)
          .single();

      return ShopModel.fromJson(response);
    } catch (e) {
      AppLogger.e(_tag, 'getShopById error', e);
      return null;
    }
  }

  @override
  Future<List<ShopModel>> getActiveShops({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? city,
    String? sortBy,
  }) async {
    try {
      var query = _supabase.from('shops').select().eq('is_active', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      // Determine order column and direction
      String orderColumn;
      bool ascending;
      switch (sortBy) {
        case 'rating':
          orderColumn = 'rating';
          ascending = false;
          break;
        case 'followers':
          orderColumn = 'followers_count';
          ascending = false;
          break;
        case 'newest':
          orderColumn = 'created_at';
          ascending = false;
          break;
        default:
          orderColumn = 'followers_count';
          ascending = false;
      }

      final offset = (page - 1) * pageSize;
      final response = await query
          .order(orderColumn, ascending: ascending)
          .range(offset, offset + pageSize - 1);

      return (response as List).map((e) => ShopModel.fromJson(e)).toList();
    } catch (e) {
      AppLogger.e(_tag, 'Error getting shops: $e');
      return [];
    }
  }

  @override
  Future<List<ShopModel>> getTopShops({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('shops')
          .select()
          .eq('is_active', true)
          .order('followers_count', ascending: false)
          .order('rating', ascending: false)
          .limit(limit);

      return (response as List).map((e) => ShopModel.fromJson(e)).toList();
    } catch (e) {
      AppLogger.e(_tag, 'Error getting top shops: $e');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getShopProducts(
    String shopId, {
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? sortBy,
  }) async {
    try {
      var query = _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .eq('is_active', true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      // Determine order column and direction
      String orderColumn;
      bool ascending;
      switch (sortBy) {
        case 'price_low':
          orderColumn = 'price';
          ascending = true;
          break;
        case 'price_high':
          orderColumn = 'price';
          ascending = false;
          break;
        case 'newest':
          orderColumn = 'created_at';
          ascending = false;
          break;
        case 'rating':
          orderColumn = 'rating';
          ascending = false;
          break;
        default:
          orderColumn = 'created_at';
          ascending = false;
      }

      final offset = (page - 1) * pageSize;
      final response = await query
          .order(orderColumn, ascending: ascending)
          .range(offset, offset + pageSize - 1);

      return (response as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      AppLogger.e(_tag, 'Error getting shop products: $e');
      return [];
    }
  }

  @override
  Future<bool> followShop(String shopId) async {
    if (_currentUserId == null) return false;

    try {
      await _supabase.from('shop_followers').insert({
        'user_id': _currentUserId,
        'shop_id': shopId,
      });
      return true;
    } catch (e) {
      AppLogger.e(_tag, 'Error following shop: $e');
      return false;
    }
  }

  @override
  Future<bool> unfollowShop(String shopId) async {
    if (_currentUserId == null) return false;

    try {
      await _supabase
          .from('shop_followers')
          .delete()
          .eq('user_id', _currentUserId!)
          .eq('shop_id', shopId);
      return true;
    } catch (e) {
      AppLogger.e(_tag, 'Error unfollowing shop: $e');
      return false;
    }
  }

  @override
  Future<bool> isFollowingShop(String shopId) async {
    if (_currentUserId == null) return false;

    try {
      final response = await _supabase
          .from('shop_followers')
          .select('id')
          .eq('user_id', _currentUserId!)
          .eq('shop_id', shopId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      AppLogger.e(_tag, 'Error checking follow status: $e');
      return false;
    }
  }

  @override
  Future<List<ShopModel>> getFollowedShops() async {
    if (_currentUserId == null) return [];

    try {
      final response = await _supabase
          .from('shop_followers')
          .select('shop:shops(*)')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return (response as List)
          .where((e) => e['shop'] != null)
          .map((e) => ShopModel.fromJson(e['shop']))
          .toList();
    } catch (e) {
      AppLogger.e(_tag, 'Error getting followed shops: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getShopStats(String shopId) async {
    try {
      // Mahsulotlar soni
      final productsCount = await _supabase
          .from('products')
          .select('id')
          .eq('shop_id', shopId)
          .eq('is_active', true);

      // Sharhlar soni
      final reviewsCount = await _supabase
          .from('shop_reviews')
          .select('id')
          .eq('shop_id', shopId);

      // Do'kon ma'lumotlari
      final shop = await getShopById(shopId);

      return {
        'products_count': (productsCount as List).length,
        'reviews_count': (reviewsCount as List).length,
        'followers_count': shop?.followersCount ?? 0,
        'rating': shop?.rating ?? 0,
        'total_orders': shop?.totalOrders ?? 0,
      };
    } catch (e) {
      AppLogger.e(_tag, 'Error getting shop stats: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getShopReviews(
    String shopId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final response = await _supabase
          .from('shop_reviews')
          .select('*, user:profiles(id, full_name, avatar_url)')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.e(_tag, 'Error getting reviews: $e');
      return [];
    }
  }

  @override
  Future<bool> addShopReview({
    required String shopId,
    required int rating,
    String? comment,
    List<String>? images,
    String? orderId,
  }) async {
    if (_currentUserId == null) return false;

    try {
      await _supabase.from('shop_reviews').insert({
        'shop_id': shopId,
        'user_id': _currentUserId,
        'rating': rating,
        'comment': comment,
        'images': images,
        'order_id': orderId,
        'is_verified_purchase': orderId != null,
      });
      return true;
    } catch (e) {
      AppLogger.e(_tag, 'Error adding review: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrCreateConversation(String shopId) async {
    if (_currentUserId == null) return null;

    try {
      // Mavjud suhbatni tekshirish
      var response = await _supabase
          .from('shop_conversations')
          .select('*, shop:shops(id, name, logo_url)')
          .eq('shop_id', shopId)
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response != null) {
        return response;
      }

      // Yangi suhbat yaratish
      final newConversation = await _supabase
          .from('shop_conversations')
          .insert({
            'shop_id': shopId,
            'user_id': _currentUserId,
          })
          .select('*, shop:shops(id, name, logo_url)')
          .single();

      return newConversation;
    } catch (e) {
      AppLogger.e(_tag, 'Error getting/creating conversation: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final response = await _supabase
          .from('shop_messages')
          .select('*, sender:profiles(id, full_name, avatar_url)')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.e(_tag, 'Error getting messages: $e');
      return [];
    }
  }

  @override
  Future<bool> sendMessage({
    required String conversationId,
    required String message,
    String messageType = 'text',
    String? attachmentUrl,
    String? productId,
    String? orderId,
  }) async {
    if (_currentUserId == null) return false;

    try {
      // Sender type ni aniqlash (user yoki shop)
      final conversation = await _supabase
          .from('shop_conversations')
          .select('user_id, shop:shops(owner_id)')
          .eq('id', conversationId)
          .single();

      final isShopOwner = conversation['shop']['owner_id'] == _currentUserId;
      final senderType = isShopOwner ? 'shop' : 'user';

      await _supabase.from('shop_messages').insert({
        'conversation_id': conversationId,
        'sender_id': _currentUserId,
        'sender_type': senderType,
        'message': message,
        'message_type': messageType,
        'attachment_url': attachmentUrl,
        'product_id': productId,
        'order_id': orderId,
      });
      return true;
    } catch (e) {
      AppLogger.e(_tag, 'Error sending message: $e');
      return false;
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    if (_currentUserId == null) return;

    try {
      // Conversation ni olish
      final conversation = await _supabase
          .from('shop_conversations')
          .select('user_id, shop:shops(owner_id)')
          .eq('id', conversationId)
          .single();

      final isShopOwner = conversation['shop']['owner_id'] == _currentUserId;

      // Mos unread_count ni 0 ga tushirish
      if (isShopOwner) {
        await _supabase
            .from('shop_conversations')
            .update({'shop_unread_count': 0}).eq('id', conversationId);
      } else {
        await _supabase
            .from('shop_conversations')
            .update({'user_unread_count': 0}).eq('id', conversationId);
      }
    } catch (e) {
      AppLogger.e(_tag, 'Error marking messages as read: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserConversations() async {
    if (_currentUserId == null) return [];

    try {
      final response = await _supabase
          .from('shop_conversations')
          .select('*, shop:shops(id, name, logo_url)')
          .eq('user_id', _currentUserId!)
          .order('last_message_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.e(_tag, 'Error getting conversations: $e');
      return [];
    }
  }
}
