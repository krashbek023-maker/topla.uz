import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/constants.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isGoogleLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Auth state o'zgarishlarini tinglash
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // Google orqali kirish muvaffaqiyatli
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('998')) {
      return '+$cleaned';
    } else if (cleaned.length == 9) {
      return '+998$cleaned';
    }
    return '+998$cleaned';
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _formatPhoneNumber(_phoneController.text.trim());
      await context.read<AuthProvider>().sendOtp(phone);

      if (mounted) {
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS kod yuborildi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.message)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('6 xonali kodni kiriting'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = _formatPhoneNumber(_phoneController.text.trim());
      await context
          .read<AuthProvider>()
          .verifyOtp(phone, _otpController.text.trim());

      if (mounted && context.read<AuthProvider>().isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.message)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      await context.read<AuthProvider>().signInWithGoogle();

      if (mounted && context.read<AuthProvider>().isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.message)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google kirish xatoligi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid phone')) {
      return 'Noto\'g\'ri telefon raqami';
    }
    if (error.contains('Invalid OTP') || error.contains('Token has expired')) {
      return 'Kod xato yoki muddati tugagan';
    }
    if (error.contains('Phone not confirmed')) {
      return 'Telefon tasdiqlanmagan';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.lg),

                  // Logo
                  _buildLogo(),

                  const SizedBox(height: AppSizes.xxl),

                  // Title
                  Text(
                    _isOtpSent ? 'Kodni kiriting' : 'Kirish',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.sm),

                  Text(
                    _isOtpSent
                        ? 'SMS orqali yuborilgan 6 xonali kodni kiriting'
                        : 'Telefon raqamingizni kiriting',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.xxl),

                  // Phone field
                  if (!_isOtpSent) ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Telefon raqami',
                        hintText: '90 123 45 67',
                        prefixIcon: const Icon(Iconsax.call),
                        prefixText: '+998 ',
                        prefixStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Telefon raqamni kiriting';
                        }
                        if (value.length != 9) {
                          return 'Telefon raqam 9 ta raqamdan iborat bo\'lishi kerak';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _sendOtp(),
                    ),
                  ] else ...[
                    // OTP field
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        hintText: '••••••',
                        hintStyle: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                      onFieldSubmitted: (_) => _verifyOtp(),
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Change phone button
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _isOtpSent = false);
                            },
                      child: const Text('Telefon raqamni o\'zgartirish'),
                    ),
                  ],

                  const SizedBox(height: AppSizes.xl),

                  // Submit button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_isOtpSent ? _verifyOtp : _sendOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isOtpSent ? 'Tasdiqlash' : 'Davom etish',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                        child: Text(
                          'yoki',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Google Sign In Button
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildGoogleLogo(),
                                const SizedBox(width: 12),
                                const Text(
                                  'Google orqali kirish',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Iconsax.user,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }

  // Google original logo
  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

// Google logo painter - original colors
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.45;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    // Blue arc (right side)
    final bluePath = Path();
    bluePath.moveTo(center.dx + radius, center.dy);
    bluePath.arcToPoint(
      Offset(center.dx, center.dy - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    bluePath.lineTo(center.dx, center.dy);
    bluePath.close();
    canvas.drawPath(bluePath, bluePaint);

    // Red arc (top-left)
    final redPath = Path();
    redPath.moveTo(center.dx, center.dy - radius);
    redPath.arcToPoint(
      Offset(center.dx - radius, center.dy),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    redPath.lineTo(center.dx, center.dy);
    redPath.close();
    canvas.drawPath(redPath, redPaint);

    // Yellow arc (bottom-left)
    final yellowPath = Path();
    yellowPath.moveTo(center.dx - radius, center.dy);
    yellowPath.arcToPoint(
      Offset(center.dx, center.dy + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    yellowPath.lineTo(center.dx, center.dy);
    yellowPath.close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green arc (bottom-right)
    final greenPath = Path();
    greenPath.moveTo(center.dx, center.dy + radius);
    greenPath.arcToPoint(
      Offset(center.dx + radius, center.dy),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    greenPath.lineTo(center.dx, center.dy);
    greenPath.close();
    canvas.drawPath(greenPath, greenPaint);

    // White inner circle
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, whitePaint);

    // Blue horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - radius * 0.1,
        center.dy - radius * 0.2,
        radius * 1.1,
        radius * 0.4,
      ),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
