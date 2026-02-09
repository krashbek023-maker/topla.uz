import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/repositories/repositories.dart';
import '../../models/models.dart';

/// Supabase bilan Favorites operatsiyalari implementatsiyasi
class FavoritesRepositoryImpl implements IFavoritesRepository {
  final SupabaseClient _client;
  final String? Function() _getCurrentUserId;

  FavoritesRepositoryImpl(this._client, this._getCurrentUserId);

  String? get _userId => _getCurrentUserId();

  @override
  Future<List<ProductModel>> getFavorites() async {
    if (_userId == null) return [];

    final response = await _client
        .from('favorites')
        .select('product_id, products(*)')
        .eq('user_id', _userId!);

    return (response as List)
        .map((json) => ProductModel.fromJson(json['products']))
        .toList();
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    if (_userId == null) return {};

    final response = await _client
        .from('favorites')
        .select('product_id')
        .eq('user_id', _userId!);

    return (response as List)
        .map((json) => json['product_id'] as String)
        .toSet();
  }

  @override
  Future<bool> isFavorite(String productId) async {
    if (_userId == null) return false;

    final response = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', _userId!)
        .eq('product_id', productId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    if (_userId == null) throw Exception('Tizimga kiring');

    final isFav = await isFavorite(productId);

    if (isFav) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(productId);
      return true;
    }
  }

  @override
  Future<void> addToFavorites(String productId) async {
    if (_userId == null) throw Exception('Tizimga kiring');

    await _client.from('favorites').insert({
      'user_id': _userId,
      'product_id': productId,
    });
  }

  @override
  Future<void> removeFromFavorites(String productId) async {
    if (_userId == null) return;

    await _client
        .from('favorites')
        .delete()
        .eq('user_id', _userId!)
        .eq('product_id', productId);
  }
}
