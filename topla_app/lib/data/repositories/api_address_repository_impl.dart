import '../../core/repositories/i_address_repository.dart';
import '../../core/services/api_client.dart';
import '../../models/models.dart';

/// Address repository - Node.js backend implementation
class ApiAddressRepositoryImpl implements IAddressRepository {
  final ApiClient _api;

  ApiAddressRepositoryImpl(this._api);

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await _api.get('/addresses');
    return (response.dataList).map((e) => AddressModel.fromJson(e)).toList();
  }

  @override
  Future<AddressModel?> getAddressById(String id) async {
    try {
      final response = await _api.get('/addresses/$id');
      return AddressModel.fromJson(response.dataMap);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<AddressModel?> getDefaultAddress() async {
    final addresses = await getAddresses();
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _api.post('/addresses', body: address.toJson());
    return AddressModel.fromJson(response.dataMap);
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    await _api.put('/addresses/${address.id}', body: address.toJson());
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _api.delete('/addresses/$id');
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    await _api.put('/addresses/$id', body: {'isDefault': true});
  }
}
