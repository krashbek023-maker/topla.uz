import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_error_handler.dart';
import 'cache_service.dart';

/// Base repository with caching and error handling
abstract class BaseRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final CacheService _cache = CacheService();

  SupabaseClient get client => _client;
  CacheService get cache => _cache;

  /// Execute query with error handling
  Future<T> execute<T>(Future<T> Function() query) {
    return ApiErrorHandler.execute(query);
  }

  /// Execute query with retry
  Future<T> executeWithRetry<T>(
    Future<T> Function() query, {
    int maxRetries = 3,
  }) {
    return ApiErrorHandler.executeWithRetry(query, maxRetries: maxRetries);
  }

  /// Execute query and return result wrapper
  Future<ApiResult<T>> executeResult<T>(Future<T> Function() query) {
    return ApiResult.from(query);
  }
}

/// Product repository with caching
class ProductRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? vendorId,
    String? search,
    bool forceRefresh = false,
  }) async {
    // Build cache key
    final cacheKey =
        'products_${page}_${limit}_${categoryId ?? 'all'}_${vendorId ?? 'all'}_${search ?? ''}';

    return cache.getOrFetch<List<Map<String, dynamic>>>(
      key: cacheKey,
      forceRefresh: forceRefresh,
      fromJson: (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
      toJson: (data) => data,
      memoryTtl: const Duration(minutes: 5),
      persistentTtl: const Duration(minutes: 30),
      fetch: () async {
        var query = client
            .from('products')
            .select('*, categories(*), vendors(*)')
            .eq('is_active', true);

        if (categoryId != null) {
          query = query.eq('category_id', categoryId);
        }

        if (vendorId != null) {
          query = query.eq('vendor_id', vendorId);
        }

        if (search != null && search.isNotEmpty) {
          query = query.ilike('name', '%$search%');
        }

        final response = await query
            .order('created_at', ascending: false)
            .range((page - 1) * limit, page * limit - 1);

        return List<Map<String, dynamic>>.from(response);
      },
    );
  }

  Future<Map<String, dynamic>> getProductById(
    String id, {
    bool forceRefresh = false,
  }) async {
    return cache.getOrFetch<Map<String, dynamic>>(
      key: CacheKeys.productDetail(id),
      forceRefresh: forceRefresh,
      fromJson: (data) => Map<String, dynamic>.from(data),
      toJson: (data) => data,
      memoryTtl: const Duration(minutes: 10),
      persistentTtl: const Duration(hours: 1),
      fetch: () async {
        final response = await client
            .from('products')
            .select('*, categories(*), vendors(*), product_images(*)')
            .eq('id', id)
            .single();

        return Map<String, dynamic>.from(response);
      },
    );
  }

  Future<void> invalidateProductCache(String productId) async {
    await cache.invalidate(CacheKeys.productDetail(productId));
    await cache.invalidateWhere((key) => key.startsWith('products_'));
  }
}

/// Category repository with caching
class CategoryRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> getCategories({
    bool forceRefresh = false,
  }) async {
    return cache.getOrFetch<List<Map<String, dynamic>>>(
      key: CacheKeys.categories,
      forceRefresh: forceRefresh,
      fromJson: (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
      toJson: (data) => data,
      memoryTtl: const Duration(minutes: 30),
      persistentTtl: const Duration(hours: 6),
      fetch: () async {
        final response = await client
            .from('categories')
            .select()
            .eq('is_active', true)
            .order('order_index');

        return List<Map<String, dynamic>>.from(response);
      },
    );
  }
}

/// Banner repository with caching
class BannerRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> getBanners({
    bool forceRefresh = false,
  }) async {
    return cache.getOrFetch<List<Map<String, dynamic>>>(
      key: CacheKeys.banners,
      forceRefresh: forceRefresh,
      fromJson: (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
      toJson: (data) => data,
      memoryTtl: const Duration(minutes: 15),
      persistentTtl: const Duration(hours: 1),
      fetch: () async {
        final now = DateTime.now().toIso8601String();

        final response = await client
            .from('banners')
            .select()
            .eq('is_active', true)
            .lte('start_date', now)
            .gte('end_date', now)
            .order('order_index');

        return List<Map<String, dynamic>>.from(response);
      },
    );
  }
}

/// Order repository
class OrderRepository extends BaseRepository {
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    return execute(() async {
      final response =
          await client.from('orders').insert(orderData).select().single();

      // Invalidate related caches
      await cache.invalidateWhere((key) => key.startsWith('orders_'));

      return Map<String, dynamic>.from(response);
    });
  }

  Future<List<Map<String, dynamic>>> getUserOrders({
    required String userId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    return execute(() async {
      var query = client
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      return List<Map<String, dynamic>>.from(response);
    });
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    return execute(() async {
      final response = await client
          .from('orders')
          .select('*, order_items(*, products(*)), addresses(*)')
          .eq('id', orderId)
          .single();

      return Map<String, dynamic>.from(response);
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await execute(() async {
      await client.from('orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    });

    await cache.invalidate(CacheKeys.orderDetail(orderId));
  }
}

/// Repository provider
class Repositories {
  static final Repositories _instance = Repositories._internal();
  factory Repositories() => _instance;
  Repositories._internal();

  final ProductRepository products = ProductRepository();
  final CategoryRepository categories = CategoryRepository();
  final BannerRepository banners = BannerRepository();
  final OrderRepository orders = OrderRepository();

  /// Clear all caches
  Future<void> clearAllCaches() async {
    await CacheService().clearAll();
  }
}
