/// Kuryer operatsiyalari uchun interface (Yandex Go uslubi)
abstract class ICourierRepository {
  // ==================== STATUS ====================

  /// Kuryer sifatida ro'yxatdan o'tish
  Future<void> registerAsCourier({
    required String vehicleType,
    String? vehicleNumber,
    double maxDistance,
  });

  /// Kuryer profilini olish
  Future<Map<String, dynamic>?> getCourierProfile();

  /// Online/Offline holatini o'zgartirish
  Future<void> setOnlineStatus(bool isOnline);

  /// GPS joylashuvni yangilash
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  });

  // ==================== ORDERS ====================

  /// Mavjud yetkazib berish buyurtmalari
  Future<List<Map<String, dynamic>>> getAvailableOrders();

  /// Faol buyurtma
  Future<Map<String, dynamic>?> getActiveOrder();

  /// Buyurtmalar tarixi
  Future<List<Map<String, dynamic>>> getOrderHistory({
    int limit = 20,
    int offset = 0,
  });

  /// Buyurtmani qabul qilish
  Future<void> acceptOrder(String assignmentId);

  /// Buyurtmani rad etish
  Future<void> rejectOrder(String assignmentId);

  /// Buyurtmani olib oldim (picked up)
  Future<void> markPickedUp(String orderId);

  /// Yetkazib berishni boshladim
  Future<void> startDelivery(String orderId);

  /// Yetkazib berdim (delivered)
  Future<void> markDelivered(String orderId);

  // ==================== EARNINGS ====================

  /// Daromad statistikasi
  Future<Map<String, dynamic>> getEarnings({String? period});

  // ==================== TRACKING ====================

  /// Buyurtma joylashuvini kuzatish (mijoz uchun)
  Future<Map<String, dynamic>?> trackOrder(String orderId);
}
