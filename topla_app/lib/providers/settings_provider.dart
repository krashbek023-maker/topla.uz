import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ilova sozlamalari uchun Provider
class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';

  ThemeMode _themeMode = ThemeMode.system; // Tizim sozlamalariga moslashadi
  String _language = 'uz';
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get isLoading => _isLoading;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemTheme => _themeMode == ThemeMode.system;

  /// Joriy locale
  Locale get locale => Locale(_language);

  SettingsProvider() {
    _loadSettings();
  }

  /// Sozlamalarni yuklash
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Theme mode - default system (tizimga moslashadi)
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null &&
          themeModeIndex >= 0 &&
          themeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeModeIndex];
      } else {
        // Birinchi marta ochilganda tizim sozlamalariga moslashadi
        _themeMode = ThemeMode.system;
      }

      // Language
      _language = prefs.getString(_languageKey) ?? 'uz';
    } catch (e) {
      debugPrint('Settings yuklashda xatolik: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Theme mode ni o'zgartirish
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      debugPrint('Theme saqlashda xatolik: $e');
    }
  }

  /// Tilni o'zgartirish
  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, lang);
    } catch (e) {
      debugPrint('Til saqlashda xatolik: $e');
    }
  }

  /// Dark mode ni toggle qilish
  Future<void> toggleDarkMode() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Tizim temasiga o'tish
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}
