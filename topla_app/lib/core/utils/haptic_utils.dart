import 'package:flutter/services.dart';

/// Haptic Feedback Utilities
/// Zamonaviy ilovalar uchun taktil qayta aloqa
class HapticUtils {
  HapticUtils._();

  /// Engil bosish (tugmalar, kartalar)
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// O'rtacha bosish (muhim amallar)
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Kuchli bosish (o'chirish, bekor qilish)
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Tanlash (checkbox, radio, switch)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Muvaffaqiyat vibratsiyasi
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Xatolik vibratsiyasi
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Ogohlantirish vibratsiyasi
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// Savatga qo'shish
  static Future<void> addToCart() async {
    await HapticFeedback.mediumImpact();
  }

  /// Sevimliga qo'shish
  static Future<void> favorite() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Swipe action
  static Future<void> swipe() async {
    await HapticFeedback.selectionClick();
  }

  /// Pull to refresh
  static Future<void> pullRefresh() async {
    await HapticFeedback.mediumImpact();
  }

  /// Tab o'zgartirish
  static Future<void> tabChange() async {
    await HapticFeedback.selectionClick();
  }

  /// Buyurtma yaratish
  static Future<void> orderCreated() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }
}
