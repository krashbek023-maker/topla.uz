import 'env_config.dart';

/// Supabase konfiguratsiya fayli
///
/// XAVFSIZLIK: API kalitlari faqat --dart-define orqali beriladi
/// Hech qanday default qiymat yo'q - xavfsizlik uchun
///
/// Build command:
/// flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
///
/// Yoki .env fayldan:
/// flutter run --dart-define-from-file=.env
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase Project URL - environment variable dan olinadi
  /// --dart-define=SUPABASE_URL=xxx orqali beriladi
  static String get url => EnvConfig.supabaseUrl;

  /// Supabase Anon Key - environment variable dan olinadi
  /// --dart-define=SUPABASE_ANON_KEY=xxx orqali beriladi
  static String get anonKey => EnvConfig.supabaseAnonKey;

  /// Storage bucket nomlari
  static const String productsBucket = EnvConfig.productsBucket;
  static const String bannersBucket = EnvConfig.bannersBucket;
  static const String avatarsBucket = EnvConfig.avatarsBucket;
  static const String shopsBucket = EnvConfig.shopsBucket;
}
