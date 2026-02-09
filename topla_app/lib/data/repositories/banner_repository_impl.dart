import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topla_app/core/repositories/repositories.dart';
import 'package:topla_app/models/models.dart';
import 'package:topla_app/services/cache_service.dart';

/// Supabase bilan Banner operatsiyalari implementatsiyasi
class BannerRepositoryImpl implements IBannerRepository {
  final SupabaseClient _client;
  final CacheService _cache;

  BannerRepositoryImpl(this._client, this._cache);

  static const _cacheKey = 'banners';
  static const _cacheDuration = Duration(minutes: 15);

  @override
  Future<List<BannerModel>> getBanners() async {
    final cached = _cache.get<List<dynamic>>(_cacheKey);
    if (cached != null) {
      return cached.map((e) => BannerModel.fromJson(e)).toList();
    }

    final response = await _client.from('banners').select().order('sort_order');

    _cache.set(_cacheKey, response, expiry: _cacheDuration);

    return (response as List)
        .map((json) => BannerModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<BannerModel>> getActiveBanners() async {
    final cacheKey = '${_cacheKey}_active';

    final cached = _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached.map((e) => BannerModel.fromJson(e)).toList();
    }

    final response = await _client
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    _cache.set(cacheKey, response, expiry: _cacheDuration);

    return (response as List)
        .map((json) => BannerModel.fromJson(json))
        .toList();
  }
}
