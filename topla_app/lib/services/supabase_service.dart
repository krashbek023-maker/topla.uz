import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../core/utils/app_logger.dart';
import '../models/models.dart';

/// Supabase bilan ishlash uchun asosiy servis
class SupabaseService {
  static const _tag = 'SupabaseService';
  static SupabaseClient get client => Supabase.instance.client;

  // ==================== AUTH ====================

  /// Joriy Supabase foydalanuvchisi
  static User? get currentUser => client.auth.currentUser;

  /// Firebase foydalanuvchisi
  static firebase.User? get firebaseUser =>
      firebase.FirebaseAuth.instance.currentUser;

  /// Tizimga kirganmi (Firebase yoki Supabase)
  static bool get isLoggedIn => currentUser != null || firebaseUser != null;

  /// Hozirgi user ID (Firebase yoki Supabase)
  static String? get currentUserId {
    if (firebaseUser != null) return firebaseUser!.uid;
    if (currentUser != null) return currentUser!.id;
    return null;
  }

  /// Telefon orqali OTP yuborish (Twilio kerak)
  static Future<void> sendOTP(String phone) async {
    await client.auth.signInWithOtp(
      phone: phone,
      shouldCreateUser: true,
    );
  }

  /// OTP ni tasdiqlash
  static Future<AuthResponse> verifyOTP(String phone, String otp) async {
    return await client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  /// Email + Password bilan ro'yxatdan o'tish
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Email + Password bilan kirish
  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Parolni tiklash (email yuborish)
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Google orqali kirish
  static Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  }

  /// Chiqish
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ==================== CATEGORIES ====================

  /// Barcha kategoriyalarni olish
  static Future<List<CategoryModel>> getCategories() async {
    final response = await client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  /// Kategoriya bo'yicha sub-kategoriyalar
  static Future<List<CategoryModel>> getSubCategories(String parentId) async {
    final response = await client
        .from('categories')
        .select()
        .eq('parent_id', parentId)
        .eq('is_active', true)
        .order('sort_order');

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  // ==================== PRODUCTS ====================

  /// Barcha mahsulotlarni olish
  static Future<List<ProductModel>> getProducts({
    String? categoryId,
    bool? isFeatured,
    bool? isFlashSale,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = client.from('products').select().eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }
    if (isFlashSale != null) {
      query = query.eq('is_flash_sale', isFlashSale);
    }
    if (search != null && search.isNotEmpty) {
      query = query.or('name_uz.ilike.%$search%,name_ru.ilike.%$search%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  /// Bitta mahsulotni olish
  static Future<ProductModel?> getProduct(String id) async {
    final response =
        await client.from('products').select().eq('id', id).single();

    return ProductModel.fromJson(response);
  }

  /// Tavsiya etilgan mahsulotlar
  static Future<List<ProductModel>> getFeaturedProducts() async {
    return getProducts(isFeatured: true, limit: 10);
  }

  /// Flash sale mahsulotlar
  static Future<List<ProductModel>> getFlashSaleProducts() async {
    return getProducts(isFlashSale: true, limit: 10);
  }

  // ==================== BANNERS ====================

  /// Bannerlarni olish
  static Future<List<BannerModel>> getBanners() async {
    final response = await client
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return (response as List)
        .map((json) => BannerModel.fromJson(json))
        .toList();
  }

  // ==================== CART ====================

  /// Savatni olish
  static Future<List<CartItemModel>> getCart() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => CartItemModel.fromJson(json))
        .toList();
  }

  /// Savatga qo'shish
  static Future<void> addToCart(String productId, {int quantity = 1}) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    await client.from('cart_items').upsert({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    }, onConflict: 'user_id,product_id');
  }

  /// Savat miqdorini yangilash
  static Future<void> updateCartQuantity(
      String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    await client.from('cart_items').update({
      'quantity': quantity,
    }).eq('id', cartItemId);
  }

  /// Savatdan o'chirish
  static Future<void> removeFromCart(String cartItemId) async {
    await client.from('cart_items').delete().eq('id', cartItemId);
  }

  /// Savatni tozalash
  static Future<void> clearCart() async {
    final userId = currentUserId;
    if (userId == null) return;
    await client.from('cart_items').delete().eq('user_id', userId);
  }

  // ==================== FAVORITES ====================

  /// Sevimlilarni olish
  static Future<List<ProductModel>> getFavorites() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('favorites')
        .select('product_id, products(*)')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => ProductModel.fromJson(json['products']))
        .toList();
  }

