import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/repositories/repositories.dart';
import '../../models/models.dart';

/// Supabase bilan Address operatsiyalari implementatsiyasi
class AddressRepositoryImpl implements IAddressRepository {
  final SupabaseClient _client;
  final String? Function() _getCurrentUserId;

  AddressRepositoryImpl(this._client, this._getCurrentUserId);

  String? get _userId => _getCurrentUserId();

  @override
  Future<List<AddressModel>> getAddresses() async {
    if (_userId == null) return [];

    final response = await _client
        .from('addresses')
        .select()
        .eq('user_id', _userId!)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AddressModel.fromJson(json))
        .toList();
  }

  @override
  Future<AddressModel?> getAddressById(String id) async {
    final response =
        await _client.from('addresses').select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return AddressModel.fromJson(response);
  }

  @override
  Future<AddressModel?> getDefaultAddress() async {
    if (_userId == null) return null;

    final response = await _client
        .from('addresses')
        .select()
        .eq('user_id', _userId!)
        .eq('is_default', true)
        .maybeSingle();

    if (response == null) return null;
    return AddressModel.fromJson(response);
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    if (_userId == null) throw Exception('Tizimga kiring');

    // Agar bu birinchi manzil bo'lsa, default qilish
    final existingAddresses = await getAddresses();
    final isFirst = existingAddresses.isEmpty;

    final response = await _client
        .from('addresses')
        .insert({
          'user_id': _userId,
          'name': address.title,
          'street': address.address,
          'apartment': address.apartment,
          'entrance': address.entrance,
          'floor': address.floor,
          'latitude': address.latitude,
          'longitude': address.longitude,
          'is_default': isFirst || address.isDefault,
        })
        .select()
        .single();

    return AddressModel.fromJson(response);
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    await _client.from('addresses').update({
      'name': address.title,
      'street': address.address,
      'apartment': address.apartment,
      'entrance': address.entrance,
      'floor': address.floor,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'is_default': address.isDefault,
    }).eq('id', address.id);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _client.from('addresses').delete().eq('id', id);
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    if (_userId == null) return;

    // Boshqa manzillardan default ni olib tashlash
    await _client
        .from('addresses')
        .update({'is_default': false}).eq('user_id', _userId!);

    // Bu manzilni default qilish
    await _client.from('addresses').update({'is_default': true}).eq('id', id);
  }
}
