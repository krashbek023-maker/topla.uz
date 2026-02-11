import '../../core/repositories/i_banner_repository.dart';
import '../../core/services/api_client.dart';
import '../../models/models.dart';

/// Banner repository - Node.js backend implementation
class ApiBannerRepositoryImpl implements IBannerRepository {
  final ApiClient _api;

  ApiBannerRepositoryImpl(this._api);

  @override
  Future<List<BannerModel>> getBanners() async {
    final response = await _api.get('/banners', auth: false);
    return (response.dataList).map((e) => BannerModel.fromJson(e)).toList();
  }

  @override
  Future<List<BannerModel>> getActiveBanners() async {
    final response = await _api.get('/banners',
        queryParams: {'active': 'true'}, auth: false);
    return (response.dataList).map((e) => BannerModel.fromJson(e)).toList();
  }
}
