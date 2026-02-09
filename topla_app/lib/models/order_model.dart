/// Buyurtma modeli
class OrderModel {
  final String id;
  final String orderNumber;
  final String? userId;
  final String? addressId;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double cashbackUsed;
  final double total;
  final String? paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final String? notes;
  final String? recipientName;
  final String? recipientPhone;
  final String? deliveryMethod;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.userId,
    this.addressId,
    this.status = OrderStatus.pending,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount = 0,
    this.cashbackUsed = 0,
    required this.total,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.notes,
    this.recipientName,
    this.recipientPhone,
    this.deliveryMethod,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as String?,
      addressId: json['address_id'] as String?,
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      cashbackUsed: (json['cashback_used'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: PaymentStatus.fromString(
          json['payment_status'] as String? ?? 'pending'),
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : null,
      deliveryTimeSlot: json['delivery_time_slot'] as String?,
      notes: json['notes'] as String?,
      recipientName: json['recipient_name'] as String?,
      recipientPhone: json['recipient_phone'] as String?,
      deliveryMethod: json['delivery_method'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      items: json['order_items'] != null
          ? (json['order_items'] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList()
          : [],
    );
  }
}

/// Buyurtma elementi
class OrderItemModel {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double total;

  OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
    );
  }
}

/// Buyurtma holati
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipping,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get nameUz {
    switch (this) {
      case OrderStatus.pending:
        return 'Kutilmoqda';
      case OrderStatus.confirmed:
        return 'Tasdiqlangan';
      case OrderStatus.processing:
        return 'Tayyorlanmoqda';
      case OrderStatus.shipping:
        return 'Yetkazilmoqda';
      case OrderStatus.delivered:
        return 'Yetkazildi';
      case OrderStatus.cancelled:
        return 'Bekor qilindi';
    }
  }

  String get nameRu {
    switch (this) {
      case OrderStatus.pending:
        return 'Ожидает';
      case OrderStatus.confirmed:
        return 'Подтвержден';
      case OrderStatus.processing:
        return 'Готовится';
      case OrderStatus.shipping:
        return 'Доставляется';
      case OrderStatus.delivered:
        return 'Доставлен';
      case OrderStatus.cancelled:
        return 'Отменен';
    }
  }
}

/// To'lov holati
enum PaymentStatus {
  pending,
  paid,
  failed;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
