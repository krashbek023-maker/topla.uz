import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topla_app/core/repositories/repositories.dart';
import 'package:topla_app/core/utils/app_logger.dart';
import 'package:topla_app/models/models.dart';
import 'package:topla_app/services/cache_service.dart';

/// Supabase bilan Product operatsiyalari implementatsiyasi
class ProductRepositoryImpl implements IProductRepository {
  final SupabaseClient _client;
  final CacheService _cache;

  ProductRepositoryImpl(this._client, this._cache);

  static const _tag = 'ProductRepo';

  static const _cachePrefix = 'products';
  static const _cacheDuration = Duration(minutes: 5);

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    bool? isFeatured,
    bool? isFlashSale,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    // Cache key yaratish
    final cacheKey =
        '${_cachePrefix}_${categoryId}_${isFeatured}_${isFlashSale}_${search}_${offset}_$limit';

    // Cache tekshirish
    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => ProductModel.fromJson(e)).toList();
    }

    // Query qurish
    var query = _client.from('products').select().eq('is_active', true);

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

    // Cache saqlash
    _cache.set(cacheKey, response, expiry: _cacheDuration);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final cacheKey = '${_cachePrefix}_$id';

    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return ProductModel.fromJson(cached);
    }

    final response =
        await _client.from('products').select().eq('id', id).maybeSingle();

    if (response == null) return null;

    _cache.set(cacheKey, response, expiry: _cacheDuration);
    return ProductModel.fromJson(response);
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    return getProducts(isFeatured: true, limit: limit);
  }

  @override
  Future<List<ProductModel>> getFlashSaleProducts({int limit = 10}) async {
    return getProducts(isFlashSale: true, limit: limit);
  }

  @override
  Future<List<ProductModel>> searchProducts(String query,
      {int limit = 20}) async {
    return getProducts(search: query, limit: limit);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return getProducts(categoryId: categoryId, limit: limit, offset: offset);
  }

  @override
  Future<List<ProductModel>> getProductsByShop(
    String shopId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final cacheKey = '${_cachePrefix}_shop_${shopId}_${offset}_$limit';

    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => ProductModel.fromJson(e)).toList();
    }

    final response = await _client
        .from('products')
        .select()
        .eq('shop_id', shopId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    _cache.set(cacheKey, response, expiry: _cacheDuration);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  // === FILTER TIZIMI ===

  @override
  Future<List<BrandModel>> getBrandsByCategory(String categoryId) async {
    final cacheKey = 'brands_category_$categoryId';

    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => BrandModel.fromJson(e)).toList();
    }

    try {
      // Avval category_brands orqali bog'langan brendlarni olish
      final response = await _client
          .from('brands')
          .select('''
            *,
            category_brands!inner(category_id)
          ''')
          .eq('category_brands.category_id', categoryId)
          .eq('is_active', true)
          .order('sort_order');

      _cache.set(cacheKey, response, expiry: _cacheDuration);
      return (response as List).map((e) => BrandModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      // Agar category_brands jadvali mavjud bo'lmasa, barcha brendlarni qaytarish
      AppLogger.w(_tag,
          'category_brands jadvali yo\'q, barcha brendlarni yuklaymiz', e);
      try {
        final response = await _client
            .from('brands')
            .select()
            .eq('is_active', true)
            .order('sort_order');

        _cache.set(cacheKey, response, expiry: _cacheDuration);
        return (response as List).map((e) => BrandModel.fromJson(e)).toList();
      } catch (e2) {
        AppLogger.e(_tag, 'Brendlarni yuklashda xato', e2, stackTrace);
        return [];
      }
    }
  }

  @override
  Future<List<ColorOption>> getColors() async {
    const cacheKey = 'colors_all';

    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => ColorOption.fromJson(e)).toList();
    }

    // color_options yoki colors jadvalidan olish
    try {
      final response = await _client
          .from('color_options')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      _cache.set(cacheKey, response, expiry: _cacheDuration);
      return (response as List).map((e) => ColorOption.fromJson(e)).toList();
    } catch (e, stackTrace) {
      // Agar color_options jadvali yo'q bo'lsa, colors jadvalidan
      AppLogger.w(_tag, 'color_options jadvali yo\'q, colors dan yuklaymiz', e);
      try {
        final response = await _client
            .from('colors')
            .select()
            .eq('is_active', true)
            .order('sort_order');

        _cache.set(cacheKey, response, expiry: _cacheDuration);
        return (response as List).map((e) => ColorOption.fromJson(e)).toList();
      } catch (e2) {
        AppLogger.e(_tag, 'Ranglarni yuklashda xato', e2, stackTrace);
        return [];
      }
    }
  }

  @override
  Future<List<ColorOption>> getColorsByCategory(String categoryId) async {
    final cacheKey = 'colors_category_$categoryId';

    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => ColorOption.fromJson(e)).toList();
    }

    // Hozircha barcha ranglarni qaytaramiz
    // Keyinchalik product_colors orqali filtrlash mumkin
    return getColors();
  }

  @override
  Future<List<CategoryFilterAttribute>> getCategoryFilters(
      String categoryId) async {
    final cacheKey = 'category_filters_$categoryId';

    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => CategoryFilterAttribute.fromJson(e)).toList();
    }

    try {
      final response = await _client
          .from('category_filter_attributes')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('sort_order');

      _cache.set(cacheKey, response, expiry: _cacheDuration);
      return (response as List)
          .map((e) => CategoryFilterAttribute.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e(_tag, 'Kategoriya filtrlari yuklashda xato: $categoryId', e,
          stackTrace);
      return [];
    }
  }

  @override
  Future<FilteredProductsResult> getFilteredProducts({
    required String categoryId,
    required ProductFilter filter,
    int limit = 20,
    int offset = 0,
  }) async {
    // Query qurish
    var query = _client
        .from('products')
        .select()
        .eq('is_active', true)
        .eq('category_id', categoryId);

    // Narx filtri
    if (filter.minPrice != null) {
      query = query.gte('price', filter.minPrice!);
    }
    if (filter.maxPrice != null) {
      query = query.lte('price', filter.maxPrice!);
    }

    // Reyting filtri
    if (filter.minRating != null) {
      query = query.gte('rating', filter.minRating!);
    }

    // Stock filtri
    if (filter.onlyInStock) {
      query = query.gt('stock', 0);
    }

    // Chegirma filtri
    if (filter.onlyWithDiscount) {
      query = query.gt('discount_percent', 0);
    }

    // Flash sale filtri
    if (filter.onlyFlashSale) {
      query = query.eq('is_flash_sale', true);
    }

    // Brand filtri
    if (filter.brandIds.isNotEmpty) {
      query = query.inFilter('brand_id', filter.brandIds.toList());
    }

    // Original filtri
    if (filter.isOriginal != null && filter.isOriginal!) {
      query = query.eq('is_original', true);
    }

    // Click delivery filtri
    if (filter.isClickDelivery != null && filter.isClickDelivery!) {
      query = query.eq('is_click_delivery', true);
    }

    // Yetkazish muddati filtri
    if (filter.deliveryHours != null) {
      query = query.lte('delivery_hours', filter.deliveryHours!);
    }

    // Sorting va Pagination
    String sortColumn = 'created_at';
    bool sortAscending = false;

    if (filter.sortBy != null) {
      switch (filter.sortBy) {
        case 'price_asc':
          sortColumn = 'price';
          sortAscending = true;
          break;
        case 'price_desc':
          sortColumn = 'price';
          sortAscending = false;
          break;
        case 'rating':
          sortColumn = 'rating';
          sortAscending = false;
          break;
        case 'sold_count':
          sortColumn = 'sold_count';
          sortAscending = false;
          break;
        case 'created_at':
        default:
          sortColumn = 'created_at';
          sortAscending = false;
          break;
      }
    } else {
      sortAscending = filter.sortAscending;
    }

    final response = await query
        .order(sortColumn, ascending: sortAscending)
        .range(offset, offset + limit - 1);

    final products =
        (response as List).map((json) => ProductModel.fromJson(json)).toList();

    // Umumiy sonini olish
    final totalCount = await getFilteredProductsCount(
      categoryId: categoryId,
      filter: filter,
    );

    return FilteredProductsResult(
      products: products,
      totalCount: totalCount,
      page: (offset / limit).floor() + 1,
      perPage: limit,
    );
  }

  @override
  Future<int> getFilteredProductsCount({
    required String categoryId,
    required ProductFilter filter,
  }) async {
    // Count query qurish
    var query = _client
        .from('products')
        .select('id')
        .eq('is_active', true)
        .eq('category_id', categoryId);

    // Narx filtri
    if (filter.minPrice != null) {
      query = query.gte('price', filter.minPrice!);
    }
    if (filter.maxPrice != null) {
      query = query.lte('price', filter.maxPrice!);
    }

    // Reyting filtri
    if (filter.minRating != null) {
      query = query.gte('rating', filter.minRating!);
    }

    // Stock filtri
    if (filter.onlyInStock) {
      query = query.gt('stock', 0);
    }

    // Chegirma filtri
    if (filter.onlyWithDiscount) {
      query = query.gt('discount_percent', 0);
    }

    // Flash sale filtri
    if (filter.onlyFlashSale) {
      query = query.eq('is_flash_sale', true);
    }

    // Brand filtri
    if (filter.brandIds.isNotEmpty) {
      query = query.inFilter('brand_id', filter.brandIds.toList());
    }

    // Original filtri
    if (filter.isOriginal != null && filter.isOriginal!) {
      query = query.eq('is_original', true);
    }

    // Click delivery filtri
    if (filter.isClickDelivery != null && filter.isClickDelivery!) {
      query = query.eq('is_click_delivery', true);
    }

    // Yetkazish muddati filtri
    if (filter.deliveryHours != null) {
      query = query.lte('delivery_hours', filter.deliveryHours!);
    }

    final response = await query;
    return (response as List).length;
  }
}
