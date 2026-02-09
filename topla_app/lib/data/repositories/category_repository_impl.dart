import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topla_app/core/repositories/repositories.dart';
import 'package:topla_app/models/models.dart';
import 'package:topla_app/services/cache_service.dart';

/// Supabase bilan Category operatsiyalari implementatsiyasi
class CategoryRepositoryImpl implements ICategoryRepository {
  final SupabaseClient _client;
  final CacheService _cache;

  CategoryRepositoryImpl(this._client, this._cache);

  static const _cacheKey = 'categories';
  static const _cacheDuration = Duration(minutes: 30);

  @override
  Future<List<CategoryModel>> getCategories() async {
    // Cache dan tekshirish
    final cached = _cache.get<List<dynamic>>(_cacheKey);
    if (cached != null) {
      return cached
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Faqat parent kategoriyalarni olish (parent_id null bo'lganlar)
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .isFilter('parent_id', null)
        .order('sort_order', ascending: true);

    // Cache saqlash
    _cache.set(_cacheKey, response, expiry: _cacheDuration);

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<CategoryModel>> getSubCategories(String parentId) async {
    final cacheKey = '${_cacheKey}_sub_$parentId';

    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => CategoryModel.fromJson(e)).toList();
    }

    final response = await _client
        .from('categories')
        .select()
        .eq('parent_id', parentId)
        .eq('is_active', true)
        .order('sort_order');

    _cache.set(cacheKey, response, expiry: _cacheDuration);

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final cacheKey = '${_cacheKey}_$id';

    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return CategoryModel.fromJson(cached);
    }

    final response =
        await _client.from('categories').select().eq('id', id).maybeSingle();

    if (response == null) return null;

    _cache.set(cacheKey, response, expiry: _cacheDuration);
    return CategoryModel.fromJson(response);
  }
}
