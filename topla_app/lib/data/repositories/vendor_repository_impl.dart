import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/repositories/repositories.dart';
import '../../models/models.dart';

/// Supabase bilan Vendor operatsiyalari implementatsiyasi
class VendorRepositoryImpl implements IVendorRepository {
  final SupabaseClient _client;
  final String? Function() _getCurrentUserId;

  VendorRepositoryImpl(this._client, this._getCurrentUserId);

  String? get _userId => _getCurrentUserId();

  // ==================== SHOP ====================

  @override
  Future<ShopModel?> getMyShop() async {
    if (_userId == null) return null;

    final response = await _client
        .from('shops')
        .select()
        .eq('owner_id', _userId!)
        .maybeSingle();

    if (response == null) return null;
    return ShopModel.fromJson(response);
  }

  @override
  Future<ShopModel> createShop({
    required String name,
    String? description,
    String? logoUrl,
    String? phone,
    String? email,
    String? address,
    String? city,
  }) async {
    if (_userId == null) throw Exception('Foydalanuvchi topilmadi');

    final response = await _client
        .from('shops')
        .insert({
          'owner_id': _userId,
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
    await _client
        .from('profiles')
        .update({'role': 'vendor'}).eq('id', _userId!);

    return ShopModel.fromJson(response);
  }

  @override
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

    final response = await _client
        .from('shops')
        .update(updates)
        .eq('id', shopId)
        .select()
        .single();

    return ShopModel.fromJson(response);
  }

  // ==================== PRODUCTS ====================

  @override
  Future<List<ProductModel>> getMyProducts({
    String? moderationStatus,
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    var query = _client.from('products').select().eq('shop_id', shop.id);

    if (moderationStatus != null) {
      query = query.eq('moderation_status', moderationStatus);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
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
  }) async {
    final shop = await getMyShop();
    if (shop == null) throw Exception('Do\'kon topilmadi');

    final response = await _client
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

  @override
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
  }) async {
    final updates = <String, dynamic>{};
    if (nameUz != null) updates['name_uz'] = nameUz;
    if (nameRu != null) updates['name_ru'] = nameRu;
    if (descriptionUz != null) updates['description_uz'] = descriptionUz;
    if (descriptionRu != null) updates['description_ru'] = descriptionRu;
    if (price != null) updates['price'] = price;
    if (oldPrice != null) updates['old_price'] = oldPrice;
    if (categoryId != null) updates['category_id'] = categoryId;
    if (images != null) updates['images'] = images;
    if (stock != null) updates['stock'] = stock;
    if (cashbackPercent != null) updates['cashback_percent'] = cashbackPercent;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from('products')
        .update(updates)
        .eq('id', productId)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }

  // ==================== ORDERS ====================

  @override
  Future<List<OrderModel>> getMyOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    var query = _client.from('orders').select('''
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

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _client
        .from('orders')
        .update({'status': status.name}).eq('id', orderId);
  }

  // ==================== PAYOUTS ====================

  @override
  Future<List<PayoutModel>> getMyPayouts({
    PayoutStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    var query = _client.from('shop_payouts').select().eq('shop_id', shop.id);

    if (status != null) {
      query = query.eq('status', status.toString().split('.').last);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => PayoutModel.fromJson(e)).toList();
  }

  @override
  Future<PayoutModel> requestPayout({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    String? notes,
  }) async {
    final shop = await getMyShop();
    if (shop == null) throw Exception('Do\'kon topilmadi');

    if (amount > shop.balance) {
      throw Exception('Yetarli mablag\' mavjud emas');
    }

    const commission = 0.0;
    final netAmount = amount - commission;

    final response = await _client
        .from('shop_payouts')
        .insert({
          'shop_id': shop.id,
          'amount': amount,
          'commission': commission,
          'net_amount': netAmount,
          'payment_details': {
            'bank_name': bankName,
            'account_number': accountNumber,
            'account_holder': accountHolder,
          },
          'notes': notes,
          'status': 'pending',
        })
        .select()
        .single();

    return PayoutModel.fromJson(response);
  }

  // ==================== STATS ====================

  @override
  Future<VendorStats> getMyStats() async {
    final shop = await getMyShop();
    if (shop == null) {
      return VendorStats();
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    final activeProducts = await _client
        .from('products')
        .select()
        .eq('shop_id', shop.id)
        .eq('moderation_status', 'approved')
        .eq('is_active', true)
        .count();

    final pendingProducts = await _client
        .from('products')
        .select()
        .eq('shop_id', shop.id)
        .eq('moderation_status', 'pending')
        .count();

    final totalProducts =
        await _client.from('products').select().eq('shop_id', shop.id).count();

    // Order stats
    final todayOrders = await _client
        .from('orders')
        .select('*, order_items!inner(products!inner(shop_id))')
        .eq('order_items.products.shop_id', shop.id)
        .gte('created_at', todayStart.toIso8601String());

    final monthlyOrders = await _client
        .from('orders')
        .select('*, order_items!inner(products!inner(shop_id))')
        .eq('order_items.products.shop_id', shop.id)
        .gte('created_at', monthStart.toIso8601String());

    double todayRevenue = 0;
    for (var order in todayOrders) {
      todayRevenue += (order['total'] ?? 0).toDouble();
    }

    double monthlyRevenue = 0;
    for (var order in monthlyOrders) {
      monthlyRevenue += (order['total'] ?? 0).toDouble();
    }

    return VendorStats(
      shopId: shop.id,
      shopName: shop.name,
      balance: shop.balance,
      totalProducts: totalProducts.count,
      activeProducts: activeProducts.count,
      pendingProducts: pendingProducts.count,
      todayOrders: todayOrders.length,
      todayRevenue: todayRevenue,
      monthlyOrders: monthlyOrders.length,
      monthlyRevenue: monthlyRevenue,
      rating: shop.rating,
    );
  }

  @override
  Future<List<CommissionModel>> getCommissionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    final shop = await getMyShop();
    if (shop == null) return [];

    final response = await _client
        .from('commissions')
        .select('*, orders(order_number)')
        .eq('shop_id', shop.id)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => CommissionModel.fromJson(e)).toList();
  }
}
