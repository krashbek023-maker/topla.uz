import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/repositories/repositories.dart';
import '../../models/models.dart';

/// Supabase bilan Cart operatsiyalari implementatsiyasi
class CartRepositoryImpl implements ICartRepository {
  final SupabaseClient _client;
  final String? Function() _getCurrentUserId;

  CartRepositoryImpl(this._client, this._getCurrentUserId);

  String? get _userId => _getCurrentUserId();

  @override
  Future<List<CartItemModel>> getCart() async {
    if (_userId == null) return [];

    final response = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', _userId!);

    return (response as List)
        .map((json) => CartItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> addToCart(String productId, {int quantity = 1}) async {
    if (_userId == null) throw Exception('Tizimga kiring');

    // Mavjud mahsulotni tekshirish
    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', _userId!)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Mavjud bo'lsa, miqdorni yangilash
      final newQuantity = (existing['quantity'] as int) + quantity;
      await _client
          .from('cart_items')
          .update({'quantity': newQuantity}).eq('id', existing['id']);
    } else {
      // Yangi qo'shish
      await _client.from('cart_items').insert({
        'user_id': _userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  @override
  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    await _client.from('cart_items').update({
      'quantity': quantity,
    }).eq('id', cartItemId);
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  @override
  Future<void> clearCart() async {
    if (_userId == null) return;
    await _client.from('cart_items').delete().eq('user_id', _userId!);
  }

  @override
  Stream<List<CartItemModel>> watchCart() {
    if (_userId == null) return Stream.value([]);

    return _client
        .from('cart_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .map((data) =>
            data.map((json) => CartItemModel.fromJson(json)).toList());
  }

  @override
  Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    if (_userId == null) throw Exception('Tizimga kiring');

    final response = await _client
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

    // Foydalanuvchi limiti tekshirish
    final userUsage = await _client
        .from('promo_code_usage')
        .select()
        .eq('promo_code_id', response['id'])
        .eq('user_id', _userId!);

    final userLimit = response['per_user_limit'] ?? 1;
    if ((userUsage as List).length >= userLimit) {
      return null;
    }

    return {
      'id': response['id'],
      'code': response['code'],
      'discount_type': response['discount_type'],
      'discount_value': response['discount_value'],
      'min_order_amount': response['min_order_amount'],
      'max_discount': response['max_discount'],
    };
  }
}
