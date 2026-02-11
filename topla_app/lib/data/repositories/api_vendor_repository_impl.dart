import '../../core/repositories/i_vendor_repository.dart';
import '../../core/services/api_client.dart';
import '../../models/models.dart';

/// Vendor repository - Node.js backend implementation
class ApiVendorRepositoryImpl implements IVendorRepository {
  final ApiClient _api;

  ApiVendorRepositoryImpl(this._api);

  // ==================== SHOP ====================

  @override
  Future<ShopModel?> getMyShop() async {
    try {
      final response = await _api.get('/vendor/shop');
      return ShopModel.fromJson(response.dataMap);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
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
    final response = await _api.post('/vendor/shop', body: {
      'name': name,
      if (description != null) 'description': description,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
    });
    return ShopModel.fromJson(response.dataMap);
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
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (logoUrl != null) body['logoUrl'] = logoUrl;
    if (bannerUrl != null) body['bannerUrl'] = bannerUrl;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;
    if (address != null) body['address'] = address;
    if (city != null) body['city'] = city;

    final response = await _api.put('/vendor/shop', body: body);
    return ShopModel.fromJson(response.dataMap);
  }

  // ==================== PRODUCTS ====================

  @override
  Future<List<ProductModel>> getMyProducts({
    String? moderationStatus,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (moderationStatus != null) params['moderationStatus'] = moderationStatus;

    final response = await _api.get('/vendor/products', queryParams: params);
    return response
        .nestedList('products')
        .map((e) => ProductModel.fromJson(e))
        .toList();
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
    final response = await _api.post('/vendor/products', body: {
      'name': nameUz,
      'nameRu': nameRu,
      if (descriptionUz != null) 'description': descriptionUz,
      if (descriptionRu != null) 'descriptionRu': descriptionRu,
      'price': price,
      if (oldPrice != null) 'originalPrice': oldPrice,
      'categoryId': categoryId,
      if (images != null) 'images': images,
      'stock': stock,
      if (cashbackPercent != null) 'cashbackPercent': cashbackPercent,
    });
    return ProductModel.fromJson(response.dataMap);
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
    final body = <String, dynamic>{};
    if (nameUz != null) body['name'] = nameUz;
    if (nameRu != null) body['nameRu'] = nameRu;
    if (descriptionUz != null) body['description'] = descriptionUz;
    if (descriptionRu != null) body['descriptionRu'] = descriptionRu;
    if (price != null) body['price'] = price;
    if (oldPrice != null) body['originalPrice'] = oldPrice;
    if (categoryId != null) body['categoryId'] = categoryId;
    if (images != null) body['images'] = images;
    if (stock != null) body['stock'] = stock;
    if (cashbackPercent != null) body['cashbackPercent'] = cashbackPercent;

    final response = await _api.put('/vendor/products/$productId', body: body);
    return ProductModel.fromJson(response.dataMap);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _api.delete('/vendor/products/$productId');
  }

  // ==================== ORDERS ====================

  @override
  Future<List<OrderModel>> getMyOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (status != null) params['status'] = status;

    final response = await _api.get('/vendor/orders', queryParams: params);
    return response
        .nestedList('orders')
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _api.put('/vendor/orders/$orderId/status', body: {
      'status': status.name,
    });
  }

  // ==================== PAYOUTS ====================

  @override
  Future<List<PayoutModel>> getMyPayouts({
    PayoutStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (status != null) params['status'] = status.name;

    final response = await _api.get('/vendor/payouts', queryParams: params);
    return response
        .nestedList('payouts')
        .map((e) => PayoutModel.fromJson(e))
        .toList();
  }

  @override
  Future<PayoutModel> requestPayout({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    String? notes,
  }) async {
    final response = await _api.post('/vendor/payouts', body: {
      'amount': amount,
      'cardNumber': accountNumber,
    });
    return PayoutModel.fromJson(response.dataMap);
  }

  // ==================== STATS ====================

  @override
  Future<VendorStats> getMyStats() async {
    final response = await _api.get('/vendor/stats');
    return VendorStats.fromJson(response.dataMap);
  }

  @override
  Future<List<CommissionModel>> getCommissionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _api.get(
      '/vendor/commissions',
      queryParams: {'limit': limit, 'offset': offset},
    );
    return response
        .nestedList('transactions')
        .map((e) => CommissionModel.fromJson(e))
        .toList();
  }
}
