import 'package:topla_app/models/models.dart';

/// Filtrlangan mahsulotlar natijasi
/// Mahsulotlar + umumiy soni
class FilteredProductsResult {
  final List<ProductModel> products;
  final int totalCount;
  final int page;
  final int perPage;

  const FilteredProductsResult({
    required this.products,
    required this.totalCount,
    this.page = 1,
    this.perPage = 20,
  });

  /// Sahifalar soni
  int get totalPages => (totalCount / perPage).ceil();

  /// Keyingi sahifa bormi
  bool get hasNextPage => page < totalPages;

  /// Oldingi sahifa bormi
  bool get hasPreviousPage => page > 1;

  /// Bo'sh natija
  static const empty = FilteredProductsResult(
    products: [],
    totalCount: 0,
  );

  FilteredProductsResult copyWith({
    List<ProductModel>? products,
    int? totalCount,
    int? page,
    int? perPage,
  }) {
    return FilteredProductsResult(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  @override
  String toString() {
    return 'FilteredProductsResult(products: ${products.length}, totalCount: $totalCount, page: $page)';
  }
}
