import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/repositories/repositories.dart';
import '../../models/models.dart';

/// Supabase bilan Order operatsiyalari implementatsiyasi
class OrderRepositoryImpl implements IOrderRepository {
  final SupabaseClient _client;
  final String? Function() _getCurrentUserId;

  OrderRepositoryImpl(this._client, this._getCurrentUserId);

  String? get _userId => _getCurrentUserId();

  @override
  Future<List<OrderModel>> getOrders({String? status}) async {
    if (_userId == null) return [];

    var query = _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', _userId!);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return OrderModel.fromJson(response);
  }

  @override
  Future<OrderModel?> createOrder({
    required String addressId,
    required String paymentMethod,
    required String deliveryTime,
    DateTime? scheduledDate,
    String? scheduledTimeSlot,
    String? comment,
    String? recipientName,
    String? recipientPhone,
    String? deliveryMethod,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    double cashbackUsed = 0,
  }) async {
    if (_userId == null) throw Exception('Tizimga kiring');

    // Stock tekshiruvi
    for (final item in items) {
      final productId = item['product_id'];
      final quantity = item['quantity'] as int;
      final product = await _client
          .from('products')
          .select('stock, name_uz')
          .eq('id', productId)
          .maybeSingle();

      if (product == null) {
        throw Exception('Mahsulot topilmadi');
      }

      final stock = product['stock'] as int? ?? 0;
      if (stock < quantity) {
        final name = product['name_uz'] ?? 'Mahsulot';
        throw Exception('"$name" mahsuloti yetarli emas. Mavjud: $stock dona');
      }
    }

    final total = subtotal + deliveryFee - discount - cashbackUsed;

    // Buyurtma yaratish
    final orderData = <String, dynamic>{
      'user_id': _userId,
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
    };

    // Yangi maydonlar (DB da ustunlar bo'lmasa xatolik chiqmasligi uchun)
    if (recipientName != null) orderData['recipient_name'] = recipientName;
    if (recipientPhone != null) orderData['recipient_phone'] = recipientPhone;
    if (deliveryMethod != null) orderData['delivery_method'] = deliveryMethod;

    final orderResponse =
        await _client.from('orders').insert(orderData).select().single();

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

    await _client.from('order_items').insert(orderItems);

    // Stock'ni kamaytirish
    for (final item in items) {
      final productId = item['product_id'];
      final quantity = item['quantity'] as int;
      await _client.rpc('decrement_stock', params: {
        'p_product_id': productId,
        'p_quantity': quantity,
      }).catchError((_) {
        // RPC mavjud bo'lmasa, oddiy update
        return _client
            .from('products')
            .select('stock')
            .eq('id', productId)
            .single()
            .then((p) async {
          final currentStock = p['stock'] as int? ?? 0;
          await _client
              .from('products')
              .update({'stock': currentStock - quantity}).eq('id', productId);
        });
      });
    }

    // To'liq buyurtmani qaytarish
    return getOrderById(orderId);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    // Buyurtma elementlarini olish (stock qaytarish uchun)
    final orderItems = await _client
        .from('order_items')
        .select('product_id, quantity')
        .eq('order_id', orderId);

    // Buyurtmani bekor qilish
    await _client.from('orders').update({
      'status': 'cancelled',
    }).eq('id', orderId);

    // Stock'ni qaytarish
    for (final item in orderItems as List) {
      final productId = item['product_id'];
      if (productId == null) continue;
      final quantity = item['quantity'] as int;
      try {
        final product = await _client
            .from('products')
            .select('stock')
            .eq('id', productId)
            .maybeSingle();
        if (product != null) {
          final currentStock = product['stock'] as int? ?? 0;
          await _client
              .from('products')
              .update({'stock': currentStock + quantity}).eq('id', productId);
        }
      } catch (_) {
        // Stock qaytarishda xatolik bo'lsa, davom etamiz
      }
    }
  }

  @override
  Future<void> updatePaymentStatus(String orderId, String status) async {
    await _client.from('orders').update({
      'payment_status': status,
    }).eq('id', orderId);
  }

  @override
  Stream<List<OrderModel>> watchOrders() {
    if (_userId == null) return Stream.value([]);

    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .map((data) => data.map((json) => OrderModel.fromJson(json)).toList());
  }
}
