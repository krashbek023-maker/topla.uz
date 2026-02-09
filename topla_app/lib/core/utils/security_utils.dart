import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Kriptografik utility funksiyalar
class CryptoUtils {
  CryptoUtils._();

  /// SHA-256 hash yaratish
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// MD5 hash yaratish (faqat checksum uchun, xavfsizlik uchun emas!)
  static String md5Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// PIN kod uchun hash (salt bilan)
  static String hashPin(String pin, String salt) {
    return sha256Hash('$salt:$pin:$salt');
  }

  /// PIN kodni tekshirish
  static bool verifyPin(String pin, String hash, String salt) {
    return hashPin(pin, salt) == hash;
  }

  /// Kriptografik xavfsiz salt generatsiya qilish
  static String generateSalt({int length = 16}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return sha256Hash(base64.encode(bytes)).substring(0, length);
  }

  /// Base64 encode
  static String base64Encode(String input) {
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  /// Base64 decode
  static String? base64Decode(String input) {
    try {
      final bytes = base64.decode(input);
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('Base64 decode error: $e');
      return null;
    }
  }

  /// Sensitive data maskalash (karta raqami, telefon)
  static String maskCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) return cardNumber;

    return '${digits.substring(0, 4)} **** **** ${digits.substring(digits.length - 4)}';
  }

  /// Telefon raqamni maskalash
  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return phone;

    return '+998 ** *** ${digits.substring(digits.length - 4)}';
  }

  /// Email maskalash
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }

    return '${name.substring(0, 2)}***@$domain';
  }
}

/// Rate limiter - API chaqiruvlarni cheklash
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Map<String, List<DateTime>> _requests = {};

  RateLimiter({
    this.maxRequests = 10,
    this.window = const Duration(minutes: 1),
  });

  /// So'rov ruxsat etilganligini tekshirish
  bool isAllowed(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    // Eski so'rovlarni tozalash
    _requests[key] = (_requests[key] ?? [])
        .where((time) => time.isAfter(windowStart))
        .toList();

    // Limit tekshirish
    if ((_requests[key]?.length ?? 0) >= maxRequests) {
      return false;
    }

    // Yangi so'rovni qo'shish
    _requests[key] = [...(_requests[key] ?? []), now];
    return true;
  }

  /// Keyingi so'rovgacha qancha vaqt kutish kerakligini qaytarish
  Duration? getWaitTime(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    final requests = (_requests[key] ?? [])
        .where((time) => time.isAfter(windowStart))
        .toList();

    if (requests.length < maxRequests) {
      return null;
    }

    // Eng eski so'rov qachon tugashini hisoblash
    requests.sort();
    final oldestRequest = requests.first;
    final expiresAt = oldestRequest.add(window);

    if (expiresAt.isAfter(now)) {
      return expiresAt.difference(now);
    }

    return null;
  }

  /// Ma'lum kalit uchun tozalash
  void clear(String key) {
    _requests.remove(key);
  }

  /// Hammani tozalash
  void clearAll() {
    _requests.clear();
  }
}

/// Device fingerprint yaratish
class DeviceFingerprint {
  /// Oddiy device ID yaratish
  static Future<String> generate() async {
    // Bu yerda device_info_plus package ishlatish mumkin
    // Hozircha sodda versiya
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return CryptoUtils.sha256Hash('device_$timestamp').substring(0, 32);
  }
}
