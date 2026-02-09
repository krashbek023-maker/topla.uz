import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';

/// Saqlangan kartalar uchun repository
abstract class CardsRepository {
  /// Foydalanuvchining barcha saqlangan kartalarini olish
  Future<List<SavedCardModel>> getCards(String userId);

  /// Yangi karta qo'shish
  Future<SavedCardModel?> addCard(SavedCardModel card);

  /// Kartani o'chirish
  Future<bool> deleteCard(String cardId);

  /// Kartani asosiy qilish
  Future<bool> setDefaultCard(String userId, String cardId);

  /// Asosiy kartani olish
  Future<SavedCardModel?> getDefaultCard(String userId);
}

/// Supabase bilan ishlaydigan CardsRepository implementatsiyasi
class CardsRepositoryImpl implements CardsRepository {
  final SupabaseClient _client;

  CardsRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<SavedCardModel>> getCards(String userId) async {
    try {
      final response = await _client
          .from('saved_cards')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List).map((e) => SavedCardModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Get cards error: $e');
      return [];
    }
  }

  @override
  Future<SavedCardModel?> addCard(SavedCardModel card) async {
    try {
      final response = await _client
          .from('saved_cards')
          .insert({
            'user_id': card.userId,
            'binding_id': card.bindingId,
            'masked_pan': card.maskedPan,
            'card_type': card.cardType.value,
            'expiry_date': card.expiryDate,
            'is_default': card.isDefault,
          })
          .select()
          .single();

      return SavedCardModel.fromJson(response);
    } catch (e) {
      debugPrint('Add card error: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteCard(String cardId) async {
    try {
      await _client.from('saved_cards').delete().eq('id', cardId);
      return true;
    } catch (e) {
      debugPrint('Delete card error: $e');
      return false;
    }
  }

  @override
  Future<bool> setDefaultCard(String userId, String cardId) async {
    try {
      // Avval barcha kartalardan default'ni olib tashlash
      await _client
          .from('saved_cards')
          .update({'is_default': false}).eq('user_id', userId);

      // Tanlangan kartani default qilish
      await _client
          .from('saved_cards')
          .update({'is_default': true}).eq('id', cardId);

      return true;
    } catch (e) {
      debugPrint('Set default card error: $e');
      return false;
    }
  }

  @override
  Future<SavedCardModel?> getDefaultCard(String userId) async {
    try {
      final response = await _client
          .from('saved_cards')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (response != null) {
        return SavedCardModel.fromJson(response);
      }

      // Agar default yo'q bo'lsa, birinchi kartani qaytarish
      final cards = await getCards(userId);
      return cards.isNotEmpty ? cards.first : null;
    } catch (e) {
      debugPrint('Get default card error: $e');
      return null;
    }
  }
}
