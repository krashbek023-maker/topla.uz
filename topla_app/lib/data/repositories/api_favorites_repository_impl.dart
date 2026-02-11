import '../../core/repositories/i_favorites_repository.dart';
import '../../core/services/api_client.dart';
import '../../models/models.dart';

/// Favorites repository - Node.js backend implementation
class ApiFavoritesRepositoryImpl implements IFavoritesRepository {
  final ApiClient _api;

  // Lokal cache
  final Set<String> _favoriteIds = {};

  ApiFavoritesRepositoryImpl(this._api);

  @override
  Future<List<ProductModel>> getFavorites() async {
    final response = await _api.get('/favorites');
    final list = (response.dataList).map((e) {
      // Backend {product: {...}, ...} formatda qaytarishi mumkin
      if (e is Map && e.containsKey('product')) {
        return ProductModel.fromJson(e['product']);
      }
      return ProductModel.fromJson(e);
    }).toList();

    _favoriteIds.clear();
    _favoriteIds.addAll(list.map((p) => p.id));
    return list;
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    if (_favoriteIds.isEmpty) {
      await getFavorites();
    }
    return Set.from(_favoriteIds);
  }

  @override
  Future<bool> isFavorite(String productId) async {
    if (_favoriteIds.isEmpty) {
      await getFavoriteIds();
    }
    return _favoriteIds.contains(productId);
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(productId);
      return true;
    }
  }

  @override
  Future<void> addToFavorites(String productId) async {
    await _api.post('/favorites/$productId');
    _favoriteIds.add(productId);
  }

  @override
  Future<void> removeFromFavorites(String productId) async {
    await _api.delete('/favorites/$productId');
    _favoriteIds.remove(productId);
  }
}