  /// Sevimlilar ro'yxatida bormi
  static Future<bool> isFavorite(String productId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final response = await client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    return response != null;
  }

  /// Sevimlilarga qo'shish/o'chirish
  static Future<bool> toggleFavorite(String productId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    final isFav = await isFavorite(productId);

    if (isFav) {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
      return false;
    } else {
      await client.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });
      return true;
    }
  }

  // ==================== PROFILE ====================

  /// Profil ma'lumotlarini olish
  static Future<UserProfile?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response =
        await client.from('profiles').select().eq('id', userId).maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Profil yaratish/yangilash
  static Future<void> upsertProfile(UserProfile profile) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    await client.from('profiles').upsert(profile.toJson());
  }

  /// Profilni yangilash (sodda)
  static Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    final updates = <String, dynamic>{
      'id': userId,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;

    await client.from('profiles').upsert(updates);
  }

  // ==================== ORDERS ====================

  /// Buyurtmalarni olish
  static Future<List<OrderModel>> getOrders({String? status}) async {
    final userId = currentUserId;
    if (userId == null) return [];

    var query =
        client.from('orders').select('*, order_items(*)').eq('user_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => OrderModel.fromJson(json)).toList();
  }

  /// Buyurtma yaratish
  static Future<OrderModel?> createOrder({
    required String addressId,
    required String paymentMethod,
    required String deliveryTime,
    DateTime? scheduledDate,
    String? scheduledTimeSlot,
    String? comment,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    double cashbackUsed = 0,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    final total = subtotal + deliveryFee - discount - cashbackUsed;

    // Buyurtma yaratish
    final orderResponse = await client
        .from('orders')
        .insert({
          'user_id': userId,
          'address_id': addressId,
          'subtotal': subtotal,
          'delivery_fee': deliveryFee,
          'discount': discount,
          'cashback_used': cashbackUsed,
          'total': total,
          'payment_method': paymentMethod,
          'delivery_date': scheduledDate?.toIso8601String(),
          'delivery_time_slot': scheduledTimeSlot,
          'notes': comment,
        })
        .select()
        .single();

    final orderId = orderResponse['id'];

    // Buyurtma elementlarini yaratish
    final orderItems = items
        .map((item) => {
              'order_id': orderId,
              'product_id': item['product_id'],
              'product_name': item['name'] ?? 'Mahsulot',
              'product_image': item['image'],
              'price': item['price'],
              'quantity': item['quantity'],
              'total': (item['price'] as num) * (item['quantity'] as num),
            })
        .toList();

    await client.from('order_items').insert(orderItems);

    // Savatni tozalash
    await clearCart();

    // Yangilangan buyurtmani qaytarish
    final fullOrder = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();

    return OrderModel.fromJson(fullOrder);
  }

  /// Bitta buyurtmani olish
  static Future<OrderModel?> getOrderById(String orderId) async {
    final response = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();

    return OrderModel.fromJson(response);
  }

  /// Buyurtmani bekor qilish
  static Future<void> cancelOrder(String orderId) async {
    await client
        .from('orders')
        .update({'status': 'cancelled'}).eq('id', orderId);
  }

  // ==================== ADDRESSES ====================

  /// Manzillarni olish
  static Future<List<AddressModel>> getAddresses() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AddressModel.fromJson(json))
        .toList();
  }

  /// Yangi manzil yaratish
  static Future<AddressModel?> createAddress({
    required String title,
    required String address,
    String? apartment,
    String? entrance,
    String? floor,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    AppLogger.d(_tag, 'createAddress: userId=$userId, title=$title');

    try {
      // Agar yangi manzil asosiy bo'lsa, boshqalarni yangilash
      if (isDefault) {
        await client
            .from('addresses')
            .update({'is_default': false}).eq('user_id', userId);
      }

      final insertData = {
        'user_id': userId,
        'title': title,
        'full_address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };

      final response =
          await client.from('addresses').insert(insertData).select().single();

      AppLogger.d(_tag, 'Address created successfully');

      return AddressModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e(_tag, 'createAddress error', e, stackTrace);
      rethrow;
    }
  }

  /// Manzilni yangilash
  static Future<void> updateAddress({
    required String id,
    required String title,
    required String address,
    String? apartment,
    String? entrance,
    String? floor,
    double? latitude,
    double? longitude,
  }) async {
    await client.from('addresses').update({
      'title': title,
      'full_address': address,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Manzilni o'chirish
  static Future<void> deleteAddress(String id) async {
    await client.from('addresses').delete().eq('id', id);
  }

  /// Asosiy manzil qilish
  static Future<void> setDefaultAddress(String id) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    // Avval barcha manzillarni asosiy emas qilish
    await client
        .from('addresses')
        .update({'is_default': false}).eq('user_id', userId);

    // Keyin tanlangan manzilni asosiy qilish
    await client.from('addresses').update({'is_default': true}).eq('id', id);
  }

  // ==================== PROMO CODES ====================

  /// Promo kodni tekshirish
  static Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    final response = await client
        .from('promo_codes')
        .select()
        .eq('code', code.toUpperCase())
        .eq('is_active', true)
        .gte('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();

    if (response == null) return null;

    // Ishlatilish limitini tekshirish
    final usageCount = response['usage_count'] ?? 0;
    final usageLimit = response['usage_limit'];
    if (usageLimit != null && usageCount >= usageLimit) {
      return null;
    }

    // Foydalanuvchi limiti tekshirish (userId yuqorida aniqlangan)
    final userUsage = await client
        .from('promo_code_usage')
        .select()
        .eq('promo_code_id', response['id'])
        .eq('user_id', userId);

    final userLimit = response['per_user_limit'] ?? 1;
    if ((userUsage as List).length >= userLimit) {
      return null;
    }

    return {
      'id': response['id'],
      'code': response['code'],
      'discount_type': response['discount_type'], // percent, fixed
      'discount_value': response['discount_value'],
      'min_order_amount': response['min_order_amount'],
      'max_discount': response['max_discount'],
    };
  }

  /// Promo kodni ishlatish
  static Future<void> usePromoCode(String promoCodeId, String orderId) async {
    if (!isLoggedIn) throw Exception('Tizimga kiring');

    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    // Promo kod ishlatilganini qayd qilish
    await client.from('promo_code_usage').insert({
      'promo_code_id': promoCodeId,
      'user_id': userId,
      'order_id': orderId,
    });

    // Ishlatilish sonini oshirish
    await client
        .rpc('increment_promo_usage', params: {'promo_id': promoCodeId});
  }

  // ==================== REAL-TIME STREAMS ====================

  /// Buyurtmalar real-time stream
  static Stream<List<Map<String, dynamic>>> ordersStream() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();

    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  /// Savat real-time stream
  static Stream<List<Map<String, dynamic>>> cartStream() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();

    return client
        .from('cart_items')
        .stream(primaryKey: ['id']).eq('user_id', userId);
  }

  /// Bildirishnomalar real-time stream
  static Stream<List<Map<String, dynamic>>> notificationsStream() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();

    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  /// Mahsulotlar real-time stream (yangi va tasdiqlangan mahsulotlar)
  static Stream<List<Map<String, dynamic>>> productsStream() {
    return client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('moderation_status', 'approved')
        .order('created_at', ascending: false);
  }

  /// Real-time channel yaratish (custom events uchun)
  static RealtimeChannel createChannel(String name) {
    return client.channel(name);
  }

  /// Channel ni o'chirish
  static Future<void> removeChannel(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
