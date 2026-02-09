import '../../models/models.dart';

/// Manzil operatsiyalari uchun interface
abstract class IAddressRepository {
  /// Barcha manzillarni olish
  Future<List<AddressModel>> getAddresses();

  /// Bitta manzilni olish
  Future<AddressModel?> getAddressById(String id);

  /// Default manzilni olish
  Future<AddressModel?> getDefaultAddress();

  /// Manzil qo'shish
  Future<AddressModel> addAddress(AddressModel address);

  /// Manzil yangilash
  Future<void> updateAddress(AddressModel address);

  /// Manzil o'chirish
  Future<void> deleteAddress(String id);

  /// Default manzil qilish
  Future<void> setDefaultAddress(String id);
}
