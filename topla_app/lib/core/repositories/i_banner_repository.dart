import '../../models/models.dart';

/// Banner operatsiyalari uchun interface
abstract class IBannerRepository {
  /// Barcha bannerlarni olish
  Future<List<BannerModel>> getBanners();

  /// Aktiv bannerlarni olish
  Future<List<BannerModel>> getActiveBanners();
}
