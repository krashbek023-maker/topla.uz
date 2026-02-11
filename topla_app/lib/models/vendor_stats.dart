/// Vendor stats modeli - IVendorRepository da ishlatiladigan
class VendorStats {
  final String? shopId;
  final String? shopName;
  final double balance;
  final int totalProducts;
  final int activeProducts;
  final int pendingProducts;
  final int todayOrders;
  final double todayRevenue;
  final int monthlyOrders;
  final double monthlyRevenue;
  final double rating;

  VendorStats({
    this.shopId,
    this.shopName,
    this.balance = 0,
    this.totalProducts = 0,
    this.activeProducts = 0,
    this.pendingProducts = 0,
    this.todayOrders = 0,
    this.todayRevenue = 0,
    this.monthlyOrders = 0,
    this.monthlyRevenue = 0,
    this.rating = 0,
  });

  factory VendorStats.fromJson(Map<String, dynamic> json) {
    // Backend returns nested: {balance, orders: {total, today, month}, products: {total, active}, revenue: {total, today, month}}
    final orders = json['orders'] as Map<String, dynamic>?;
    final products = json['products'] as Map<String, dynamic>?;
    final revenue = json['revenue'] as Map<String, dynamic>?;

    return VendorStats(
      shopId: json['shop_id'] ?? json['shopId'],
      shopName: json['shop_name'] ?? json['shopName'],
      balance: (json['balance'] ?? 0).toDouble(),
      totalProducts: products?['total'] ?? json['total_products'] ?? 0,
      activeProducts: products?['active'] ?? json['active_products'] ?? 0,
      pendingProducts: products?['inactive'] ?? json['pending_products'] ?? 0,
      todayOrders: orders?['today'] ?? json['today_orders'] ?? 0,
      todayRevenue:
          (revenue?['today'] ?? json['today_revenue'] ?? 0).toDouble(),
      monthlyOrders: orders?['month'] ?? json['monthly_orders'] ?? 0,
      monthlyRevenue:
          (revenue?['month'] ?? json['monthly_revenue'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  String get formattedBalance => '${balance.toStringAsFixed(0)} so\'m';
  String get formattedTodayRevenue =>
      '${todayRevenue.toStringAsFixed(0)} so\'m';
  String get formattedMonthlyRevenue =>
      '${monthlyRevenue.toStringAsFixed(0)} so\'m';
}

/// Vendor statistika modeli - VendorService uchun
class VendorStatsModel {
  final double balance;
  final double totalSales;
  final int totalOrders;
  final int totalProducts;
  final double rating;
  final int reviewCount;
  final int todayOrders;
  final double todayRevenue;
  final double monthlyRevenue;
  final double monthlyCommission;
  final int monthlyOrders;
  final int activeProducts;
  final int pendingProducts;
  final int rejectedProducts;

  VendorStatsModel({
    this.balance = 0,
    this.totalSales = 0,
    this.totalOrders = 0,
    this.totalProducts = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.todayOrders = 0,
    this.todayRevenue = 0,
    this.monthlyRevenue = 0,
    this.monthlyCommission = 0,
    this.monthlyOrders = 0,
    this.activeProducts = 0,
    this.pendingProducts = 0,
    this.rejectedProducts = 0,
  });

  String get formattedBalance => '${balance.toStringAsFixed(0)} so\'m';
  String get formattedTodayRevenue =>
      '${todayRevenue.toStringAsFixed(0)} so\'m';
  String get formattedMonthlyRevenue =>
      '${monthlyRevenue.toStringAsFixed(0)} so\'m';
  String get formattedTotalSales => '${totalSales.toStringAsFixed(0)} so\'m';
  String get formattedRating => rating.toStringAsFixed(1);
}
