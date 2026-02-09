import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shop_model.dart';
import '../models/payout_model.dart';
import '../models/commission_model.dart';
import '../models/vendor_stats.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

/// Vendor (Do'kon egasi) servislar
class VendorService {
  static final _supabase = Supabase.instance.client;

  // ==================== SHOP ====================

  /// Vendor o'z do'konini olish
  static Future<ShopModel?> getMyShop() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('shops')
        .select()
        .eq('owner_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return ShopModel.fromJson(response);
  }

  /// Yangi do'kon yaratish
  static Future<ShopModel> createShop({
    required String name,
    String? description,
    String? logoUrl,
    String? phone,
    String? email,
    String? address,
    String? city,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Foydalanuvchi topilmadi');

    final response = await _supabase
        .from('shops')
        .insert({
          'owner_id': userId,
          'name': name,
          'description': description,
          'logo_url': logoUrl,
          'phone': phone,
          'email': email,
          'address': address,
          'city': city,
        })
        .select()
        .single();

    // Foydalanuvchi rolini vendor ga o'zgartirish
    await _supabase.from('profiles').update({'role': 'vendor'}).eq(
      'id',
      userId,
    );

    return ShopModel.fromJson(response);
  }

  /// Do'konni yangilash
  static Future<ShopModel> updateShop({
    required String shopId,
    String? name,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? phone,
    String? email,
    String? address,
    String? city,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (logoUrl != null) updates['logo_url'] = logoUrl;
    if (bannerUrl != null) updates['banner_url'] = bannerUrl;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (address != null) updates['address'] = address;
    if (city != null) updates['city'] = city;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('shops')
        .update(updates)
        .eq('id', shopId)
        .select()
        .single();

    return ShopModel.fromJson(response);
  }

  // ==================== PRODUCTS ====================

  /// Vendor mahsulotlarini olish
  static Future<List<ProductModel>> getMyProducts({
    String? moderationStatus,
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    var query = _supabase.from('products').select().eq('shop_id', shop.id);

    if (moderationStatus != null) {
      query = query.eq('moderation_status', moderationStatus);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  /// Yangi mahsulot qo'shish
  static Future<ProductModel> createProduct({
    required String nameUz,
    required String nameRu,
    String? descriptionUz,
    String? descriptionRu,
    required double price,
    double? oldPrice,
    required String categoryId,
    String? subcategoryId,
    List<String>? images,
    int stock = 0,
    int? cashbackPercent,
  }) async {
    final shop = await getMyShop();
    if (shop == null) throw Exception('Do\'kon topilmadi');

    final response = await _supabase
        .from('products')
        .insert({
          'shop_id': shop.id,
          'name_uz': nameUz,
          'name_ru': nameRu,
          'description_uz': descriptionUz,
          'description_ru': descriptionRu,
          'price': price,
          'old_price': oldPrice,
          'category_id': categoryId,
          'subcategory_id': subcategoryId,
          'images': images ?? [],
          'stock': stock,
          'cashback_percent': cashbackPercent,
          'moderation_status': 'pending',
          'is_active': false,
        })
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  /// Mahsulotni yangilash
  static Future<ProductModel> updateProduct({
    required String productId,
    String? nameUz,
    String? nameRu,
    String? descriptionUz,
    String? descriptionRu,
    double? price,
    double? oldPrice,
    String? categoryId,
    String? subcategoryId,
    List<String>? images,
    int? stock,
    int? cashbackPercent,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{};
    if (nameUz != null) updates['name_uz'] = nameUz;
    if (nameRu != null) updates['name_ru'] = nameRu;
    if (descriptionUz != null) updates['description_uz'] = descriptionUz;
    if (descriptionRu != null) updates['description_ru'] = descriptionRu;
    if (price != null) updates['price'] = price;
    if (oldPrice != null) updates['old_price'] = oldPrice;
    if (categoryId != null) updates['category_id'] = categoryId;
    if (subcategoryId != null) updates['subcategory_id'] = subcategoryId;
    if (images != null) updates['images'] = images;
    if (stock != null) updates['stock'] = stock;
    if (cashbackPercent != null) updates['cashback_percent'] = cashbackPercent;
    if (isActive != null) updates['is_active'] = isActive;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('products')
        .update(updates)
        .eq('id', productId)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  /// Mahsulotni o'chirish
  static Future<void> deleteProduct(String productId) async {
    await _supabase.from('products').delete().eq('id', productId);
  }

  /// Mahsulotni qayta moderatsiyaga yuborish
  static Future<void> resubmitProduct(String productId) async {
    await _supabase.from('products').update({
      'moderation_status': 'pending',
      'rejection_reason': null,
    }).eq('id', productId);

    await _supabase.from('product_moderation_log').insert({
      'product_id': productId,
      'action': 'resubmitted',
      'previous_status': 'rejected',
      'new_status': 'pending',
    });
  }

  // ==================== ORDERS ====================

  /// Vendor buyurtmalarini olish
  static Future<List<OrderModel>> getMyOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    // Shop mahsulotlariga tegishli buyurtmalarni olish
    var query = _supabase.from('orders').select('''
      *,
      order_items!inner(*, products!inner(shop_id))
    ''').eq('order_items.products.shop_id', shop.id);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  // ==================== PAYOUTS ====================

  /// Vendor to'lovlarini olish
  static Future<List<PayoutModel>> getMyPayouts({
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    final response = await _supabase
        .from('shop_payouts')
        .select()
        .eq('shop_id', shop.id)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => PayoutModel.fromJson(e)).toList();
  }

  /// To'lov so'rovi yuborish
  static Future<PayoutModel> requestPayout({
    required double amount,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? paymentDetails,
    String? notes,
  }) async {
    final shop = await getMyShop();
    if (shop == null) throw Exception('Do\'kon topilmadi');

    if (amount > shop.balance) {
      throw Exception('Yetarli mablag\' mavjud emas');
    }

    // Komissiya hisoblash (standard 0% for payout)
    const commission = 0.0;
    final netAmount = amount - commission;

    final response = await _supabase
        .from('shop_payouts')
        .insert({
          'shop_id': shop.id,
          'amount': amount,
          'commission': commission,
          'net_amount': netAmount,
          'payment_method': paymentMethod.toString().split('.').last,
          'payment_details': paymentDetails,
          'notes': notes,
          'status': 'pending',
        })
        .select()
        .single();

    return PayoutModel.fromJson(response);
  }

  // ==================== COMMISSIONS ====================

  /// Vendor komissiyalarini olish
  static Future<List<CommissionModel>> getMyCommissions({
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    final response = await _supabase
        .from('commissions')
        .select('*, orders(order_number)')
        .eq('shop_id', shop.id)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => CommissionModel.fromJson(e)).toList();
  }

  // ==================== STATISTICS ====================

  /// Vendor statistikasi
  static Future<VendorStatsModel> getMyStats() async {
    final shop = await getMyShop();
    if (shop == null) {
      return VendorStatsModel();
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    // Alohida so'rovlar
    final activeProducts = await _supabase
        .from('products')
        .select()
        .eq('shop_id', shop.id)
        .eq('moderation_status', 'approved')
        .eq('is_active', true)
        .count();

    final pendingProducts = await _supabase
        .from('products')
        .select()
        .eq('shop_id', shop.id)
        .eq('moderation_status', 'pending')
        .count();

    final rejectedProducts = await _supabase
        .from('products')
        .select()
        .eq('shop_id', shop.id)
        .eq('moderation_status', 'rejected')
        .count();

    // Commissions
    final todayCommissions = await _supabase
        .from('commissions')
        .select('order_amount, commission_amount')
        .eq('shop_id', shop.id)
        .gte('created_at', todayStart.toIso8601String());

    final monthlyCommissions = await _supabase
        .from('commissions')
        .select('order_amount, commission_amount')
        .eq('shop_id', shop.id)
        .gte('created_at', monthStart.toIso8601String());

    // Parse results
    double todayRevenue = 0;
    for (var comm in todayCommissions) {
      todayRevenue += (comm['order_amount'] ?? 0).toDouble() -
          (comm['commission_amount'] ?? 0).toDouble();
    }

    double monthlyRevenue = 0;
    double monthlyCommission = 0;
    for (var comm in monthlyCommissions) {
      monthlyRevenue += (comm['order_amount'] ?? 0).toDouble();
      monthlyCommission += (comm['commission_amount'] ?? 0).toDouble();
    }

    return VendorStatsModel(
      balance: shop.balance,
      totalSales: shop.totalSales,
      totalOrders: shop.totalOrders,
      totalProducts:
          activeProducts.count + pendingProducts.count + rejectedProducts.count,
      rating: shop.rating,
      reviewCount: shop.reviewCount,
      todayOrders: todayCommissions.length,
      todayRevenue: todayRevenue,
      monthlyRevenue: monthlyRevenue - monthlyCommission,
      monthlyCommission: monthlyCommission,
      monthlyOrders: monthlyCommissions.length,
      activeProducts: activeProducts.count,
      pendingProducts: pendingProducts.count,
      rejectedProducts: rejectedProducts.count,
    );
  }

  // ==================== ANALYTICS ====================

  /// Vendor analitikasi
  static Future<Map<String, dynamic>> getAnalytics({
    String period = 'week',
  }) async {
    final shop = await getMyShop();
    if (shop == null) return {};

    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    // Get commissions for the period
    final commissions = await _supabase
        .from('commissions')
        .select('order_amount, commission_amount, created_at')
        .eq('shop_id', shop.id)
        .gte('created_at', startDate.toIso8601String())
        .order('created_at');

    double revenue = 0;
    double commission = 0;
    Map<String, double> salesByDay = {};

    for (var c in commissions) {
      final orderAmount = (c['order_amount'] ?? 0).toDouble();
      final commissionAmount = (c['commission_amount'] ?? 0).toDouble();
      revenue += orderAmount;
      commission += commissionAmount;

      final date = DateTime.parse(c['created_at']);
      final dayKey = '${date.month}/${date.day}';
      salesByDay[dayKey] =
          (salesByDay[dayKey] ?? 0) + orderAmount - commissionAmount;
    }

    // Get top products
    final topProductsResponse = await _supabase
        .from('products')
        .select('id, name_uz, sold_count, price')
        .eq('shop_id', shop.id)
        .order('sold_count', ascending: false)
        .limit(5);

    final topProducts = (topProductsResponse as List)
        .map((p) => {
              'name': p['name_uz'],
              'sold': p['sold_count'] ?? 0,
              'revenue':
                  ((p['sold_count'] ?? 0) * (p['price'] ?? 0)).toDouble(),
            })
        .toList();

    // Get order stats
    final orders = await _supabase
        .from('orders')
        .select('status, order_items!inner(products!inner(shop_id))')
        .eq('order_items.products.shop_id', shop.id)
        .gte('created_at', startDate.toIso8601String());

    int pendingOrders = 0;
    int processingOrders = 0;
    int completedOrders = 0;
    int cancelledOrders = 0;

    for (var order in orders) {
      switch (order['status']) {
        case 'pending':
          pendingOrders++;
          break;
        case 'confirmed':
        case 'preparing':
        case 'ready':
        case 'delivering':
          processingOrders++;
          break;
        case 'delivered':
          completedOrders++;
          break;
        case 'cancelled':
          cancelledOrders++;
          break;
      }
    }

    return {
      'revenue': revenue,
      'commission': commission,
      'netRevenue': revenue - commission,
      'orders': commissions.length,
      'salesByDay': salesByDay.entries
          .map((e) => {
                'label': e.key,
                'amount': e.value,
              })
          .toList(),
      'topProducts': topProducts,
      'pendingOrders': pendingOrders,
      'processingOrders': processingOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
    };
  }

  // ==================== IMAGE UPLOAD ====================

  /// Rasm yuklash
  static Future<String> uploadImage(
    String filePath,
    String fileName,
  ) async {
    final shop = await getMyShop();
    if (shop == null) throw Exception('Do\'kon topilmadi');

    final path = 'shops/${shop.id}/$fileName';

    await _supabase.storage.from('products').upload(
          path,
          // File handling would go here
          filePath as dynamic,
        );

    return _supabase.storage.from('products').getPublicUrl(path);
  }
}
