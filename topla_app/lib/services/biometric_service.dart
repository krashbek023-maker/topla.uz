import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Biometric Authentication Service
/// Face ID / Touch ID / Fingerprint autentifikatsiya
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _userIdKey = 'biometric_user_id';

  /// Qurilma biometrik autentifikatsiyani qo'llab-quvvatlashini tekshirish
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Mavjud biometrik turlarini olish
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Biometrik autentifikatsiya qilish
  static Future<bool> authenticate({
    String reason = 'Hisobingizga kirish uchun autentifikatsiya qiling',
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: ${e.message}');
      return false;
    }
  }

  /// Biometrik login yoqilganmi?
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Biometrik loginni yoqish
  static Future<void> enableBiometric(String userId) async {
    await _storage.write(key: _biometricEnabledKey, value: 'true');
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Biometrik loginni o'chirish
  static Future<void> disableBiometric() async {
    await _storage.delete(key: _biometricEnabledKey);
    await _storage.delete(key: _userIdKey);
  }

  /// Saqlangan user ID ni olish
  static Future<String?> getSavedUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Biometrik turi nomini olish
  static String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris Scanner';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    }
    return 'Biometric';
  }

  /// Biometrik turi ikonkasini olish
  static IconData getBiometricIcon(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return Icons.face;
    } else if (types.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    }
    return Icons.security;
  }
}

/// Biometric Login Widget
class BiometricLoginButton extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onError;

  const BiometricLoginButton({
    super.key,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<BiometricLoginButton> createState() => _BiometricLoginButtonState();
}

class _BiometricLoginButtonState extends State<BiometricLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isAuthenticating = false;
  List<BiometricType> _biometrics = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final biometrics = await BiometricService.getAvailableBiometrics();
    if (mounted) {
      setState(() => _biometrics = biometrics);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);
    HapticFeedback.mediumImpact();

    try {
      final success = await BiometricService.authenticate();
      if (success) {
        HapticFeedback.lightImpact();
        widget.onSuccess();
      } else {
        widget.onError?.call();
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_biometrics.isEmpty) return const SizedBox.shrink();

    final icon = BiometricService.getBiometricIcon(_biometrics);
    final name = BiometricService.getBiometricTypeName(_biometrics);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _authenticate,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isAuthenticating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon, size: 24, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              Text(
                '$name bilan kirish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
