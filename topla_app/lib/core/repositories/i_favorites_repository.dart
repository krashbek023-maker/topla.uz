import '../../models/models.dart';

/// Sevimlilar operatsiyalari uchun interface
abstract class IFavoritesRepository {
  /// Sevimlilarni olish
  Future<List<ProductModel>> getFavorites();

  /// Sevimli product ID larini olish
  Future<Set<String>> getFavoriteIds();

  /// Sevimlilar ro'yxatida bormi
  Future<bool> isFavorite(String productId);

  /// Sevimlilarga qo'shish/o'chirish (toggle)
  Future<bool> toggleFavorite(String productId);

  /// Sevimlilarga qo'shish
  Future<void> addToFavorites(String productId);

  /// Sevimlilardan o'chirish
  Future<void> removeFromFavorites(String productId);
}
