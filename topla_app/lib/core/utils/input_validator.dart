/// Input validatsiya utilities
///
/// Barcha foydalanuvchi inputlari uchun xavfsiz validatsiya
class InputValidator {
  InputValidator._();

  // ==================== REGEX PATTERNS ====================

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Telefon raqam formati (+998XXXXXXXXX)
  static final RegExp phoneRegex = RegExp(
    r'^\+?998[0-9]{9}$',
  );

  static final RegExp _uzbekPhoneRegex = RegExp(
    r'^(\+998|998)?[0-9]{9}$',
  );

  static final RegExp _onlyDigitsRegex = RegExp(r'^[0-9]+$');

  /// Faqat harflar (kirill va lotin)
  static final RegExp onlyLettersRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s]+$');

  /// Alphanumeric (harflar va raqamlar)
  static final RegExp alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');

  /// Username formati (3-20 belgi, harflar, raqamlar, pastki chiziq)
  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  // SQL injection patterns
  static final RegExp _sqlInjectionRegex = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|FETCH|DECLARE|TRUNCATE)\b)|(--)|;',
    caseSensitive: false,
  );

  // XSS patterns
  static final RegExp _xssRegex = RegExp(
    r'<script[^>]*>.*?</script>|<[^>]+on\w+\s*=|javascript:|data:text/html',
    caseSensitive: false,
  );

  // ==================== EMAIL ====================

  /// Email validatsiyasi
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email kiriting';
    }

    final email = value.trim().toLowerCase();

    if (email.length > 254) {
      return 'Email juda uzun';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Email formati noto\'g\'ri';
    }

    return null;
  }

  /// Email sanitize qilish
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // ==================== PHONE ====================

  /// Telefon raqam validatsiyasi (O'zbekiston)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon raqamini kiriting';
    }

    // Faqat raqamlarni olish
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length < 9) {
      return 'Telefon raqami juda qisqa';
    }

    if (digits.length > 12) {
      return 'Telefon raqami juda uzun';
    }

    // 998 bilan boshlanishi kerak yoki 9 ta raqam
    if (!_uzbekPhoneRegex.hasMatch(digits) && digits.length != 9) {
      return 'Telefon raqami noto\'g\'ri';
    }

    return null;
  }

  /// Telefon raqamni formatlash (+998 XX XXX XX XX)
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    String normalized;
    if (digits.startsWith('998')) {
      normalized = digits;
    } else if (digits.startsWith('8') && digits.length == 10) {
      normalized = '998${digits.substring(1)}';
    } else if (digits.length == 9) {
      normalized = '998$digits';
    } else {
      normalized = digits;
    }

    if (normalized.length == 12) {
      return '+${normalized.substring(0, 3)} ${normalized.substring(3, 5)} ${normalized.substring(5, 8)} ${normalized.substring(8, 10)} ${normalized.substring(10)}';
    }

    return phone;
  }

  /// Telefon raqamni sanitize qilish
  static String sanitizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 9) {
      return '+998$digits';
    }
    if (digits.startsWith('998')) {
      return '+$digits';
    }
    return '+$digits';
  }

  // ==================== PASSWORD ====================

  /// Parol validatsiyasi
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Parolni kiriting';
    }

    if (value.length < minLength) {
      return 'Parol kamida $minLength belgidan iborat bo\'lishi kerak';
    }

    if (value.length > 128) {
      return 'Parol juda uzun';
    }

    return null;
  }

  /// Kuchli parol validatsiyasi
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parolni kiriting';
    }

    if (value.length < 8) {
      return 'Parol kamida 8 belgidan iborat bo\'lishi kerak';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Parolda kamida 1 ta katta harf bo\'lishi kerak';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Parolda kamida 1 ta kichik harf bo\'lishi kerak';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Parolda kamida 1 ta raqam bo\'lishi kerak';
    }

    return null;
  }

  /// Parol kuchini tekshirish (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    return strength.clamp(0, 4);
  }

  // ==================== USERNAME ====================

  /// Username validatsiyasi
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username kiriting';
    }

    final username = value.trim();

    if (username.length < 3) {
      return 'Username kamida 3 belgidan iborat bo\'lishi kerak';
    }

    if (username.length > 20) {
      return 'Username 20 belgidan oshmasligi kerak';
    }

    if (!usernameRegex.hasMatch(username)) {
      return 'Username faqat harflar, raqamlar va pastki chiziqdan iborat bo\'lishi kerak';
    }

    return null;
  }

  // ==================== TEXT PATTERNS ====================

  /// Faqat harflardan iboratligini tekshirish
  static String? validateOnlyLetters(String? value,
      {String fieldName = 'Maydon'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName kiriting';
    }

    if (!onlyLettersRegex.hasMatch(value.trim())) {
      return '$fieldName faqat harflardan iborat bo\'lishi kerak';
    }

    return null;
  }

  /// Alphanumeric (harflar va raqamlar) tekshirish
  static String? validateAlphanumeric(String? value,
      {String fieldName = 'Maydon'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName kiriting';
    }

    if (!alphanumericRegex.hasMatch(value.trim())) {
      return '$fieldName faqat harflar va raqamlardan iborat bo\'lishi kerak';
    }

    return null;
  }

  // ==================== NAME ====================

  /// Ism validatsiyasi
  static String? validateName(String? value, {String fieldName = 'Ism'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName kiriting';
    }

    final name = value.trim();

    if (name.length < 2) {
      return '$fieldName juda qisqa';
    }

    if (name.length > 50) {
      return '$fieldName juda uzun';
    }

    // XSS va SQL injection tekshirish
    if (_containsMaliciousContent(name)) {
      return '$fieldName noto\'g\'ri belgilar mavjud';
    }

    return null;
  }

  /// Ismni sanitize qilish
  static String sanitizeName(String name) {
    return _sanitizeText(name.trim());
  }

  // ==================== TEXT ====================

  /// Umumiy matn validatsiyasi
  static String? validateText(
    String? value, {
    String fieldName = 'Matn',
    int minLength = 1,
    int maxLength = 500,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName kiriting' : null;
    }

    final text = value.trim();

    if (text.length < minLength) {
      return '$fieldName kamida $minLength belgidan iborat bo\'lishi kerak';
    }

    if (text.length > maxLength) {
      return '$fieldName $maxLength belgidan oshmasligi kerak';
    }

    if (_containsMaliciousContent(text)) {
      return '$fieldName noto\'g\'ri belgilar mavjud';
    }

    return null;
  }

  /// Matnni sanitize qilish
  static String sanitizeText(String text) {
    return _sanitizeText(text.trim());
  }

  // ==================== NUMBER ====================

  /// Raqam validatsiyasi
  static String? validateNumber(
    String? value, {
    String fieldName = 'Raqam',
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName kiriting' : null;
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName noto\'g\'ri';
    }

    if (min != null && number < min) {
      return '$fieldName $min dan kam bo\'lmasligi kerak';
    }

    if (max != null && number > max) {
      return '$fieldName $max dan oshmasligi kerak';
    }

    return null;
  }

  /// Butun son validatsiyasi
  static String? validateInteger(
    String? value, {
    String fieldName = 'Son',
    int? min,
    int? max,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName kiriting' : null;
    }

    final number = int.tryParse(value.trim());
    if (number == null) {
      return '$fieldName butun son bo\'lishi kerak';
    }

    if (min != null && number < min) {
      return '$fieldName $min dan kam bo\'lmasligi kerak';
    }

    if (max != null && number > max) {
      return '$fieldName $max dan oshmasligi kerak';
    }

    return null;
  }

  // ==================== OTP ====================

  /// OTP kod validatsiyasi
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Kodni kiriting';
    }

    if (value.length != length) {
      return 'Kod $length raqamdan iborat bo\'lishi kerak';
    }

    if (!_onlyDigitsRegex.hasMatch(value)) {
      return 'Kod faqat raqamlardan iborat bo\'lishi kerak';
    }

    return null;
  }

  // ==================== CARD ====================

  /// Karta raqami validatsiyasi (Uzbek cards: 8600, 9860)
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Karta raqamini kiriting';
    }

    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 16) {
      return 'Karta raqami 16 raqamdan iborat bo\'lishi kerak';
    }

    // Uzbek karta prefikslari
    if (!digits.startsWith('8600') && !digits.startsWith('9860')) {
      return 'Faqat O\'zbekiston kartalari qabul qilinadi';
    }

    return null;
  }

  /// Karta amal qilish muddati validatsiyasi (MM/YY)
  static String? validateCardExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amal qilish muddatini kiriting';
    }

    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Format: MM/YY';
    }

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return 'Noto\'g\'ri format';
    }

    if (month < 1 || month > 12) {
      return 'Oy 01-12 orasida bo\'lishi kerak';
    }

    final now = DateTime.now();
    final expiryYear = 2000 + year;
    final expiryDate = DateTime(expiryYear, month + 1, 0);

    if (expiryDate.isBefore(now)) {
      return 'Karta muddati o\'tgan';
    }

    return null;
  }

  // ==================== SECURITY HELPERS ====================

  /// Zararli kontent mavjudligini tekshirish
  static bool _containsMaliciousContent(String text) {
    return _sqlInjectionRegex.hasMatch(text) || _xssRegex.hasMatch(text);
  }

  /// Matnni xavfsiz qilish
  static String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '') // HTML teglarni olib tashlash
        .replaceAll(RegExp(r'[<>]'), '') // Xavfli belgilarni olib tashlash
        .replaceAll(RegExp(r'\s+'), ' ') // Ortiqcha bo'shliqlarni olib tashlash
        .trim();
  }

  /// SQL injection uchun tekshirish
  static bool containsSqlInjection(String text) {
    return _sqlInjectionRegex.hasMatch(text);
  }

  /// XSS uchun tekshirish
  static bool containsXss(String text) {
    return _xssRegex.hasMatch(text);
  }
}

/// Validatsiya natijasi
class ValidationResult {
  final bool isValid;
  final String? error;
  final String? sanitizedValue;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.sanitizedValue,
  });

  factory ValidationResult.success(String value) => ValidationResult(
        isValid: true,
        sanitizedValue: value,
      );

  factory ValidationResult.failure(String error) => ValidationResult(
        isValid: false,
        error: error,
      );
}
