/// Environment konfiguratsiya fayli
///
/// XAVFSIZLIK: Barcha maxfiy kalitlar faqat --dart-define orqali beriladi
/// Hech qanday default qiymat ko'rsatilmaydi!
///
/// Build commands:
/// ```bash
/// # Development
/// flutter run --dart-define=ENV=dev \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxx \
///   --dart-define=FIREBASE_WEB_API_KEY=xxx \
///   --dart-define=FIREBASE_ANDROID_API_KEY=xxx \
///   --dart-define=FIREBASE_IOS_API_KEY=xxx
///
/// # Production APK
/// flutter build apk --release --dart-define=ENV=prod \
///   --dart-define=SUPABASE_URL=$SUPABASE_URL \
///   --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
///   --dart-define=FIREBASE_WEB_API_KEY=$FIREBASE_WEB_API_KEY \
///   --dart-define=FIREBASE_ANDROID_API_KEY=$FIREBASE_ANDROID_API_KEY \
///   --dart-define=FIREBASE_IOS_API_KEY=$FIREBASE_IOS_API_KEY
/// ```
///
/// CI/CD da GitHub Secrets yoki environment variables ishlatiladi
library;

import 'package:flutter/foundation.dart';

/// Environment turlari
enum Environment { dev, staging, prod }

/// Xavfsiz environment konfiguratsiyasi
class EnvConfig {
  EnvConfig._();

  // ================= ENVIRONMENT =================

  /// Joriy muhit
  static Environment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (env) {
      case 'prod':
      case 'production':
        return Environment.prod;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.dev;
    }
  }

  /// Debug mode
  static bool get isDebug => kDebugMode || environment == Environment.dev;

  /// Production mode
  static bool get isProduction => environment == Environment.prod;

  // ================= SUPABASE =================

  /// Supabase Project URL
  /// --dart-define=SUPABASE_URL=xxx orqali beriladi
  static String get supabaseUrl {
    const url = String.fromEnvironment('SUPABASE_URL');
    _validateNotEmpty(url, 'SUPABASE_URL');
    return url;
  }

  /// Supabase Anon Key
  /// --dart-define=SUPABASE_ANON_KEY=xxx orqali beriladi
  static String get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    _validateNotEmpty(key, 'SUPABASE_ANON_KEY');
    return key;
  }

  // ================= FIREBASE =================

  /// Firebase Web API Key
  static String get firebaseWebApiKey {
    const key =
        String.fromEnvironment('FIREBASE_WEB_API_KEY', defaultValue: '');
    return key;
  }

  /// Firebase Android API Key
  static String get firebaseAndroidApiKey {
    const key =
        String.fromEnvironment('FIREBASE_ANDROID_API_KEY', defaultValue: '');
    return key;
  }

  /// Firebase iOS API Key
  static String get firebaseIosApiKey {
    const key =
        String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: '');
    return key;
  }

  /// Firebase Project ID
  static String get firebaseProjectId {
    const id = String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'topla-app-ef946',
    );
    return id;
  }

  /// Firebase Messaging Sender ID
  static String get firebaseMessagingSenderId {
    const id = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '541689366619',
    );
    return id;
  }

  // ================= STORAGE BUCKETS =================

  /// Supabase storage bucket nomlari
  static const String productsBucket = 'products';
  static const String bannersBucket = 'banners';
  static const String avatarsBucket = 'avatars';
  static const String shopsBucket = 'shops';

  // ================= VALIDATION =================

  /// Muhim kalitlar mavjudligini tekshirish
  static void _validateNotEmpty(String value, String keyName) {
    if (value.isEmpty) {
      throw EnvironmentConfigException(
        '$keyName topilmadi! '
        'Build qilayotganda --dart-define=$keyName=xxx parametrini qo\'shing.',
      );
    }
  }

  /// Barcha kerakli environment variable'lar mavjudligini tekshirish
  /// App ishga tushganda chaqiriladi
  static void validateAllKeys() {
    final missingKeys = <String>[];

    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const webKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
    const androidKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
    const iosKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');

    if (supabaseUrl.isEmpty) missingKeys.add('SUPABASE_URL');
    if (supabaseKey.isEmpty) missingKeys.add('SUPABASE_ANON_KEY');
    if (webKey.isEmpty) missingKeys.add('FIREBASE_WEB_API_KEY');
    if (androidKey.isEmpty) missingKeys.add('FIREBASE_ANDROID_API_KEY');
    if (iosKey.isEmpty) missingKeys.add('FIREBASE_IOS_API_KEY');

    if (missingKeys.isNotEmpty) {
      throw EnvironmentConfigException(
        'Quyidagi environment variable\'lar topilmadi: ${missingKeys.join(', ')}\n'
        'Build qilayotganda --dart-define parametrlarini qo\'shing.',
      );
    }
  }

  /// Development uchun test qiymatlari mavjudligini tekshirish
  /// Faqat debug mode da ishlaydi
  static bool hasDevConfig() {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    return supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
  }
}

/// Environment konfiguratsiya xatosi
class EnvironmentConfigException implements Exception {
  final String message;
  EnvironmentConfigException(this.message);

  @override
  String toString() => 'EnvironmentConfigException: $message';
}
